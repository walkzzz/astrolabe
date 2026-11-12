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

///|
/// Internal: collect zero or more matches of `p` from `state` into `acc`.
fn[T] many_step(
  p : @core.Parser[T],
  state : @core.State,
  acc : Array[T],
) -> @core.ParseResult[Array[T]] {
  match (p.run)(state) {
    @core.Success(value, st) => {
      acc.push(value)
      many_step(p, st, acc)
    }
    @core.Failure(err) =>
      if err.committed {
        @core.Failure(err)
      } else {
        @core.Success(acc, state)
      }
  }
}

///| Match `p` zero or more times, collecting results into an array.

///|

///| Always succeeds (returns `[]` on zero matches).

///| Stops when `p` fails with an **uncommitted** error.

///|
/// If `p` fails with a **committed** error, that error propagates.
pub fn[T] many(p : @core.Parser[T]) -> @core.Parser[Array[T]] {
  @core.Parser::of(fn(state) { many_step(p, state, []) })
}

///|
/// Internal: collect one or more matches after the first success.
fn[T] many1_step(
  p : @core.Parser[T],
  state : @core.State,
  acc : Array[T],
) -> @core.ParseResult[Array[T]] {
  match (p.run)(state) {
    @core.Success(value, st) => {
      acc.push(value)
      many1_step(p, st, acc)
    }
    @core.Failure(err) =>
      if err.committed {
        @core.Failure(err)
      } else {
        @core.Success(acc, state)
      }
  }
}

///| Match `p` one or more times, collecting results into an array.

///|

///| Fails if `p` does not match at least once.

///| On first-match failure the error is uncommitted (backtracking allowed).

///|
/// On second-or-later failure the error is committed ("sequence commits").
pub fn[T] many1(p : @core.Parser[T]) -> @core.Parser[Array[T]] {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Failure(err) => @core.Failure(err)
      @core.Success(first, st) => many1_step(p, st, [first])
    }
  })
}

///|
/// Internal: collect `sep`-separated matches after the first success.
fn[T, S] sep_by_step(
  p : @core.Parser[T],
  sep : @core.Parser[S],
  state : @core.State,
  acc : Array[T],
) -> @core.ParseResult[Array[T]] {
  match (sep.run)(state) {
    @core.Failure(_) => @core.Success(acc, state)
    @core.Success(_, st_sep) =>
      match (p.run)(st_sep) {
        @core.Failure(err) =>
          if err.committed {
            @core.Failure(err)
          } else {
            @core.Success(acc, state)
          }
        @core.Success(value, st_p) => {
          acc.push(value)
          sep_by_step(p, sep, st_p, acc)
        }
      }
  }
}

///| Match `p` zero or more times, separated by `sep`.

///|

///| Only the values from `p` are collected; `sep` results are discarded.

///|
/// Always succeeds (returns `[]` on zero matches).
pub fn[T, S] sep_by(
  p : @core.Parser[T],
  sep : @core.Parser[S],
) -> @core.Parser[Array[T]] {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Failure(err) =>
        if err.committed {
          @core.Failure(err)
        } else {
          @core.Success([], state)
        }
      @core.Success(first, st) => sep_by_step(p, sep, st, [first])
    }
  })
}

///| Match `p` one or more times, separated by `sep`.

///|

///| Only the values from `p` are collected; `sep` results are discarded.

///|
/// Fails if `p` does not match at least once.
pub fn[T, S] sep_by1(
  p : @core.Parser[T],
  sep : @core.Parser[S],
) -> @core.Parser[Array[T]] {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Failure(err) => @core.Failure(err)
      @core.Success(first, st) => sep_by_step(p, sep, st, [first])
    }
  })
}

///|
/// Internal: collect exactly `n` matches, committing after the first success.
fn[T] count_step(
  p : @core.Parser[T],
  state : @core.State,
  remaining : Int32,
  acc : Array[T],
  isFirst : Bool,
) -> @core.ParseResult[Array[T]] {
  if remaining <= 0 {
    @core.Success(acc, state)
  } else {
    match (p.run)(state) {
      @core.Success(value, st) => {
        acc.push(value)
        count_step(p, st, remaining - 1, acc, false)
      }
      @core.Failure(err) =>
        if isFirst {
          @core.Failure(err)
        } else {
          @core.Failure({
            pos: err.pos,
            expected: err.expected,
            committed: true,
            context: err.context,
          })
        }
    }
  }
}

///| Match `p` exactly `n` times, collecting results into an array.

///|

///| Fails if any of the `n` applications fails.

///|
/// After the first successful match, subsequent failures are committed.
pub fn[T] count(n : Int32, p : @core.Parser[T]) -> @core.Parser[Array[T]] {
  @core.Parser::of(fn(state) { count_step(p, state, n, [], true) })
}

///|
/// Internal: collect matches of `p` until `end_` succeeds.
fn[T, E] many_till_step(
  p : @core.Parser[T],
  end_ : @core.Parser[E],
  state : @core.State,
  acc : Array[T],
) -> @core.ParseResult[Array[T]] {
  let saved_offset = state.offset
  let saved_pos : @core.Pos = {
    line: state.pos.line,
    column: state.pos.column,
    offset: state.pos.offset,
  }
  match (end_.run)(state) {
    @core.Success(_, _) => {
      state.offset = saved_offset
      state.pos = saved_pos
      @core.Success(acc, state)
    }
    @core.Failure(_) =>
      match (p.run)(state) {
        @core.Success(value, st) => {
          acc.push(value)
          many_till_step(p, end_, st, acc)
        }
        @core.Failure(err) => @core.Failure(err)
      }
  }
}

///| Match `p` zero or more times until `end_` succeeds.

///|

///| `end_` is tried first at each position.  When `end_` succeeds,

///| `many_till` stops and returns the collected results **without**

///| consuming the input matched by `end_`.

///|
/// If `p` fails before `end_` matches, that failure propagates.
pub fn[T, E] many_till(
  p : @core.Parser[T],
  end_ : @core.Parser[E],
) -> @core.Parser[Array[T]] {
  @core.Parser::of(fn(state) {
    let saved_offset = state.offset
    let saved_pos : @core.Pos = {
      line: state.pos.line,
      column: state.pos.column,
      offset: state.pos.offset,
    }
    match (end_.run)(state) {
      @core.Success(_, _) => {
        state.offset = saved_offset
        state.pos = saved_pos
        @core.Success([], state)
      }
      @core.Failure(_) =>
        match (p.run)(state) {
          @core.Failure(err) => @core.Failure(err)
          @core.Success(first, st) => many_till_step(p, end_, st, [first])
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
