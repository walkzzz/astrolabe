<div align="center">

# Astrolabe

**位置感知解析器组合子库** — MoonBit 生态首个

灵感来自 OCaml [Angstrom](https://github.com/SimonCourteaux/angstrom)，填补 yacc（重）与 parkit（无位置）之间的空白

[![mooncakes.io](https://img.shields.io/badge/mooncakes-0.1.10-orange)](https://mooncakes.io/package/walkzzz/astrolabe)
[![license](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
[![tests](https://img.shields.io/badge/tests-122%20%C3%97%204%20backends-green)]()
[![formal](https://img.shields.io/badge/formal-Z3%20verified-brightgreen)](docs/formal-spec.md)

</div>

---

## 为什么选 Astrolabe？

| 特性 | Astrolabe | yacc | 正则 | 手写递归下降 |
|------|-----------|------|------|-------------|
| 位置追踪 | 内置 line:column(offset) | 内置 | 无 | 手动 |
| 回溯控制 | `commit`/`alt` 显式 | 隐式（LALR） | 隐式 | 隐式 |
| 组合性 | 小组合子 → 大解析器 | 规则文件 | 模式拼接 | 函数调用 |
| 错误信息 | 精确位置 + 上下文片段 | 精确但不友好 | 模糊 | 取决于实现 |
| 学习曲线 | 低 | 高 | 低 | 中 |

## 快速开始

``moonbit
moon add walkzzz/astrolabe
``

``moonbit
let p = @astrolabe.char('a')
inspect!(p.parse("abc"), content="Ok('a')")

let greeting = @astrolabe.map(@astrolabe.string("hello"), fn(s) { s.length() })
inspect!(greeting.parse("hello"), content="Ok(5)")

let letter_or_digit = @astrolabe.alt(
  @astrolabe.char_range('a', 'z'),
  @astrolabe.char_range('0', '9'),
)
``

## 错误报告

每个解析器自动追踪行号、列号和偏移量：

``moonbit
let p = @astrolabe.string("hello")
match p.parse_full("helLO") {
  Err(e) => println(@astrolabe.format_error_with_input(e, "helLO"))
  // line 1, column 4 (offset 3):
  // expected hello
  //   ...helLO
  //       ^
  _ => ()
}
``

## 核心：commit/alt 回溯控制

Astrolabe 的核心区分点：**显式回溯控制**，避免隐式回溯的指数爆炸。

``moonbit
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
``

**序列自动承诺**：`bind`/`seq2` 中，如果第一个解析器成功但第二个失败，错误自动标记为已承诺。

## 子包

### JSON 解析器

``moonbit
let json = @astrolabe/json.parse("{`"name`": `"Alice`", `"age`": 30}")
// Ok(JObj([("name", JStr("Alice")), ("age", JNum(30.0))]))
``

### HTTP 解析器

``moonbit
let uri = @astrolabe/http.parse_uri_string("https://example.com:8080/path?q=1#sec")

let req = @astrolabe/http.parse_request_string(
  "GET /index.html HTTP/1.1`r`nHost: example.com`r`n`r`n"
)
``

## API 一览

### 入口函数

| 函数 | 说明 |
|------|------|
| `parse(p, input)` | 解析，允许尾部未消费 |
| `parse_full(p, input)` | 解析，要求全部消费 |
| `format_error(e)` | 格式化错误 |
| `format_error_with_input(e, input)` | 错误 + 输入上下文 |

### 基础组合子

| 组合子 | 返回 | 说明 |
|--------|------|------|
| `char(c)` | `Parser[Char]` | 匹配单个字符 |
| `string(s)` | `Parser[String]` | 匹配字符串字面量 |
| `any_char()` | `Parser[Char]` | 匹配任意字符 |
| `take(n)` | `Parser[String]` | 消费 n 个字符 |
| `satisfy(pred)` | `Parser[Char]` | 满足谓词的字符 |
| `end_of_input()` | `Parser[Unit]` | 仅在 EOF 成功 |
| `peek(p)` | `Parser[T]` | 前瞻不消费 |
| `skip(p)` | `Parser[Unit]` | 消费但丢弃结果 |
| `char_range(lo, hi)` | `Parser[Char]` | 字符范围 |
| `char_class(pred, label)` | `Parser[Char]` | 带标签的字符类 |

### 组合组合子

| 组合子 | 说明 |
|--------|------|
| `map(p, f)` | 变换结果 |
| `bind(p, f)` | 序列，第二个依赖第一个 |
| `pure(v)` / `return_(v)` | 总是成功 |
| `seq2` / `seq3` / `seq4` | 序列收集 |
| `many(p)` / `many1(p)` | 零次或多次 / 一次或多次 |
| `sep_by(p, sep)` / `sep_by1` | 分隔符分隔 |
| `count(n, p)` | 精确 n 次 |
| `many_till(p, end)` | 重复直到 end 匹配 |

### 控制组合子

| 组合子 | 说明 |
|--------|------|
| `commit(p)` | 标记失败为已承诺 |
| `alt(p1, p2)` | 有序选择（回溯控制） |
| `choice(parsers)` | N 路有序选择 |
| `label(p, name)` | 替换错误信息 |

## 性能基准

`moon bench --target native benchmarks/`

| 类别 | 示例 | 耗时 |
|------|------|------|
| 基础 | `char` x 1000 | ~132 us |
| 组合 | `map` x 1000 | ~177 us |
| 组合 | `bind` x 1000 | ~378 us |
| 控制 | `commit` vs 无 commit | 1.2 us vs 48 us |
| JSON | `json_object_100` | ~2.1 ms |
| HTTP | `http_request_5_headers` | ~109 us |

## 示例

``bash
moon run examples/uri          # URI 解析器
moon run examples/csv_header   # CSV 头解析器
moon run examples/calc         # 四则运算计算器
moon run cmd/main              # 交互式 CLI 演示
``

## 形式化验证

核心 commit/alt 回溯语义已通过 Z3 SMT 求解器机械化验证，详见 [docs/formal-spec.md](docs/formal-spec.md)。

验证的性质包括：
- **P1**: `commit` 总是将 `committed` 设为 `true`
- **P2**: `alt` 在未承诺失败时回溯，在已承诺失败时不回溯
- **P3**: `bind` 序列承诺（第二个解析器失败时强制承诺）

## 项目结构

``text
astrolabe/
├── core/          Pos, State, ParseError, Parser[T]
├── basic/         char, string, take, satisfy, ...
├── compose/       map, bind, seq2-seq4, many, sep_by, ...
├── control/       commit, alt, choice, label
├── json/          JValue + JSON 解析器 + stringify
├── http/          Method, Request, Uri + 解析器
├── benchmarks/    25 个基准测试
├── examples/      URI, CSV, 计算器
├── cmd/main/      CLI 演示
└── docs/          API 参考、教程、迁移指南、形式化规范
``

## 文档

| 文档 | 说明 |
|------|------|
| [API 参考](docs/api.md) | 所有公开函数签名 + 示例 |
| [教程](docs/tutorial.md) | 从零到 JSON 解析器 |
| [迁移指南](docs/migration.md) | 从 yacc / regex / nom / Angstrom 迁移 |
| [形式化规范](docs/formal-spec.md) | Z3 验证的核心语义性质 |
| [变更日志](CHANGELOG.md) | 版本历史 |
| [贡献指南](CONTRIBUTING.md) | 开发流程 |

## License

[MIT](LICENSE)