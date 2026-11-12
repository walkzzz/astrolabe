///|
#derive(Debug)
enum ParseResult[T] {
  Success(T, State)
  Failure(ParseError)
}

///|
pub(all) struct Parser[T] {
  run : (State) -> ParseResult[T]
}

///|
fn[T] Parser::of(f : (State) -> ParseResult[T]) -> Parser[T] {
  { run: f, }
}

///|
pub fn[T] Parser::parse(
  self : Parser[T],
  input : String,
) -> Result[T, ParseError] {
  let state = State::new(input)
  match (self.run)(state) {
    Success(value, _) => Ok(value)
    Failure(err) => Err(err)
  }
}

///|
pub fn[T] Parser::parse_full(
  self : Parser[T],
  input : String,
) -> Result[T, ParseError] {
  let state = State::new(input)
  match (self.run)(state) {
    Success(value, st) =>
      if st.is_eof() {
        Ok(value)
      } else {
        Err(ParseError::at(pos=st.pos, expected="end of input"))
      }
    Failure(err) => Err(err)
  }
}
