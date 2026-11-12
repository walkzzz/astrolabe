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
