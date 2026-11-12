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

/// ============================================================================
/// Basic combinators
/// ============================================================================

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

/// ============================================================================
/// Composition combinators
/// ============================================================================

///|
pub fn[T, U] map(p : Parser[T], f : (T) -> U) -> Parser[U] {
  Parser::of(fn(state) {
    match (p.run)(state) {
      Success(value, st) => Success(f(value), st)
      Failure(err) => Failure(err)
    }
  })
}

///|
pub fn[T, U] bind(p : Parser[T], f : (T) -> Parser[U]) -> Parser[U] {
  Parser::of(fn(state) {
    match (p.run)(state) {
      Success(value, st) => {
        let next = f(value)
        match (next.run)(st) {
          Success(result, st2) => Success(result, st2)
          Failure(err) =>
            Failure({
              pos: err.pos,
              expected: err.expected,
              committed: true,
              context: err.context,
            })
        }
      }
      Failure(err) => Failure(err)
    }
  })
}

///|
pub fn[T] pure(value : T) -> Parser[T] {
  Parser::of(fn(state) { Success(value, state) })
}

///|
pub fn[T] return_(value : T) -> Parser[T] {
  pure(value)
}

///|
pub fn[A, B] seq2(p1 : Parser[A], p2 : Parser[B]) -> Parser[(A, B)] {
  Parser::of(fn(state) {
    match (p1.run)(state) {
      Failure(err) => Failure(err)
      Success(a, st1) =>
        match (p2.run)(st1) {
          Failure(err) =>
            Failure({
              pos: err.pos,
              expected: err.expected,
              committed: true,
              context: err.context,
            })
          Success(b, st2) => Success((a, b), st2)
        }
    }
  })
}

///|
pub fn[A, B, C] seq3(
  p1 : Parser[A],
  p2 : Parser[B],
  p3 : Parser[C],
) -> Parser[(A, B, C)] {
  Parser::of(fn(state) {
    match (p1.run)(state) {
      Failure(err) => Failure(err)
      Success(a, st1) =>
        match (p2.run)(st1) {
          Failure(err) =>
            Failure({
              pos: err.pos,
              expected: err.expected,
              committed: true,
              context: err.context,
            })
          Success(b, st2) =>
            match (p3.run)(st2) {
              Failure(err) =>
                Failure({
                  pos: err.pos,
                  expected: err.expected,
                  committed: true,
                  context: err.context,
                })
              Success(c, st3) => Success((a, b, c), st3)
            }
        }
    }
  })
}

///|
pub fn[A, B, C, D] seq4(
  p1 : Parser[A],
  p2 : Parser[B],
  p3 : Parser[C],
  p4 : Parser[D],
) -> Parser[(A, B, C, D)] {
  Parser::of(fn(state) {
    match (p1.run)(state) {
      Failure(err) => Failure(err)
      Success(a, st1) =>
        match (p2.run)(st1) {
          Failure(err) =>
            Failure({
              pos: err.pos,
              expected: err.expected,
              committed: true,
              context: err.context,
            })
          Success(b, st2) =>
            match (p3.run)(st2) {
              Failure(err) =>
                Failure({
                  pos: err.pos,
                  expected: err.expected,
                  committed: true,
                  context: err.context,
                })
              Success(c, st3) =>
                match (p4.run)(st3) {
                  Failure(err) =>
                    Failure({
                      pos: err.pos,
                      expected: err.expected,
                      committed: true,
                      context: err.context,
                    })
                  Success(d, st4) => Success((a, b, c, d), st4)
                }
            }
        }
    }
  })
}

/// ============================================================================
/// Control flow combinators
/// ============================================================================

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
