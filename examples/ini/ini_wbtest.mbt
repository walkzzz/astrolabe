///|
/// 测试 INI → JSON 端到端转换（raise 风格 API + try/catch 惯用法）
/// Test INI → JSON end-to-end conversion (raise-style API + try/catch idiom)
test "INI to JSON end-to-end" {
  let input = "; config\n[server]\nhost = localhost\nport = 8080\n\n[client]\ntimeout = 30\n"
  let json = try ini_to_json_string(input) catch {
    e => fail("unexpected: \{e.format()}")
  }
  assert_eq(
    json,
    "{\"server\":{\"host\":\"localhost\",\"port\":\"8080\"},\"client\":{\"timeout\":\"30\"}}",
  )
}

///|
/// 测试键值两侧空白裁剪与节名裁剪
/// Test whitespace trimming around keys, values and section names
test "INI trims whitespace" {
  let input = "[ s ]\n  k1  =  v1  \n"
  let json = try ini_to_json_string(input) catch {
    e => fail("unexpected: \{e.format()}")
  }
  assert_true(json.contains("\"s\""))
  assert_true(json.contains("\"k1\""))
  assert_true(json.contains("\"v1\""))
}

///|
/// 测试无节头的键归入空名节
/// Test keys before any section land in the unnamed section
test "INI keys before section land in unnamed section" {
  let input = "root = yes\n[server]\nhost = localhost\n"
  let json = try ini_to_json_string(input) catch {
    e => fail("unexpected: \{e.format()}")
  }
  assert_true(json.contains("\"\":{\"root\":\"yes\"}"))
  assert_true(json.contains("\"server\":{\"host\":\"localhost\"}"))
}

///|
/// 测试错误聚合：单行解析失败位置指向最远失败点（`]` 缺失处），期望含 `']'`
/// Test error aggregation: failure position points to the furthest spot (missing `]`)
test "INI line errors point to furthest position" {
  let input = "[unclosed"
  let p = ini_line()
  match p.parse(input) {
    Ok(_) => fail("expected failure")
    Err(e) => {
      assert_eq(e.pos().offset, 9)
      assert_true(e.expected().contains("']'"))
    }
  }
}

///|
/// 测试顶层解析强制全消费并保持序列承诺
/// Test top-level parsing enforces full consumption with sequence commitment
test "INI top-level enforces full consumption" {
  let input = "[unclosed\n"
  let result : Result[String, @core.ParseError] = try {
    Ok(ini_to_json_string(input))
  } catch {
    e => Err(e)
  }
  match result {
    Ok(_) => fail("expected failure")
    Err(e) => assert_true(e.committed())
  }
}

///|
/// 测试 many 的零消耗防护：零宽匹配的解析器不再无限循环而是报错（v0.5.2 稳定性防护）
/// Test many's zero-consumption guard: zero-width parsers error out instead of looping (v0.5.2)
test "many guards against zero-width match" {
  let zero : @core.Parser[Int] = @core.Parser::of(fn(state) { @core.Success(42, state) })
  let p = @sequence.many(zero)
  let s = @core.State::new("abc")
  match (p.run)(s) {
    Ok(_) => fail("expected failure: zero-width match must error, not loop")
    Err(e) => {
      assert_eq(e.pos().offset, 0)
      assert_true(e.expected().length() >= 1)
    }
  }
}

///|
/// 测试 many 对正常消耗输入仍正常收集（防护不误伤）
/// Test many still collects normally for consuming input (guard does not misfire)
test "many works with consuming parser" {
  let p = @sequence.many(@char.char('a'))
  let s = @core.State::new("aaab")
  match (p.run)(s) {
    Ok(arr) => assert_eq(arr.length(), 3)
    Err(_) => fail("unexpected failure")
  }
}

///|
/// 测试 CRLF 行结束与文件末尾无换行的最后一行
/// Test CRLF line endings and a final line without trailing newline
test "INI supports CRLF and unterminated last line" {
  let input = "[server]\r\nhost = localhost\r\nport = 8080"
  let json = try ini_to_json_string(input) catch {
    e => fail("unexpected: \{e.format()}")
  }
  assert_eq(json, "{\"server\":{\"host\":\"localhost\",\"port\":\"8080\"}}")
}
