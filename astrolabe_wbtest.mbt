///|
test "Parser::parse via root" {
  let p = @basic.char('a')
  match p.parse("abc") {
    Ok(ch) => assert_eq(ch, 'a')
    Err(_) => fail("expected Ok")
  }
}

///|
test "Parser::parse_full via root" {
  let p = @basic.char('a')
  match p.parse_full("a") {
    Ok(ch) => assert_eq(ch, 'a')
    Err(_) => fail("expected Ok")
  }
  match p.parse_full("ab") {
    Err(err) => assert_true(err.expected().contains("end of input"))
    Ok(_) => fail("expected Err")
  }
}
