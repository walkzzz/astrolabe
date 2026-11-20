///|
/// 覆盖率补强 — 门面包（raise 包装与带输入上下文的错误格式化）
/// Coverage-gap tests for the facade (raise wrappers and context error formatting).

///|
test "facade: parse_raise success" {
  let p = @astrolabe.char('a')
  assert_eq(@astrolabe.parse_raise(p, "abc"), 'a')
}

///|
test "facade: parse_raise failure raises" {
  let p = @astrolabe.char('z')
  let mut raised = false
  try {
    let _ = @astrolabe.parse_raise(p, "abc")
  } catch {
    _ => raised = true
  }
  assert_true(raised)
}

///|
test "facade: parse_full_raise rejects trailing" {
  let p = @astrolabe.char('a')
  let mut raised = false
  try {
    let _ = @astrolabe.parse_full_raise(p, "ab")
  } catch {
    _ => raised = true
  }
  assert_true(raised)
}

///|
test "facade: format_error_with_input contains caret" {
  let input = "abcdefghijklmnopqrstuvwxyz0123456789"
  match @astrolabe.parse(@astrolabe.char('z'), input) {
    Err(err) => {
      let s = @astrolabe.format_error_with_input(err, input)
      assert_true(s.contains("^"))
    }
    Ok(_) => fail("expected Err")
  }
}
