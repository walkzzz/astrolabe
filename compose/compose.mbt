///| 用纯函数变换解析器的结果。

///|

///| 若 `p` 成功返回值 `v`，则返回 `Success(f(v))`；

///| 若 `p` 失败，失败直接传递。不改变承诺行为。

///|

///| Transform the result of a parser with a pure function.

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

///| 序列绑定 — 第二个解析器依赖第一个的结果。

///|

///| 这是单子绑定（>>=）。若 `p` 成功返回值 `v`，

///| 将 `f` 应用于 `v` 获取下一个解析器并在剩余输入上运行。

///|

///| **承诺语义**（"序列承诺"）：

///| 若 `p` 成功但第二个解析器失败，错误为**已承诺** —

///| `alt` 不会尝试其他备选。

///|

///| Sequence two parsers where the second depends on the first's result.

///| **Commitment semantics** ("sequence commits"):

///|
/// If `p` succeeds but the second parser fails, the error is committed.
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
          @core.Failure(err) => @core.Failure(err.commit())
        }
      }
      @core.Failure(err) => @core.Failure(err)
    }
  })
}

///| 总是成功且不消耗输入的解析器，返回 `value`。

///|

///| 这是 applicative/monadic 接口的 `pure` / `return`。

///|

///|
/// A parser that always succeeds without consuming input, yielding `value`.
#alias(return_, deprecated="Use pure instead")
pub fn[T] pure(value : T) -> @core.Parser[T] {
  @core.Parser::of(fn(state) { @core.Success(value, state) })
}

///| 序列两个独立解析器，收集两个结果。

///|

///| **承诺语义**：若 `p1` 成功但 `p2` 失败，错误为已承诺（"序列承诺"）。

///|

///| Sequence two independent parsers and collect both results.

///|
/// **Commitment semantics**: if `p1` succeeds but `p2` fails, the error is committed.
pub fn[A, B] seq2(
  p1 : @core.Parser[A],
  p2 : @core.Parser[B],
) -> @core.Parser[(A, B)] {
  @core.Parser::of(fn(state) {
    match (p1.run)(state) {
      @core.Failure(err) => @core.Failure(err)
      @core.Success(a, st1) =>
        match (p2.run)(st1) {
          @core.Failure(err) => @core.Failure(err.commit())
          @core.Success(b, st2) => @core.Success((a, b), st2)
        }
    }
  })
}

///| 序列三个独立解析器，收集所有结果。

///|

///| **承诺语义**：第一个之后的解析器失败时，错误为已承诺。

///|

///| Sequence three independent parsers and collect all results.

///|
/// **Commitment semantics**: if any parser after the first fails, the error is committed.
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
          @core.Failure(err) => @core.Failure(err.commit())
          @core.Success(b, st2) =>
            match (p3.run)(st2) {
              @core.Failure(err) => @core.Failure(err.commit())
              @core.Success(c, st3) => @core.Success((a, b, c), st3)
            }
        }
    }
  })
}

///|
/// 内部：从 `state` 开始零次或多次匹配 `p`，收集到 `acc`。
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
      if err.committed() {
        @core.Failure(err)
      } else {
        @core.Success(acc, state)
      }
  }
}

///| 零次或多次匹配 `p`，收集结果到数组。

///|

///| 总是成功（零次匹配返回 `[]`）。

///| 在**未承诺**失败时停止；**已承诺**错误则传播。

///|

///| Match `p` zero or more times, collecting results into an array.

///| Always succeeds (returns `[]` on zero matches).

///|
/// Stops when `p` fails with an uncommitted error; committed errors propagate.
pub fn[T] many(p : @core.Parser[T]) -> @core.Parser[Array[T]] {
  @core.Parser::of(fn(state) { many_step(p, state, []) })
}

///|
/// 内部：首次成功后的一次或多次匹配。
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
      if err.committed() {
        @core.Failure(err)
      } else {
        @core.Success(acc, state)
      }
  }
}

///| 一次或多次匹配 `p`，收集结果到数组。

///|

///| 若 `p` 至少不匹配一次则失败。首次失败为未承诺（允许回溯），

///| 第二次及之后的失败为已承诺（"序列承诺"）。

///|

///| Match `p` one or more times. Fails if `p` does not match at least once.

///|
/// First-match failure is uncommitted; later failures are committed.
pub fn[T] many1(p : @core.Parser[T]) -> @core.Parser[Array[T]] {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Failure(err) => @core.Failure(err)
      @core.Success(first, st) => many1_step(p, st, [first])
    }
  })
}

///|
/// 内部：首次成功后收集 `sep` 分隔的匹配。
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
          if err.committed() {
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

///| 零次或多次匹配 `p`，用 `sep` 分隔。

///|

///| 只收集 `p` 的结果；`sep` 的结果被丢弃。

///| 总是成功（零次匹配返回 `[]`）。

///|

///| Match `p` zero or more times, separated by `sep`.

///| Only values from `p` are collected; `sep` results are discarded.

///|
/// Always succeeds (returns `[]` on zero matches).
pub fn[T, S] sep_by(
  p : @core.Parser[T],
  sep : @core.Parser[S],
) -> @core.Parser[Array[T]] {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Failure(err) =>
        if err.committed() {
          @core.Failure(err)
        } else {
          @core.Success([], state)
        }
      @core.Success(first, st) => sep_by_step(p, sep, st, [first])
    }
  })
}

///| 一次或多次匹配 `p`，用 `sep` 分隔。

///|

///| 若 `p` 至少不匹配一次则失败。

///|

///| Match `p` one or more times, separated by `sep`.

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
/// 内部：精确匹配 `n` 次，首次成功后承诺。
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
          @core.Failure(err.commit())
        }
    }
  }
}

///| 精确匹配 `p` `n` 次，收集结果到数组。

///|

///| 任一匹配失败则整体失败。首次成功后，后续失败为已承诺。

///|

///| Match `p` exactly `n` times. Fails if any match fails.

///|
/// After the first successful match, subsequent failures are committed.
pub fn[T] count(n : Int32, p : @core.Parser[T]) -> @core.Parser[Array[T]] {
  @core.Parser::of(fn(state) { count_step(p, state, n, [], true) })
}

///|
/// 内部：匹配 `p` 直到 `end_` 成功。
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

///| 零次或多次匹配 `p`，直到 `end_` 成功。

///|

///| `end_` 在每个位置优先尝试。当 `end_` 成功时，

///| `many_till` 停止并返回收集的结果，**不消耗** `end_` 匹配的输入。

///| 若 `p` 在 `end_` 匹配前失败，该失败直接传播。

///|

///| Match `p` zero or more times until `end_` succeeds.

///| `end_` is tried first at each position. When `end_` succeeds,

///|
/// stops and returns collected results **without** consuming `end_`'s match.
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

///| 序列四个独立解析器，收集所有结果。

///|

///| **承诺语义**：第一个之后的解析器失败时，错误为已承诺。

///|

///| Sequence four independent parsers and collect all results.

///|
/// **Commitment semantics**: if any parser after the first fails, the error is committed.
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
          @core.Failure(err) => @core.Failure(err.commit())
          @core.Success(b, st2) =>
            match (p3.run)(st2) {
              @core.Failure(err) => @core.Failure(err.commit())
              @core.Success(c, st3) =>
                match (p4.run)(st3) {
                  @core.Failure(err) => @core.Failure(err.commit())
                  @core.Success(d, st4) => @core.Success((a, b, c, d), st4)
                }
            }
        }
    }
  })
}
