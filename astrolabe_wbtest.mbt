///|
/// 测试通过根包门面调用 Parser::parse 方法
/// Test calling Parser::parse method through root facade
test "Parser::parse via root" {
  let p = @char.char('a')
  match p.parse("abc") {
    Ok(ch) => assert_eq(ch, 'a')
    Err(_) => fail("expected Ok")
  }
}

///|
/// 测试通过根包门面调用 Parser::parse_full 方法（要求完整消耗输入）
/// Test calling Parser::parse_full method through root facade (requires full input consumption)
test "Parser::parse_full via root" {
  let p = @char.char('a')
  match p.parse_full("a") {
    Ok(ch) => assert_eq(ch, 'a')
    Err(_) => fail("expected Ok")
  }
  match p.parse_full("ab") {
    Err(err) => assert_true(err.expected().contains("end of input"))
    Ok(_) => fail("expected Err")
  }
}
