///| INI 解析器 — astrolabe 生态采用示范。

///| 用 astrolabe 组合子实现一个完整的真实文法（INI 配置格式），

///| 并提供 INI → JSON 的一站式转换入口，展示"第三方项目依赖

///| astrolabe 构建解析能力"的完整链路：

///|

///|   文法组合（core/char/sequence/branch 组合子）→ `parse_ini` → `build_ini_doc` → `ini_to_json_string`

///|

///| 使用的组合子：`take_while` / `take_while1` / `alt`（错误聚合）/

///| `seq2` / `seq3` / `between` / `many` / `option` / `label` / `end_of_input`。

///|

///| The INI parser — an ecosystem-adoption demo built with astrolabe

///| combinators: grammar composition → `parse_ini` → `build_ini_doc` →

///| `ini_to_json_string`.

///| 行级语法元素。
///|
///| Line-level syntax elements.
pub(all) enum IniLine {
  Section(String)
  Pair(String, String)
  Comment
  Blank
}

///| 解析后的 INI 文档：`sections[i] = (节名, [(键, 值)...])`。

///| 无节头的键归入空名节 `""`。

///|

///| Parsed INI document: `sections[i] = (name, [(key, value)...])`.

///| Keys before the first section header land in the unnamed section `""`.
pub(all) struct IniDoc {
  sections : Array[(String, Array[(String, String)])]
}

///| 键名字符集：字母 / 数字 / `_` / `-` / `.`。

///|

///| Key character set: letters / digits / `_` / `-` / `.`.
fn is_key_char(c : Char) -> Bool {
  (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_' || c == '-' || c == '.'
}

///| 行内空白（不跨行）。

///|

///| Intra-line whitespace (never crosses lines).
fn ws() -> @core.Parser[String] noraise {
  @char.take_while(fn(c) { c == ' ' || c == '\t' })
}

///| 行结束：`\r\n` 或 `\n`。

///|

///| Line terminator: `\r\n` or `\n`.
fn eol() -> @core.Parser[String] noraise {
  @branch.alt(@char.string("\r\n"), @char.string("\n"))
}

///| 可选行尾 — 行尾无换行时（文件末尾）回退成功。

///|

///| Optional line end — succeeds at EOF when no trailing newline exists.
fn line_end() -> @core.Parser[Unit] noraise {
  @sequence.map(@sequence.option(eol(), ""), fn(_) { () })
}

///| 注释行：`;` 或 `#` 开头直到行尾。

///|

///| Comment line: starts with `;` or `#` until end of line.
fn comment_line() -> @core.Parser[IniLine] noraise {
  @sequence.map(
    @sequence.seq2(
      @branch.alt(@char.char(';'), @char.char('#')),
      @char.take_while(fn(c) { c != '\n' && c != '\r' }),
    ),
    fn(_) { IniLine::Comment },
  )
}

///| 空行。

///|

///| Blank line.
fn blank_line() -> @core.Parser[IniLine] noraise {
  @sequence.map(eol(), fn(_) { IniLine::Blank })
}

///| 节头行：`[name]`，节名两侧空白被裁剪。

///|

///| Section header: `[name]`, whitespace around the name is trimmed.
fn section_line() -> @core.Parser[IniLine] noraise {
  @sequence.map(
    @sequence.seq2(
      @sequence.between(
        @char.char('['),
        @char.take_while(fn(c) { c != ']' && c != '\n' && c != '\r' }),
        @char.char(']'),
      ),
      line_end(),
    ),
    fn(pair) { IniLine::Section(pair.0.trim().to_owned()) },
  )
}

///| 键值行：`key = value`，两侧空白裁剪，值到行尾（可含空格）。

///|

///| Key-value line: `key = value`, both sides trimmed, value runs to

///| end of line (may contain spaces).
fn pair_line() -> @core.Parser[IniLine] noraise {
  @sequence.map(
    @sequence.seq3(
      @sequence.seq3(
        ws(),
        @char.take_while1(is_key_char, label="INI key"),
        ws(),
      ),
      @char.char('='),
      @sequence.seq2(ws(), @char.take_while(fn(c) { c != '\n' && c != '\r' })),
    ),
    fn(p) {
      let ((_, k, _), _, (_, v)) = p
      IniLine::Pair(k, v.trim().to_owned())
    },
  )
}

///| 单行解析器 — 按首字符分派四种行形态（无承诺歧义）。

///| 手写 `Parser::of` 分派 + 组合子子解析器的混合风格：

///| 分派本身不产生承诺（失败可回退），各分支内部的失败（如 key 已消耗

///| 但 `=` 缺失）按序列承诺语义传播。

///|

///| One-line parser — dispatches on the first character (no commitment

///| ambiguity). Hand-written `Parser::of` dispatch combined with combinator

///| sub-parsers: dispatch failures backtrack freely, while in-branch failures

///| (e.g. `=` missing after a consumed key) propagate as sequence commitments.

fn ini_line() -> @core.Parser[IniLine] noraise {
  @core.Parser::of(fn(state) {
    let saved_offset = state.offset
    let saved_pos = state.pos
    let _ = (ws().run)(state)
    match state.peek() {
      Some('[') => (section_line().run)(state)
      Some(';') | Some('#') => (comment_line().run)(state)
      Some('\r') | Some('\n') => (blank_line().run)(state)
      Some(c) =>
        if is_key_char(c) {
          (pair_line().run)(state)
        } else {
          state.offset = saved_offset
          state.pos = saved_pos
          @core.Failure(
            @core.ParseError::at(pos=saved_pos, expected="INI line"),
          )
        }
      None => {
        state.offset = saved_offset
        state.pos = saved_pos
        @core.Failure(@core.ParseError::at(pos=saved_pos, expected="INI line"))
      }
    }
  })
}

///| 解析完整 INI 文本，要求全部输入被消费。

///|

///| Parse a full INI document, requiring all input consumed.
pub fn parse_ini(input : String) -> Array[IniLine] raise @core.ParseError {
  match @sequence
    .map(
      @sequence.seq2(@sequence.many(ini_line()), @char.end_of_input()),
      fn(pair) { pair.0 },
    )
    .parse_full(input) {
    Ok(lines) => lines
    Err(e) => raise e
  }
}

///| 将行序列组装为文档结构：`Section` 开启新节，`Pair` 进入当前节，

///| 首个 `Pair` 之前若无 `Section`，键归入空名节 `""`。

///|

///| Assemble lines into a document: `Section` opens a new section,

///| `Pair` joins the current one; keys before any `Section` land in `""`.
pub fn build_ini_doc(lines : Array[IniLine]) -> IniDoc noraise {
  let sections : Array[(String, Array[(String, String)])] = []
  let mut current : Array[(String, String)] = []
  let mut started : Bool = false
  for line in lines {
    match line {
      Section(name) => {
        current = []
        started = true
        sections.push((name, current))
      }
      Pair(k, v) => {
        if !started {
          started = true
          current = []
          sections.push(("", current))
        }
        current.push((k, v))
      }
      Comment | Blank => ()
    }
  }
  { sections, }
}

///| JSON 字符串转义。

///|

///| JSON string escaping.
fn json_escape_string(s : String) -> String noraise {
  let buf : StringBuilder = StringBuilder()
  buf.write_char('"')
  for c in s {
    match c {
      '"' => buf.write_string("\\\"")
      '\\' => buf.write_string("\\\\")
      '\n' => buf.write_string("\\n")
      '\r' => buf.write_string("\\r")
      '\t' => buf.write_string("\\t")
      _ => buf.write_char(c)
    }
  }
  buf.write_char('"')
  buf.to_string()
}

///| `IniDoc` → JSON 字符串：`{"section":{"key":"value",...},...}`。

///|

///| `IniDoc` → JSON string: `{"section":{"key":"value",...},...}`.
pub fn ini_to_json(doc : IniDoc) -> String noraise {
  let buf : StringBuilder = StringBuilder()
  buf.write_char('{')
  for i, sec in doc.sections {
    if i > 0 {
      buf.write_char(',')
    }
    buf.write_string(json_escape_string(sec.0))
    buf.write_char(':')
    buf.write_char('{')
    for j, kv in sec.1 {
      if j > 0 {
        buf.write_char(',')
      }
      buf.write_string(json_escape_string(kv.0))
      buf.write_char(':')
      buf.write_string(json_escape_string(kv.1))
    }
    buf.write_char('}')
  }
  buf.write_char('}')
  buf.to_string()
}

///| 一站式入口：INI 文本 → JSON 字符串。

///|

///| One-shot entry: INI text → JSON string.
pub fn ini_to_json_string(input : String) -> String raise @core.ParseError {
  ini_to_json(build_ini_doc(parse_ini(input)))
}
