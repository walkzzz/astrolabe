///| Source position in the input being parsed.

///|

///| Tracks line, column, and byte-offset simultaneously so error messages

///| can point to an exact human-readable location while offset enables

///| O(1) slicing into the input string.

///|

///| - `line`   — 1-based line number, incremented by `'\n'`

///| - `column` — 1-based column number, reset to 1 on `'\n'`

///|
/// - `offset` — 0-based byte offset from the start of input
#derive(Eq, Debug)
pub(all) struct Pos {
  /// 1-based line number, starting at 1. Incremented when `'\n'` is consumed.
  mut line : Int32
  /// 1-based column number, starting at 1. Reset to 1 after `'\n'`.
  mut column : Int32
  /// 0-based byte offset from the beginning of the input string.
  mut offset : Int32
}

///|
pub extend Pos with Eq::{not_equal, equal}

///|
pub extend Pos with @debug.Debug::{to_repr}

///|
/// Create the initial position (line 1, column 1, offset 0).
pub fn Pos::initial() -> Pos {
  { line: 1, column: 1, offset: 0, }
}

///| Advance the position by one character.

///|

///| - If `ch` is `'\n'`, line increments and column resets to 1.

///| - Otherwise, column increments by 1.

///| - offset always increments by 1.

///|

///|
/// Returns a **new** Pos; the original is not mutated.
pub fn Pos::advance(self : Pos, ch : Char) -> Pos {
  if ch == '\n' {
    { line: self.line + 1, column: 1, offset: self.offset + 1, }
  } else {
    { line: self.line, column: self.column + 1, offset: self.offset + 1, }
  }
}

/// ============================================================================
/// Parsing state
/// ============================================================================

///| Mutable parsing state that wraps the input string and a cursor.

///|

///| Each `Parser.run` receives a `State`, may mutate it (advance the cursor),

///| and returns a `ParseResult` carrying the (possibly advanced) state forward.

///|

///| - `input`  — the full input string, never modified

///| - `offset` — current read position as a byte offset

///|
/// - `pos`    — current human-readable (line, column, offset) position
#derive(Debug)
pub(all) struct State {
  /// The complete input string. Immutable after construction.
  input : String
  /// Current read position as a 0-based byte offset into `input`.
  mut offset : Int32
  /// Current source position (line, column, offset) for error reporting.
  mut pos : Pos
}

///|
pub extend State with @debug.Debug::{to_repr}

///|
/// Create a fresh `State` positioned at the start of `input`.
pub fn State::new(input : String) -> State {
  { input, offset: 0, pos: Pos::initial(), }
}

///|
/// Number of characters remaining from the current offset to end-of-input.
pub fn State::remaining(self : State) -> Int32 {
  self.input.length() - self.offset
}

///|
/// True when the cursor has reached or passed the end of input.
pub fn State::is_eof(self : State) -> Bool {
  self.offset >= self.input.length()
}

///| Peek at the character under the cursor without advancing.

///|

///|
/// Returns `Some(ch)` if not at EOF, `None` otherwise.
pub fn State::peek(self : State) -> Char? {
  if self.is_eof() {
    None
  } else {
    self.input.get_char(self.offset)
  }
}

///| Advance the cursor by exactly one character, updating position tracking.

///|

///|
/// No-op when already at EOF.
pub fn State::advance_one(self : State) -> Unit {
  if !self.is_eof() {
    let ch = self.input.get_char(self.offset).unwrap()
    self.pos = self.pos.advance(ch)
    self.offset = self.offset + 1
  }
}

///| Advance the cursor by `n` characters, updating position tracking.

///|

///| Equivalent to calling `advance_one` `n` times.

///|
/// Caller must ensure `n <= remaining()`.
pub fn State::advance_by(self : State, n : Int32) -> Unit {
  for _ in 0..<n {
    self.advance_one()
  }
}

///| Extract a substring of `input` from byte offset `[start, end)`.

///|

///| Does not modify the cursor.  Used internally to read matched input

///|
/// without advancing first, then advancing by the known length.
pub fn State::slice(self : State, start : Int32, end : Int32) -> String {
  self.input[start:end].to_owned()
}

/// ============================================================================
/// Error reporting
/// ============================================================================

///| A parse error carrying position, expected tokens, and commitment status.

///|

///| The `committed` flag implements Angstrom's commitment semantics:

///|

///| - `committed = false` — the parser has not consumed significant input,

///|   so `alt` may try the next alternative (backtracking is allowed).

///| - `committed = true`  — the parser has consumed significant input,

///|   so `alt` will **not** try the next alternative (no backtracking).

///|

///| Commitment is set by:

///| - `commit(p)` — explicitly marks `p`'s failure as committed

///| - `bind` / `seq2` / `seq3` / `seq4` — if the *second* parser fails,

///|   the error is committed ("sequence commits")

///|

///| - `pos`       — where the error occurred

///| - `expected`  — human-readable descriptions of what was expected

///| - `committed` — whether backtracking should be suppressed

///|
/// - `context`   — optional context label for nested error reporting
#derive(Debug, Eq)
pub(all) struct ParseError {
  /// Source position where the error was detected.
  pos : Pos
  /// Descriptions of what the parser expected at this position.
  ///| Multiple entries arise from `alt` merging expectations.
  expected : Array[String]
  /// Whether this error is committed (suppresses backtracking in `alt`).
  ///| `false` = uncommitted (backtracking allowed), `true` = committed.
  committed : Bool
  /// Optional context label for structured error messages.
  ///| Empty string means no context.
  context : String
}

///|
pub extend ParseError with Eq::{not_equal, equal}

///|
pub extend ParseError with @debug.Debug::{to_repr}

pub fn ParseError::at(pos~ : Pos, expected~ : String) -> ParseError {
  { pos, expected: [expected], committed: false, context: "", }
}

pub fn ParseError::commit(self : ParseError) -> ParseError {
  { pos: self.pos, expected: self.expected, committed: true, context: self.context, }
}

///| Format this error as a human-readable string.

///|

///| Output format:

///| ```text

///| line L, column C (offset O):

///| expected X or Y

///|   context-label

///| ```

///|

///| Multiple `expected` entries are joined with `" or "`.

///|
/// The `context` line is omitted when empty.
pub fn ParseError::format(self : ParseError) -> String {
  let loc = "line \{self.pos.line}, column \{self.pos.column} (offset \{self.pos.offset})"
  let exp = self.expected.join(" or ")
  let ctx = if self.context == "" { "" } else { "\n  \{self.context}" }
  "\{loc}:\nexpected \{exp}\{ctx}"
}

///| Format this error with a context snippet extracted from `input`.

///|

///| Produces the same header as `format()`, plus a snippet line showing

///| up to 20 characters before and after the error position:

///|

///| ```text

///| line 3, column 15 (offset 42):

///| expected HTTP method

///|   ...GET /path with-P<error>ayload...

///|                ^

///|
/// ```
pub fn ParseError::format_with_input(
  self : ParseError,
  input : String,
) -> String {
  let base = self.format()
  let offset = self.pos.offset
  let ctx_start = if offset > 20 { offset - 20 } else { 0 }
  let ctx_end = if offset + 20 < input.length() {
    offset + 20
  } else {
    input.length()
  }
  let snippet = input[ctx_start:ctx_end].to_owned()
  let prefix = if ctx_start > 0 { "..." } else { "" }
  let suffix = if ctx_end < input.length() { "..." } else { "" }
  let caret_offset = offset - ctx_start + prefix.length()
  let caret = " ".repeat(caret_offset) + "^"
  "\{base}\n  \{prefix}\{snippet}\{suffix}\n  \{caret}"
}

/// ============================================================================
/// Parse result & Parser core
/// ============================================================================

///| The result of running a `Parser[T]` against a `State`.

///|

///| - `Success(value, state)` — matched successfully; `value` is the parsed

///|   result and `state` is the cursor position after consumption.

///| - `Failure(error)` — failed to match; `error` carries position and

///|
///   commitment information for `alt` backtracking decisions.
pub(all) enum ParseResult[T] {
  Success(T, State)
  Failure(ParseError)
}

///| A position-aware parser combinator.

///|

///| Wraps a function `State -> ParseResult[T]` that attempts to match

///| input at the current cursor position.  Combinators (`map`, `bind`,

///| `alt`, `seq2`, etc.) compose `Parser` values into larger parsers

///| without exposing the internal `State` machinery.

///|

///| Use `Parser::parse` for a simple parse-entire-string entry point,

///| or `Parser::parse_full` to also enforce that the entire input was

///|
/// consumed.
pub(all) struct Parser[T] {
  /// The core parsing function. Takes a `State` and returns either
  ///| `Success(value, nextState)` or `Failure(error)`.
  run : (State) -> ParseResult[T]
}

///|
/// Wrap a raw function into a `Parser[T]`.
pub fn[T] Parser::of(f : (State) -> ParseResult[T]) -> Parser[T] {
  { run: f, }
}

///| Parse `input` and return the result, allowing trailing unconsumed input.

///|

///| This is the loosest entry point: it succeeds as long as the parser

///| matches a prefix of `input`.  Use `parse_full` when you need to

///| ensure the entire input is consumed.

///|

///| - Returns `Ok(value)` on success.

///|
/// - Returns `Err(ParseError)` on failure.
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

///| Parse `input` and require that the entire input is consumed.

///|

///| Like `parse`, but if the parser succeeds without reaching EOF,

///| returns an `Err` with `expected = "end of input"`.

///|

///| Use this for validation-style parsing where leftover input indicates

///|
/// a malformed input.
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
