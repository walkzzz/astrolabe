///| 源码位置 — 解析过程中追踪的位置信息。

///|

///| 同时追踪行号、列号和字节偏移，使错误信息可以指向精确的可读位置，

///| 同时偏移量支持对输入字符串的 O(1) 切片。

///|

///| Source position tracked during parsing.

///| Tracks line, column, and byte-offset simultaneously so error messages

///| can point to an exact human-readable location while offset enables

///| O(1) slicing into the input string.

///|

///| - `line` — 1 起始的行号，遇到 `'\n'` 递增

///| - `column` — 1 起始的列号，遇到 `'\n'` 重置为 1

///|
/// - `offset` — 0 起始的字节偏移
#derive(Eq, Debug)
pub(all) struct Pos {
  mut line : Int32
  mut column : Int32
  mut offset : Int32
}

///|
pub extend Pos with Eq::{not_equal, equal}

///|
pub extend Pos with @debug.Debug::{to_repr}

///| 创建初始位置（行 1，列 1，偏移 0）。

///|

///|
/// Create the initial position (line 1, column 1, offset 0).
pub fn Pos::initial() -> Pos noraise {
  { line: 1, column: 1, offset: 0, }
}

///| 将位置前进一个字符。

///|

///| - 若 `ch` 为 `'\n'`，行号递增、列号重置为 1

///| - 否则列号递增 1

///| - 偏移量始终递增 1

///|

///| 返回一个**新的** Pos，原对象不被修改。

///|

///| Advance the position by one character.

///|
/// Returns a **new** Pos; the original is not mutated.
pub fn Pos::advance(self : Pos, ch : Char) -> Pos noraise {
  if ch == '\n' {
    { line: self.line + 1, column: 1, offset: self.offset + 1, }
  } else {
    { line: self.line, column: self.column + 1, offset: self.offset + 1, }
  }
}

///| 可变解析状态 — 包装输入字符串和游标。

///|

///| 每个 `Parser.run` 接收一个 `State`，可以修改它（推进游标），

///| 并返回携带（可能已前进的）状态的 `ParseResult`。

///|

///| Mutable parsing state that wraps the input string and a cursor.

///| Each `Parser.run` receives a `State`, may mutate it (advance the cursor),

///| and returns a `ParseResult` carrying the (possibly advanced) state forward.

///|

///| - `input` — 完整输入字符串，构造后不可变

///| - `offset` — 当前读取位置（字节偏移）

///|
/// - `pos` — 当前可读位置（行、列、偏移）
#derive(Debug)
pub(all) struct State {
  input : String
  mut offset : Int32
  mut pos : Pos
}

///|
pub extend State with @debug.Debug::{to_repr}

///| 创建一个位于 `input` 起始位置的新 `State`。

///|

///|
/// Create a fresh `State` positioned at the start of `input`.
pub fn State::new(input : String) -> State noraise {
  { input, offset: 0, pos: Pos::initial(), }
}

///| 从当前偏移到输入末尾的剩余字符数。

///|

///|
/// Number of characters remaining from the current offset to end-of-input.
pub fn State::remaining(self : State) -> Int32 noraise {
  self.input.length() - self.offset
}

///| 游标是否已到达或越过输入末尾。

///|

///|
/// True when the cursor has reached or passed the end of input.
pub fn State::is_eof(self : State) -> Bool noraise {
  self.offset >= self.input.length()
}

///| 查看游标下方的字符，不推进游标。

///|

///| 未到 EOF 返回 `Some(ch)`，否则返回 `None`。

///|

///| Peek at the character under the cursor without advancing.

///|
/// Returns `Some(ch)` if not at EOF, `None` otherwise.
pub fn State::peek(self : State) -> Char? noraise {
  if self.is_eof() {
    None
  } else {
    self.input.get_char(self.offset)
  }
}

///| 将游标前进一个字符，更新位置追踪。

///|

///| 已在 EOF 时无操作。

///|

///| Advance the cursor by exactly one character, updating position tracking.

///|
/// No-op when already at EOF.
pub fn State::advance_one(self : State) -> Unit noraise {
  if !self.is_eof() {
    let ch = self.input.get_char(self.offset).unwrap()
    self.pos = self.pos.advance(ch)
    self.offset = self.offset + 1
  }
}

///| 将游标前进 `n` 个字符，更新位置追踪。

///|

///| 等价于调用 `advance_one` `n` 次。

///| 调用者必须确保 `n <= remaining()`。

///|

///| Advance the cursor by `n` characters, updating position tracking.

///| Equivalent to calling `advance_one` `n` times.

///|
/// Caller must ensure `n <= remaining()`.
pub fn State::advance_by(self : State, n : Int32) -> Unit noraise {
  for _ in 0..<n {
    self.advance_one()
  }
}

///| 从字节偏移 `[start, end)` 提取子字符串。

///|

///| 不修改游标。内部用于先读取匹配的输入再按已知长度前进。

///|

///| Extract a substring of `input` from byte offset `[start, end)`.

///|
/// Does not modify the cursor. Used internally to read matched input.
pub fn State::slice(self : State, start : Int32, end : Int32) -> String noraise {
  self.input[start:end].to_owned()
}

///| 解析错误 — 携带位置、期望词元和承诺状态。

///|

///| `committed` 标志实现了 Angstrom 的承诺语义：

///|

///| - `committed = false` — 解析器未消耗有效输入，`alt` 可尝试下一个备选（允许回溯）

///| - `committed = true` — 解析器已消耗有效输入，`alt` **不会**尝试下一个备选（禁止回溯）

///|

///| 承诺由以下方式设定：

///| - `commit(p)` — 显式将 `p` 的失败标记为已承诺

///| - `bind` / `seq2` / `seq3` / `seq4` — 若第二个解析器失败，错误被承诺（"序列承诺"）

///|

///| A parse error carrying position, expected tokens, and commitment status.

///| The `committed` flag implements Angstrom's commitment semantics:

///| - `committed = false` — backtracking is allowed in `alt`

///|
/// - `committed = true` — backtracking is suppressed in `alt`
#derive(Debug, Eq)
pub(all) suberror ParseError {
  ParseError(Pos, Array[String], Bool, Array[String])
}

///|
pub extend ParseError with Eq::{not_equal, equal}

///|
pub extend ParseError with @debug.Debug::{to_repr}

///| 在 `pos` 处构造一个未承诺的错误，期望 `expected`。

///|

///| 便捷工厂：单个期望词元、无上下文、未承诺。

///|

///| Construct an uncommitted error at `pos` expecting `expected`.

///|
/// Convenience factory for the common case: single expected token, no context, uncommitted.
pub fn ParseError::at(pos~ : Pos, expected~ : String) -> ParseError noraise {
  ParseError(pos, [expected], false, [])
}

///| 返回错误的位置信息。

///|

///|
/// Return the position where the error occurred.
pub fn ParseError::pos(self : ParseError) -> Pos noraise {
  match self {
    ParseError(pos, _, _, _) => pos
  }
}

///| 返回期望的词元列表。

///|

///|
/// Return the list of expected tokens.
pub fn ParseError::expected(self : ParseError) -> Array[String] noraise {
  match self {
    ParseError(_, expected, _, _) => expected
  }
}

///| 返回承诺状态。

///|

///|
/// Return the commitment status.
pub fn ParseError::committed(self : ParseError) -> Bool noraise {
  match self {
    ParseError(_, _, committed, _) => committed
  }
}

///| 返回上下文链。

///|

///|
/// Return the context chain.
pub fn ParseError::contexts(self : ParseError) -> Array[String] noraise {
  match self {
    ParseError(_, _, _, contexts) => contexts
  }
}

///| 返回上下文标签（已拼接）。

///|

///|
/// Return the context label (joined with " > ").
pub fn ParseError::context(self : ParseError) -> String noraise {
  match self {
    ParseError(_, _, _, contexts) => contexts.join(" > ")
  }
}

///| 返回 `committed = true` 的副本，用于序列承诺语义。

///|

///|
/// Return a copy with `committed = true`, used for sequence-commit semantics.
#inline
pub fn ParseError::commit(self : ParseError) -> ParseError noraise {
  match self {
    ParseError(pos, expected, _, contexts) =>
      ParseError(pos, expected, true, contexts)
  }
}

///| 返回追加了上下文标签的副本，用于错误链追踪。

///|

///|
/// Return a copy with `ctx` appended to the context chain.
pub fn ParseError::with_context(
  self : ParseError,
  ctx : String,
) -> ParseError noraise {
  match self {
    ParseError(pos, expected, committed, contexts) => {
      let new_contexts = contexts.copy()
      new_contexts.push(ctx)
      ParseError(pos, expected, committed, new_contexts)
    }
  }
}

///| 将错误格式化为人类可读的字符串。

///|

///| 输出格式：

///| ```text

///| line L, column C (offset O):

///| expected X or Y

///|   context-label

///| ```

///|

///| 多个 `expected` 条目用 `" or "` 连接。`context` 为空时省略。

///|

///| Format this error as a human-readable string.

///| Multiple `expected` entries are joined with `" or "`.

///|
/// The `context` line is omitted when empty.
pub fn ParseError::format(self : ParseError) -> String noraise {
  match self {
    ParseError(pos, expected, _, contexts) => {
      let loc = "line \{pos.line}, column \{pos.column} (offset \{pos.offset})"
      let exp = expected.join(" or ")
      let ctx = if contexts.length() == 0 {
        ""
      } else {
        "\n  in \{contexts.join(" > ")}"
      }
      "\{loc}:\nexpected \{exp}\{ctx}"
    }
  }
}

///| 将错误格式化，并附加从 `input` 提取的上下文片段。

///|

///| 生成与 `format()` 相同的头部，加上显示错误位置前后各最多 20 个字符的片段：

///|

///| ```text

///| line 3, column 15 (offset 42):

///| expected HTTP method

///|   ...GET /path with-P<error>ayload...

///|                ^

///| ```

///|

///| Format this error with a context snippet extracted from `input`.

///| Produces the same header as `format()`, plus a snippet line showing

///|
/// up to 20 characters before and after the error position.
pub fn ParseError::format_with_input(
  self : ParseError,
  input : String,
) -> String noraise {
  match self {
    ParseError(pos, _, _, _) => {
      let base = self.format()
      let offset = pos.offset
      let ctx_start = if offset > 20 { offset - 20 } else { 0 }
      let ctx_end = if offset + 20 < input.length() {
        offset + 20
      } else {
        input.length()
      }
      let snippet = input[ctx_start:ctx_end].to_owned()
      let prefix = if ctx_start > 0 { "..." } else { "" }
      let suffix = if ctx_end < input.length() { "..." } else { "" }
      let caret_offset = offset - ctx_start + prefix.length()
      let caret = " ".repeat(caret_offset) + "^"
      "\{base}\n  \{prefix}\{snippet}\{suffix}\n  \{caret}"
    }
  }
}

///| 解析结果 — 运行 `Parser[T]` 后的输出。

///|

///| - `Success(value, state)` — 匹配成功；`value` 为解析结果，`state` 为消耗后的游标位置

///| - `Failure(error)` — 匹配失败；`error` 携带位置和承诺信息，供 `alt` 回溯决策

///|

///| The result of running a `Parser[T]` against a `State`.

///| - `Success(value, state)` — matched successfully

///|
/// - `Failure(error)` — failed; `error` carries position and commitment for `alt`
pub(all) enum ParseResult[T] {
  Success(T, State)
  Failure(ParseError)
}

///| 位置感知解析器组合子。

///|

///| 包装函数 `State -> ParseResult[T]`，尝试在当前游标位置匹配输入。

///| 组合子（`map`、`bind`、`alt`、`seq2` 等）将 `Parser` 组合为更大的解析器，

///| 无需暴露内部 `State` 机制。

///|

///| 使用 `Parser::parse` 进行简单解析，或 `Parser::parse_full` 要求全部输入被消耗。

///| 使用 `Parser::parse_raise` / `Parser::parse_full_raise` 以 `raise` 方式抛出错误。

///|

///| A position-aware parser combinator.

///| Wraps a function `State -> ParseResult[T]` that attempts to match input

///| at the current cursor position. Combinators compose `Parser` values

///|
/// into larger parsers without exposing the internal `State` machinery.
pub(all) struct Parser[T] {
  run : (State) -> ParseResult[T]
}

///| 将原始函数包装为 `Parser[T]` — 通用扩展点。

///|

///|
/// Wrap a raw function into a `Parser[T]` — the universal extension point.
pub fn[T] Parser::of(f : (State) -> ParseResult[T]) -> Parser[T] noraise {
  { run: f, }
}

///| 解析 `input`，允许尾部未消耗的输入。

///|

///| 这是最宽松的入口：只要解析器匹配了 `input` 的前缀即成功。

///| 需要确保全部输入被消耗时使用 `parse_full`。

///|

///| Parse `input` and return the result, allowing trailing unconsumed input.

///|
/// Use `parse_full` when you need to ensure the entire input is consumed.
#warnings("-result_error_return")
pub fn[T] Parser::parse(
  self : Parser[T],
  input : String,
) -> Result[T, ParseError] noraise {
  let state = State::new(input)
  match (self.run)(state) {
    Success(value, _) => Ok(value)
    Failure(err) => Err(err)
  }
}

///| 解析 `input`，要求全部输入被消耗。

///|

///| 类似 `parse`，但若解析器成功却未到达 EOF，

///| 返回 `Err` 且 `expected = "end of input"`。

///|

///| Parse `input` and require that the entire input is consumed.

///|
/// If the parser succeeds without reaching EOF, returns an `Err`.
#warnings("-result_error_return")
pub fn[T] Parser::parse_full(
  self : Parser[T],
  input : String,
) -> Result[T, ParseError] noraise {
  let state = State::new(input)
  match (self.run)(state) {
    Success(value, st) =>
      if st.is_eof() {
        Ok(value)
      } else {
        Err(ParseError::at(pos=st.pos, expected="end of input"))
      }
    Failure(err) => Err(err)
  }
}

///| 解析 `input`，允许尾部未消耗的输入，失败时 `raise ParseError`。

///|

///| 与 `parse` 类似，但将 `Err` 转为 `raise` 抛出，

///| 适合在 `try...catch` 上下文中使用。

///|

///| Parse `input` and raise `ParseError` on failure, allowing trailing input.

///|
/// Like `parse`, but converts `Err` to `raise` for use in `try...catch`.
pub fn[T] Parser::parse_raise(
  self : Parser[T],
  input : String,
) -> T raise ParseError {
  match self.parse(input) {
    Ok(value) => value
    Err(err) => raise err
  }
}

///| 解析 `input`，要求全部输入被消耗，失败时 `raise ParseError`。

///|

///| 与 `parse_full` 类似，但将 `Err` 转为 `raise` 抛出，

///| 适合在 `try...catch` 上下文中使用。

///|

///| Parse `input` and raise `ParseError` on failure, requiring full consumption.

///|
/// Like `parse_full`, but converts `Err` to `raise` for use in `try...catch`.
pub fn[T] Parser::parse_full_raise(
  self : Parser[T],
  input : String,
) -> T raise ParseError {
  match self.parse_full(input) {
    Ok(value) => value
    Err(err) => raise err
  }
}
