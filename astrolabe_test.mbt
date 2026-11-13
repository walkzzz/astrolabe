///|
test "public API: char parse" {
  let p = @astrolabe.char('a')
  match @astrolabe.parse(p, "abc") {
    Ok(ch) => assert_eq(ch, 'a')
    Err(_) => fail("expected Ok")
  }
}

///|
test "public API: string parse" {
  let p = @astrolabe.string("hello")
  match @astrolabe.parse(p, "hello world") {
    Ok(val) => assert_eq(val, "hello")
    Err(_) => fail("expected Ok")
  }
}

///|
test "public API: take parse" {
  let p = @astrolabe.take(3)
  match @astrolabe.parse(p, "hello") {
    Ok(val) => assert_eq(val, "hel")
    Err(_) => fail("expected Ok")
  }
}

///|
test "public API: ParseError format" {
  let p = @astrolabe.char('x')
  match @astrolabe.parse(p, "abc") {
    Err(err) => {
      let fmt = @astrolabe.format_error(err)
      assert_true(fmt.contains("'x'"))
    }
    Ok(_) => fail("expected Err")
  }
}

///|
test "public API: parse_full rejects trailing" {
  let p = @astrolabe.char('a')
  match @astrolabe.parse_full(p, "ab") {
    Err(err) => assert_true(err.expected().contains("end of input"))
    Ok(_) => fail("expected Err")
  }
}

///|
test "public API: take_while digits" {
  let p = @astrolabe.take_while(fn(c) { c >= '0' && c <= '9' })
  match @astrolabe.parse(p, "123abc") {
    Ok(val) => assert_eq(val, "123")
    Err(_) => fail("expected Ok")
  }
}

///|
test "public API: take_while1 digits" {
  let p = @astrolabe.take_while1(fn(c) { c >= '0' && c <= '9' }, label="digit")
  match @astrolabe.parse(p, "123abc") {
    Ok(val) => assert_eq(val, "123")
    Err(_) => fail("expected Ok")
  }
}

///|
test "public API: option with default" {
  let p = @astrolabe.option(@astrolabe.char('x'), 'z')
  match @astrolabe.parse(p, "abc") {
    Ok(val) => assert_eq(val, 'z')
    Err(_) => fail("expected Ok")
  }
}

///|
test "public API: skip_many whitespace" {
  let ws = @astrolabe.skip_many(@astrolabe.char(' '))
  match @astrolabe.parse(ws, "   abc") {
    Ok(unit) => ignore(unit)
    Err(_) => fail("expected Ok")
  }
}

///|
test "public API: between parens" {
  let p = @astrolabe.between(
    @astrolabe.char('('),
    @astrolabe.take_while(fn(c) { c != ')' }),
    @astrolabe.char(')'),
  )
  match @astrolabe.parse(p, "(hello) world") {
    Ok(val) => assert_eq(val, "hello")
    Err(_) => fail("expected Ok")
  }
}

///|
test "public API: not_followed_by" {
  let keyword = @astrolabe.bind(@astrolabe.string("if"), fn(_) {
    @astrolabe.not_followed_by(
      @astrolabe.char_range('a', 'z'),
      label="keyword boundary",
    )
  })
  match @astrolabe.parse(keyword, "if x") {
    Ok(_) => ()
    Err(_) => fail("expected Ok for 'if '")
  }
  match @astrolabe.parse(keyword, "ifx") {
    Err(err) => assert_true(err.expected().contains("keyword boundary"))
    Ok(_) => fail("expected Err for 'ifx'")
  }
}

///|
test "public API: fix recursive" {
  let x_parser = @astrolabe.map(@astrolabe.char('x'), fn(c) { c.to_string() })
  let expr = @astrolabe.fix(fn(self) {
    @astrolabe.alt(
      x_parser,
      @astrolabe.map(
        @astrolabe.between(@astrolabe.char('('), self, @astrolabe.char(')')),
        fn(inner) { "(" + inner + ")" },
      ),
    )
  })
  match @astrolabe.parse(expr, "((x))") {
    Ok(val) => assert_eq(val, "((x))")
    Err(_) => fail("expected Ok")
  }
}
