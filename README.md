<div align="center">

# Astrolabe

**位置感知解析器组合子库** | Position-Aware Parser Combinator Library

MoonBit 生态首个位置感知解析器组合子库，灵感来自 OCaml [Angstrom](https://github.com/SimonCourteaux/angstrom)

[![mooncakes.io](https://img.shields.io/badge/mooncakes-0.1.15-orange)](https://mooncakes.io/package/walkzzz/astrolabe)
[![license](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
[![tests](https://img.shields.io/badge/tests-122%20%C3%97%204%20backends-green)]()
[![formal](https://img.shields.io/badge/formal-Z3%20verified-brightgreen)](docs/formal-spec.md)
[![docs](https://img.shields.io/badge/docs-bilingual-blueviolet)](docs/)

</div>

---

## 为什么选 Astrolabe？ | Why Astrolabe?

| 特性 | Astrolabe | yacc | 正则 | 手写递归下降 |
|------|-----------|------|------|-------------|
| 位置追踪 | 内置 line:column(offset) | 内置 | 无 | 手动 |
| 回溯控制 | `commit`/`alt` 显式 | 隐式（LALR） | 隐式 | 隐式 |
| 组合性 | 小组合子 → 大解析器 | 规则文件 | 模式拼接 | 函数调用 |
| 错误信息 | 精确位置 + 上下文片段 | 精确但不友好 | 模糊 | 取决于实现 |
| 学习曲线 | 低 | 高 | 低 | 中 |
| 形式化验证 | Z3 SMT 7 性质已证 | 无 | 无 | 无 |

## 特性 | Features

- **位置感知** — 每个解析器自动追踪行号、列号和字节偏移
- **显式回溯控制** — `commit`/`alt` 机制避免隐式回溯的指数爆炸
- **组合子风格** — 小函数组合成大解析器，无需外部代码生成
- **精确错误报告** — 字符级位置 + 输入上下文片段
- **JSON/HTTP 解析器** — 开箱即用的格式解析子包
- **Z3 形式化验证** — 核心 commit/alt 语义已机械化证明
- **4 后端全通** — wasm / wasm-gc / js / native 均通过 122 项测试
- **双语文档** — 所有公共 API 均有中英双语 `///` 注释

## 快速开始 | Quick Start

```bash
moon add walkzzz/astrolabe
```

```moonbit
// 基础：匹配单字符
let p = @astrolabe.char('a')
inspect!(p.parse("abc"), content="Ok('a')")

// 组合：变换结果
let greeting = @astrolabe.map(@astrolabe.string("hello"), fn(s) { s.length() })
inspect!(greeting.parse("hello"), content="Ok(5)")

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
inspect!(full.parse_full("ab"), content="Ok(\"ab\")")
```

## 核心：commit/alt 回溯控制 | Commitment Semantics

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

**序列自动承诺**：`bind`/`seq2` 中，如果第一个解析器成功但第二个失败，错误自动标记为已承诺。

### 承诺传播表 | Commitment Propagation

| 场景 | committed 结果 | 说明 |
|------|---------------|------|
| `commit(p)` 失败 | `true` | 显式承诺 |
| `bind(p, f)` 第二个失败 | `true` | 序列承诺 |
| `seq2/seq3/seq4` 第 N 个失败 (N>1) | `true` | 序列承诺 |
| `alt(p1, p2)` p1 未承诺失败 | 尝试 p2 | 允许回溯 |
| `alt(p1, p2)` p1 已承诺失败 | 传播错误 | 禁止回溯 |
| `map(p, f)` p 失败 | 不变 | 不改变承诺 |
| `label(p, name)` p 失败 | 不变 | 不改变承诺 |

## 错误报告 | Error Reporting

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

## 子包 | Subpackages

### JSON 解析器

```moonbit
let json = @astrolabe/json.parse("{\"name\": \"Alice\", \"age\": 30}")
// Ok(JObj([("name", JStr("Alice")), ("age", JNum(30.0))]))

// JValue 支持 stringify
match json {
  Ok(v) => println(v.stringify())  // {"name": "Alice", "age": 30}
  _ => ()
}
```

### HTTP 解析器

```moonbit
// URI 解析
let uri = @astrolabe/http.parse_uri_string("https://example.com:8080/path?q=1#sec")
// Ok({ scheme: "https", host: "example.com", port: Some(8080), path: "/path", ... })

// HTTP 请求解析
let req = @astrolabe/http.parse_request_string(
  "GET /index.html HTTP/1.1\r\nHost: example.com\r\n\r\n"
)
// Ok({ req_method: GET, uri: "/index.html", version: { major: 1, minor: 1 }, ... })

// 类型方法：impl Show + to_string
match req {
  Ok(r) => println(r.to_string())  // GET /index.html HTTP/1.1\r\nHost: example.com\r\n\r\n
  _ => ()
}
```

## API 一览 | API Reference

### 入口函数 | Entry Points

| 函数 / 方法 | 说明 |
|-------------|------|
| `p.parse(input)` | 解析，允许尾部未消费 |
| `p.parse_full(input)` | 解析，要求全部消费 |
| `err.format()` | 格式化错误 |
| `err.format_with_input(input)` | 错误 + 输入上下文 |
| `err.commit()` | 返回 committed=true 的副本 |

### 基础组合子 | Basic Combinators

| 组合子 | 返回 | 说明 |
|--------|------|------|
| `char(c)` | `Parser[Char]` | 匹配单个字符 |
| `string(s)` | `Parser[String]` | 匹配字符串字面量 |
| `any_char()` | `Parser[Char]` | 匹配任意字符 |
| `take(n)` | `Parser[String]` | 消费 n 个字符 |
| `satisfy(pred, label~)` | `Parser[Char]` | 满足谓词的字符 |
| `end_of_input()` | `Parser[Unit]` | 仅在 EOF 成功 |
| `peek(p)` | `Parser[T]` | 前瞻不消费 |
| `skip(p)` | `Parser[Unit]` | 消费但丢弃结果 |
| `char_range(lo, hi)` | `Parser[Char]` | 字符范围 |
| `char_class(pred, label)` | `Parser[Char]` | 带标签的字符类 |

### 组合组合子 | Compose Combinators

| 组合子 | 说明 |
|--------|------|
| `map(p, f)` | 变换结果 |
| `bind(p, f)` | 序列，第二个依赖第一个 |
| `pure(v)` / `return_(v)` ⚠️ | 总是成功（`return_` 已弃用，请用 `pure`） |
| `seq2` / `seq3` / `seq4` | 序列收集 |
| `many(p)` / `many1(p)` | 零次或多次 / 一次或多次 |
| `sep_by(p, sep)` / `sep_by1` | 分隔符分隔 |
| `count(n, p)` | 精确 n 次 |
| `many_till(p, end)` | 重复直到 end 匹配 |

### 控制组合子 | Control Combinators

| 组合子 | 说明 |
|--------|------|
| `commit(p)` | 标记失败为已承诺 |
| `alt(p1, p2)` | 有序选择（回溯控制） |
| `choice(parsers)` | N 路有序选择 |
| `label(p, name)` | 替换错误信息 |

### HTTP 类型方法 | HTTP Type Methods

| 方法 | 说明 |
|------|------|
| `method.to_string()` | 通过 Show trait — `"GET"`, `"POST"` 等 |
| `version.to_string()` | 通过 Show trait — `"HTTP/1.1"` 等 |
| `request_line.to_string()` | `"GET /path HTTP/1.1"` |
| `header.to_string()` | `"Content-Type: text/html"` |
| `request.to_string()` | 完整 HTTP 请求文本 |
| `uri.to_string()` | 完整 URI 字符串 |

## MoonBit 惯用法 | MoonBit Idioms

Astrolabe 充分利用 MoonBit 的方法系统、特征系统和派生属性：

| 特性 | 使用方式 |
|------|---------|
| `#derive(Eq, Debug)` | Pos/State/ParseError/JValue/HTTP 类型自动生成 Eq/Debug |
| `impl Show` + `extend with Show::{output, to_string}` | Method/Version 实现 Show，支持 `.to_string()` 点调用 |
| `TypeName::method(self, ...)` | 所有关键操作以方法定义（Parser::parse, ParseError::format, State::peek） |
| `ParseError::commit()` | 消除 bind/seq2/seq3/seq4/control 中 7 处 `committed: true` 重复构造 |
| `Parser::of(fn)` | 通用扩展点，将任意函数包装为 Parser |
| 递归 step 函数 | many/many1/sep_by/count/many_till 使用尾递归 step 函数，避免 `unused_mut` 警告 |
| peek/save-restore 模式 | `peek(p)` 和 `many_till` 保存/恢复 state.offset 和 state.pos |

## 性能基准 | Benchmarks

```bash
moon bench --target native benchmarks/
```

| 类别 | 示例 | 耗时 |
|------|------|------|
| 基础 | `char` x 1000 | ~132 us |
| 组合 | `map` x 1000 | ~177 us |
| 组合 | `bind` x 1000 | ~378 us |
| 控制 | `commit` vs 无 commit | 1.2 us vs 48 us |
| JSON | `json_object_100` | ~2.1 ms |
| HTTP | `http_request_5_headers` | ~109 us |

## 形式化验证 | Formal Verification

核心 commit/alt 回溯语义已通过 Z3 SMT 求解器机械化验证，详见 [docs/formal-spec.md](docs/formal-spec.md)。

| 性质 | 含义 | 状态 |
|------|------|------|
| P1 | `commit` 总是将 `committed` 设为 `true` | ✅ proved |
| P2a | `alt` 在未承诺失败时回溯 | ✅ proved |
| P2b | `alt` 在已承诺失败时不回溯 | ✅ proved |
| P3a | `map` 不改变承诺标志 | ✅ proved |
| P3b | `bind` 序列承诺（第二个失败时强制承诺） | ✅ proved |
| — | 偏移量前进保持非负 | ✅ proved |
| — | 剩余字符数保持非负 | ✅ proved |

## 示例 | Examples

```bash
moon run examples/uri          # URI 解析器
moon run examples/csv_header   # CSV 头解析器
moon run examples/calc         # 四则运算计算器
moon run cmd/main              # 交互式 CLI 演示
```

## 项目结构 | Project Structure

```
astrolabe/
├── core/          Pos, State, ParseError, Parser[T]
├── basic/         char, string, take, satisfy, ...
├── compose/       map, bind, seq2-seq4, many, sep_by, ...
├── control/       commit, alt, choice, label
├── json/          JValue + JSON 解析器 + stringify
├── http/          Method, Request, Uri + 解析器 + impl Show
├── proof/         Z3 形式化验证 (7 goals proved)
├── benchmarks/    25 个基准测试
├── examples/      URI, CSV, 计算器
├── cmd/main/      CLI 演示
└── docs/          API 参考、教程、迁移指南、形式化规范
```

## 文档 | Documentation

| 文档 | 说明 |
|------|------|
| [API 参考](docs/api.md) | 所有公开函数签名 + 示例 |
| [教程](docs/tutorial.md) | 从零到 JSON 解析器 |
| [迁移指南](docs/migration.md) | 从 yacc / regex / nom / Angstrom 迁移 |
| [形式化规范](docs/formal-spec.md) | Z3 验证的核心语义性质 |
| [路线图](docs/roadmap.md) | v0.1.0→v1.0.0 迭代计划 |
| [变更日志](CHANGELOG.md) | 版本历史 |
| [贡献指南](CONTRIBUTING.md) | 开发流程 |

## License

[MIT](LICENSE)
