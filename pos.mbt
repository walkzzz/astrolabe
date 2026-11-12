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
