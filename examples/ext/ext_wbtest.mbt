///|
/// 测试 Traced 通过 run_fn 接入 pmap 通用组合子
/// Test Traced plugs into the generic pmap combinator via run_fn
test "Traced plugs into pmap" {
  let t : Traced[Char] = Traced::new(@char.char('a'))
  let p = @core.pmap(t.run_fn(), fn(c) { c.to_string() })
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Success(v, st) => {
      assert_eq(v, "a")
      assert_eq(st.offset, 1)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
/// 测试 palt 混合 Traced 与普通 Parser（run_fn 提取运行函数）
/// Test palt mixes Traced and plain Parser (run_fn extracts the run function)
test "palt mixes Traced and Parser" {
  let t : Traced[Char] = Traced::new(@char.char('x'))
  let p = @core.palt(t.run_fn(), @char.char('a').run_fn())
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Success(ch, st) => {
      assert_eq(ch, 'a')
      assert_eq(st.offset, 1)
    }
    @core.Failure(_) => fail("expected failure")
  }
}

///|
/// 测试 Traced 的调用日志被记录
/// Test Traced logs parser invocations
test "Traced logs parser invocations" {
  let t : Traced[Char] = Traced::new(@char.char('a'))
  let s = @core.State::new("abc")
  let run = t.run_fn()
  let _ = run(s)
  assert_eq(t.log.length(), 1)
  assert_true(t.log[0].contains("offset 0"))
}

///|
/// 测试 pbind 对 Traced 做序列绑定且保持序列承诺
/// Test pbind sequences over Traced and preserves sequence commitment
test "pbind sequences over Traced" {
  let t : Traced[Char] = Traced::new(@char.char('a'))
  let p = @core.pbind(t.run_fn(), fn(_) { @char.char('b') })
  let s = @core.State::new("axc")
  match (p.run)(s) {
    @core.Failure(err) => {
      assert_true(err.committed())
      assert_true(t.log.length() == 1)
    }
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
/// 测试 poption 在未承诺失败时回退到默认值
/// Test poption falls back to the default on uncommitted failure
test "poption falls back to default" {
  let t : Traced[Char] = Traced::new(@char.char('x'))
  let p = @core.poption(t.run_fn(), 'd')
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Success(ch, st) => {
      assert_eq(ch, 'd')
      assert_eq(st.offset, 0)
    }
    @core.Failure(_) => fail("expected success")
  }
}
