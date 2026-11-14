<div align="center">

# 🔭 Astrolabe

### 位置感知解析器组合子库 · Position-Aware Parser Combinator Library

**[中文](#-为什么选-astrolabe) &nbsp;|&nbsp; [English](#-why-astrolabe)**

_MoonBit 生态首个位置感知解析器组合子库，灵感来自 OCaml [Angstrom](https://github.com/SimonCourteaux/angstrom)_

[![mooncakes.io](https://img.shields.io/badge/mooncakes-0.5.1-orange?style=flat-square)](https://mooncakes.io/package/walkzzz/astrolabe)
[![CI](https://github.com/walkzzz/astrolabe/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/walkzzz/astrolabe/actions/workflows/ci.yml)
[![license](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](LICENSE)
[![tests](https://img.shields.io/badge/tests-198%20%C3%97%204%20backends-green?style=flat-square)]()
[![formal](https://img.shields.io/badge/formal-Z3%20verified-brightgreen?style=flat-square)](docs/formal-spec.md)
[![docs](https://img.shields.io/badge/docs-bilingual-blueviolet?style=flat-square)](docs/)

</div>

---

<!-- ═══════════════════ 中文 ═══════════════════ -->

## 🧭 为什么选 Astrolabe？

| 特性 | Astrolabe | yacc | 正则 | 手写递归下降 |
|:-----|:---------:|:----:|:----:|:----------:|
| 📍 位置追踪 | **内置** line:column(offset) | 内置 | ❌ | 手动 |
| 🔒 回溯控制 | **显式** `commit`/`alt` | 隐式 (LALR) | 隐式 | 隐式 |
| 🧱 组合性 | 小组合子 → 大解析器 | 规则文件 | 模式拼接 | 函数调用 |
| 🎯 错误信息 | 精确位置 + 上下文片段 | 精确但不友好 | 模糊 | 取决于实现 |
| 📈 学习曲线 | **低** | 高 | 低 | 中 |
| 🔬 形式化验证 | **Z3 SMT 7 性质已证** | ❌ | ❌ | ❌ |

### ✨ 特性一览

- 📍 **位置感知** — 每个解析器自动追踪行号、列号和字节偏移
- 🔒 **显式回溯控制** — `commit`/`alt` 机制避免隐式回溯的指数爆炸
- 🧱 **组合子风格** — 小函数组合成大解析器，无需外部代码生成
- 🎯 **精确错误报告** — 字符级位置 + 输入上下文片段
- 📦 **JSON/HTTP 解析器** — 开箱即用的格式解析子包
- 🔬 **Z3 形式化验证** — 核心 commit/alt 语义已机械化证明
- ✅ **4 后端全通** — wasm / wasm-gc / js / native 均通过 198 项测试，`moon check --deny-warn --target all` 零警告
- 🌐 **双语文档** — 所有公共 API 均有中英双语 `///` 注释

## 🚀 快速开始

```bash
moon add walkzzz/astrolabe
```

```moonbit
// 基础：匹配单字符
let p = @astrolabe.char('a')
match p.parse("abc") {
  Ok(c) => println("parsed: \{c}") // parsed: a
  Err(e) => println(e.format()) // 精确位置 + 上下文片段
}

// 组合：变换结果
let greeting = @astrolabe.map(@astrolabe.string("hello"), fn(s) { s.length() })
match greeting.parse("hello") {
  Ok(n) => println("length: \{n}") // length: 5
  Err(e) => println(e.format())
}

// 选择：有序回溯
let letter_or_digit = @astrolabe.alt(
  @astrolabe.char_range('a', 'z'),
  @astrolabe.char_range('0', '9'),
)

// 完整解析：要求全部输入被消费
let full = @astrolabe.bind(@astrolabe.char('a'), fn(_) {
  @astrolabe.bind(@astrolabe.char('b'), fn(_) {
    @astrolabe.pure("ab")
  })
})
match full.parse_full("ab") {
  Ok(v) => println("value: \{v}") // value: ab
  Err(e) => println(e.format())
}
```

## 🔒 核心：commit/alt 回溯控制

Astrolabe 的核心区分点：**显式回溯控制**，避免隐式回溯的指数爆炸。

```moonbit
// alt 默认回溯
@astrolabe.alt(@astrolabe.string("ab"), @astrolabe.string("ac"))
  |> .parse("ac")  // Ok("ac") — "ab" 失败后回溯，"ac" 成功

// commit 阻止回溯
@astrolabe.alt(
  @astrolabe.bind(@astrolabe.char('a'), fn(_) {
    @astrolabe.commit(@astrolabe.char('b'))  // 看到第一个字符后承诺
  }),
  @astrolabe.string("ac"),
)
  |> .parse("ac")  // Err — 'a' 已消耗，'b' 失败且已承诺，不回溯
```

> **序列自动承诺**：`bind`/`seq2` 中，如果第一个解析器成功但第二个失败，错误自动标记为已承诺。

<details>
<summary><b>📋 承诺传播表</b></summary>

| 场景 | committed 结果 | 说明 |
|:-----|:-------------:|:-----|
| `commit(p)` 失败 | `true` | 显式承诺 |
| `bind(p, f)` 第二个失败 | `true` | 序列承诺 |
| `seq2/seq3/seq4` 第 N 个失败 (N>1) | `true` | 序列承诺 |
| `alt(p1, p2)` p1 未承诺失败 | 尝试 p2 | 允许回溯 |
| `alt(p1, p2)` p1 已承诺失败 | 传播错误 | 禁止回溯 |
| `map(p, f)` p 失败 | 不变 | 不改变承诺 |
| `label(p, name)` p 失败 | 不变 | 不改变承诺 |

</details>

## 🎯 错误报告

每个解析器自动追踪行号、列号和偏移量：

```moonbit
let p = @astrolabe.string("hello")
match p.parse_full("helLO") {
  Err(e) => println(e.format_with_input("helLO"))
  // line 1, column 4 (offset 3):
  // expected hello
  //   ...helLO
  //       ^
  _ => ()
}
```

### Raise 模式

`ParseError` 是 `suberror` 类型，支持 MoonBit 原生 `raise`/`try...catch`：

```moonbit
let value : Char = try @astrolabe.parse_raise(p, "abc") catch {
  e => fail("unexpected: \{e}")
}
```

## 📦 子包

### JSON 解析器（`examples/json` 包）

JSON/HTTP 解析器以示例子包形式提供，包路径为 `walkzzz/astrolabe/examples/json`：

```moonbit
// moon.pkg
import {
  "walkzzz/astrolabe/examples/json" @json,
}
```

```moonbit
let json = @json.parse("{\"name\": \"Alice\", \"age\": 30}")
// Ok(JObj([("name", JStr("Alice")), ("age", JNum(30.0))]))
```

### HTTP 解析器（`examples/http` 包）

```moonbit
// moon.pkg
import {
  "walkzzz/astrolabe/examples/http" @http,
}
```

```moonbit
let uri = @http.parse_uri_string("https://example.com:8080/path?q=1#sec")
let req = @http.parse_request_string(
  "GET /index.html HTTP/1.1\r\nHost: example.com\r\n\r\n"
)
```

## 📖 API 一览

### 入口函数

| 函数 / 方法 | 说明 |
|:------------|:-----|
| `p.parse(input)` | 解析，允许尾部未消费 |
| `p.parse_full(input)` | 解析，要求全部消费 |
| `p.parse_raise(input)` | 解析，失败时 raise ParseError |
| `p.parse_full_raise(input)` | 解析+全消费，失败时 raise ParseError |
| `err.format()` | 格式化错误 |
| `err.format_with_input(input)` | 错误 + 输入上下文 |
| `err.commit()` | 返回 committed=true 的副本 |

### 基础组合子

| 组合子 | 返回 | 说明 |
|:-------|:----:|:-----|
| `char(c)` | `Parser[Char]` | 匹配单个字符 |
| `string(s)` | `Parser[String]` | 匹配字符串字面量 |
| `any_char()` | `Parser[Char]` | 匹配任意字符 |
| `take(n)` | `Parser[String]` | 消费 n 个字符 |
| `take_while(pred)` | `Parser[String]` | 消费连续满足谓词的字符 |
| `take_while1(pred, label~)` | `Parser[String]` | 同上，至少匹配一个 |
| `satisfy(pred, label~)` | `Parser[Char]` | 满足谓词的字符 |
| `end_of_input()` | `Parser[Unit]` | 仅在 EOF 成功 |
| `peek(p)` | `Parser[T]` | 前瞻不消费 |
| `skip(p)` | `Parser[Unit]` | 消费但丢弃结果 |
| `char_range(lo, hi)` | `Parser[Char]` | 字符范围 |
| `char_class(pred, label)` | `Parser[Char]` | 带标签的字符类 |

### 组合组合子

| 组合子 | 说明 |
|:-------|:-----|
| `map(p, f)` | 变换结果 |
| `bind(p, f)` | 序列，第二个依赖第一个 |
| `pure(v)` | 总是成功（`return_` 已弃用，请用 `pure`） |
| `seq2` / `seq3` / `seq4` | 序列收集 |
| `many(p)` / `many1(p)` | 零次或多次 / 一次或多次 |
| `sep_by(p, sep)` / `sep_by1` | 分隔符分隔 |
| `count(n, p)` | 精确 n 次 |
| `many_till(p, end)` | 重复直到 end 匹配 |
| `option(p, default)` | 尝试 p，失败返回 default |
| `skip_many(p)` / `skip_many1(p)` | 重复匹配但丢弃结果 |
| `between(open, p, close)` | 匹配 open + p + close，只返回 p |

### 控制组合子

| 组合子 | 说明 |
|:-------|:-----|
| `commit(p)` | 标记失败为已承诺 |
| `alt(p1, p2)` | 有序选择（回溯控制） |
| `choice(parsers)` | N 路有序选择 |
| `label(p, name)` | 替换错误信息 |
| `not_followed_by(p, label~)` | 仅当 p 失败时成功（不消耗输入） |
| `fix(f)` | 不动点组合子，支持递归文法 |

<details>
<summary><b>🌐 HTTP 类型方法</b></summary>

| 方法 | 说明 |
|:-----|:-----|
| `method.to_string()` | `"GET"`, `"POST"` 等 |
| `version.to_string()` | `"HTTP/1.1"` 等 |
| `request_line.to_string()` | `"GET /path HTTP/1.1"` |
| `header.to_string()` | `"Content-Type: text/html"` |
| `request.to_string()` | 完整 HTTP 请求文本 |
| `uri.to_string()` | 完整 URI 字符串 |

</details>

## 🧪 MoonBit 惯用法

| 特性 | 使用方式 |
|:-----|:---------|
| `#derive(Eq, Debug)` | Pos/State/JValue/HTTP 类型自动生成 |
| `suberror ParseError` | 自动向上转型为 Error，支持 raise/try...catch |
| `ParseError::pos()/expected()/committed()/context()` | 访问器方法 |
| `impl Show` + `extend with Show::{output, to_string}` | Method/Version 实现 Show |
| `TypeName::method(self, ...)` | 所有关键操作以方法定义 |
| `ParseError::commit()` | 消除 7 处 `committed: true` 重复构造 |
| `Parser::parse_raise/parse_full_raise` | raise-based API |
| `Parser::of(fn)` | 通用扩展点，将任意函数包装为 Parser |
| `#alias(return_, deprecated)` | 弃用别名机制 |
| `#non_exhaustive` | Method 枚举前向兼容 |
| `#inline` | 外观包装器零成本抽象 |
| 递归 step 函数 | many/many1/sep_by/count/many_till 尾递归 |
| peek/save-restore 模式 | 保存/恢复 state.offset 和 state.pos |

## ⚡ 性能基准

```bash
moon bench --target native benchmarks/
```

| 类别 | 示例 | 耗时 |
|:-----|:-----|-----:|
| 基础 | `char` × 1000 | ~132 μs |
| 组合 | `map` × 1000 | ~177 μs |
| 组合 | `bind` × 1000 | ~378 μs |
| 控制 | `commit` vs 无 commit | 1.2 μs vs 48 μs |
| JSON | `json_object_100` | ~2.1 ms |
| HTTP | `http_request_5_headers` | ~109 μs |

> 上表为历史实测示例数据；当前 25 项基准以 `moon bench --target native benchmarks/` 实时结果为准。

## 🔬 形式化验证

核心 commit/alt 回溯语义的关键不变量，通过 MoonBit 的 proof 条件（编译期 SMT 求解自动验证）静态证明，详见 [docs/formal-spec.md](docs/formal-spec.md)。

| 性质 | 含义 | 状态 |
|:-----|:-----|:----:|
| P1 | `commit` 总是将 `committed` 设为 `true` | ✅ |
| P2a | `alt` 在未承诺失败时回溯 | ✅ |
| P2b | `alt` 在已承诺失败时不回溯 | ✅ |
| P3b | `bind` 序列承诺 | ✅ |
| — | 偏移量前进保持非负 | ✅ |
| — | 剩余字符数保持非负 | ✅ |
| — | EOF 判定条件正确（`offset >= length`） | ✅ |

## 📂 项目结构

```
astrolabe/
├── astrolabe.mbt  根包门面 — pub using 扁平化导出全部公共 API
├── core/          Pos, State, ParseError, Parser[T]
├── char/          char, string, take, satisfy, take_while, ...
├── sequence/      map, bind, seq2-seq4, many, sep_by, option, between, ...
├── branch/        commit, alt, choice, label, not_followed_by, fix
├── proof/         形式化验证 — 7 个证明函数（SMT 支持的 proof 条件）
├── benchmarks/    25 个基准测试
├── examples/      uri, json, http, csv_header, calc 五个示例包
├── cmd/main/      CLI 演示
└── docs/          API 参考、教程、迁移指南、形式化规范、路线图
```

## 📚 文档

| 文档 | 说明 |
|:-----|:-----|
| [API 参考](docs/api.md) | 所有公开函数签名 + 示例 |
| [教程](docs/tutorial.md) | 从零到 JSON 解析器 |
| [迁移指南](docs/migration.md) | 从 yacc / regex / nom / Angstrom 迁移 |
| [形式化规范](docs/formal-spec.md) | Z3 验证的核心语义性质 |
| [竞品对比](docs/comparison.md) | 10 库 parser 竞品矩阵（mooncakes 实测核查） |
| [性能基准报告](docs/performance_report.md) | 25 基准实测 + stdlib JSON 对照（commit 57 倍收益量化） |
| [路线图](docs/roadmap.md) | v0.1.0→v1.0.0 迭代计划 |
| [变更日志](CHANGELOG.md) | 版本历史 |
| [贡献指南](CONTRIBUTING.md) | 开发流程 |
| [申报书](docs/proposal.md) | 季度评选申报材料 |
| [陷阱目录](docs/pitfall-catalog.md) | MoonBit 语法演进 + 解析器语义实测陷阱（15 条） |
| [工程评估报告](docs/assessment.md) | 实测数据与竞品分析 |

## License

[MIT](LICENSE)

---

<!-- ═══════════════════ English ═══════════════════ -->

## 🧭 Why Astrolabe?

| Feature | Astrolabe | yacc | Regex | Hand-written RD |
|:--------|:---------:|:----:|:-----:|:--------------:|
| 📍 Position tracking | **Built-in** line:column(offset) | Built-in | ❌ | Manual |
| 🔒 Backtrack control | **Explicit** `commit`/`alt` | Implicit (LALR) | Implicit | Implicit |
| 🧱 Composability | Small combinators → big parsers | Grammar files | Pattern concat | Function calls |
| 🎯 Error messages | Precise position + context snippet | Precise but unfriendly | Vague | Depends |
| 📈 Learning curve | **Low** | High | Low | Medium |
| 🔬 Formal verification | **Z3 SMT 7 properties proved** | ❌ | ❌ | ❌ |

### ✨ Feature Highlights

- 📍 **Position-aware** — Every parser auto-tracks line, column, and byte offset
- 🔒 **Explicit backtracking** — `commit`/`alt` mechanism prevents exponential blowup
- 🧱 **Combinator style** — Compose small functions into big parsers, no code generation
- 🎯 **Precise errors** — Character-level position + input context snippets
- 📦 **JSON/HTTP parsers** — Ready-to-use format parsing subpackages
- 🔬 **Z3 formal verification** — Core commit/alt semantics mechanically proved
- ✅ **4 backends pass** — wasm / wasm-gc / js / native all pass 198 tests, `moon check --deny-warn --target all` with zero warnings
- 🌐 **Bilingual docs** — All public APIs have Chinese+English `///` comments

## 🚀 Quick Start

```bash
moon add walkzzz/astrolabe
```

```moonbit
let p = @astrolabe.char('a')
inspect(p.parse("abc"), content="Ok(a)")

let greeting = @astrolabe.map(@astrolabe.string("hello"), fn(s) { s.length() })
inspect(greeting.parse("hello"), content="Ok(5)")

let letter_or_digit = @astrolabe.alt(
  @astrolabe.char_range('a', 'z'),
  @astrolabe.char_range('0', '9'),
)

let full = @astrolabe.bind(@astrolabe.char('a'), fn(_) {
  @astrolabe.bind(@astrolabe.char('b'), fn(_) {
    @astrolabe.pure("ab")
  })
})
match full.parse_full("ab") {
  Ok(v) => println("value: \{v}") // value: ab
  Err(e) => println(e.format())
}
```

## 🔒 Core: commit/alt Backtrack Control

Astrolabe's key differentiator: **explicit backtracking control** prevents exponential blowup from implicit backtracking.

```moonbit
// alt backtracks by default
@astrolabe.alt(@astrolabe.string("ab"), @astrolabe.string("ac"))
  |> .parse("ac")  // Ok("ac") — "ab" fails, backtracks, "ac" succeeds

// commit prevents backtracking
@astrolabe.alt(
  @astrolabe.bind(@astrolabe.char('a'), fn(_) {
    @astrolabe.commit(@astrolabe.char('b'))  // commit after consuming first char
  }),
  @astrolabe.string("ac"),
)
  |> .parse("ac")  // Err — 'a' consumed, 'b' fails with commitment, no backtrack
```

> **Sequence commits automatically**: In `bind`/`seq2`, if the first parser succeeds but the second fails, the error is automatically marked as committed.

<details>
<summary><b>📋 Commitment Propagation Table</b></summary>

| Scenario | committed result | Note |
|:---------|:---------------:|:-----|
| `commit(p)` fails | `true` | Explicit commit |
| `bind(p, f)` second fails | `true` | Sequence commits |
| `seq2/seq3/seq4` Nth fails (N>1) | `true` | Sequence commits |
| `alt(p1, p2)` p1 fails uncommitted | Try p2 | Backtrack allowed |
| `alt(p1, p2)` p1 fails committed | Propagate error | Backtrack blocked |
| `map(p, f)` p fails | Unchanged | Commitment preserved |
| `label(p, name)` p fails | Unchanged | Commitment preserved |

</details>

## 🎯 Error Reporting

Every parser auto-tracks line, column, and offset:

```moonbit
let p = @astrolabe.string("hello")
match p.parse_full("helLO") {
  Err(e) => println(e.format_with_input("helLO"))
  // line 1, column 4 (offset 3):
  // expected hello
  //   ...helLO
  //       ^
  _ => ()
}
```

### Raise Pattern

`ParseError` is a `suberror`, supporting MoonBit's native `raise`/`try...catch`:

```moonbit
let value : Char = try @astrolabe.parse_raise(p, "abc") catch {
  e => fail("unexpected: \{e}")
}
```

## 📦 Subpackages

### JSON Parser (`examples/json` package)

The JSON/HTTP parsers ship as example subpackages, located at `walkzzz/astrolabe/examples/json`:

```moonbit
// moon.pkg
import {
  "walkzzz/astrolabe/examples/json" @json,
}
```

```moonbit
let json = @json.parse("{\"name\": \"Alice\", \"age\": 30}")
// Ok(JObj([("name", JStr("Alice")), ("age", JNum(30.0))]))
```

### HTTP Parser (`examples/http` package)

```moonbit
// moon.pkg
import {
  "walkzzz/astrolabe/examples/http" @http,
}
```

```moonbit
let uri = @http.parse_uri_string("https://example.com:8080/path?q=1#sec")
let req = @http.parse_request_string(
  "GET /index.html HTTP/1.1\r\nHost: example.com\r\n\r\n"
)
```

## 📖 API Reference

### Entry Points

| Function / Method | Description |
|:------------------|:------------|
| `p.parse(input)` | Parse, allow trailing input |
| `p.parse_full(input)` | Parse, require full consumption |
| `p.parse_raise(input)` | Parse, raise ParseError on failure |
| `p.parse_full_raise(input)` | Parse+full, raise ParseError on failure |
| `err.format()` | Format error |
| `err.format_with_input(input)` | Error + input context |
| `err.commit()` | Return copy with committed=true |

### Basic Combinators

| Combinator | Returns | Description |
|:-----------|:-------:|:------------|
| `char(c)` | `Parser[Char]` | Match a single character |
| `string(s)` | `Parser[String]` | Match a string literal |
| `any_char()` | `Parser[Char]` | Match any character |
| `take(n)` | `Parser[String]` | Consume n characters |
| `take_while(pred)` | `Parser[String]` | Consume consecutive chars matching pred |
| `take_while1(pred, label~)` | `Parser[String]` | Same, requires at least one match |
| `satisfy(pred, label~)` | `Parser[Char]` | Character satisfying predicate |
| `end_of_input()` | `Parser[Unit]` | Succeed only at EOF |
| `peek(p)` | `Parser[T]` | Look ahead without consuming |
| `skip(p)` | `Parser[Unit]` | Consume but discard result |
| `char_range(lo, hi)` | `Parser[Char]` | Character in range |
| `char_class(pred, label)` | `Parser[Char]` | Character class with label |

### Compose Combinators

| Combinator | Description |
|:-----------|:------------|
| `map(p, f)` | Transform result |
| `bind(p, f)` | Sequence, second depends on first |
| `pure(v)` | Always succeed (`return_` deprecated) |
| `seq2` / `seq3` / `seq4` | Sequence collection |
| `many(p)` / `many1(p)` | Zero-or-more / one-or-more |
| `sep_by(p, sep)` / `sep_by1` | Separator-separated |
| `count(n, p)` | Exactly n times |
| `many_till(p, end)` | Repeat until end matches |
| `option(p, default)` | Try p, return default on failure |
| `skip_many(p)` / `skip_many1(p)` | Repeat discarding results |
| `between(open, p, close)` | Match open + p + close, return only p |

### Control Combinators

| Combinator | Description |
|:-----------|:------------|
| `commit(p)` | Mark failure as committed |
| `alt(p1, p2)` | Ordered choice (backtrack control) |
| `choice(parsers)` | N-way ordered choice |
| `label(p, name)` | Replace error message |
| `not_followed_by(p, label~)` | Succeed only when p fails (no consumption) |
| `fix(f)` | Fixpoint combinator for recursive grammars |

<details>
<summary><b>🌐 HTTP Type Methods</b></summary>

| Method | Description |
|:-------|:------------|
| `method.to_string()` | `"GET"`, `"POST"`, etc. |
| `version.to_string()` | `"HTTP/1.1"`, etc. |
| `request_line.to_string()` | `"GET /path HTTP/1.1"` |
| `header.to_string()` | `"Content-Type: text/html"` |
| `request.to_string()` | Full HTTP request text |
| `uri.to_string()` | Full URI string |

</details>

## 🧪 MoonBit Idioms

| Feature | Usage |
|:--------|:------|
| `#derive(Eq, Debug)` | Auto-generated for Pos/State/JValue/HTTP types |
| `suberror ParseError` | Auto-upcasts to Error, enables raise/try...catch |
| `ParseError::pos()/expected()/committed()/context()` | Accessor methods |
| `impl Show` + `extend with Show::{output, to_string}` | Method/Version impl Show |
| `TypeName::method(self, ...)` | All key operations defined as methods |
| `ParseError::commit()` | Eliminates 7 `committed: true` repetitions |
| `Parser::parse_raise/parse_full_raise` | Raise-based API |
| `Parser::of(fn)` | Universal extension point |
| `#alias(return_, deprecated)` | Deprecated alias mechanism |
| `#non_exhaustive` | Forward-compatible Method enum |
| `#inline` | Zero-cost abstraction on facades |
| Recursive step functions | Tail-recursive for many/many1/sep_by/count/many_till |
| peek/save-restore pattern | Save/restore state.offset and state.pos |

## ⚡ Benchmarks

```bash
moon bench --target native benchmarks/
```

| Category | Example | Time |
|:---------|:--------|-----:|
| Basic | `char` × 1000 | ~132 μs |
| Compose | `map` × 1000 | ~177 μs |
| Compose | `bind` × 1000 | ~378 μs |
| Control | `commit` vs no commit | 1.2 μs vs 48 μs |
| JSON | `json_object_100` | ~2.1 ms |
| HTTP | `http_request_5_headers` | ~109 μs |

> Figures above are historical sample measurements; run `moon bench --target native benchmarks/` for live numbers (25 benchmarks).

## 🔬 Formal Verification

Key invariants of the core commit/alt backtracking semantics are statically proved via MoonBit proof conditions (automatically verified by the SMT backend at compile time). See [docs/formal-spec.md](docs/formal-spec.md).

| Property | Meaning | Status |
|:---------|:--------|:------:|
| P1 | `commit` always sets `committed = true` | ✅ |
| P2a | `alt` backtracks on uncommitted failure | ✅ |
| P2b | `alt` does not backtrack on committed failure | ✅ |
| P3b | `bind` sequence commits | ✅ |
| — | Offset advance stays non-negative | ✅ |
| — | Remaining chars stay non-negative | ✅ |
| — | EOF condition correct (`offset >= length`) | ✅ |

## 📂 Project Structure

```
astrolabe/
├── astrolabe.mbt  Root facade — flattens all public API via `pub using`
├── core/          Pos, State, ParseError, Parser[T]
├── char/          char, string, take, satisfy, take_while, ...
├── sequence/      map, bind, seq2-seq4, many, sep_by, option, between, ...
├── branch/        commit, alt, choice, label, not_followed_by, fix
├── proof/         Formal verification — 7 proof functions (SMT-backed proof conditions)
├── benchmarks/    25 benchmarks
├── examples/      Five example packages: uri, json, http, csv_header, calc
├── cmd/main/      CLI demo
└── docs/          API reference, tutorial, migration guide, formal spec, roadmap
```

## 📚 Documentation

| Doc | Description |
|:----|:------------|
| [API Reference](docs/api.md) | All public function signatures + examples |
| [Tutorial](docs/tutorial.md) | From zero to JSON parser |
| [Migration Guide](docs/migration.md) | From yacc / regex / nom / Angstrom |
| [Formal Spec](docs/formal-spec.md) | Z3-verified core semantic properties |
| [Comparison](docs/comparison.md) | 10-library parser matrix (mooncakes-verified) |
| [Performance Report](docs/performance_report.md) | 25 benches + stdlib JSON comparison |
| [Roadmap](docs/roadmap.md) | v0.1.0→v1.0.0 iteration plan |
| [Changelog](CHANGELOG.md) | Version history |
| [Contributing](CONTRIBUTING.md) | Development workflow |
| [Proposal](docs/proposal.md) | Quarterly award submission |
| [Pitfall Catalog](docs/pitfall-catalog.md) | MoonBit evolution & parser-semantics pitfalls (measured) |
| [Assessment](docs/assessment.md) | Measured data & competitor analysis |

## License

[MIT](LICENSE)
