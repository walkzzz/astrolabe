///|
/// 覆盖率补强 — branch 包（空 choice / 成功直通 / 恢复与回溯）
/// Coverage-gap tests for the branch package.

///|
test "choice empty fails with any choice label" {
  let p : @core.Parser[Char] = choice([])
  match (p.run)(@core.State::new("x")) {
    @core.Failure(err) => assert_true(err.expected().contains("any choice"))
    _ => fail("expected failure")
  }
}

///|
test "choice picks the first matching alternative" {
  let p = choice([char('a'), char('b')])
  match (p.run)(@core.State::new("b")) {
    @core.Success(ch, _) => assert_eq(ch, 'b')
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "label passes success through unchanged" {
  let p = label(char('a'), "a label")
  match (p.run)(@core.State::new("a")) {
    @core.Success(ch, _) => assert_eq(ch, 'a')
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "commit passes success through" {
  let p = commit(char('a'))
  match (p.run)(@core.State::new("a")) {
    @core.Success(ch, _) => assert_eq(ch, 'a')
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "attempt passes success through" {
  let p = attempt(char('a'))
  match (p.run)(@core.State::new("a")) {
    @core.Success(ch, _) => assert_eq(ch, 'a')
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "recover passes success through" {
  let p = recover(char('a'), fn(_) { succeed('z') })
  match (p.run)(@core.State::new("a")) {
    @core.Success(ch, _) => assert_eq(ch, 'a')
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "fix returns a working parser" {
  let p = fix(fn(_self) { char('a') })
  match (p.run)(@core.State::new("a")) {
    @core.Success(ch, _) => assert_eq(ch, 'a')
    @core.Failure(_) => fail("expected success")
  }
}
