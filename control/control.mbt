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
pub fn[T] commit(p : @core.Parser[T]) -> @core.Parser[T] {
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
pub fn[T] alt(p1 : @core.Parser[T], p2 : @core.Parser[T]) -> @core.Parser[T] {
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

///| 用自定义标签替换解析器的错误信息。

///|

///| 当 `p` 失败时，`label(p, name)` 将 `expected` 替换为 `[name]`。

///| `committed` 标志保持不变 — 标记不影响回溯。

///|

///| Replace a parser's error message with a custom label.

///|
/// The `committed` flag is preserved — labeling does not affect backtracking.
pub fn[T] label(p : @core.Parser[T], name : String) -> @core.Parser[T] {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Success(value, st) => @core.Success(value, st)
      @core.Failure(err) =>
        @core.Failure(
          @core.ParseError(err.pos(), [name], err.committed(), err.context()),
        )
    }
  })
}
