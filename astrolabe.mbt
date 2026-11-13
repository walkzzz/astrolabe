///| 根包门面 — 通过 `pub using` 从子包重导出所有公共 API。

///|

///| Root package facade — re-exports all public API from subpackages via `pub using`.

///|

///| 外部用户通过 `@astrolabe.xxx` 访问所有 API：

///| External users access all API through `@astrolabe.xxx`:

///|

///|   @astrolabe.char('a')

///|   @astrolabe.map(p, f)

///|   @astrolabe.Parser::parse(p, input)

///|

///| 核心类型在 `@core`，字符原语在 `@char`，顺序/重复在 `@sequence`，

///| 分支/回溯在 `@branch`。本文件通过 `pub using` 扁平化公共 API。

///|

///| Core types live in `@core`, character primitives in `@char`,

///| sequencing/repetition in `@sequence`, branching/backtracking in `@branch`.

///| This file flattens the public API via `pub using`.

// ============================================================================
// 从 @core 重导出核心类型 / Re-export core types from @core
// ============================================================================

///| 解析错误类型（位置感知 + 上下文链 + 提交标记）

///|
/// Parse error type (position-aware + context chain + committed flag)
pub using @core {
  type ParseError,
  type ParseHint,
  type ParseResult,
  type Parser,
  type Pos,
  type State,
}

// ============================================================================
// 从 @char 重导出字符原语 / Re-export character primitives from @char
// ============================================================================

///|
pub using @char {
  char,
  string,
  any_char,
  take,
  satisfy,
  end_of_input,
  peek,
  skip,
  char_range,
  char_class,
  take_while,
  take_while1,
}

// ============================================================================
// 从 @sequence 重导出顺序/重复组合子 / Re-export sequencing/repetition from @sequence
// ============================================================================

///|
pub using @sequence {
  map,
  bind,
  pure,
  seq2,
  seq3,
  seq4,
  many,
  many1,
  sep_by,
  sep_by1,
  count,
  many_till,
  option,
  skip_many,
  skip_many1,
  between,
  filter,
  validate,
  chainl1,
  chainr1,
  count_min_max,
  sep_end_by,
  sep_end_by1,
}

// ============================================================================
// 从 @branch 重导出分支/回溯组合子 / Re-export branching/backtracking from @branch
// ============================================================================

///|
pub using @branch {
  commit,
  alt,
  choice,
  label,
  not_followed_by,
  fix,
  with_context,
  map_error,
  recover,
  reject,
  succeed,
  attempt,
  with_hint,
}

// ============================================================================
// 从 @core 重导出 ParserLike 通用组合子 / Re-export ParserLike generic combinators
// ============================================================================

///| 通用组合子作用于任何实现 `@core.ParserLike` 的类型：

///| 第三方类型实现 `run_like(self, state)` 后即可直接使用。

///|

///| Generic combinators work over any type implementing `@core.ParserLike`:

///| third-party types become usable after implementing `run_like(self, state)`.

///|

///| The `ParserLike` trait itself is re-exported as `@core.ParserLike`.

///|

///| 示例见 `examples/ext`（Traced[T] 带调用日志的包装解析器）：

///| See `examples/ext` for a worked example (Traced[T], a logging wrapper):

///|

///|   let t = @ext.Traced::new(@astrolabe.char('a'))

///|   let p = @astrolabe.pmap(t, fn(c) { c.to_string() })

pub using @core {
  pmap,
  pbind,
  palt,
  poption,
}

// ============================================================================
// 便捷入口 / Convenience entry points
// ============================================================================

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
