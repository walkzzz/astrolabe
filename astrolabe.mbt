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
fn Pos::initial() -> Pos {
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
fn Pos::advance(self : Pos, ch : Char) -> Pos {
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

///| Internal to the library — not exposed to end users.  Each `Parser.run`

///| receives a `State`, may mutate it (advance the cursor), and returns a

///| `ParseResult` carrying the (possibly advanced) state forward.

///|

///| - `input`  — the full input string, never modified

///| - `offset` — current read position as a byte offset

///|
/// - `pos`    — current human-readable (line, column, offset) position
#derive(Debug)
struct State {
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
fn State::new(input : String) -> State {
  { input, offset: 0, pos: Pos::initial(), }
}

///|
/// Number of characters remaining from the current offset to end-of-input.
fn State::remaining(self : State) -> Int32 {
  self.input.length() - self.offset
}

///|
/// True when the cursor has reached or passed the end of input.
fn State::is_eof(self : State) -> Bool {
  self.offset >= self.input.length()
}

///| Peek at the character under the cursor without advancing.

///|

///|
/// Returns `Some(ch)` if not at EOF, `None` otherwise.
fn State::peek(self : State) -> Char? {
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
fn State::advance_one(self : State) -> Unit {
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
fn State::advance_by(self : State, n : Int32) -> Unit {
  for _ in 0..<n {
    self.advance_one()
  }
}

///| Extract a substring of `input` from byte offset `[start, end)`.

///|

///| Does not modify the cursor.  Used internally to read matched input

///|
/// without advancing first, then advancing by the known length.
fn State::slice(self : State, start : Int32, end : Int32) -> String {
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

///| Construct an uncommitted error at `pos` expecting `expected`.

///|

///| Convenience factory for the common case: single expected token,

///|
/// no context, uncommitted.
fn ParseError::at(pos~ : Pos, expected~ : String) -> ParseError {
  { pos, expected: [expected], committed: false, context: "", }
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
enum ParseResult[T] {
  /// Successful parse. `value` is the parsed result, `state` is the
  ///| advanced cursor position after the consumed input.
  Success(T, State)
  /// Failed parse. `error` describes what went wrong and where.
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
/// Internal constructor — wraps a raw function into a `Parser[T]`.
fn[T] Parser::of(f : (State) -> ParseResult[T]) -> Parser[T] {
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

/// ============================================================================
/// Basic combinators — match primitive input elements
/// ============================================================================

///| Match a single specific character.

///|

///| Succeeds and consumes one character if it equals `expected`.

///| Fails with an uncommitted error at the current position otherwise.

///|

///| Example:

///| ```moonbit

///| let comma = char(',')

///| // parses ',' from ",abc" → Ok(',')

///| // fails on "abc" → Err(expected "','")

///|
/// ```
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

///| Match an exact string literal.

///|

///| Succeeds and consumes `expected` if the input starting at the cursor

///| equals `expected`.  Fails with an uncommitted error otherwise.

///|

///| Does **not** partially match — the entire `expected` string must

///| be present.  If the input is too short, fails immediately.

///|

///| Example:

///| ```moonbit

///| let hello = string("hello")

///| // parses "hello" from "hello world" → Ok("hello")

///| // fails on "hell" → Err(expected "\"hello\"")

///|
/// ```
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

///| Match any single character.

///|

///| Succeeds and consumes exactly one character from the input.

///| Fails with an uncommitted error at EOF.

///|

///| Example:

///| ```moonbit

///| let any = any_char()

///| // parses 'a' from "abc" → Ok('a')

///| // fails on "" → Err(expected "any character")

///|
/// ```
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

///| Consume exactly `n` characters from the input.

///|

///| Succeeds if at least `n` characters remain, returning the consumed

///| substring.  Fails with an uncommitted error if fewer than `n`

///| characters are available.

///|

///| Example:

///| ```moonbit

///| let three = take(3)

///| // parses "hel" from "hello" → Ok("hel")

///| // fails on "hi" → Err(expected "3 characters")

///|
/// ```
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

///| Match a single character that satisfies a predicate.

///|

///| Peeks at the current character; succeeds and consumes it if `pred`

///| returns `true`.  Fails with an uncommitted error otherwise.

///|

///| The `label` parameter controls the error message — use it to give

///| a human-readable description of what was expected (e.g. "digit",

///| "hex character", "whitespace").

///|

///| Example:

///| ```moonbit

///| let digit = satisfy(fn(c) { c >= '0' && c <= '9' }, label="digit")

///| // parses '7' from "7abc" → Ok('7')

///| // fails on "abc" → Err(expected "digit")

///|
/// ```
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

///| Succeed only at the end of input.

///|

///| Matches zero characters and succeeds when the cursor is at EOF.

///| Fails with an uncommitted error if any input remains.

///|

///| Typically used with `parse_full` or composed at the end of a

///| sequence to ensure complete consumption.

///|

///| Example:

///| ```moonbit

///| let strict = bind(char('a'), fn(_) { end_of_input() })

///| // parses "a" → Ok(())

///| // fails on "ab" → Err(expected "end of input")

///|
/// ```
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
/// Composition combinators — transform and combine parsers
/// ============================================================================

///| Transform the result of a parser with a pure function.

///|

///| If `p` succeeds with value `v`, returns `Success(f(v))`.

///| If `p` fails, the failure passes through unchanged.

///|

///| This is the functor map for `Parser`.  It does not change commitment

///| behavior — a failure from `p` retains its original `committed` flag.

///|

///| Example:

///| ```moonbit

///| let upper = map(char('a'), fn(c) { c.to_upper() })

///| // parses 'A' (from 'a') → Ok('A')

///|
/// ```
pub fn[T, U] map(p : Parser[T], f : (T) -> U) -> Parser[U] {
  Parser::of(fn(state) {
    match (p.run)(state) {
      Success(value, st) => Success(f(value), st)
      Failure(err) => Failure(err)
    }
  })
}

///| Sequence two parsers where the second depends on the first's result.

///|

///| This is the monadic bind (>>=).  If `p` succeeds with value `v`,

///| applies `f` to get the next parser and runs it on the remaining input.

///|

///| **Commitment semantics** (Angstrom's "sequence commits" rule):

///| If `p` succeeds but the second parser (`f(v)`) fails, the error

///| is marked as **committed** — `alt` will not try other alternatives.

///| This prevents exponential backtracking in sequences.

///|

///| If `p` fails, the failure passes through unchanged (uncommitted

///| unless `p` was already committed).

///|

///| Example:

///| ```moonbit

///| let letter_then_digit = bind(

///|   satisfy(fn(c) { c.is_alpha() }, label="letter"),

///|   fn(_) { satisfy(fn(c) { c.is_digit() }, label="digit") },

///| )

///| // parses "a7" → Ok('7')

///| // fails on "ab" → committed Err(expected "digit")

///| // fails on "7a" → uncommitted Err(expected "letter")

///|
/// ```
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

///| A parser that always succeeds without consuming input, yielding `value`.

///|

///| This is the `pure` / `return` of the applicative / monadic interface.

///| Useful as a default in conditional branches or to inject constant

///| values into a parse pipeline.

///|

///| Example:

///| ```moonbit

///| let always_true = pure(true)

///| // always succeeds → Ok(true), consumes nothing

///|
/// ```
pub fn[T] pure(value : T) -> Parser[T] {
  Parser::of(fn(state) { Success(value, state) })
}

///| Alias for `pure`.  Provided for naming compatibility with monadic

///| conventions where `return` is the standard name.

///|

///|
/// Named `return_` to avoid conflicting with MoonBit's `return` keyword.
pub fn[T] return_(value : T) -> Parser[T] {
  pure(value)
}

///| Sequence two independent parsers and collect both results.

///|

///| Runs `p1` then `p2`; if both succeed, returns the pair `(a, b)`.

///|

///| **Commitment semantics**: same as `bind` — if `p1` succeeds but

///| `p2` fails, the error is committed ("sequence commits").

///| If `p1` fails, its error passes through unchanged.

///|

///| Example:

///| ```moonbit

///| let pair = seq2(char('a'), char('b'))

///| // parses "ab" → Ok(('a', 'b'))

///| // fails on "ac" → committed Err(expected "'b'")

///|
/// ```
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

///| Sequence three independent parsers and collect all results.

///|

///| Runs `p1`, `p2`, `p3` in order; returns the triple `(a, b, c)`.

///|

///| **Commitment semantics**: if any parser after the first fails,

///|
/// the error is committed.  If `p1` fails, its error is unchanged.
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

///| Sequence four independent parsers and collect all results.

///|

///| Runs `p1`, `p2`, `p3`, `p4` in order; returns the 4-tuple

///| `(a, b, c, d)`.

///|

///| **Commitment semantics**: if any parser after the first fails,

///|
/// the error is committed.  If `p1` fails, its error is unchanged.
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
/// Control flow combinators — backtracking and error context
/// ============================================================================

///| Mark a parser's failure as committed, preventing `alt` backtracking.

///|

///| When `p` succeeds, `commit(p)` passes through the result unchanged.

///| When `p` fails, `commit(p)` sets `committed = true` on the error,

///| which tells `alt` to **not** try the next alternative.

///|

///| Use this at "point of no return" points — typically after recognizing

///| a unique prefix that rules out all other alternatives.

///|

///| Example:

///| ```moonbit

///| let keyword_if = commit(string("if"))

///| // "if..." matched → Ok("if")

///| // "if..." failed after partial match → committed Err (no backtrack)

///|
/// ```
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

///| Ordered choice: try `p1`, fall back to `p2` on uncommitted failure.

///|

///| This is the core branching combinator.  Its behavior depends on the

///| `committed` flag of `p1`'s error:

///|

///| - If `p1` succeeds, return its result (short-circuit).

///| - If `p1` fails with `committed = true`, return that error

///|   immediately (**no backtracking**).

///| - If `p1` fails with `committed = false`, try `p2` on the **original**

///|   input state (backtracking is allowed).

///|

///| This implements Angstrom's committed-choice semantics, preventing

///| exponential backtracking in left-recursive grammars.

///|

///| Example:

///| ```moonbit

///| let a_or_b = alt(char('a'), char('b'))

///| // parses 'a' from "abc" → Ok('a')

///| // parses 'b' from "bcd" → Ok('b')

///| // fails on "xyz" → uncommitted Err

///|
/// ```
pub fn[T] alt(p1 : Parser[T], p2 : Parser[T]) -> Parser[T] {
  Parser::of(fn(state) {
    match (p1.run)(state) {
      Success(value, st) => Success(value, st)
      Failure(err) => if err.committed { Failure(err) } else { (p2.run)(state) }
    }
  })
}

///| N-way ordered choice over an array of parsers.

///|

///| Equivalent to left-associative `alt`: `parsers[0] | parsers[1] | ...`.

///| Each parser is tried in order; if it fails uncommitted, the next

///| is tried on the original input.

///|

///| If `parsers` is empty, returns a parser that always fails with

///| `expected = "any choice"`.

///|

///| Example:

///| ```moonbit

///| let vowel = choice([char('a'), char('e'), char('i'), char('o'), char('u')])

///| // parses 'e' from "ello" → Ok('e')

///| // fails on "xyz" → uncommitted Err

///|
/// ```
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

///| Replace a parser's error message with a custom label.

///|

///| When `p` succeeds, `label(p, name)` passes through the result unchanged.

///| When `p` fails, `label(p, name)` replaces the `expected` array with

///| `[name]`, giving a cleaner error message.

///|

///| The `committed` flag is preserved — labeling does not affect

///| backtracking behavior.

///|

///| Example:

///| ```moonbit

///| let digit = label(

///|   satisfy(fn(c) { c >= '0' && c <= '9' }),

///|   "decimal digit",

///| )

///| // fails on "abc" → Err(expected "decimal digit")

///| //  (instead of the raw "satisfy")

///|
/// ```
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
