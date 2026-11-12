///|
pub fn[T] commit(p : Parser[T]) -> Parser[T] {
  Parser::of(fn(state) {
    match (p.run)(state) {
      Success(value, st) => Success(value, st)
      Failure(err) =>
        Failure({
          pos: err.pos,
          expected: err.expected,
          committed: true,
          context: err.context,
        })
    }
  })
}

///|
pub fn[T] alt(p1 : Parser[T], p2 : Parser[T]) -> Parser[T] {
  Parser::of(fn(state) {
    match (p1.run)(state) {
      Success(value, st) => Success(value, st)
      Failure(err) => if err.committed { Failure(err) } else { (p2.run)(state) }
    }
  })
}

///|
pub fn[T] choice(parsers : Array[Parser[T]]) -> Parser[T] {
  if parsers.length() == 0 {
    Parser::of(fn(state) {
      Failure(ParseError::at(pos=state.pos, expected="any choice"))
    })
  } else {
    let mut result = parsers[0]
    for i in 1..<parsers.length() {
      result = alt(result, parsers[i])
    }
    result
  }
}

///|
pub fn[T] label(p : Parser[T], name : String) -> Parser[T] {
  Parser::of(fn(state) {
    match (p.run)(state) {
      Success(value, st) => Success(value, st)
      Failure(err) =>
        Failure({
          pos: err.pos,
          expected: [name],
          committed: err.committed,
          context: err.context,
        })
    }
  })
}
