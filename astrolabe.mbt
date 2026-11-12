/// ============================================================================
/// Root package facade — re-exports from subpackages
/// ============================================================================

///|

///| External users access all API through `@astrolabe.xxx`:

///|

///|   @astrolabe.char('a')

///|   @astrolabe.Parser::parse(p, input)

///|   @astrolabe.map(p, f)

///|

///| Internally, types live in `@core` and combinators in `@basic` / `@compose`

///| / `@control`.  This file re-exports them as thin wrappers so the public

///| API surface is flat and convenient.

/// ============================================================================
/// Convenience entry points
/// ============================================================================

///|
/// Parse `input` with `p`, allowing trailing unconsumed input.
pub fn[T] parse(
  p : @core.Parser[T],
  input : String,
) -> Result[T, @core.ParseError] {
  p.parse(input)
}

///|
/// Parse `input` with `p`, requiring entire input consumed.
pub fn[T] parse_full(
  p : @core.Parser[T],
  input : String,
) -> Result[T, @core.ParseError] {
  p.parse_full(input)
}

///|
/// Format a `ParseError` as a human-readable string.
pub fn format_error(err : @core.ParseError) -> String {
  err.format()
}

/// ============================================================================
/// Basic combinators (re-export from @basic)
/// ============================================================================

///|
/// Match a single specific character.
pub fn char(expected : Char) -> @core.Parser[Char] {
  @basic.char(expected)
}

///|
/// Match an exact string literal.
pub fn string(expected : String) -> @core.Parser[String] {
  @basic.string(expected)
}

///|
/// Match any single character.
pub fn any_char() -> @core.Parser[Char] {
  @basic.any_char()
}

///|
/// Consume exactly `n` characters from the input.
pub fn take(n : Int32) -> @core.Parser[String] {
  @basic.take(n)
}

///|
/// Match a single character that satisfies a predicate.
pub fn satisfy(
  pred : (Char) -> Bool,
  label~ : String = "satisfy",
) -> @core.Parser[Char] {
  @basic.satisfy(pred, label~)
}

///|
/// Succeed only at the end of input.
pub fn end_of_input() -> @core.Parser[Unit] {
  @basic.end_of_input()
}

/// ============================================================================
/// Compose combinators (re-export from @compose)
/// ============================================================================

///|
/// Transform the result of a parser with a pure function.
pub fn[T, U] map(p : @core.Parser[T], f : (T) -> U) -> @core.Parser[U] {
  @compose.map(p, f)
}

///|
/// Sequence two parsers where the second depends on the first's result.
pub fn[T, U] bind(
  p : @core.Parser[T],
  f : (T) -> @core.Parser[U],
) -> @core.Parser[U] {
  @compose.bind(p, f)
}

///|
/// A parser that always succeeds without consuming input.
pub fn[T] pure(value : T) -> @core.Parser[T] {
  @compose.pure(value)
}

///|
/// Alias for `pure`.
pub fn[T] return_(value : T) -> @core.Parser[T] {
  @compose.return_(value)
}

///|
/// Sequence two independent parsers and collect both results.
pub fn[A, B] seq2(
  p1 : @core.Parser[A],
  p2 : @core.Parser[B],
) -> @core.Parser[(A, B)] {
  @compose.seq2(p1, p2)
}

///|
/// Sequence three independent parsers and collect all results.
pub fn[A, B, C] seq3(
  p1 : @core.Parser[A],
  p2 : @core.Parser[B],
  p3 : @core.Parser[C],
) -> @core.Parser[(A, B, C)] {
  @compose.seq3(p1, p2, p3)
}

///|
/// Sequence four independent parsers and collect all results.
pub fn[A, B, C, D] seq4(
  p1 : @core.Parser[A],
  p2 : @core.Parser[B],
  p3 : @core.Parser[C],
  p4 : @core.Parser[D],
) -> @core.Parser[(A, B, C, D)] {
  @compose.seq4(p1, p2, p3, p4)
}

///|
/// Match `p` zero or more times, collecting results into an array.
pub fn[T] many(p : @core.Parser[T]) -> @core.Parser[Array[T]] {
  @compose.many(p)
}

///|
/// Match `p` one or more times, collecting results into an array.
pub fn[T] many1(p : @core.Parser[T]) -> @core.Parser[Array[T]] {
  @compose.many1(p)
}

///|
/// Match `p` zero or more times, separated by `sep`.
pub fn[T, S] sep_by(
  p : @core.Parser[T],
  sep : @core.Parser[S],
) -> @core.Parser[Array[T]] {
  @compose.sep_by(p, sep)
}

///|
/// Match `p` one or more times, separated by `sep`.
pub fn[T, S] sep_by1(
  p : @core.Parser[T],
  sep : @core.Parser[S],
) -> @core.Parser[Array[T]] {
  @compose.sep_by1(p, sep)
}

///|
/// Match `p` exactly `n` times, collecting results into an array.
pub fn[T] count(n : Int32, p : @core.Parser[T]) -> @core.Parser[Array[T]] {
  @compose.count(n, p)
}

/// ============================================================================
/// Control combinators (re-export from @control)
/// ============================================================================

///|
/// Mark a parser's failure as committed.
pub fn[T] commit(p : @core.Parser[T]) -> @core.Parser[T] {
  @control.commit(p)
}

///|
/// Ordered choice: try `p1`, fall back to `p2` on uncommitted failure.
pub fn[T] alt(p1 : @core.Parser[T], p2 : @core.Parser[T]) -> @core.Parser[T] {
  @control.alt(p1, p2)
}

///|
/// N-way ordered choice over an array of parsers.
pub fn[T] choice(parsers : Array[@core.Parser[T]]) -> @core.Parser[T] {
  @control.choice(parsers)
}

///|
/// Replace a parser's error message with a custom label.
pub fn[T] label(p : @core.Parser[T], name : String) -> @core.Parser[T] {
  @control.label(p, name)
}
