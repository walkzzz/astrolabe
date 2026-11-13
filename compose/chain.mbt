///| 过滤解析结果 — 若 `pred` 返回 `false`，产生未承诺的错误。

///|

///|
/// Filter a parser's result — if `pred` returns `false`, produce an uncommitted error.
pub fn[T] filter(
  p : @core.Parser[T],
  pred : (T) -> Bool,
  label~ : String = "filter",
) -> @core.Parser[T] noraise {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Failure(err) => @core.Failure(err)
      @core.Success(value, st) =>
        if pred(value) {
          @core.Success(value, st)
        } else {
          @core.Failure(@core.ParseError::at(pos=state.pos, expected=label))
        }
    }
  })
}

///| 验证解析结果 — 对 `p` 的结果应用 `f`。

///| 若 `f` 返回 `Ok(v)`，成功返回 `v`；

///| 若 `f` 返回 `Err(msg)`，在当前位置产生未承诺的错误。

///|

///| Validate a parser's result — apply `f` to `p`'s output.

///| If `f` returns `Ok(v)`, succeed with `v`;

///|
/// if `f` returns `Err(msg)`, produce an uncommitted error.
pub fn[T, U] validate(
  p : @core.Parser[T],
  f : (T) -> Result[U, String],
  label~ : String = "validate",
) -> @core.Parser[U] noraise {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Failure(err) => @core.Failure(err)
      @core.Success(value, st) =>
        match f(value) {
          Ok(v) => @core.Success(v, st)
          Err(_) =>
            @core.Failure(@core.ParseError::at(pos=st.pos, expected=label))
        }
    }
  })
}

///| 左结合链式解析 — 解析至少一个 `p`，其间用 `op` 连接。

///| `op` 返回一个将左侧值合并为新值的函数。

///|

///| 典型用法：解析 `1 + 2 + 3` 为 `((1 + 2) + 3)`。

///|

///| Left-associative chain — parse at least one `p`, joined by `op`.

///| `op` returns a function that merges the left value into a new value.

///|

///|
/// Typical use: parse `1 + 2 + 3` as `((1 + 2) + 3)`.
pub fn[T] chainl1(
  p : @core.Parser[T],
  op : @core.Parser[(T, T) -> T],
) -> @core.Parser[T] noraise {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Failure(err) => @core.Failure(err)
      @core.Success(first, st1) => chainl1_step(p, op, first, st1)
    }
  })
}

///|
fn[T] chainl1_step(
  p : @core.Parser[T],
  op : @core.Parser[(T, T) -> T],
  acc : T,
  state : @core.State,
) -> @core.ParseResult[T] {
  match (op.run)(state) {
    @core.Failure(_) => @core.Success(acc, state)
    @core.Success(f, st2) =>
      match (p.run)(st2) {
        @core.Failure(err) => @core.Failure(err.commit())
        @core.Success(rhs, st3) => chainl1_step(p, op, f(acc, rhs), st3)
      }
  }
}

///| 右结合链式解析 — 解析至少一个 `p`，其间用 `op` 连接。

///| `op` 返回一个将左右值合并为新值的函数。

///|

///| 典型用法：解析 `1 ^ 2 ^ 3` 为 `(1 ^ (2 ^ 3))`。

///|

///| Right-associative chain — parse at least one `p`, joined by `op`.

///| `op` returns a function that merges left and right values.

///|

///|
/// Typical use: parse `1 ^ 2 ^ 3` as `(1 ^ (2 ^ 3))`.
pub fn[T] chainr1(
  p : @core.Parser[T],
  op : @core.Parser[(T, T) -> T],
) -> @core.Parser[T] noraise {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Failure(err) => @core.Failure(err)
      @core.Success(first, st1) => chainr1_rest(p, op, first, st1)
    }
  })
}

///|
fn[T] chainr1_rest(
  p : @core.Parser[T],
  op : @core.Parser[(T, T) -> T],
  left : T,
  state : @core.State,
) -> @core.ParseResult[T] {
  match (op.run)(state) {
    @core.Failure(_) => @core.Success(left, state)
    @core.Success(f, st2) =>
      match (p.run)(st2) {
        @core.Failure(err) => @core.Failure(err.commit())
        @core.Success(right, st3) =>
          match chainr1_rest(p, op, right, st3) {
            @core.Failure(err2) => @core.Failure(err2)
            @core.Success(merged, st4) => @core.Success(f(left, merged), st4)
          }
      }
  }
}

///| 有界重复 — 解析 `p` 至少 `min` 次、至多 `max` 次。

///| 若少于 `min` 次则失败；到达 `max` 次后停止。

///|

///| Bounded repetition — parse `p` between `min` and `max` times.

///|
/// Fails if fewer than `min` matches; stops after `max` matches.
pub fn[T] count_min_max(
  min~ : Int32,
  max~ : Int32,
  p : @core.Parser[T],
) -> @core.Parser[Array[T]] noraise {
  @core.Parser::of(fn(state) { count_min_max_step(p, min, max, [], state) })
}

///|
fn[T] count_min_max_step(
  p : @core.Parser[T],
  remaining : Int32,
  max_remaining : Int32,
  acc : Array[T],
  state : @core.State,
) -> @core.ParseResult[Array[T]] {
  if max_remaining <= 0 {
    @core.Success(acc, state)
  } else {
    match (p.run)(state) {
      @core.Success(value, st) => {
        acc.push(value)
        count_min_max_step(p, remaining - 1, max_remaining - 1, acc, st)
      }
      @core.Failure(err) =>
        if remaining <= 0 {
          @core.Success(acc, state)
        } else {
          @core.Failure(err)
        }
    }
  }
}

///| 分隔解析（允许尾部分隔符）— 零次或多次 `p` 用 `sep` 分隔，

///| 可选地以 `sep` 结尾。

///|

///| Separated parse with optional trailing separator — zero or more `p`

///|
/// separated by `sep`, optionally ending with `sep`.
pub fn[T, S] sep_end_by(
  p : @core.Parser[T],
  sep : @core.Parser[S],
) -> @core.Parser[Array[T]] noraise {
  @core.Parser::of(fn(state) {
    match (sep_end_by1(p, sep).run)(state) {
      @core.Success(v, st) => @core.Success(v, st)
      @core.Failure(_) => @core.Success([], state)
    }
  })
}

///| 分隔解析（允许尾部分隔符，至少一个）— 一次或多次 `p` 用 `sep` 分隔，

///| 可选地以 `sep` 结尾。

///|

///| Separated parse with optional trailing separator (at least one) —

///|
/// one or more `p` separated by `sep`, optionally ending with `sep`.
pub fn[T, S] sep_end_by1(
  p : @core.Parser[T],
  sep : @core.Parser[S],
) -> @core.Parser[Array[T]] noraise {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Failure(err) => @core.Failure(err)
      @core.Success(first, st1) => {
        let acc : Array[T] = [first]
        sep_end_by1_step(p, sep, acc, st1)
      }
    }
  })
}

///|
fn[T, S] sep_end_by1_step(
  p : @core.Parser[T],
  sep : @core.Parser[S],
  acc : Array[T],
  state : @core.State,
) -> @core.ParseResult[Array[T]] {
  match (sep.run)(state) {
    @core.Failure(_) => @core.Success(acc, state)
    @core.Success(_, st_after_sep) =>
      match (p.run)(st_after_sep) {
        @core.Success(next, st2) => {
          acc.push(next)
          sep_end_by1_step(p, sep, acc, st2)
        }
        @core.Failure(_) => @core.Success(acc, st_after_sep)
      }
  }
}
