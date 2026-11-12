# API Reference

> Complete reference for all public API in `@astrolabe`, `@astrolabe/json`, and `@astrolabe/http`.

## Core Types (`@astrolabe`)

### Pos

Source position tracked during parsing.

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
| `Pos::advance` | `(Pos, Char) -> Pos` | Advance by one character; newline resets column |

### State

Mutable parsing state wrapping input string and cursor.

```moonbit
struct State {
  input : String         // Full input, immutable
  mut offset : Int32     // Current read position
  mut pos : Pos          // Current source position
}
```

| Method | Signature | Description |
|--------|-----------|-------------|
| `State::new` | `(String) -> State` | Create state at start of input |
| `State::remaining` | `(State) -> Int32` | Characters remaining |
| `State::is_eof` | `(State) -> Bool` | At end of input? |
| `State::peek` | `(State) -> Char?` | Peek current char (None at EOF) |
| `State::advance_one` | `(State) -> Unit` | Advance cursor by one char |
| `State::advance_by` | `(State, Int32) -> Unit` | Advance by `n` chars |
| `State::slice` | `(State, Int32, Int32) -> String` | Extract substring `[start, end)` |

### ParseError

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
| `ParseError::at` | `(pos~, expected~) -> ParseError` | Uncommitted error at position |
| `ParseError::format` | `(ParseError) -> String` | Human-readable string |
| `ParseError::format_with_input` | `(ParseError, String) -> String` | Same + context snippet with caret |

### Parser[T]

```moonbit
struct Parser[T] {
  run : (State) -> ParseResult[T]
}
```

| Method | Signature | Description |
|--------|-----------|-------------|
| `Parser::of` | `fn[T]((State) -> ParseResult[T]) -> Parser[T]` | Wrap raw function into Parser |
| `Parser::parse` | `fn[T](Parser[T], String) -> Result[T, ParseError]` | Parse, allow trailing |
| `Parser::parse_full` | `fn[T](Parser[T], String) -> Result[T, ParseError]` | Parse, require full consumption |

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
| `JValue::stringify` | Convert to JSON string representation |

### Public API

| Function | Signature | Description |
|----------|-----------|-------------|
| `value` | `() -> Parser[JValue]` | Parser for any JSON value |
| `parse` | `(String) -> Result[JValue, ParseError]` | Parse complete JSON string |

---

## HTTP Subpackage (`@astrolabe/http`)

### Types

| Type | Fields | Description |
|------|--------|-------------|
| `Method` | `GET, POST, PUT, DELETE, HEAD, OPTIONS, PATCH, CONNECT, TRACE` | HTTP method enum |
| `Version` | `major: Int32, minor: Int32` | HTTP version |
| `RequestLine` | `req_method: Method, uri: String, version: Version` | Parsed request line |
| `Header` | `name: String, value: String` | Header key-value pair |
| `Request` | `req_method, uri, version, headers: Array[Header]` | Complete HTTP request |
| `Uri` | `scheme, host, port: Int32?, path, query: String?, fragment: String?` | URI components |

| Method | Description |
|--------|-------------|
| `Method::to_string` | `"GET"`, `"POST"`, etc. |
| `Version::to_string` | `"HTTP/1.1"`, etc. |

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
