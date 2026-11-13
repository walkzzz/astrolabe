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

///|
test "public API: with_context chains contexts in format" {
  let p = @astrolabe.with_context(
    @astrolabe.with_context(@astrolabe.char('x'), "field"),
    "record",
  )
  match @astrolabe.parse(p, "abc") {
    Err(err) => {
      let fmt = @astrolabe.format_error(err)
      assert_true(fmt.contains("field > record"))
    }
    Ok(_) => fail("expected Err")
  }
}

///|
test "public API: recover continues past committed failure" {
  let p = @astrolabe.recover(@astrolabe.commit(@astrolabe.char('x')), fn(_) {
    @astrolabe.char('a')
  })
  match @astrolabe.parse(p, "abc") {
    Ok(ch) => assert_eq(ch, 'a')
    Err(_) => fail("expected Ok via recovery")
  }
}

///|
test "public API: reject always fails" {
  let p : @core.Parser[Char] = @astrolabe.reject("nope")
  match @astrolabe.parse(p, "abc") {
    Err(err) => assert_true(err.expected().contains("nope"))
    Ok(_) => fail("expected Err")
  }
}

///|
test "public API: succeed without consuming" {
  let p = @astrolabe.succeed(99)
  match @astrolabe.parse(p, "abc") {
    Ok(v) => assert_eq(v, 99)
    Err(_) => fail("expected Ok")
  }
}

///|
test "public API: attempt backtracks committed failure" {
  let p = @astrolabe.alt(
    @astrolabe.attempt(@astrolabe.commit(@astrolabe.char('x'))),
    @astrolabe.char('a'),
  )
  match @astrolabe.parse(p, "abc") {
    Ok(ch) => assert_eq(ch, 'a')
    Err(_) => fail("expected Ok via attempt + alt")
  }
}

///|
test "public API: with_hint attaches metadata" {
  let p = @astrolabe.with_hint(
    @astrolabe.char('a'),
    hint=@core.ParseHint::heavy(),
  )
  match @astrolabe.parse(p, "abc") {
    Ok(ch) => assert_eq(ch, 'a')
    Err(_) => fail("expected Ok")
  }
}

///|
test "public API: filter rejects non-matching" {
  let p = @astrolabe.filter(
    @astrolabe.any_char(),
    fn(c) { c >= 'a' && c <= 'z' },
    label="lowercase",
  )
  match @astrolabe.parse(p, "A") {
    Err(err) => assert_true(err.expected().contains("lowercase"))
    Ok(_) => fail("expected Err")
  }
}

///|
test "public API: sep_end_by with trailing separator" {
  let p = @astrolabe.sep_end_by(@astrolabe.char('a'), @astrolabe.char(','))
  match @astrolabe.parse(p, "a,a,") {
    Ok(arr) => assert_eq(arr.length(), 2)
    Err(_) => fail("expected Ok")
  }
}
