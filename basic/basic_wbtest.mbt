///|
test "char success" {
  let p = char('a')
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Success(ch, st) => {
      assert_eq(ch, 'a')
      assert_eq(st.offset, 1)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "char failure wrong char" {
  let p = char('a')
  let s = @core.State::new("xyz")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("'a'"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "char failure eof" {
  let p = char('a')
  let s = @core.State::new("")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("'a'"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "string success" {
  let p = string("hello")
  let s = @core.State::new("hello world")
  match (p.run)(s) {
    @core.Success(val, st) => {
      assert_eq(val, "hello")
      assert_eq(st.offset, 5)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "string failure" {
  let p = string("hello")
  let s = @core.State::new("world")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("\"hello\""))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "any_char success" {
  let p = any_char()
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Success(ch, st) => {
      assert_eq(ch, 'a')
      assert_eq(st.offset, 1)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "any_char failure eof" {
  let p = any_char()
  let s = @core.State::new("")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("any character"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "take success" {
  let p = take(3)
  let s = @core.State::new("hello")
  match (p.run)(s) {
    @core.Success(val, st) => {
      assert_eq(val, "hel")
      assert_eq(st.offset, 3)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "take failure insufficient" {
  let p = take(5)
  let s = @core.State::new("hi")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("5 characters"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "satisfy success" {
  let p = satisfy(fn(c) { c >= 'a' && c <= 'z' }, label="lowercase")
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Success(ch, st) => {
      assert_eq(ch, 'a')
      assert_eq(st.offset, 1)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "satisfy failure" {
  let p = satisfy(fn(c) { c >= 'a' && c <= 'z' }, label="lowercase")
  let s = @core.State::new("ABC")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("lowercase"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "end_of_input success" {
  let p = end_of_input()
  let s = @core.State::new("")
  match (p.run)(s) {
    @core.Success(unit, _) => ignore(unit)
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "end_of_input failure" {
  let p = end_of_input()
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("end of input"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "peek success no consume" {
  let p = peek(char('a'))
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Success(ch, st) => {
      assert_eq(ch, 'a')
      assert_eq(st.offset, 0)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "peek failure" {
  let p = peek(char('x'))
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("'x'"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "skip success" {
  let p = skip(char('a'))
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Success(unit, st) => {
      ignore(unit)
      assert_eq(st.offset, 1)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "skip failure" {
  let p = skip(char('x'))
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("'x'"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "char_range lowercase" {
  let p = char_range('a', 'z')
  let s = @core.State::new("hello")
  match (p.run)(s) {
    @core.Success(ch, st) => {
      assert_eq(ch, 'h')
      assert_eq(st.offset, 1)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "char_range digit" {
  let p = char_range('0', '9')
  let s = @core.State::new("42")
  match (p.run)(s) {
    @core.Success(ch, _) => assert_eq(ch, '4')
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "char_range failure out of range" {
  let p = char_range('a', 'z')
  let s = @core.State::new("Z")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("char in [a-z]"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "char_range boundary_lo" {
  let p = char_range('a', 'z')
  let s = @core.State::new("a")
  match (p.run)(s) {
    @core.Success(ch, _) => assert_eq(ch, 'a')
    @core.Failure(_) => fail("expected success at lo boundary")
  }
}

///|
test "char_range boundary_hi" {
  let p = char_range('a', 'z')
  let s = @core.State::new("z")
  match (p.run)(s) {
    @core.Success(ch, _) => assert_eq(ch, 'z')
    @core.Failure(_) => fail("expected success at hi boundary")
  }
}

///|
test "char_class hex_digit" {
  let hex_digit = char_class(
    fn(c) {
      (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')
    },
    "hex digit",
  )
  let s = @core.State::new("aF3")
  match (hex_digit.run)(s) {
    @core.Success(ch, st) => {
      assert_eq(ch, 'a')
      assert_eq(st.offset, 1)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "char_class identifier_start" {
  let ident_start = char_class(
    fn(c) { (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_' },
    "identifier start",
  )
  let s = @core.State::new("_foo")
  match (ident_start.run)(s) {
    @core.Success(ch, _) => assert_eq(ch, '_')
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "char_class failure" {
  let ident_start = char_class(
    fn(c) { (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_' },
    "identifier start",
  )
  let s = @core.State::new("123")
  match (ident_start.run)(s) {
    @core.Failure(err) =>
      assert_true(err.expected().contains("identifier start"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
/// Test custom parser via Parser::of — a parser that consumes exactly 2 hex chars
test "custom_parser_via_of" {
  let hex_char = char_class(
    fn(c) {
      (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')
    },
    "hex digit",
  )
  let hex_byte = @compose.seq2(hex_char, hex_char)
  let s = @core.State::new("4A")
  match (hex_byte.run)(s) {
    @core.Success((c1, c2), st) => {
      assert_eq(c1, '4')
      assert_eq(c2, 'A')
      assert_eq(st.offset, 2)
    }
    @core.Failure(_) => fail("expected success")
  }
}
