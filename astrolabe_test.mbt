///|
test "public API: char parse" {
  let p = @astrolabe.char('a')
  match @astrolabe.Parser::parse(p, "abc") {
    Ok(ch) => assert_eq(ch, 'a')
    Err(_) => fail("expected Ok")
  }
}

///|
test "public API: string parse" {
  let p = @astrolabe.string("hello")
  match @astrolabe.Parser::parse(p, "hello world") {
    Ok(val) => assert_eq(val, "hello")
    Err(_) => fail("expected Ok")
  }
}

///|
test "public API: take parse" {
  let p = @astrolabe.take(3)
  match @astrolabe.Parser::parse(p, "hello") {
    Ok(val) => assert_eq(val, "hel")
    Err(_) => fail("expected Ok")
  }
}

///|
test "public API: ParseError format" {
  let p = @astrolabe.char('x')
  match @astrolabe.Parser::parse(p, "abc") {
    Err(err) => {
      let fmt = @astrolabe.ParseError::format(err)
      assert_true(fmt.contains("'x'"))
    }
    Ok(_) => fail("expected Err")
  }
}

///|
test "public API: parse_full rejects trailing" {
  let p = @astrolabe.char('a')
  match @astrolabe.Parser::parse_full(p, "ab") {
    Err(err) => assert_true(err.expected.contains("end of input"))
    Ok(_) => fail("expected Err")
  }
}
