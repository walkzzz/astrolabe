///|
pub fn char(expected : Char) -> Parser[Char] {
  Parser::of(fn(state) {
    match state.peek() {
      Some(ch) =>
        if ch == expected {
          state.advance_one()
          Success(ch, state)
        } else {
          Failure(ParseError::at(pos=state.pos, expected="'\{expected}'"))
        }
      None => Failure(ParseError::at(pos=state.pos, expected="'\{expected}'"))
    }
  })
}

///|
pub fn string(expected : String) -> Parser[String] {
  Parser::of(fn(state) {
    let len = expected.length()
    if state.remaining() < len {
      Failure(ParseError::at(pos=state.pos, expected="\"\{expected}\""))
    } else {
      let actual = state.slice(state.offset, state.offset + len)
      if actual == expected {
        state.advance_by(len)
        Success(expected, state)
      } else {
        Failure(ParseError::at(pos=state.pos, expected="\"\{expected}\""))
      }
    }
  })
}

///|
pub fn any_char() -> Parser[Char] {
  Parser::of(fn(state) {
    match state.peek() {
      Some(ch) => {
        state.advance_one()
        Success(ch, state)
      }
      None => Failure(ParseError::at(pos=state.pos, expected="any character"))
    }
  })
}
