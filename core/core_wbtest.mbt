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
test "Pos::advance sequence" {
  let p = Pos::initial().advance('H').advance('i').advance('\n').advance('!')
  assert_eq(p.line, 2)
  assert_eq(p.column, 2)
  assert_eq(p.offset, 4)
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
test "State::slice" {
  let s = State::new("hello world")
  assert_eq(s.slice(0, 5), "hello")
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
