///|
/// Astrolabe 浏览器演示导出层（JS / WasmGC 目标）。
/// Browser-demo exports. Non-raising signatures: failures fold into
/// `{"ok":false,...}` / false / "" so the JS side needs no exception mapping.

///|
fn error_json(msg : String) -> String {
  let j : @json.Json = { "ok": @json.Json(false), "error": @json.Json(msg) }
  j.stringify()
}

///|
/// 位置 → JSON（line / column / offset，与错误信息同源）。
fn pos_json(pos : @core.Pos) -> @json.Json {
  {
    "line": @json.Json::number(pos.line.to_double()),
    "column": @json.Json::number(pos.column.to_double()),
    "offset": @json.Json::number(pos.offset.to_double()),
    "label": @json.Json(pos.to_string()),
  }
}

///|
/// 解析错误 → 结构化 JSON（位置 + 期望集合 + 上下文片段）。
fn error_detail(err : @core.ParseError, input : String) -> @json.Json {
  let expected : Array[@json.Json] = []
  for item in err.expected() {
    expected.push(@json.Json(item))
  }
  {
    "ok": @json.Json(false),
    "error": @json.Json(err.expected_joined()),
    "pos": pos_json(err.pos()),
    "expected": @json.Json::array(expected),
    "format": @json.Json(err.format_with_input(input)),
  }
}

///|
/// 版本（与 moon.mod 同步）。
#export_name("astrolabe_version")
pub fn astrolabe_version() -> String {
  "0.5.7"
}

///|
/// 单字符解析：`char(ch).parse_full(input)`。
#export_name("parse_char")
pub fn parse_char(input : String, ch : String) -> String {
  let c = match ch {
    s if s.length() == 1 => s.to_array()[0]
    _ => return error_json("ch must be exactly one character")
  }
  match @astrolabe.char(c).parse_prefix(input) {
    Ok(pair) => {
      let j : @json.Json = {
        "ok": @json.Json(true),
        "value": @json.Json(pair.0.to_string()),
        "consumed": @json.Json::number(1.0),
        "rest": @json.Json(pair.1),
      }
      j.stringify()
    }
    Err(err) => error_detail(err, input).stringify()
  }
}

///|
/// 字符串字面量解析：`string(lit).parse_full(input)`。
#export_name("parse_string")
pub fn parse_string(input : String, lit : String) -> String {
  if lit.length() == 0 {
    return error_json("literal must not be empty")
  }
  match @astrolabe.string(lit).parse_prefix(input) {
    Ok(pair) => {
      let j : @json.Json = {
        "ok": @json.Json(true),
        "value": @json.Json(pair.0),
        "consumed": @json.Json::number(lit.length().to_double()),
        "rest": @json.Json(pair.1),
      }
      j.stringify()
    }
    Err(err) => error_detail(err, input).stringify()
  }
}

///|
/// 字符范围解析：`char_range(lo, hi).parse_full(input)`。
#export_name("parse_range")
pub fn parse_range(input : String, lo : String, hi : String) -> String {
  let lo_c = match lo {
    s if s.length() == 1 => s.to_array()[0]
    _ => return error_json("lo must be exactly one character")
  }
  let hi_c = match hi {
    s if s.length() == 1 => s.to_array()[0]
    _ => return error_json("hi must be exactly one character")
  }
  if lo_c > hi_c {
    return error_json("lo must be <= hi")
  }
  match @astrolabe.char_range(lo_c, hi_c).parse_prefix(input) {
    Ok(pair) => {
      let j : @json.Json = {
        "ok": @json.Json(true),
        "value": @json.Json(pair.0.to_string()),
        "rest": @json.Json(pair.1),
      }
      j.stringify()
    }
    Err(err) => error_detail(err, input).stringify()
  }
}

///|
/// 标识符解析：字母/下划线开头，后接字母数字下划线（`take_while1`）。
#export_name("parse_identifier")
pub fn parse_identifier(input : String) -> String {
  let head = fn(c : Char) {
    (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'
  }
  let tail = fn(c : Char) {
    (c >= 'a' && c <= 'z') ||
    (c >= 'A' && c <= 'Z') ||
    (c >= '0' && c <= '9') ||
    c == '_'
  }
  let parser = @astrolabe.bind(
    @astrolabe.take_while1(head, label="identifier start"),
    fn(first) {
      @astrolabe.map(@astrolabe.take_while(tail), fn(rest) { first + rest })
    },
  )
  match parser.parse_full(input) {
    Ok(value) => {
      let j : @json.Json = {
        "ok": @json.Json(true),
        "value": @json.Json(value),
        "length": @json.Json::number(value.length().to_double()),
      }
      j.stringify()
    }
    Err(err) => error_detail(err, input).stringify()
  }
}

///|
/// 十进制整数解析（Int32 范围校验）。
#export_name("parse_int")
pub fn parse_int(input : String) -> String {
  let digit = fn(c : Char) { c >= '0' && c <= '9' }
  match @astrolabe.take_while1(digit, label="digit").parse_full(input) {
    Ok(text) => {
      let mut value : Int64 = 0L
      for ch in text {
        value = value * 10L + (ch.to_int().to_int64() - 48L)
        if value > 2147483647L {
          return error_json("integer exceeds int32 range")
        }
      }
      let j : @json.Json = {
        "ok": @json.Json(true),
        "value": @json.Json::number(value.to_double()),
        "digits": @json.Json::number(text.length().to_double()),
      }
      j.stringify()
    }
    Err(err) => error_detail(err, input).stringify()
  }
}

///|
/// CSV 行解析：标识符以逗号分隔（`sep_by`）。
#export_name("parse_csv")
pub fn parse_csv(input : String) -> String {
  let ident_char = fn(c : Char) {
    (c >= 'a' && c <= 'z') ||
    (c >= 'A' && c <= 'Z') ||
    (c >= '0' && c <= '9') ||
    c == '_' ||
    c == '-' ||
    c == '.'
  }
  let item = @astrolabe.take_while1(ident_char, label="csv item")
  let parser = @astrolabe.sep_by(item, @astrolabe.char(','))
  match parser.parse_full(input) {
    Ok(items) => {
      let out : Array[@json.Json] = []
      for item_text in items {
        out.push(@json.Json(item_text))
      }
      let j : @json.Json = {
        "ok": @json.Json(true),
        "count": @json.Json::number(items.length().to_double()),
        "items": @json.Json::array(out),
      }
      j.stringify()
    }
    Err(err) => error_detail(err, input).stringify()
  }
}

///|
/// `parse` / `parse_prefix` / `parse_full` 三种入口对比。
#export_name("parse_modes_demo")
pub fn parse_modes_demo(input : String, lit : String) -> String {
  if lit.length() == 0 {
    return error_json("literal must not be empty")
  }
  let parser = @astrolabe.string(lit)
  let partial = match parser.parse(input) {
    Ok(value) => { "ok": @json.Json(true), "value": @json.Json(value) }
    Err(err) =>
      { "ok": @json.Json(false), "error": @json.Json(err.expected_joined()) }
  }
  let prefixed = match parser.parse_prefix(input) {
    Ok(pair) =>
      {
        "ok": @json.Json(true),
        "value": @json.Json(pair.0),
        "rest": @json.Json(pair.1),
      }
    Err(err) =>
      { "ok": @json.Json(false), "error": @json.Json(err.expected_joined()) }
  }
  let full = match parser.parse_full(input) {
    Ok(value) => { "ok": @json.Json(true), "value": @json.Json(value) }
    Err(err) =>
      {
        "ok": @json.Json(false),
        "error": @json.Json(err.expected_joined()),
        "pos": pos_json(err.pos()),
      }
  }
  let j : @json.Json = {
    "ok": @json.Json(true),
    "parse": partial,
    "parse_prefix": prefixed,
    "parse_full": full,
  }
  j.stringify()
}

///|
/// 失败演示：返回位置 + 期望集合 + `format_with_input` 上下文片段。
#export_name("error_demo")
pub fn error_demo(input : String, lit : String) -> String {
  if lit.length() == 0 {
    return error_json("literal must not be empty")
  }
  match @astrolabe.string(lit).parse_full(input) {
    Ok(_) => {
      let j : @json.Json = {
        "ok": @json.Json(true),
        "matched": @json.Json(true),
      }
      j.stringify()
    }
    Err(err) => error_detail(err, input).stringify()
  }
}

///|
/// `alt`（可回溯）与 `commit`（承诺后不回退）的对比。
#export_name("commit_vs_alt")
pub fn commit_vs_alt(input : String) -> String {
  let backtracking = @astrolabe.alt(
    @astrolabe.string("ab"),
    @astrolabe.string("ac"),
  )
  let committed = @astrolabe.alt(
    @astrolabe.commit(@astrolabe.string("ab")),
    @astrolabe.string("ac"),
  )
  let plain = match backtracking.parse_full(input) {
    Ok(value) => { "ok": @json.Json(true), "value": @json.Json(value) }
    Err(err) =>
      { "ok": @json.Json(false), "error": @json.Json(err.expected_joined()) }
  }
  let strict = match committed.parse_full(input) {
    Ok(value) => { "ok": @json.Json(true), "value": @json.Json(value) }
    Err(err) =>
      {
        "ok": @json.Json(false),
        "error": @json.Json(err.expected_joined()),
        "committed": @json.Json(err.committed()),
        "pos": pos_json(err.pos()),
      }
  }
  let j : @json.Json = {
    "ok": @json.Json(true),
    "alt": plain,
    "commit": strict,
  }
  j.stringify()
}

///|
/// 逐字符位置追踪：返回每个字符的 line / column / offset。
#export_name("pos_track")
pub fn pos_track(input : String) -> String {
  let steps : Array[@json.Json] = []
  let parser = @core.Parser::of(fn(st) {
    while true {
      match st.peek() {
        Some(ch) => {
          steps.push({
            "char": @json.Json(ch.to_string()),
            "line": @json.Json::number(st.pos.line.to_double()),
            "column": @json.Json::number(st.pos.column.to_double()),
            "offset": @json.Json::number(st.pos.offset.to_double()),
          })
          st.advance_one()
        }
        None => break
      }
    }
    @core.Success(steps, st)
  })
  match parser.parse_full(input) {
    Ok(items) => {
      let j : @json.Json = {
        "ok": @json.Json(true),
        "count": @json.Json::number(items.length().to_double()),
        "steps": @json.Json::array(items),
      }
      j.stringify()
    }
    Err(err) => error_detail(err, input).stringify()
  }
}
