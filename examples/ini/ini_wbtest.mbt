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
/// 测试 CRLF 行结束与文件末尾无换行的最后一行
/// Test CRLF line endings and a final line without trailing newline
test "INI supports CRLF and unterminated last line" {
  let input = "[server]\r\nhost = localhost\r\nport = 8080"
  let json = try ini_to_json_string(input) catch {
    e => fail("unexpected: \{e.format()}")
  }
  assert_eq(json, "{\"server\":{\"host\":\"localhost\",\"port\":\"8080\"}}")
}
