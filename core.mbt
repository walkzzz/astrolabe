///|
#derive(Eq, Debug)
pub(all) struct Pos {
  mut line : Int32
  mut column : Int32
  mut offset : Int32
}

///|
pub extend Pos with Eq::{not_equal, equal}

///|
pub extend Pos with @debug.Debug::{to_repr}

///|
fn Pos::initial() -> Pos {
  { line: 1, column: 1, offset: 0, }
}

///|
fn Pos::advance(self : Pos, ch : Char) -> Pos {
  if ch == '\n' {
    { line: self.line + 1, column: 1, offset: self.offset + 1, }
  } else {
    { line: self.line, column: self.column + 1, offset: self.offset + 1, }
  }
}

/// ============================================================================

///|
#derive(Debug)
struct State {
  input : String
  mut offset : Int32
  mut pos : Pos
}

///|
pub extend State with @debug.Debug::{to_repr}

///|
fn State::new(input : String) -> State {
  { input, offset: 0, pos: Pos::initial(), }
}

///|
fn State::remaining(self : State) -> Int32 {
  self.input.length() - self.offset
}

///|
fn State::is_eof(self : State) -> Bool {
  self.offset >= self.input.length()
}

///|
fn State::peek(self : State) -> Char? {
  if self.is_eof() {
    None
  } else {
    self.input.get_char(self.offset)
  }
}

///|
fn State::advance_one(self : State) -> Unit {
  if !self.is_eof() {
    let ch = self.input.get_char(self.offset).unwrap()
    self.pos = self.pos.advance(ch)
    self.offset = self.offset + 1
  }
}

///|
fn State::advance_by(self : State, n : Int32) -> Unit {
  for _ in 0..<n {
    self.advance_one()
  }
}

///|
fn State::slice(self : State, start : Int32, end : Int32) -> String {
  self.input[start:end].to_owned()
}

/// ============================================================================

///|
#derive(Debug, Eq)
pub(all) struct ParseError {
  pos : Pos
  expected : Array[String]
  committed : Bool
  context : String
}

///|
pub extend ParseError with Eq::{not_equal, equal}

///|
pub extend ParseError with @debug.Debug::{to_repr}

///|
fn ParseError::at(pos~ : Pos, expected~ : String) -> ParseError {
  { pos, expected: [expected], committed: false, context: "", }
}

///|
pub fn ParseError::format(self : ParseError) -> String {
  let loc = "line \{self.pos.line}, column \{self.pos.column} (offset \{self.pos.offset})"
  let exp = self.expected.join(" or ")
  let ctx = if self.context == "" { "" } else { "\n  \{self.context}" }
  "\{loc}:\nexpected \{exp}\{ctx}"
}

/// ============================================================================

///|
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
