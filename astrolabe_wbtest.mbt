///|
test "Pos::initial" {
  let p = Pos::initial()
  assert_eq(p.line, 1)
  assert_eq(p.column, 1)
  assert_eq(p.offset, 0)
}

///|
test "Pos::advance normal char" {
  let p = Pos::initial().advance('a')
  assert_eq(p.line, 1)
  assert_eq(p.column, 2)
  assert_eq(p.offset, 1)
}

///|
test "Pos::advance newline" {
  let p = Pos::initial().advance('\n')
  assert_eq(p.line, 2)
  assert_eq(p.column, 1)
  assert_eq(p.offset, 1)
}

///|
test "State::new" {
  let s = State::new("hello")
  assert_eq(s.offset, 0)
  assert_eq(s.remaining(), 5)
  assert_true(!s.is_eof())
}

///|
test "State::peek" {
  let s = State::new("abc")
  assert_eq(s.peek(), Some('a'))
  assert_eq(s.offset, 0)
}

///|
test "State::advance_one" {
  let s = State::new("abc")
  s.advance_one()
  assert_eq(s.offset, 1)
  assert_eq(s.peek(), Some('b'))
}

///|
test "State::is_eof" {
  let s = State::new("ab")
  assert_true(!s.is_eof())
  s.advance_one()
  s.advance_one()
  assert_true(s.is_eof())
}

///|
test "ParseError::format" {
  let err = ParseError::at(
    pos={ line: 3, column: 15, offset: 42, },
    expected="HTTP method",
  )
  let fmt = err.format()
  assert_true(fmt.contains("line 3"))
  assert_true(fmt.contains("column 15"))
  assert_true(fmt.contains("offset 42"))
  assert_true(fmt.contains("HTTP method"))
}

///|
test "char success" {
  let p = char('a')
  let s = State::new("abc")
  match (p.run)(s) {
    Success(ch, st) => {
      assert_eq(ch, 'a')
      assert_eq(st.offset, 1)
    }
    Failure(_) => fail("expected success")
  }
}

///|
test "char failure wrong char" {
  let p = char('a')
  let s = State::new("xyz")
  match (p.run)(s) {
    Failure(err) => assert_true(err.expected.contains("'a'"))
    Success(_, _) => fail("expected failure")
  }
}

///|
test "char failure eof" {
  let p = char('a')
  let s = State::new("")
  match (p.run)(s) {
    Failure(err) => assert_true(err.expected.contains("'a'"))
    Success(_, _) => fail("expected failure")
  }
}

///|
test "string success" {
  let p = string("hello")
  let s = State::new("hello world")
  match (p.run)(s) {
    Success(val, st) => {
      assert_eq(val, "hello")
      assert_eq(st.offset, 5)
    }
    Failure(_) => fail("expected success")
  }
}

///|
test "string failure" {
  let p = string("hello")
  let s = State::new("world")
  match (p.run)(s) {
    Failure(err) => assert_true(err.expected.contains("\"hello\""))
    Success(_, _) => fail("expected failure")
  }
}

///|
test "any_char success" {
  let p = any_char()
  let s = State::new("abc")
  match (p.run)(s) {
    Success(ch, st) => {
      assert_eq(ch, 'a')
      assert_eq(st.offset, 1)
    }
    Failure(_) => fail("expected success")
  }
}

///|
test "any_char failure eof" {
  let p = any_char()
  let s = State::new("")
  match (p.run)(s) {
    Failure(err) => assert_true(err.expected.contains("any character"))
    Success(_, _) => fail("expected failure")
  }
}

///|
test "take success" {
  let p = take(3)
  let s = State::new("hello")
  match (p.run)(s) {
    Success(val, st) => {
      assert_eq(val, "hel")
      assert_eq(st.offset, 3)
    }
    Failure(_) => fail("expected success")
  }
}

///|
test "take failure insufficient" {
  let p = take(5)
  let s = State::new("hi")
  match (p.run)(s) {
    Failure(err) => assert_true(err.expected.contains("5 characters"))
    Success(_, _) => fail("expected failure")
  }
}

///|
test "satisfy success" {
  let p = satisfy(fn(c) { c >= 'a' && c <= 'z' }, label="lowercase")
  let s = State::new("abc")
  match (p.run)(s) {
    Success(ch, st) => {
      assert_eq(ch, 'a')
      assert_eq(st.offset, 1)
    }
    Failure(_) => fail("expected success")
  }
}

///|
test "satisfy failure" {
  let p = satisfy(fn(c) { c >= 'a' && c <= 'z' }, label="lowercase")
  let s = State::new("ABC")
  match (p.run)(s) {
    Failure(err) => assert_true(err.expected.contains("lowercase"))
    Success(_, _) => fail("expected failure")
  }
}

///|
test "end_of_input success" {
  let p = end_of_input()
  let s = State::new("")
  match (p.run)(s) {
    Success(unit, _) => ignore(unit)
    Failure(_) => fail("expected success")
  }
}

///|
test "end_of_input failure" {
  let p = end_of_input()
  let s = State::new("abc")
  match (p.run)(s) {
    Failure(err) => assert_true(err.expected.contains("end of input"))
    Success(_, _) => fail("expected failure")
  }
}

///|
test "Parser::parse" {
  let p = char('a')
  match p.parse("abc") {
    Ok(ch) => assert_eq(ch, 'a')
    Err(_) => fail("expected Ok")
  }
}

///|
test "Parser::parse_full" {
  let p = char('a')
  match p.parse_full("a") {
    Ok(ch) => assert_eq(ch, 'a')
    Err(_) => fail("expected Ok")
  }
  match p.parse_full("ab") {
    Err(err) => assert_true(err.expected.contains("end of input"))
    Ok(_) => fail("expected Err")
  }
}

///|
test "Pos::advance sequence" {
  let p = Pos::initial().advance('H').advance('i').advance('\n').advance('!')
  assert_eq(p.line, 2)
  assert_eq(p.column, 2)
  assert_eq(p.offset, 4)
}

///|
test "State::slice" {
  let s = State::new("hello world")
  assert_eq(s.slice(0, 5), "hello")
}
