///| JSON 值类型 — JSON 解析的输出。

///|

///|
/// JSON value type — the output of JSON parsing.
#derive(Debug, Eq)
pub(all) enum JValue {
  JNull
  JBool(Bool)
  JNum(Double)
  JStr(String)
  JArr(Array[JValue])
  JObj(Array[(String, JValue)])
}

///|
pub extend JValue with Eq::{not_equal, equal}

///|
pub extend JValue with @debug.Debug::{to_repr}

///| 对字符串进行 JSON 转义处理（内部辅助函数）。

///|

///|
/// Internal helper: escape a string for JSON output.
fn stringify_string(s : String) -> String {
  let mut result : String = "\""
  for i in 0..<s.length() {
    let ch = s.get_char(i).unwrap()
    match ch {
      '"' => result = result + "\\\""
      '\\' => result = result + "\\\\"
      '\n' => result = result + "\\n"
      '\r' => result = result + "\\r"
      '\t' => result = result + "\\t"
      _ => result = result + ch.to_string()
    }
  }
  result = result + "\""
  result
}

///| 将 `JValue` 转换为 JSON 字符串表示。

///|

///|
/// Convert a `JValue` to its JSON string representation.
pub fn JValue::stringify(self : JValue) -> String noraise {
  match self {
    JNull => "null"
    JBool(b) => if b { "true" } else { "false" }
    JNum(d) => d.to_string()
    JStr(s) => stringify_string(s)
    JArr(arr) => {
      let parts = arr.map(fn(v) { v.stringify() })
      "[\{parts.join(", ")}]"
    }
    JObj(pairs) => {
      let parts = pairs.map(fn(p) {
        stringify_string(p.0) + ": " + p.1.stringify()
      })
      "{\{parts.join(", ")}}"
    }
  }
}

///| 尝试将字符串解析为 Double，失败返回 None。

///|

///|
/// Try to parse a string as Double, returning None on failure.
fn try_parse_double(s : String) -> Double? {
  Some(@string.parse_double(s.to_string_view())) catch {
    _ => None
  }
}

///| 将 4 位十六进制字符串转换为 Char，失败返回 None。

///|

///|
/// Convert a 4-digit hex string to Char, returning None on failure.
fn hex4_to_char(s : String) -> Char? {
  if s.length() != 4 {
    return None
  }
  let mut code : Int32 = 0
  for i in 0..<4 {
    let c = s.get_char(i).unwrap()
    let n = c.to_int()
    let digit : Int32 = if n >= '0'.to_int() && n <= '9'.to_int() {
      n - '0'.to_int()
    } else if n >= 'a'.to_int() && n <= 'f'.to_int() {
      n - 'a'.to_int() + 10
    } else if n >= 'A'.to_int() && n <= 'F'.to_int() {
      n - 'A'.to_int() + 10
    } else {
      return None
    }
    code = code * 16 + digit
  }
  code.to_char()
}

///| 从 state 收集连续数字到字符串。

///|

///|
/// Collect consecutive digits from state into a string.
fn collect_digits(state : @core.State) -> String {
  let mut acc : String = ""
  let done : Bool = false
  while !done {
    match state.peek() {
      Some(ch) if ch >= '0' && ch <= '9' => {
        state.advance_one()
        acc = acc + ch.to_string()
      }
      _ => break
    }
  }
  acc
}

///| 解析 JSON 空白符（空格、制表符、换行），丢弃结果。

///|

///|
/// Parse JSON whitespace (space, tab, newline), discarding the result.
fn ws() -> @core.Parser[Unit] {
  @basic.skip(
    @compose.many(
      @basic.satisfy(
        fn(c) { c == ' ' || c == '\t' || c == '\n' || c == '\r' },
        label="whitespace",
      ),
    ),
  )
}

///| 解析字面量 `null`。

///|

///|
/// Parse the literal `null`.
fn null_() -> @core.Parser[JValue] {
  @compose.map(@basic.string("null"), fn(_) { JNull })
}

///| 解析 JSON 布尔值（`true` / `false`）。

///|

///|
/// Parse a JSON boolean (`true` / `false`).
fn bool_() -> @core.Parser[JValue] {
  @control.alt(
    @compose.map(@basic.string("true"), fn(_) { JBool(true) }),
    @compose.map(@basic.string("false"), fn(_) { JBool(false) }),
  )
}

///| 解析 JSON 数字。

///|

///|
/// Parse a JSON number.
fn number() -> @core.Parser[JValue] {
  @core.Parser::of(fn(state) {
    let negative = match state.peek() {
      Some('-') => {
        state.advance_one()
        true
      }
      _ => false
    }
    let int_part = collect_digits(state)
    if int_part.length() == 0 {
      return @core.Failure(
        @core.ParseError::at(pos=state.pos, expected="number"),
      )
    }
    let frac_part : String = match state.peek() {
      Some('.') => {
        state.advance_one()
        let frac = collect_digits(state)
        "." + frac
      }
      _ => ""
    }
    let exp_part : String = match state.peek() {
      Some('e') => {
        state.advance_one()
        parse_exp(state)
      }
      Some('E') => {
        state.advance_one()
        parse_exp(state)
      }
      _ => ""
    }
    let num_str : String = (if negative { "-" } else { "" }) +
      int_part +
      frac_part +
      exp_part
    match try_parse_double(num_str) {
      Some(d) => @core.Success(JNum(d), state)
      None =>
        @core.Failure(
          @core.ParseError::at(pos=state.pos, expected="valid number"),
        )
    }
  })
}

///| 解析 'e'/'E' 之后的指数部分。

///|

///|
/// Parse the exponent part after 'e'/'E'.
fn parse_exp(state : @core.State) -> String {
  let sign : String = match state.peek() {
    Some('+') => {
      state.advance_one()
      "+"
    }
    Some('-') => {
      state.advance_one()
      "-"
    }
    _ => ""
  }
  let exp = collect_digits(state)
  "e" + sign + exp
}

///| 解析 JSON 字符串（含转义序列）。

///|

///|
/// Parse a JSON string (with escape sequences).
fn string_() -> @core.Parser[JValue] {
  @core.Parser::of(fn(state) {
    match state.peek() {
      Some('"') => {
        state.advance_one()
        match parse_string_body(state) {
          @core.Failure(err) => @core.Failure(err)
          @core.Success(s, st) => @core.Success(JStr(s), st)
        }
      }
      _ =>
        @core.Failure(
          @core.ParseError::at(pos=state.pos, expected="JSON string"),
        )
    }
  })
}

///| 内部：解析开引号后的字符串主体。

///|

///|
/// Internal: parse the string body after the opening quote.
fn parse_string_body(state : @core.State) -> @core.ParseResult[String] {
  let mut acc : String = ""
  let done : Bool = false
  while !done {
    match state.peek() {
      None =>
        return @core.Failure(
          @core.ParseError::at(pos=state.pos, expected="closing \""),
        )
      Some('"') => {
        state.advance_one()
        break
      }
      Some('\\') => {
        state.advance_one()
        match state.peek() {
          Some('"') => {
            state.advance_one()
            acc = acc + "\""
          }
          Some('\\') => {
            state.advance_one()
            acc = acc + "\\"
          }
          Some('/') => {
            state.advance_one()
            acc = acc + "/"
          }
          Some('n') => {
            state.advance_one()
            acc = acc + "\n"
          }
          Some('r') => {
            state.advance_one()
            acc = acc + "\r"
          }
          Some('t') => {
            state.advance_one()
            acc = acc + "\t"
          }
          Some('b') => {
            state.advance_one()
            acc = acc + "\u{8}"
          }
          Some('f') => {
            state.advance_one()
            acc = acc + "\u{c}"
          }
          Some('u') => {
            state.advance_one()
            let hex = state.slice(state.offset, state.offset + 4)
            state.advance_by(4)
            match hex4_to_char(hex) {
              Some(ch) => acc = acc + ch.to_string()
              None =>
                return @core.Failure(
                  @core.ParseError::at(pos=state.pos, expected="4 hex digits"),
                )
            }
          }
          _ =>
            return @core.Failure(
              @core.ParseError::at(pos=state.pos, expected="valid escape"),
            )
        }
      }
      Some(ch) => {
        state.advance_one()
        acc = acc + ch.to_string()
      }
    }
  }
  @core.Success(acc, state)
}

///| 解析任意 JSON 值。

///|

///|
/// Parse any JSON value.
pub fn value() -> @core.Parser[JValue] noraise {
  @control.choice([null_(), bool_(), number(), string_(), array_(), object_()])
}

///| 解析 JSON 数组：`[value, value, ...]`

///|

///|
/// Parse a JSON array: `[value, value, ...]`
fn array_() -> @core.Parser[JValue] {
  @core.Parser::of(fn(state) {
    match state.peek() {
      Some('[') => {
        state.advance_one()
        ignore((ws().run)(state))
        match state.peek() {
          Some(']') => {
            state.advance_one()
            @core.Success(JArr([]), state)
          }
          _ =>
            match (value().run)(state) {
              @core.Failure(err) => @core.Failure(err)
              @core.Success(first, st1) =>
                match parse_array_tail(st1, [first]) {
                  @core.Failure(err) => @core.Failure(err)
                  @core.Success(items, st2) => @core.Success(JArr(items), st2)
                }
            }
        }
      }
      _ =>
        @core.Failure(
          @core.ParseError::at(pos=state.pos, expected="JSON array"),
        )
    }
  })
}

///| 内部：解析第一个值后的数组剩余项。

///|

///|
/// Internal: parse remaining array items after the first value.
fn parse_array_tail(
  state : @core.State,
  acc : Array[JValue],
) -> @core.ParseResult[Array[JValue]] {
  let items = acc
  let mut current = state
  while true {
    ignore((ws().run)(current))
    match current.peek() {
      Some(',') => {
        current.advance_one()
        ignore((ws().run)(current))
        match (value().run)(current) {
          @core.Failure(err) => return @core.Failure(err)
          @core.Success(v, st) => {
            items.push(v)
            current = st
          }
        }
      }
      Some(']') => {
        current.advance_one()
        break
      }
      _ =>
        return @core.Failure(
          @core.ParseError::at(pos=current.pos, expected=", or ]"),
        )
    }
  }
  @core.Success(items, current)
}

///| 解析 JSON 对象：`{"key": value, ...}`

///|

///|
/// Parse a JSON object: `{"key": value, ...}`
fn object_() -> @core.Parser[JValue] {
  @core.Parser::of(fn(state) {
    match state.peek() {
      Some('{') => {
        state.advance_one()
        ignore((ws().run)(state))
        match state.peek() {
          Some('}') => {
            state.advance_one()
            @core.Success(JObj([]), state)
          }
          _ =>
            match (pair_().run)(state) {
              @core.Failure(err) => @core.Failure(err)
              @core.Success(p, st1) =>
                match parse_object_tail(st1, [p]) {
                  @core.Failure(err) => @core.Failure(err)
                  @core.Success(pairs, st2) => @core.Success(JObj(pairs), st2)
                }
            }
        }
      }
      _ =>
        @core.Failure(
          @core.ParseError::at(pos=state.pos, expected="JSON object"),
        )
    }
  })
}

///| 内部：解析第一对之后的对象剩余键值对。

///|

///|
/// Internal: parse remaining object pairs after the first one.
fn parse_object_tail(
  state : @core.State,
  acc : Array[(String, JValue)],
) -> @core.ParseResult[Array[(String, JValue)]] {
  let pairs = acc
  let mut current = state
  while true {
    ignore((ws().run)(current))
    match current.peek() {
      Some(',') => {
        current.advance_one()
        ignore((ws().run)(current))
        match (pair_().run)(current) {
          @core.Failure(err) => return @core.Failure(err)
          @core.Success(p, st) => {
            pairs.push(p)
            current = st
          }
        }
      }
      Some('}') => {
        current.advance_one()
        break
      }
      _ =>
        return @core.Failure(
          @core.ParseError::at(pos=current.pos, expected=", or }"),
        )
    }
  }
  @core.Success(pairs, current)
}

///| 解析键值对：`"key": value`

///|

///|
/// Parse a key-value pair: `"key": value`
fn pair_() -> @core.Parser[(String, JValue)] {
  @core.Parser::of(fn(state) {
    match (string_().run)(state) {
      @core.Failure(err) => @core.Failure(err)
      @core.Success(JStr(key), st1) => {
        ignore((ws().run)(st1))
        match st1.peek() {
          Some(':') => {
            st1.advance_one()
            ignore((ws().run)(st1))
            match (value().run)(st1) {
              @core.Failure(err) => @core.Failure(err)
              @core.Success(val_, st2) => @core.Success((key, val_), st2)
            }
          }
          _ => @core.Failure(@core.ParseError::at(pos=st1.pos, expected=":"))
        }
      }
      @core.Success(_, _) =>
        @core.Failure(
          @core.ParseError::at(pos=state.pos, expected="string key"),
        )
    }
  })
}

///| 将完整 JSON 字符串解析为 `JValue`。

///|

///|
/// Parse a complete JSON string into a `JValue`.
#warnings("-result_error_return")
pub fn parse(input : String) -> Result[JValue, @core.ParseError] noraise {
  let p = @compose.bind(ws(), fn(_) {
    @compose.bind(value(), fn(v) {
      @compose.bind(ws(), fn(_) {
        @compose.map(@basic.end_of_input(), fn(_) { v })
      })
    })
  })
  @core.Parser::parse(p, input)
}
