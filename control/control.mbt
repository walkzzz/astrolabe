///| 将解析器的失败标记为已承诺，阻止 `alt` 回溯。

///|

///| 当 `p` 成功时，`commit(p)` 原样传递结果。

///| 当 `p` 失败时，`commit(p)` 将错误的 `committed` 设为 `true`，

///| 告诉 `alt` **不要**尝试下一个备选。

///|

///| Mark a parser's failure as committed, preventing `alt` backtracking.

///| When `p` succeeds, `commit(p)` passes through the result unchanged.

///|
/// When `p` fails, sets `committed = true` so `alt` will not try the next alternative.
pub fn[T] commit(p : @core.Parser[T]) -> @core.Parser[T] noraise {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Success(value, st) => @core.Success(value, st)
      @core.Failure(err) => @core.Failure(err.commit())
    }
  })
}

///| 有序选择 — 在未承诺失败时尝试 `p2`。

///|

///| - 若 `p1` 成功，返回其结果

///| - 若 `p1` 失败且 `committed = true`，返回该错误（不回溯）

///| - 若 `p1` 失败且 `committed = false`，在原始输入上尝试 `p2`

///|

///| Ordered choice: try `p1`, fall back to `p2` on uncommitted failure.

///| - If `p1` succeeds, return its result.

///| - If `p1` fails with `committed = true`, no backtrack.

///|
/// - If `p1` fails with `committed = false`, try `p2` on the original input.
pub fn[T] alt(
  p1 : @core.Parser[T],
  p2 : @core.Parser[T],
) -> @core.Parser[T] noraise {
  @core.Parser::of(fn(state) {
    match (p1.run)(state) {
      @core.Success(value, st) => @core.Success(value, st)
      @core.Failure(err) =>
        if err.committed() {
          @core.Failure(err)
        } else {
          (p2.run)(state)
        }
    }
  })
}

///| N 路有序选择。

///|

///| 等价于左结合的 `alt`：`parsers[0] | parsers[1] | ...`。

///| 若 `parsers` 为空，返回一个总是失败的解析器。

///|

///| N-way ordered choice over an array of parsers.

///| Equivalent to left-associative `alt`.

///|
/// If `parsers` is empty, returns a parser that always fails.
pub fn[T] choice(parsers : Array[@core.Parser[T]]) -> @core.Parser[T] noraise {
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

///| 用自定义标签替换解析器的错误信息。

///|

///| 当 `p` 失败时，`label(p, name)` 将 `expected` 替换为 `[name]`。

///| `committed` 标志保持不变 — 标记不影响回溯。

///|

///| Replace a parser's error message with a custom label.

///|
/// The `committed` flag is preserved — labeling does not affect backtracking.
pub fn[T] label(p : @core.Parser[T], name : String) -> @core.Parser[T] noraise {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Success(value, st) => @core.Success(value, st)
      @core.Failure(err) =>
        @core.Failure(
          @core.ParseError(err.pos(), [name], err.committed(), err.contexts()),
        )
    }
  })
}

///| 仅当 `p` 失败时成功；不消耗输入。

///|

///|
/// Succeed only when `p` fails; does not consume input.
pub fn[T] not_followed_by(
  p : @core.Parser[T],
  label~ : String = "not_followed_by",
) -> @core.Parser[Unit] noraise {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Failure(_) => @core.Success((), state)
      @core.Success(_, _) =>
        @core.Failure(@core.ParseError::at(pos=state.pos, expected=label))
    }
  })
}

///| 不动点组合子 — 支持递归文法。

///| 传入函数 `f` 接收自身的引用，返回递归解析器。

///|

///| Fixpoint combinator for recursive grammars.

///|
/// `f` receives a reference to the resulting parser, enabling recursion.
pub fn[T] fix(f : (@core.Parser[T]) -> @core.Parser[T]) -> @core.Parser[T] {
  let cell : Array[@core.Parser[T]] = []
  let self_parser = @core.Parser::of(fn(state) { (cell[0].run)(state) })
  let result = f(self_parser)
  cell.push(result)
  result
}

///| 为解析器的错误追加上下文标签，形成错误链。

///| 不改变 `expected` 和 `committed`，仅在 `contexts` 末尾追加 `ctx`。

///|

///| Append a context label to the parser's error chain.

///|
/// Does not change `expected` or `committed`; only appends `ctx` to `contexts`.
pub fn[T] with_context(
  p : @core.Parser[T],
  ctx : String,
) -> @core.Parser[T] noraise {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Success(value, st) => @core.Success(value, st)
      @core.Failure(err) => @core.Failure(err.with_context(ctx))
    }
  })
}

///| 用函数 `f` 变换解析器的错误。

///| `committed` 标志保持不变 — `f` 可修改 `pos`/`expected`/`contexts`。

///|

///| Transform the parser's error with function `f`.

///|
/// The `committed` flag is preserved; `f` may modify `pos`/`expected`/`contexts`.
pub fn[T] map_error(
  p : @core.Parser[T],
  f : (@core.ParseError) -> @core.ParseError,
) -> @core.Parser[T] {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Success(value, st) => @core.Success(value, st)
      @core.Failure(err) => @core.Failure(f(err))
    }
  })
}

///| 错误恢复 — 当 `p` 失败时，用 `fallback` 在原始状态上重新尝试。

///| 与 `alt` 不同：`recover` 在**已承诺**失败时也会尝试恢复。

///| 适用于需要从不可回溯错误中恢复的场景（如错误恢复解析器）。

///|

///| Error recovery — when `p` fails, try `fallback` on the original state.

///| Unlike `alt`: `recover` attempts recovery even on **committed** failure.

///|
/// Useful for error-recovery parsers that must continue past committed failures.
pub fn[T] recover(
  p : @core.Parser[T],
  fallback : (@core.ParseError) -> @core.Parser[T],
) -> @core.Parser[T] {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Success(value, st) => @core.Success(value, st)
      @core.Failure(err) => (fallback(err).run)(state)
    }
  })
}
