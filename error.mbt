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
