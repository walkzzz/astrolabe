///| Mark a parser's failure as committed, preventing `alt` backtracking.

///|

///| When `p` succeeds, `commit(p)` passes through the result unchanged.

///| When `p` fails, `commit(p)` sets `committed = true` on the error,

///|
/// which tells `alt` to **not** try the next alternative.
pub fn[T] commit(p : @core.Parser[T]) -> @core.Parser[T] {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Success(value, st) => @core.Success(value, st)
      @core.Failure(err) =>
        @core.Failure({
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

///| - If `p1` succeeds, return its result.

///| - If `p1` fails with `committed = true`, return that error (no backtrack).

///|
/// - If `p1` fails with `committed = false`, try `p2` on the original input.
pub fn[T] alt(p1 : @core.Parser[T], p2 : @core.Parser[T]) -> @core.Parser[T] {
  @core.Parser::of(fn(state) {
    match (p1.run)(state) {
      @core.Success(value, st) => @core.Success(value, st)
      @core.Failure(err) =>
        if err.committed {
          @core.Failure(err)
        } else {
          (p2.run)(state)
        }
    }
  })
}

///| N-way ordered choice over an array of parsers.

///|

///| Equivalent to left-associative `alt`: `parsers[0] | parsers[1] | ...`.

///|
/// If `parsers` is empty, returns a parser that always fails.
pub fn[T] choice(parsers : Array[@core.Parser[T]]) -> @core.Parser[T] {
  if parsers.length() == 0 {
    @core.Parser::of(fn(state) {
      @core.Failure(@core.ParseError::at(pos=state.pos, expected="any choice"))
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

///| When `p` fails, `label(p, name)` replaces `expected` with `[name]`.

///|
/// The `committed` flag is preserved — labeling does not affect backtracking.
pub fn[T] label(p : @core.Parser[T], name : String) -> @core.Parser[T] {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Success(value, st) => @core.Success(value, st)
      @core.Failure(err) =>
        @core.Failure({
          pos: err.pos,
          expected: [name],
          committed: err.committed,
          context: err.context,
        })
    }
  })
}
