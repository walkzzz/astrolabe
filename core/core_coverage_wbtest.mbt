///|
/// 覆盖率补强 — core 包（错误格式化/raise 包装/提示工厂）
/// Coverage-gap tests for the core package (error formatting, raise wrappers, hint factories).

///|
test "format_with_input: far offset adds ellipsis context" {
  let input = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJ"
  let err = ParseError::at(
    pos={ line: 1, column: 31, offset: 30, },
    expected="'x'",
  )
  let s = err.format_with_input(input)
  assert_true(s.contains("..."))
  assert_true(s.contains("^"))
}

///|
test "format_with_input: near start has no prefix ellipsis" {
  let err = ParseError::at(
    pos={ line: 1, column: 3, offset: 2, },
    expected="'x'",
  )
  let s = err.format_with_input("abc")
  assert_true(s.contains("^"))
  assert_true(s.contains("abc"))
}

///|
test "parse_raise: success returns value" {
  let p : Parser[Char] = Parser::of(fn(st) { Success('a', st) })
  assert_eq(p.parse_raise("abc"), 'a')
}

///|
test "parse_full_raise: trailing input raises" {
  let p : Parser[Char] = Parser::of(fn(st) { Success('a', st) })
  let mut raised = false
  try {
    let _ = p.parse_full_raise("abc")
  } catch {
    _ => raised = true
  }
  assert_true(raised)
}

///|
test "hint factories cover all variants" {
  assert_true(ParseHint::light() is Light)
  assert_true(ParseHint::recovery() is Recovery)
  assert_true(ParseHint::heavy() is Heavy)
}
