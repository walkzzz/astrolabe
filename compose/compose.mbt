///| Transform the result of a parser with a pure function.

///|

///| If `p` succeeds with value `v`, returns `Success(f(v))`.

///| If `p` fails, the failure passes through unchanged.

///|
/// Does not change commitment behavior.
pub fn[T, U] map(p : @core.Parser[T], f : (T) -> U) -> @core.Parser[U] {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Success(value, st) => @core.Success(f(value), st)
      @core.Failure(err) => @core.Failure(err)
    }
  })
}

///| Sequence two parsers where the second depends on the first's result.

///|

///| This is the monadic bind (>>=).  If `p` succeeds with value `v`,

///| applies `f` to get the next parser and runs it on the remaining input.

///|

///| **Commitment semantics** ("sequence commits"):

///| If `p` succeeds but the second parser fails, the error is **committed** —

///|
/// `alt` will not try other alternatives.
pub fn[T, U] bind(
  p : @core.Parser[T],
  f : (T) -> @core.Parser[U],
) -> @core.Parser[U] {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Success(value, st) => {
        let next = f(value)
        match (next.run)(st) {
          @core.Success(result, st2) => @core.Success(result, st2)
          @core.Failure(err) =>
            @core.Failure({
              pos: err.pos,
              expected: err.expected,
              committed: true,
              context: err.context,
            })
        }
      }
      @core.Failure(err) => @core.Failure(err)
    }
  })
}

///| A parser that always succeeds without consuming input, yielding `value`.

///|

///|
/// This is the `pure` / `return` of the applicative / monadic interface.
pub fn[T] pure(value : T) -> @core.Parser[T] {
  @core.Parser::of(fn(state) { @core.Success(value, state) })
}

///|
/// Alias for `pure`. Named `return_` to avoid conflicting with MoonBit keyword.
pub fn[T] return_(value : T) -> @core.Parser[T] {
  pure(value)
}

///| Sequence two independent parsers and collect both results.

///|

///| **Commitment semantics**: if `p1` succeeds but `p2` fails,

///|
/// the error is committed ("sequence commits").
pub fn[A, B] seq2(
  p1 : @core.Parser[A],
  p2 : @core.Parser[B],
) -> @core.Parser[(A, B)] {
  @core.Parser::of(fn(state) {
    match (p1.run)(state) {
      @core.Failure(err) => @core.Failure(err)
      @core.Success(a, st1) =>
        match (p2.run)(st1) {
          @core.Failure(err) =>
            @core.Failure({
              pos: err.pos,
              expected: err.expected,
              committed: true,
              context: err.context,
            })
          @core.Success(b, st2) => @core.Success((a, b), st2)
        }
    }
  })
}

///| Sequence three independent parsers and collect all results.

///|

///| **Commitment semantics**: if any parser after the first fails,

///|
/// the error is committed.
pub fn[A, B, C] seq3(
  p1 : @core.Parser[A],
  p2 : @core.Parser[B],
  p3 : @core.Parser[C],
) -> @core.Parser[(A, B, C)] {
  @core.Parser::of(fn(state) {
    match (p1.run)(state) {
      @core.Failure(err) => @core.Failure(err)
      @core.Success(a, st1) =>
        match (p2.run)(st1) {
          @core.Failure(err) =>
            @core.Failure({
              pos: err.pos,
              expected: err.expected,
              committed: true,
              context: err.context,
            })
          @core.Success(b, st2) =>
            match (p3.run)(st2) {
              @core.Failure(err) =>
                @core.Failure({
                  pos: err.pos,
                  expected: err.expected,
                  committed: true,
                  context: err.context,
                })
              @core.Success(c, st3) => @core.Success((a, b, c), st3)
            }
        }
    }
  })
}

///| Sequence four independent parsers and collect all results.

///|

///| **Commitment semantics**: if any parser after the first fails,

///|
/// the error is committed.
pub fn[A, B, C, D] seq4(
  p1 : @core.Parser[A],
  p2 : @core.Parser[B],
  p3 : @core.Parser[C],
  p4 : @core.Parser[D],
) -> @core.Parser[(A, B, C, D)] {
  @core.Parser::of(fn(state) {
    match (p1.run)(state) {
      @core.Failure(err) => @core.Failure(err)
      @core.Success(a, st1) =>
        match (p2.run)(st1) {
          @core.Failure(err) =>
            @core.Failure({
              pos: err.pos,
              expected: err.expected,
              committed: true,
              context: err.context,
            })
          @core.Success(b, st2) =>
            match (p3.run)(st2) {
              @core.Failure(err) =>
                @core.Failure({
                  pos: err.pos,
                  expected: err.expected,
                  committed: true,
                  context: err.context,
                })
              @core.Success(c, st3) =>
                match (p4.run)(st3) {
                  @core.Failure(err) =>
                    @core.Failure({
                      pos: err.pos,
                      expected: err.expected,
                      committed: true,
                      context: err.context,
                    })
                  @core.Success(d, st4) => @core.Success((a, b, c, d), st4)
                }
            }
        }
    }
  })
}
