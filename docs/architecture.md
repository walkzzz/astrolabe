# 架构设计（astrolabe 0.5.7）

> 范围：`walkzzz/astrolabe` —— MoonBit 位置感知解析器组合子库（参考 OCaml Angstrom，MIT）。
> 本文描述包分层、核心数据流、回溯语义与边界；数字口径见 `assessment.md` 与 `performance_report.md`。

## 1. 包分层

```
        应用面（examples/* · cmd · playground）
                        │
        组合子层  astrolabe（根包，facade：char/string/sequence/branch 汇总）
                  ├── char/       基础字符与扫描（char/string/range/satisfy/take_while）
                  ├── sequence/   顺序与重复（map/bind/seq2-4/many/sep_by/count/chainl1）
                  └── branch/     回溯控制（alt/choice/commit/attempt/recover/fix）
                        │
        内核层  core/          Parser[T] · State · Pos · ParseError · ParseHint · ParserLike
                        │
        验证/支撑  proof/（Z3 契约核）· benchmarks/（25+ 基准）· examples/（json/http/ini/uri/csv_header/calc/ext）
```

依赖单向：`astrolabe → {char, sequence, branch} → core`；`proof` 与 `benchmarks` 不参与库运行时。
`playground` 仅依赖 `astrolabe + core + core/json`，不触碰 IO/时钟/网络。

## 2. 核心数据模型

| 类型 | 作用 | 关键约束 |
| --- | --- | --- |
| `State` | 输入字符串 + 游标（offset）与当前 `Pos` | `advance_one` 同时推进 offset 与 Pos |
| `Pos` | 行 / 列 / 偏移（1 起始行、1 起始列、0 起始偏移） | `'\n'` 使行 +1、列重置 1；`to_string` 稳定为 `line:column@offset` |
| `ParseResult[T]` | `Success(T, State)` / `Failure(ParseError)` | 失败携带出错时的 State 位置 |
| `ParseError` | 位置 + 期望集合 + committed 标志 + 上下文链 | `merge` 聚合期望；`format_with_input` 生成 caret 片段 |
| `Parser[T]` | `(State) -> ParseResult[T]` 的函数包装 | `Parser::of` 为通用扩展点 |

## 3. 回溯语义（核心区分点）

- `alt(p, q)`：`p` 失败且 **未 committed** 时回退到输入起点执行 `q`；`p` 的 `committed=true` 时直接传播失败。
- `commit(p)`：把 `p` 的失败标记为 committed —— 后续 `alt` 不再尝试其它分支（避免指数回溯）。
- `attempt(p)`：显式重置 committed 语义（在需要「先试探再回退」时使用）。
- `recover(p, f)`：失败时用 `f(error)` 产出替代解析器，用于错误恢复。
- `choice(ps)`：有序选择，等价于右折叠 `alt`。
- 不变量：同一输入上，`alt` 的回退点总是本次分支的起始 offset；`commit` 只影响失败传播，不改变成功结果。

> 以上语义由 `proof/` 的 7 条 Z3 性质与 `core_wbtest` / `branch` 测试双重守护。

## 4. 三种入口

| 入口 | 语义 | 典型场景 |
| --- | --- | --- |
| `parse` | 匹配前缀即成功，允许尾部 | 词法扫描、增量读取 |
| `parse_prefix` | 返回 `(值, 未消费尾部)` | 流式/多段解析（0.5.6 新增） |
| `parse_full` | 要求到达 EOF，否则 `expected="end of input"` | 整串解析、配置/DSL |

## 5. 错误模型

- 期望集合 `expected: Array[String]`；`expected_joined` 去重保序并以 ` | ` 连接（空集合为 `unknown`）。
- `format_with_input` 输出 `line L, column C (offset O):` + 期望 + 原文片段 + `^` caret。
- 上下文链 `with_context` 逐层包裹，`contexts()` 返回链；`format` 不含输入片段（便于日志）。

## 6. 包边界与不做的部分

- 不含词法/语法生成器（不做 yacc 式代码生成）；不做隐式回溯。
- 不含 IO：输入是 `String`，读取/流式分片由调用方负责。
- 不含 Unicode 字素簇切分：按 `Char`（codepoint）推进；需要字素级语义时在解析器外层处理。
- 不含并发模型：解析器为纯同步值；并发由调用方编排。

## 7. 演示层（0.5.6 新增）

`playground/` 为 `pkgtype(kind: "foreign_library")` 的 11 个 `#export_name` 非 raise 函数；
错误统一折叠为 `{"ok":false,...}`。页面 `docs/` 为静态库首页，`scripts/check_pages.mjs` 做结构与语义双轨断言。