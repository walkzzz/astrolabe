///|
pub fn take(n : Int32) -> Parser[String] {
  Parser::of(fn(state) {
    if state.remaining() < n {
      Failure(ParseError::at(pos=state.pos, expected="\{n} characters"))
    } else {
      let result = state.slice(state.offset, state.offset + n)
      state.advance_by(n)
      Success(result, state)
    }
  })
}

///|
pub fn satisfy(
  pred : (Char) -> Bool,
  label~ : String = "satisfy",
) -> Parser[Char] {
  Parser::of(fn(state) {
    match state.peek() {
      Some(ch) =>
        if pred(ch) {
          state.advance_one()
          Success(ch, state)
        } else {
          Failure(ParseError::at(pos=state.pos, expected=label))
        }
      None => Failure(ParseError::at(pos=state.pos, expected=label))
    }
  })
}

///|
pub fn end_of_input() -> Parser[Unit] {
  Parser::of(fn(state) {
    if state.is_eof() {
      Success((), state)
    } else {
      Failure(ParseError::at(pos=state.pos, expected="end of input"))
    }
  })
}
