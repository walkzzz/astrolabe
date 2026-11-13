# 教程：从零到 JSON 解析器

> **[中文](#教程从零到-json-解析器) | [English](#tutorial-from-zero-to-json-parser)**

逐步引导你用 Astrolabe 构建一个 JSON 解析器。完成后你将理解核心组合子及其组合方式。

## 前置准备

```bash
moon add walkzzz/astrolabe
```

## 1. 你的第一个解析器

最简单的解析器匹配单个字符：

```moonbit
let a = @astrolabe.char('a')

inspect!(a.parse("abc"), content="Ok('a')")
inspect!(a.parse("bbc"), content="Err(ParseError)")
```

`parse` 允许尾部有未消费的输入。使用 `parse_full` 要求全部输入被消费：

```moonbit
inspect!(a.parse_full("abc"), content="Err(ParseError)")
inspect!(a.parse_full("a"), content="Ok('a')")
```

## 2. 用 `map` 组合解析器

`map` 用纯函数变换解析器的结果：

```moonbit
let upper = @astrolabe.map(@astrolabe.char('a'), fn(c) { c.to_upper() })
inspect!(upper.parse("abc"), content="Ok('A')")
```

## 3. 用 `bind` 顺序组合

`bind` 链接两个解析器，第二个依赖第一个的结果：

```moonbit
let two_chars = @astrolabe.bind(@astrolabe.char('a'), fn(a) {
  @astrolabe.bind(@astrolabe.char('b'), fn(b) {
    @astrolabe.pure([a, b])
  })
})
inspect!(two_chars.parse("abc"), content="Ok(['a', 'b'])")
```

对于独立的解析器，`seq2` 更简洁：

```moonbit
let pair = @astrolabe.seq2(@astrolabe.char('a'), @astrolabe.char('b'))
inspect!(pair.parse("abc"), content="Ok(('a', 'b'))")
```

## 4. 用 `alt` 做选择

`alt` 先尝试第一个解析器，失败时回溯再尝试第二个：

```moonbit
let letter = @astrolabe.alt(
  @astrolabe.char_range('a', 'z'),
  @astrolabe.char_range('A', 'Z'),
)
inspect!(letter.parse("H"), content="Ok('H')")
inspect!(letter.parse("z"), content="Ok('z')")
```

## 5. 用 `many` / `many1` 重复匹配

```moonbit
let digits = @astrolabe.many1(@astrolabe.char_range('0', '9'))
let result = digits.parse("123abc")
// Ok(['1', '2', '3'])

let digits_str = @astrolabe.map(digits, fn(arr) {
  arr.fold(fn(acc, c) { acc + c.to_string() }, init="")
})
inspect!(digits_str.parse("123abc"), content="Ok(\"123\")")
```

更高效的方式 — 用 `take_while1` 直接消费连续数字：

```moonbit
let fast_digits = @astrolabe.take_while1(fn(c) { c >= '0' && c <= '9' }, label="digit")
inspect!(fast_digits.parse("123abc"), content="Ok(\"123\")")
```

## 6. 用 `sep_by1` 匹配分隔值

```moonbit
let csv = @astrolabe.sep_by1(@astrolabe.char_range('a', 'z'), @astrolabe.char(','))
let result = csv.parse("a,b,c")
// Ok(['a', 'b', 'c'])
```

## 7. 用 `label` 自定义错误信息

```moonbit
let digit = @astrolabe.label(@astrolabe.char_range('0', '9'), "digit")
match digit.parse_full("x") {
  Err(e) => println(@astrolabe.format_error(e))
  // line 1, column 1 (offset 0):
  // expected digit
  _ => ()
}
```

## 8. 承诺机制：防止指数级回溯

这是 Astrolabe 来自 Angstrom 的核心洞察。考虑匹配两字符前缀：

```moonbit
// 糟糕：alt 回溯，尝试所有组合
let prefix = @astrolabe.alt(
  @astrolabe.string("ab"),
  @astrolabe.string("ac"),
)
// 输入 "ad" → 尝试 "ab"（匹配 'a' 后失败），回溯，尝试 "ac"（又匹配 'a' 后失败）
// 多个备选时，这是指数级的！
```

用 `commit`，一旦消费了 'a'，就提交不再回溯：

```moonbit
// 好的做法：commit 阻止回溯到已消费的输入
let prefix = @astrolabe.alt(
  @astrolabe.bind(@astrolabe.char('a'), fn(_) {
    @astrolabe.commit(@astrolabe.alt(
      @astrolabe.char('b'),
      @astrolabe.char('c'),
    ))
  }),
  // 不以 'a' 开头的其他备选
)
```

**经验法则**：当你已消费足够多的输入确定自己在正确的分支时，使用 `commit`。`bind` 组合子在第二个解析器失败时自动提交（"序列提交"）。

## 9. 构建迷你 JSON 解析器

现在让我们逐步构建一个简化的 JSON 解析器。

### 9.1 空白

```moonbit
fn ws() -> @astrolabe.Parser[Unit] {
  @astrolabe.skip(
    @astrolabe.many(
      @astrolabe.satisfy(fn(c) { c == ' ' || c == '\t' || c == '\n' || c == '\r' }, label="whitespace"),
    ),
  )
}
```

### 9.2 Null 与 Bool

```moonbit
let null_p = @astrolabe.map(@astrolabe.string("null"), fn(_) { "null" })

let bool_p = @astrolabe.alt(
  @astrolabe.map(@astrolabe.string("true"), fn(_) { true }),
  @astrolabe.map(@astrolabe.string("false"), fn(_) { false }),
)
```

### 9.3 字符串

```moonbit
let string_p : @astrolabe.Parser[String] = @astrolabe.Parser::of(fn(state) {
  match @astrolabe.char('"').parse(state.input) {
    Ok(_) => {
      let body = @astrolabe.many1(@astrolabe.satisfy(fn(c) { c != '"' }, label="string char"))
      @astrolabe.bind(body, fn(chars) {
        @astrolabe.map(@astrolabe.char('"'), fn(_) {
          chars.fold(fn(acc, c) { acc + c.to_string() }, init="")
        })
      })
      |> .parse(state.input)
    }
    Err(e) => Err(e)
  }
})
```

### 9.4 完整解析器

`@astrolabe/json` 中的真实实现处理了所有 JSON 类型、转义序列和嵌套结构。直接使用：

```moonbit
let result = @astrolabe/json.parse("{\"name\": \"Alice\"}")
match result {
  Ok(v) => println(v.stringify())
  Err(e) => println(@astrolabe.format_error_with_input(e, input))
}
```

## 10. 更多组合子

v0.1.17 新增组合子速览：

| 组合子 | 用途 |
|--------|------|
| `take_while(pred)` | 消费连续满足谓词的字符（总是成功） |
| `take_while1(pred, label~)` | 同上但至少匹配一个 |
| `option(p, default)` | 尝试 `p`，失败返回 `default` |
| `skip_many(p)` / `skip_many1(p)` | 重复匹配但丢弃结果 |
| `between(open, p, close)` | 匹配 `open` + `p` + `close`，只返回 `p` |
| `not_followed_by(p)` | 仅当 `p` 失败时成功（不消耗输入） |
| `fix(f)` | 不动点组合子，支持递归文法 |

## 11. 下一步

- 阅读 [API 参考](./api.md) 了解完整组合子列表
- 查看 `examples/` 目录的 URI、CSV、计算器示例
- 阅读 [迁移指南](./migration.md) 从 yacc 或其他工具迁移

---

# Tutorial: From Zero to JSON Parser

A step-by-step guide to building a JSON parser with Astrolabe. By the end, you'll understand the core combinators and how they compose.

## Prerequisites

```bash
moon add walkzzz/astrolabe
```

## 1. Your First Parser

The simplest parser matches a single character:

```moonbit
let a = @astrolabe.char('a')

inspect!(a.parse("abc"), content="Ok('a')")
inspect!(a.parse("bbc"), content="Err(ParseError)")
```

`parse` allows trailing input. Use `parse_full` to require the entire input is consumed:

```moonbit
inspect!(a.parse_full("abc"), content="Err(ParseError)")
inspect!(a.parse_full("a"), content="Ok('a')")
```

## 2. Combining Parsers with `map`

`map` transforms a parser's result:

```moonbit
let upper = @astrolabe.map(@astrolabe.char('a'), fn(c) { c.to_upper() })
inspect!(upper.parse("abc"), content="Ok('A')")
```

## 3. Sequencing with `bind`

`bind` chains parsers where the second depends on the first:

```moonbit
let two_chars = @astrolabe.bind(@astrolabe.char('a'), fn(a) {
  @astrolabe.bind(@astrolabe.char('b'), fn(b) {
    @astrolabe.pure([a, b])
  })
})
inspect!(two_chars.parse("abc"), content="Ok(['a', 'b'])")
```

For independent parsers, `seq2` is cleaner:

```moonbit
let pair = @astrolabe.seq2(@astrolabe.char('a'), @astrolabe.char('b'))
inspect!(pair.parse("abc"), content="Ok(('a', 'b'))")
```

## 4. Choice with `alt`

`alt` tries the first parser, backtracks on failure to try the second:

```moonbit
let letter = @astrolabe.alt(
  @astrolabe.char_range('a', 'z'),
  @astrolabe.char_range('A', 'Z'),
)
inspect!(letter.parse("H"), content="Ok('H')")
inspect!(letter.parse("z"), content="Ok('z')")
```

## 5. Repetition with `many` / `many1`

```moonbit
let digits = @astrolabe.many1(@astrolabe.char_range('0', '9'))
let result = digits.parse("123abc")
// Ok(['1', '2', '3'])

let digits_str = @astrolabe.map(digits, fn(arr) {
  arr.fold(fn(acc, c) { acc + c.to_string() }, init="")
})
inspect!(digits_str.parse("123abc"), content="Ok(\"123\")")
```

More efficient — use `take_while1` to consume consecutive digits directly:

```moonbit
let fast_digits = @astrolabe.take_while1(fn(c) { c >= '0' && c <= '9' }, label="digit")
inspect!(fast_digits.parse("123abc"), content="Ok(\"123\")")
```

## 6. Separated Values with `sep_by1`

```moonbit
let csv = @astrolabe.sep_by1(@astrolabe.char_range('a', 'z'), @astrolabe.char(','))
let result = csv.parse("a,b,c")
// Ok(['a', 'b', 'c'])
```

## 7. Error Messages with `label`

```moonbit
let digit = @astrolabe.label(@astrolabe.char_range('0', '9'), "digit")
match digit.parse_full("x") {
  Err(e) => println(@astrolabe.format_error(e))
  // line 1, column 1 (offset 0):
  // expected digit
  _ => ()
}
```

## 8. Commitment: Preventing Exponential Backtracking

This is Astrolabe's key insight from Angstrom. Consider parsing a two-character prefix:

```moonbit
// BAD: alt backtracks, tries all combinations
let prefix = @astrolabe.alt(
  @astrolabe.string("ab"),
  @astrolabe.string("ac"),
)
// Input "ad" → tries "ab" (fails after 'a'), backtracks, tries "ac" (fails after 'a')
// With many alternatives, this is exponential!
```

With `commit`, once we've consumed 'a', we commit and don't backtrack:

```moonbit
// GOOD: commit prevents backtracking past consumed input
let prefix = @astrolabe.alt(
  @astrolabe.bind(@astrolabe.char('a'), fn(_) {
    @astrolabe.commit(@astrolabe.alt(
      @astrolabe.char('b'),
      @astrolabe.char('c'),
    ))
  }),
  // other alternatives that DON'T start with 'a'
)
```

**Rule of thumb**: Use `commit` after you've consumed enough input to know you're in the right branch. The `bind` combinator automatically commits when the second parser fails ("sequence commits").

## 9. Building a Mini JSON Parser

Now let's build a simplified JSON parser step by step.

### 9.1 Whitespace

```moonbit
fn ws() -> @astrolabe.Parser[Unit] {
  @astrolabe.skip(
    @astrolabe.many(
      @astrolabe.satisfy(fn(c) { c == ' ' || c == '\t' || c == '\n' || c == '\r' }, label="whitespace"),
    ),
  )
}
```

### 9.2 Null & Bool

```moonbit
let null_p = @astrolabe.map(@astrolabe.string("null"), fn(_) { "null" })

let bool_p = @astrolabe.alt(
  @astrolabe.map(@astrolabe.string("true"), fn(_) { true }),
  @astrolabe.map(@astrolabe.string("false"), fn(_) { false }),
)
```

### 9.3 Strings

```moonbit
let string_p : @astrolabe.Parser[String] = @astrolabe.Parser::of(fn(state) {
  match @astrolabe.char('"').parse(state.input) {
    Ok(_) => {
      let body = @astrolabe.many1(@astrolabe.satisfy(fn(c) { c != '"' }, label="string char"))
      @astrolabe.bind(body, fn(chars) {
        @astrolabe.map(@astrolabe.char('"'), fn(_) {
          chars.fold(fn(acc, c) { acc + c.to_string() }, init="")
        })
      })
      |> .parse(state.input)
    }
    Err(e) => Err(e)
  }
})
```

### 9.4 The Full Parser

The real implementation in `@astrolabe/json` handles all JSON types, escape sequences, and nested structures. Use it directly:

```moonbit
let result = @astrolabe/json.parse("{\"name\": \"Alice\"}")
match result {
  Ok(v) => println(v.stringify())
  Err(e) => println(@astrolabe.format_error_with_input(e, input))
}
```

## 10. New Combinators Quick Reference

New in v0.1.17:

| Combinator | Purpose |
|------------|---------|
| `take_while(pred)` | Consume consecutive chars matching predicate (always succeeds) |
| `take_while1(pred, label~)` | Same but requires at least one match |
| `option(p, default)` | Try `p`, return `default` on failure |
| `skip_many(p)` / `skip_many1(p)` | Repeat `p` discarding results |
| `between(open, p, close)` | Match `open` + `p` + `close`, return only `p` |
| `not_followed_by(p)` | Succeed only when `p` fails (no consumption) |
| `fix(f)` | Fixpoint combinator for recursive grammars |

## 11. Next Steps

- Read the [API Reference](./api.md) for the full combinator list
- Check `examples/` for URI, CSV, and arithmetic calculator examples
- Read the [Migration Guide](./migration.md) if coming from yacc or other parser tools
