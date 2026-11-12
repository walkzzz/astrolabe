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
