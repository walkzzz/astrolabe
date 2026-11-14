# API Reference

> Complete reference for all public API in `@astrolabe`, `@astrolabe/json`, and `@astrolabe/http`.

## Method & Trait System

Astrolabe uses MoonBit's method and trait system throughout:

- **Types define methods** via `TypeName::method_name(self, ...)` — e.g., `Parser::parse`, `ParseError::format`
- **Dot syntax** works on methods: `p.parse("abc")`, `err.format()`
- **Traits** are used for standard interfaces: `Method` and `Version` implement `Show` (providing `.to_string()`)
- **Derive** auto-generates `Eq`, `Debug` for core types: `Pos`, `State`, `ParseError`, `JValue`, all HTTP types
- **Extend** explicitly attaches trait methods for dot syntax: `extend Method with Show::{to_string, output}`

## v0.5.x 新增 API（错误聚合 / ParserLike 扩展点 / Show）

### 错误聚合（v0.4.0）

| API | 签名 | 说明 |
|---|---|---|
| `ParseError::merge` | `merge(self, other : ParseError) -> ParseError` | furthest-position 优先；同位置合并 expected（去重保序）+ committed 取或 |
| `alt` / `choice` 聚合 | 内置语义（无新 API） | 全分支失败时自动聚合多候选期望——下游看到 "expected 'a' or 'b'" |

### ParserLike 扩展点（v0.5.0，函数式）

| API | 签名 | 说明 |
|---|---|---|
| `pmap` | `pmap(run, f) -> Parser[B]` | 对任意 run 函数应用变换 |
| `pbind` | `pbind(run, f) -> Parser[B]` | 单调绑定（第二解析器依赖第一结果，序列承诺） |
| `palt` | `palt(run1, run2) -> Parser[A]` | 有序选择（未承诺失败回溯 + 错误聚合） |
| `poption` | `poption(run, default) -> Parser[A]` | 未承诺失败回退默认值 |
| `Parser::run_fn` | `run_fn(self) -> (State) -> ParseResult[T]` | 提取运行函数——第三方类型暴露 `run_fn` 方法即接入全部组合子 |

> 设计说明：MoonBit trait 不支持类型参数（`trait ParserLike[A]` 语法拒绝），扩展点采用函数式约定（与 `Parser::of` 同一扩展点）——见 `core/parser_like.mbt`。

### `ParseError` 实现 Show（0.5.1）

- `ParseError` 已实现 `Show`（委托 `format()`）：`"\{err}"` 插值、`println`、inspect 快照**开箱可用**
- `to_string()` 经 `extend ParseError with Show::{to_string}` 派生
- ⚠️ 调试场景官方推荐 `Debug`（`#derive(Debug)` 已在——`debug_inspect`）；`ParseError::format()` / `format_with_input(input)` 仍是错误报告的最佳入口（位置 + 期望 + 上下文指针）

## Core Types (`@astrolabe`)

### Pos

Source position tracked during parsing. `#derive(Eq, Debug)`.

```moonbit
struct Pos {
  mut line : Int32    // 1-based line number
  mut column : Int32  // 1-based column number
  mut offset : Int32  // 0-based byte offset
}
```

| Method | Signature | Description |
|--------|-----------|-------------|
| `Pos::initial()` | `() -> Pos` | Create position at (1, 1, 0) |
| `pos.advance(ch)` | `(Char) -> Pos` | Advance by one character; newline resets column |

### State

Mutable parsing state wrapping input string and cursor. `#derive(Debug)`.

```moonbit
struct State {
  input : String         // Full input, immutable
  mut offset : Int32     // Current read position
  mut pos : Pos          // Current source position
}
```

| Method | Signature | Description |
|--------|-----------|-------------|
| `State::new(input)` | `(String) -> State` | Create state at start of input |
| `state.remaining()` | `() -> Int32` | Characters remaining |
| `state.is_eof()` | `() -> Bool` | At end of input? |
| `state.peek()` | `() -> Char?` | Peek current char (None at EOF) |
| `state.advance_one()` | `() -> Unit` | Advance cursor by one char |
| `state.advance_by(n)` | `(Int32) -> Unit` | Advance by `n` chars |
| `state.slice(start, end)` | `(Int32, Int32) -> String` | Extract substring `[start, end)` |

### ParseError

`#derive(Debug, Eq)`. Error carrying position, expected tokens, and commitment status.

```moonbit
struct ParseError {
  pos : Pos                // Where error occurred
  expected : Array[String] // What was expected
  committed : Bool         // Suppress backtracking?
  context : String         // Optional context label
}
```

| Method | Signature | Description |
|--------|-----------|-------------|
| `ParseError::at(pos~, expected~)` | `() -> ParseError` | Uncommitted error at position |
| `err.commit()` | `() -> ParseError` | Return copy with `committed = true` |
| `err.format()` | `() -> String` | Human-readable string |
| `err.format_with_input(input)` | `(String) -> String` | Same + context snippet with caret |

### Parser[T]

Core parser combinator type.

```moonbit
struct Parser[T] {
  run : (State) -> ParseResult[T]
}
```

| Method | Signature | Description |
|--------|-----------|-------------|
| `Parser::of(f)` | `fn[T]((State) -> ParseResult[T]) -> Parser[T]` | Wrap raw function into Parser |
| `p.parse(input)` | `fn[T](String) -> Result[T, ParseError]` | Parse, allow trailing |
| `p.parse_full(input)` | `fn[T](String) -> Result[T, ParseError]` | Parse, require full consumption |

### ParseResult[T]

```moonbit
enum ParseResult[T] {
  Success(T, State)
  Failure(ParseError)
}
```

---

## Basic Combinators

### char

```moonbit
fn char(expected : Char) -> Parser[Char]
```

Match a single specific character. Fails if the next character differs or at EOF.

```moonbit
@astrolabe.char('a').parse("abc")  // Ok('a')
@astrolabe.char('a').parse("bbc")  // Err(ParseError)
```

### string

```moonbit
fn string(expected : String) -> Parser[String]
```

Match an exact string literal. Consumes the entire literal on success.

```moonbit
@astrolabe.string("hello").parse("hello world")  // Ok("hello")
```

### any_char

```moonbit
fn any_char() -> Parser[Char]
```

Match any single character. Fails only at EOF.

### take

```moonbit
fn take(n : Int32) -> Parser[String]
```

Consume exactly `n` characters. Fails if fewer than `n` remain.

### satisfy

```moonbit
fn satisfy(pred : (Char) -> Bool, label~ : String = "satisfy") -> Parser[Char]
```

Match a character satisfying `pred`. The `label` parameter customizes error messages.

```moonbit
@astrolabe.satisfy(fn(c) { c >= '0' && c <= '9' }, label="digit")
```

### end_of_input

```moonbit
fn end_of_input() -> Parser[Unit]
```

Succeed only when at EOF. Useful as the final check in `parse_full`.

### peek

```moonbit
fn[T] peek(p : Parser[T]) -> Parser[T]
```

Run `p` but restore the cursor position regardless of outcome. Does not consume input.

### skip

```moonbit
fn[T] skip(p : Parser[T]) -> Parser[Unit]
```

Run `p` and consume its input, but discard the result.

### char_range

```moonbit
fn char_range(lo : Char, hi : Char) -> Parser[Char]
```

Match a character in the inclusive range `[lo, hi]`.

```moonbit
@astrolabe.char_range('a', 'z').parse("hello")  // Ok('h')
@astrolabe.char_range('0', '9').parse("7")      // Ok('7')
```

### char_class

```moonbit
fn char_class(pred : (Char) -> Bool, label_ : String) -> Parser[Char]
```

Like `satisfy` with a required custom label. Use for named character classes.

---

## Composition Combinators

### map

```moonbit
fn[T, U] map(p : Parser[T], f : (T) -> U) -> Parser[U]
```

Transform the result of a parser with a pure function.

```moonbit
@astrolabe.map(@astrolabe.char('a'), fn(c) { c.to_string() })
  |> .parse("abc")  // Ok("a")
```

### bind

```moonbit
fn[T, U] bind(p : Parser[T], f : (T) -> Parser[U]) -> Parser[U]
```

Sequence where the second parser depends on the first's result. **Sequence commits**: if `p` succeeds but `f(x)` fails, the error is committed.

```moonbit
@astrolabe.bind(@astrolabe.char('['), fn(_) {
  @astrolabe.many1(@astrolabe.satisfy(fn(c) { c != ']' }, label="non-bracket"))
})
```

### pure / return_

```moonbit
fn[T] pure(value : T) -> Parser[T]
fn[T] return_(value : T) -> Parser[T]
```

Always succeed without consuming input, returning `value`. `return_` is an alias for `pure` (avoids keyword conflict).

### seq2 / seq3 / seq4

```moonbit
fn[A, B] seq2(p1 : Parser[A], p2 : Parser[B]) -> Parser[(A, B)]
fn[A, B, C] seq3(p1 : Parser[A], p2 : Parser[B], p3 : Parser[C]) -> Parser[(A, B, C)]
fn[A, B, C, D] seq4(p1 : Parser[A], p2 : Parser[B], p3 : Parser[C], p4 : Parser[D]) -> Parser[(A, B, C, D)]
```

Sequence independent parsers and collect all results. Like `bind` but for parsers whose results don't depend on each other.

### many / many1

```moonbit
fn[T] many(p : Parser[T]) -> Parser[Array[T]]
fn[T] many1(p : Parser[T]) -> Parser[Array[T]]
```

- `many` — zero or more matches. Always succeeds (returns `[]` if no match).
- `many1` — one or more matches. Fails if no match at all.

Stops on committed errors; uncommitted failures end the loop.

### sep_by / sep_by1

```moonbit
fn[T, S] sep_by(p : Parser[T], sep : Parser[S]) -> Parser[Array[T]]
fn[T, S] sep_by1(p : Parser[T], sep : Parser[S]) -> Parser[Array[T]]
```

- `sep_by` — zero or more, separated by `sep`. Succeeds with `[]` if no match.
- `sep_by1` — one or more, separated by `sep`. Fails if no match.

```moonbit
@astrolabe.sep_by1(@astrolabe.char('a'), @astrolabe.char(','))
  |> .parse("a,a,a")  // Ok(['a', 'a', 'a'])
```

### count

```moonbit
fn[T] count(n : Int32, p : Parser[T]) -> Parser[Array[T]]
```

Match `p` exactly `n` times. Fails if fewer matches available.

### many_till

```moonbit
fn[T, E] many_till(p : Parser[T], end_ : Parser[E]) -> Parser[Array[T]]
```

Repeat `p` until `end_` succeeds. The `end_` parser is **not consumed** (its match is discarded, cursor is restored).

---

## Control Combinators

### commit

```moonbit
fn[T] commit(p : Parser[T]) -> Parser[T]
```

Mark `p`'s failure as committed. Prevents `alt` from backtracking past this point.

### alt

```moonbit
fn[T] alt(p1 : Parser[T], p2 : Parser[T]) -> Parser[T]
```

Ordered choice: try `p1`. If it fails with `committed = false`, backtrack and try `p2`. If `committed = true`, propagate the failure without trying `p2`.

### choice

```moonbit
fn[T] choice(parsers : Array[Parser[T]]) -> Parser[T]
```

N-way ordered choice. Tries each parser in order; backtracks on uncommitted failures.

### label

```moonbit
fn[T] label(p : Parser[T], name : String) -> Parser[T]
```

Replace `p`'s error message with `name`. Useful for domain-specific error messages.

```moonbit
@astrolabe.label(@astrolabe.char_range('A', 'Z'), "uppercase letter")
```

---

## JSON Subpackage (`@astrolabe/json`)

### JValue

`#derive(Debug, Eq)`. JSON value type.

```moonbit
enum JValue {
  JNull
  JBool(Bool)
  JNum(Double)
  JStr(String)
  JArr(Array[JValue])
  JObj(Array[(String, JValue)])
}
```

| Method | Description |
|--------|-------------|
| `jv.stringify()` | Convert to JSON string representation |

### Public API

| Function | Signature | Description |
|----------|-----------|-------------|
| `value` | `() -> Parser[JValue]` | Parser for any JSON value |
| `parse` | `(String) -> Result[JValue, ParseError]` | Parse complete JSON string |

---

## HTTP Subpackage (`@astrolabe/http`)

### Types

| Type | Fields | Traits | Description |
|------|--------|--------|-------------|
| `Method` | `GET, POST, PUT, DELETE, HEAD, OPTIONS, PATCH, CONNECT, TRACE` | `Eq, Debug, Show` | HTTP method enum |
| `Version` | `major: Int32, minor: Int32` | `Eq, Debug, Show` | HTTP version |
| `RequestLine` | `req_method: Method, uri: String, version: Version` | `Eq, Debug` | Parsed request line |
| `Header` | `name: String, value: String` | `Eq, Debug` | Header key-value pair |
| `Request` | `req_method, uri, version, headers: Array[Header]` | `Eq, Debug` | Complete HTTP request |
| `Uri` | `scheme, host, port: Int32?, path, query: String?, fragment: String?` | `Eq, Debug` | URI components |

### Methods

| Method | Description |
|--------|-------------|
| `method.to_string()` | Via `Show` trait — `"GET"`, `"POST"`, etc. |
| `version.to_string()` | Via `Show` trait — `"HTTP/1.1"`, etc. |
| `req_line.to_string()` | `"GET /path HTTP/1.1"` |
| `header.to_string()` | `"Content-Type: text/html"` |
| `request.to_string()` | Full HTTP request text |
| `uri.to_string()` | Full URI string |

### Public API

| Function | Returns | Description |
|----------|---------|-------------|
| `parse_request_line` | `Parser[RequestLine]` | Parser for `METHOD /path HTTP/1.1\r\n` |
| `parse_header` | `Parser[Header]` | Parser for single header line |
| `parse_headers` | `Parser[Array[Header]]` | Parser for all headers until empty line |
| `parse_request` | `Parser[Request]` | Parser for complete HTTP request |
| `parse_uri` | `Parser[Uri]` | Parser for URI with all components |
| `parse_uri_string` | `(String) -> Result[Uri, ParseError]` | Convenience: parse URI string |
| `parse_request_string` | `(String) -> Result[Request, ParseError]` | Convenience: parse request string |

---

## Extension Point

Use `Parser::of` to create custom parsers from raw functions:

```moonbit
let custom : @astrolabe.Parser[Int32] = @astrolabe.Parser::of(fn(state) {
  // Access state.input, state.offset, state.pos
  // Return Success(value, newState) or Failure(error)
  match state.peek() {
    Some(ch) if ch >= '0' && ch <= '9' => {
      state.advance_one()
      @core.Success(ch.to_int() - '0'.to_int(), state)
    }
    _ => @core.Failure(@core.ParseError::at(pos=state.pos, expected="digit"))
  }
})
```
