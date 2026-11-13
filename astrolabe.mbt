///| 根包门面 — 从子包重新导出所有公共 API。

///|

///| Root package facade — re-exports from subpackages.

///|

///| 外部用户通过 `@astrolabe.xxx` 访问所有 API：

///| External users access all API through `@astrolabe.xxx`:

///|

///|   @astrolabe.char('a')

///|   @astrolabe.Parser::parse(p, input)

///|   @astrolabe.map(p, f)

///|

///| 内部类型在 `@core`，组合子在 `@basic` / `@compose` / `@control`。

///| Internally, types live in `@core` and combinators in `@basic` / `@compose`

///| / `@control`.  This file re-exports them as thin wrappers so the public

///| API surface is flat and convenient.

/// ============================================================================
/// 便捷入口 / Convenience entry points
/// ============================================================================

///| 用 `p` 解析 `input`，允许尾部有未消费的输入。

///|

///|
/// Parse `input` with `p`, allowing trailing unconsumed input.
#warnings("-result_error_return")
pub fn[T] parse(
  p : @core.Parser[T],
  input : String,
) -> Result[T, @core.ParseError] {
  p.parse(input)
}

///| 用 `p` 解析 `input`，要求整个输入被消费完毕。

///|

///|
/// Parse `input` with `p`, requiring entire input consumed.
#warnings("-result_error_return")
pub fn[T] parse_full(
  p : @core.Parser[T],
  input : String,
) -> Result[T, @core.ParseError] {
  p.parse_full(input)
}

///| 用 `p` 解析 `input`，允许尾部未消耗的输入，失败时 `raise ParseError`。

///|

///|
/// Parse `input` with `p`, raising `ParseError` on failure, allowing trailing input.
pub fn[T] parse_raise(
  p : @core.Parser[T],
  input : String,
) -> T raise @core.ParseError {
  p.parse_raise(input)
}

///| 用 `p` 解析 `input`，要求全部输入被消耗，失败时 `raise ParseError`。

///|

///|
/// Parse `input` with `p`, raising `ParseError` on failure, requiring full consumption.
pub fn[T] parse_full_raise(
  p : @core.Parser[T],
  input : String,
) -> T raise @core.ParseError {
  p.parse_full_raise(input)
}

///| 将 `ParseError` 格式化为人类可读字符串。

///|

///|
/// Format a `ParseError` as a human-readable string.
#inline
pub fn format_error(err : @core.ParseError) -> String noraise {
  err.format()
}

///| 将 `ParseError` 格式化，并附带原始输入的上下文片段。

///|

///|
/// Format a `ParseError` with a context snippet from the original input.
pub fn format_error_with_input(
  err : @core.ParseError,
  input : String,
) -> String noraise {
  err.format_with_input(input)
}

/// ============================================================================
/// 基础组合子（从 @basic 重新导出）/ Basic combinators (re-export from @basic)
/// ============================================================================

///| 匹配单个指定字符。

///|

///|
/// Match a single specific character.
#inline
pub fn char(expected : Char) -> @core.Parser[Char] noraise {
  @basic.char(expected)
}

///| 匹配精确的字符串字面量。

///|

///|
/// Match an exact string literal.
#inline
pub fn string(expected : String) -> @core.Parser[String] noraise {
  @basic.string(expected)
}

///| 匹配任意单个字符。

///|

///|
/// Match any single character.
#inline
pub fn any_char() -> @core.Parser[Char] noraise {
  @basic.any_char()
}

///| 从输入中消费恰好 `n` 个字符。

///|

///|
/// Consume exactly `n` characters from the input.
#inline
pub fn take(n : Int32) -> @core.Parser[String] noraise {
  @basic.take(n)
}

///| 匹配满足谓词的单个字符。

///|

///|
/// Match a single character that satisfies a predicate.
pub fn satisfy(
  pred : (Char) -> Bool,
  label~ : String = "satisfy",
) -> @core.Parser[Char] {
  @basic.satisfy(pred, label~)
}

///| 仅在输入末尾时成功。

///|

///|
/// Succeed only at the end of input.
#inline
pub fn end_of_input() -> @core.Parser[Unit] noraise {
  @basic.end_of_input()
}

///| 前瞻：运行 `p` 但不消费输入。

///|

///|
/// Look ahead without consuming input.
pub fn[T] peek(p : @core.Parser[T]) -> @core.Parser[T] noraise {
  @basic.peek(p)
}

///| 运行 `p` 并丢弃结果，但消费输入。

///|

///|
/// Run `p` and discard its result, but consume the input.
pub fn[T] skip(p : @core.Parser[T]) -> @core.Parser[Unit] noraise {
  @basic.skip(p)
}

///| 匹配闭区间 [lo, hi] 内的单个字符。

///|

///|
/// Parse a single character in the inclusive range [lo, hi].
#inline
pub fn char_range(lo : Char, hi : Char) -> @core.Parser[Char] noraise {
  @basic.char_range(lo, hi)
}

///| 匹配满足谓词函数的单个字符。

///|

///|
/// Parse a single character matching a predicate function.
#inline
pub fn char_class(pred : (Char) -> Bool, label_ : String) -> @core.Parser[Char] {
  @basic.char_class(pred, label_)
}

///| 消费满足谓词的连续字符，返回拼接字符串。

///|

///|
/// Consume consecutive characters satisfying `pred`, returning the matched string.
#inline
pub fn take_while(pred : (Char) -> Bool) -> @core.Parser[String] {
  @basic.take_while(pred)
}

///| 消费满足谓词的连续字符（至少一个）。

///|

///|
/// Consume consecutive characters satisfying `pred` (at least one).
pub fn take_while1(
  pred : (Char) -> Bool,
  label~ : String = "take_while1",
) -> @core.Parser[String] {
  @basic.take_while1(pred, label~)
}

/// ============================================================================
/// 组合组合子（从 @compose 重新导出）/ Compose combinators (re-export from @compose)
/// ============================================================================

///| 用纯函数变换解析器结果。

///|

///|
/// Transform the result of a parser with a pure function.
pub fn[T, U] map(p : @core.Parser[T], f : (T) -> U) -> @core.Parser[U] {
  @compose.map(p, f)
}

///| 顺序组合两个解析器，第二个依赖第一个的结果。

///|

///|
/// Sequence two parsers where the second depends on the first's result.
pub fn[T, U] bind(
  p : @core.Parser[T],
  f : (T) -> @core.Parser[U],
) -> @core.Parser[U] {
  @compose.bind(p, f)
}

///| 总是成功且不消费输入的解析器。

///|

///|
/// A parser that always succeeds without consuming input.
#alias(return_, deprecated="Use pure instead")
pub fn[T] pure(value : T) -> @core.Parser[T] noraise {
  @compose.pure(value)
}

///| 顺序组合两个独立解析器，收集两者结果。

///|

///|
/// Sequence two independent parsers and collect both results.
pub fn[A, B] seq2(
  p1 : @core.Parser[A],
  p2 : @core.Parser[B],
) -> @core.Parser[(A, B)] noraise {
  @compose.seq2(p1, p2)
}

///| 顺序组合三个独立解析器，收集全部结果。

///|

///|
/// Sequence three independent parsers and collect all results.
pub fn[A, B, C] seq3(
  p1 : @core.Parser[A],
  p2 : @core.Parser[B],
  p3 : @core.Parser[C],
) -> @core.Parser[(A, B, C)] noraise {
  @compose.seq3(p1, p2, p3)
}

///| 顺序组合四个独立解析器，收集全部结果。

///|

///|
/// Sequence four independent parsers and collect all results.
pub fn[A, B, C, D] seq4(
  p1 : @core.Parser[A],
  p2 : @core.Parser[B],
  p3 : @core.Parser[C],
  p4 : @core.Parser[D],
) -> @core.Parser[(A, B, C, D)] noraise {
  @compose.seq4(p1, p2, p3, p4)
}

///| 匹配 `p` 零次或多次，结果收集为数组。

///|

///|
/// Match `p` zero or more times, collecting results into an array.
#inline
pub fn[T] many(p : @core.Parser[T]) -> @core.Parser[Array[T]] {
  @compose.many(p)
}

///| 匹配 `p` 一次或多次，结果收集为数组。

///|

///|
/// Match `p` one or more times, collecting results into an array.
#inline
pub fn[T] many1(p : @core.Parser[T]) -> @core.Parser[Array[T]] {
  @compose.many1(p)
}

///| 匹配 `p` 零次或多次，以 `sep` 分隔。

///|

///|
/// Match `p` zero or more times, separated by `sep`.
pub fn[T, S] sep_by(
  p : @core.Parser[T],
  sep : @core.Parser[S],
) -> @core.Parser[Array[T]] {
  @compose.sep_by(p, sep)
}

///| 匹配 `p` 一次或多次，以 `sep` 分隔。

///|

///|
/// Match `p` one or more times, separated by `sep`.
pub fn[T, S] sep_by1(
  p : @core.Parser[T],
  sep : @core.Parser[S],
) -> @core.Parser[Array[T]] {
  @compose.sep_by1(p, sep)
}

///| 匹配 `p` 恰好 `n` 次，结果收集为数组。

///|

///|
/// Match `p` exactly `n` times, collecting results into an array.
#inline
pub fn[T] count(n : Int32, p : @core.Parser[T]) -> @core.Parser[Array[T]] {
  @compose.count(n, p)
}

///| 匹配 `p` 零次或多次，直到 `end_` 成功。

///|

///|
/// Match `p` zero or more times until `end_` succeeds.
pub fn[T, E] many_till(
  p : @core.Parser[T],
  end_ : @core.Parser[E],
) -> @core.Parser[Array[T]] {
  @compose.many_till(p, end_)
}

///| 尝试 `p`，未承诺失败时返回 `default`。

///|

///|
/// Try `p`; on uncommitted failure, return `default`.
pub fn[T] option(p : @core.Parser[T], default : T) -> @core.Parser[T] noraise {
  @compose.option(p, default)
}

///| 零次或多次运行 `p`，丢弃结果。

///|

///|
/// Run `p` zero or more times, discarding results.
#inline
pub fn[T] skip_many(p : @core.Parser[T]) -> @core.Parser[Unit] noraise {
  @compose.skip_many(p)
}

///| 一次或多次运行 `p`，丢弃结果。

///|

///|
/// Run `p` one or more times, discarding results.
#inline
pub fn[T] skip_many1(p : @core.Parser[T]) -> @core.Parser[Unit] noraise {
  @compose.skip_many1(p)
}

///| 匹配 `open` + `p` + `close`，只返回 `p` 的结果。

///|

///|
/// Match `open` + `p` + `close`, returning only `p`'s result.
pub fn[O, T, C] between(
  open : @core.Parser[O],
  p : @core.Parser[T],
  close : @core.Parser[C],
) -> @core.Parser[T] noraise {
  @compose.between(open, p, close)
}

/// ============================================================================
/// 控制组合子（从 @control 重新导出）/ Control combinators (re-export from @control)
/// ============================================================================

///| 将解析器失败标记为已提交（不可回溯）。

///|

///|
/// Mark a parser's failure as committed.
#inline
pub fn[T] commit(p : @core.Parser[T]) -> @core.Parser[T] noraise {
  @control.commit(p)
}

///| 有序选择：先尝试 `p1`，未提交失败时回退到 `p2`。

///|

///|
/// Ordered choice: try `p1`, fall back to `p2` on uncommitted failure.
pub fn[T] alt(
  p1 : @core.Parser[T],
  p2 : @core.Parser[T],
) -> @core.Parser[T] noraise {
  @control.alt(p1, p2)
}

///| N 路有序选择，从解析器数组中依次尝试。

///|

///|
/// N-way ordered choice over an array of parsers.
#inline
pub fn[T] choice(parsers : Array[@core.Parser[T]]) -> @core.Parser[T] noraise {
  @control.choice(parsers)
}

///| 用自定义标签替换解析器的错误消息。

///|

///|
/// Replace a parser's error message with a custom label.
#inline
pub fn[T] label(p : @core.Parser[T], name : String) -> @core.Parser[T] noraise {
  @control.label(p, name)
}

///| 仅当 `p` 失败时成功；不消耗输入。

///|

///|
/// Succeed only when `p` fails; does not consume input.
pub fn[T] not_followed_by(
  p : @core.Parser[T],
  label~ : String = "not_followed_by",
) -> @core.Parser[Unit] noraise {
  @control.not_followed_by(p, label~)
}

///| 不动点组合子 — 支持递归文法。

///|

///|
/// Fixpoint combinator for recursive grammars.
pub fn[T] fix(f : (@core.Parser[T]) -> @core.Parser[T]) -> @core.Parser[T] {
  @control.fix(f)
}

///| 为解析器的错误追加上下文标签，形成错误链。

///|

///|
/// Append a context label to the parser's error chain.
pub fn[T] with_context(
  p : @core.Parser[T],
  ctx : String,
) -> @core.Parser[T] noraise {
  @control.with_context(p, ctx)
}

///| 用函数 `f` 变换解析器的错误。

///|

///|
/// Transform the parser's error with function `f`.
pub fn[T] map_error(
  p : @core.Parser[T],
  f : (@core.ParseError) -> @core.ParseError,
) -> @core.Parser[T] {
  @control.map_error(p, f)
}

///| 错误恢复 — 当 `p` 失败时用 `fallback` 重新尝试。

///| 与 `alt` 不同：即使已承诺失败也会尝试恢复。

///|

///| Error recovery — when `p` fails, try `fallback`.

///|
/// Unlike `alt`: attempts recovery even on committed failure.
pub fn[T] recover(
  p : @core.Parser[T],
  fallback : (@core.ParseError) -> @core.Parser[T],
) -> @core.Parser[T] {
  @control.recover(p, fallback)
}
