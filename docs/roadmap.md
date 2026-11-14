# Astrolabe 迭代路线图

> 规划 v0.1.0-v1.0.0 · 2026-11-12

## vNext 竞争力路线图（Q4 赛期 · 截止 2026-11-18）

> 为季度优秀社区项目评选制定，沿 proposal.md 承诺编号体系；每版本绑定大赛评分维度与可验证产物。时间不足时按 v0.4.0 > v0.5.0 > v0.6.0 基准 > v0.7.0 Playground 优先级降级。

| 版本 | 主题 | 核心内容 | 大赛维度映射 | 可验证产物 |
|:---|:---|:---|:---|:---|
| **v0.4.0 ✅**（11-13 开发完成） | 错误聚合与诊断质量 | `ParseError::merge`（furthest-position + expected 标签合并，吸收 talcparsec CanMerge 思想，独立实现）；`choice`/`alt` 失败聚合；多候选期望的格式化输出 | 工程质量：诊断对齐 talcparsec、超越 parkit | ✅ 185×4 测试全绿 + check 零警告，待 mooncakes 发布 |
| **v0.5.0 ✅**（11-13 开发完成） | ParserLike 函数式扩展点 | `pmap`/`pbind`/`palt`/`poption` 通用组合子 + `Parser::run_fn` 入口；`examples/ext` 的 Traced[T] 扩展示例（设计说明：MoonBit trait 不支持实现类型/结果类型分离的参数化，采用函数式约定，与 `Parser::of` 同一扩展点） | 完成度：兑现 proposal.md 承诺（章程红线） | ✅ 190×4 测试全绿 + check 零警告，待 mooncakes 发布 |
| v0.6.0（下赛期） | 性能优化 + 三方对比基准 | String View / 惰性行列；astrolabe vs parkit vs talcparsec vs stdlib JSON 同 workload 对比表 | 工程质量 + 生态贡献 | README 性能对比章节 |
| v0.7.0（下赛期） | 生态采用案例 + Playground | INI/表达式完整用例；wasm Web Playground（错误位置高亮） | 生态贡献 + 展示表现 | ✅ INI 用例已提前落地（`examples/ini`，6 测试全绿）；Playground 待做 |

> 配套文档（2026-11-13）：`docs/comparison.md`（10 库竞品矩阵，mooncakes 实测核查）与 `docs/performance_report.md`（25 基准实测数据：commit 798 ns vs nocommit 45 µs 的 57 倍收益量化）已落地——生态贡献与工程质量维度的文档化证据。
| 持续动作 | 证据链维护 | 每版本 git tag + CHANGELOG + badge 同步；proof 前端增强跟进；mooncakes 索引收录跟进；赛事群阶段性展示 | 全维度 | 可追踪提交历史 |

合规边界：talcparsec（AGPL-3.0）仅吸收设计思想、仅实测性能数字，零代码引入。

---

## 进度快照（2026-11-13）

实际开发快于初版规划，当前状态如下（详见 `docs/assessment.md`）：

| 规划版本 | 规划内容 | 实际状态 |
|:---|:---|:---|
| v0.1.0 | 核心类型 + 基础组合子 | ✅ 完成（core/ + char/） |
| v0.2.0 | 组合组合子 + commit/alt | ✅ 完成（sequence/ + branch/ + proof 形式化验证） |
| v0.3.0 | 重复组合子 + 错误格式化 | ✅ 完成（many/sep_by/count/many_till + format_with_input） |
| v0.4.0 | JSON 解析器 | ✅ 完成（examples/json，含 stringify 往返） |
| v0.5.0 | HTTP 解析器 | ✅ 完成（examples/http + URI） |
| v0.6.0 | trait ParserLike | 🔄 规划中（吸收竞品输入抽象思想，见 proposal.md） |
| v0.7.0 | CLI 演示 + 示例 | ✅ 超额完成（cmd/main + 5 个示例包） |
| v0.8.0 | 性能优化 + 基准 | 🔶 部分完成（25 项基准已建立；String View/竞品对比基准待做） |
| v0.9.0 | 文档完善 | 🔶 部分完成（双语五份文档已交付；测试覆盖分析待做） |
| v1.0.0 | mooncakes.io 完整发布 | 🔶 部分完成（0.2.0 已发布，0.4.0/0.5.0 开发完成待发布） |

实际测试数：**190 × 4 后端全绿**（初版规划累积 135+），`moon check --deny-warn --target all` 零警告，CI 三门禁已建立。

---

MoonBit 生态首个**位置感知解析器组合子库**，填补 yacc（重）与 parkit（无位置）之间的空白。

### 交付线

| 交付线 | 发布渠道 | 消费者 | 覆盖版本 |
|--------|----------|--------|----------|
| 库 API | `moon add walkzzz/astrolabe` | MoonBit 开发者 | v0.1.0-v0.9.0 |
| CLI 演示 | `moon run cmd/main` | 开发者体验 | v0.7.0 |
| 示例集 | examples/ 目录 | 学习者 | v0.7.0 |
| mooncakes 发布 | mooncakes.io | 全社区 | v1.0.0 |

## 路线总览

```
v0.1.0 ──► v0.2.0 ──► v0.3.0 ──► v0.4.0 ──► v0.5.0
核心类型    组合组合子   重复组合子    JSON       HTTP
Pos/State  commit/alt  错误格式化    解析器     解析器

v0.5.0 ──► v0.6.0 ──► v0.7.0 ──► v0.8.0 ──► v0.9.0 ──► v1.0.0
HTTP      trait       CLI+示例     性能       文档       完整
解析器    ParserLike   演示        优化       完善       发布
```

---

## v0.1.0 — 核心类型 + 基础组合子

**目标**：建立 Parser[T] 核心抽象与基础组合子，可解析单字符/字符串/子串。

| Sprint | 内容 | 验收标准 |
|--------|------|----------|
| S1 | Pos / State / ParseError struct 定义 | 构造 + 位置推进测试 |
| S2 | Parser[T] struct + run 机制 | `Parser::of(fn)` 构造 + roundtrip 测试 |
| S3 | 基础组合子：char / string / any_char | `char('a')` 解析 "abc" → ('a', "bc") |
| S4 | 基础组合子：take / satisfy / end_of_input | `take(3)` 解析 "hello" → ("hel", "lo") |
| S5 | moon.mod + moon.pkg + AGENTS.md + CI | `moon check --target all` 通过 |
| S6 | 门禁验证 + 提交推送 | 20+ 白盒测试，0 warning |

**交付 API**：`Pos` / `State` / `ParseError` / `Parser[T]` / `char` / `string` / `any_char` / `take` / `satisfy` / `end_of_input`

---

## v0.2.0 — 组合组合子 + commit/alt 回溯控制

**目标**：实现函数组合子与 Angstrom 核心的显式回溯控制。

| Sprint | 内容 | 验收标准 |
|--------|------|----------|
| S1 | map / bind / pure / return | `map(char('a'), fn(x) { x.to_string() })` |
| S2 | seq2 / seq3 / seq4 | `seq2(char('a'), char('b'))` → ('a','b') |
| S3 | choice — 顺序尝试（不回溯） | `choice(char('a'), char('b'))` |
| S4 | alt — 回溯选择 + commit — 切断回溯 | `alt(string("ab"), string("ac"))` + commit 边界测试 |
| S5 | label — 组合子命名（错误信息） | 失败时显示 `expected HTTP method` |
| S6 | 测试 + 文档 | 25+ 测试，含 10+ commit/alt 边界 |

**交付 API**：`map` / `bind` / `pure` / `seq2` / `seq3` / `seq4` / `choice` / `alt` / `commit` / `label`

**关键设计**：`alt(p1, p2)` 在 p1 失败且未 commit 时回溯；`commit(p)` 使失败不可回溯。这是 Angstrom 区别于其他组合子库的核心——避免隐式回溯的指数爆炸。

---

## v0.3.0 — 重复组合子 + 错误格式化

**目标**：实现重复/分隔组合子，完善错误报告。

| Sprint | 内容 | 验收标准 |
|--------|------|----------|
| S1 | many / many1 — 零次或多次 / 一次或多次 | `many(char('a'))` 解析 "aaab" → (['a','a','a'], "b") |
| S2 | sep_by / sep_by1 — 分隔符分隔 | `sep_by1(char('a'), char(','))` 解析 "a,a,a" |
| S3 | count — 固定次数重复 | `count(char('a'), 3)` 解析 "aaa" |
| S4 | many_till — 重复直到终止符 | `many_till(any_char(), char('}'))` |
| S5 | skip / peek — 跳过/预览不消耗 | `peek(char('a'))` 不推进 offset |
| S6 | ParseError 格式化 + 上下文片段 | 报错含行/列/偏移 + 前后 20 字符 |
| S7 | 测试 + 文档 | 20+ 测试，错误格式化 5+ 场景 |

**交付 API**：`many` / `many1` / `sep_by` / `sep_by1` / `count` / `many_till` / `skip` / `peek` / `ParseError::format`

**错误报告示例**：
```
line 3, column 15 (offset 42):
expected HTTP method
  ...GET /path with-P<error>ayload...
```

---

## v0.4.0 — JSON 解析器子包

**目标**：用 Astrolabe 实现完整 JSON 解析器，验证组合子实用性。

| Sprint | 内容 | 验收标准 |
|--------|------|----------|
| S1 | JSON 值类型（JNull/JBool/JNum/JStr/JArr/Obj） | 类型定义 + derive(Eq, Debug) |
| S2 | 基础解析器（null / bool / number / string） | `parse("null")` → JNull |
| S3 | 复合解析器（array / object） | `parse("[1,2,3]")` → JArr |
| S4 | 错误报告验证 | 非法 JSON 报错含位置 + 上下文 |
| S5 | roundtrip 测试（JSON → parse → 值 → stringify → parse） | 与 stdlib JSON 对比 |
| S6 | 测试 + 文档 | 30+ 测试 |

**交付**：`@astrolabe/json` 子包，`parse(s: String) -> Result[JValue, ParseError]`

---

## v0.5.0 — HTTP 解析器子包

**目标**：实现 HTTP 请求行 + Header 解析，覆盖常见 Web 场景。

| Sprint | 内容 | 验收标准 |
|--------|------|----------|
| S1 | HTTP 请求行解析（GET /path HTTP/1.1） | 方法 + 路径 + 版本 |
| S2 | Header 行解析（Content-Type: text/html） | Key: Value 对 |
| S3 | 完整请求头块解析（多行 Header + 空行终止） | `parse_request` |
| S4 | URI 解析（scheme://host:port/path?query#frag） | RFC 3986 子集 |
| S5 | 错误报告验证 | 非法请求行报错含位置 |
| S6 | 测试 + 文档 | 30+ 测试 |

**交付**：`@astrolabe/http` 子包，`parse_request` / `parse_uri` / `parse_header`

---

## v0.6.0 — trait ParserLike + 自定义扩展

**目标**：开放扩展点，用户可实现自定义组合子。

| Sprint | 内容 | 验收标准 |
|--------|------|----------|
| S1 | trait ParserLike[A] 定义 | `fn run(self, State) -> Result[(A, State), ParseError]` |
| S2 | Parser[T] impl ParserLike | 现有组合子兼容 |
| S3 | 用户自定义组合子示例（range / regex-char-class） | 示例可运行 |
| S4 | 测试 + 文档 | 自定义组合子 5+ 测试 |

**交付**：`trait ParserLike[A]`，用户可 `impl ParserLike for MyParser`

---

## v0.7.0 — CLI 演示 + 3 个示例

**目标**：提供直观体验，让评审/用户 5 分钟上手。

| Sprint | 内容 | 验收标准 |
|--------|------|----------|
| S1 | CLI `moon run cmd/main` — 交互演示 | 输入字符串 → 选择解析器 → 输出结果/报错 |
| S2 | 示例 1：URI 解析器 | `parse_uri("https://example.com/path?q=1")` |
| S3 | 示例 2：CSV header 解析器 | `parse_csv_header("name,age,email")` |
| S4 | 示例 3：简单 calc（四则运算） | `parse_expr("1+2*3")` → 7 |
| S5 | 测试 + 文档 | 示例可运行，README 5 分钟上手 |

**交付**：CLI 演示 + examples/ 目录 3 个示例 + README

---

## v0.8.0 — 性能优化 + 基准测试

**目标**：优化热路径，建立性能基线。

| Sprint | 内容 | 验收标准 |
|--------|------|----------|
| S1 | String View 优化（避免子串拷贝） | offset+length 视图替代 String[i..j] |
| S2 | 错误收集优化（合并 expected 列表） | choice 失败时只报最远点错误 |
| S3 | 基准测试框架 | JSON 1KB/10KB/100KB 解析耗时 |
| S4 | 与 stdlib JSON / parkit 对比基准 | README 含对比表 |
| S5 | 测试 + 文档 | 基准数据可复现 |

**交付**：性能基准 + String View 优化 + 与竞品对比

---

## v0.9.0 — 文档完善 + API 覆盖

**目标**：生产可用级别的文档与 API 完整度。

| Sprint | 内容 | 验收标准 |
|--------|------|----------|
| S1 | API 文档覆盖所有公开函数 | 每个组合子含签名+说明+示例 |
| S2 | 教程文档（从零到 JSON 解析器） | 逐步引导，可跟练 |
| S3 | 与 yacc / parkit 迁移指南 | 对照表 + 迁移步骤 |
| S4 | 测试覆盖 95%+ | `moon coverage analyze` |
| S5 | 变更日志 + 贡献指南 | docs/changelog.md + CONTRIBUTING.md |

**交付**：完整 API 文档 + 教程 + 迁移指南 + 95% 测试覆盖

---

## v1.0.0 — mooncakes.io 完整发布

**目标**：生产可用，完整发布到 mooncakes.io。

| Sprint | 内容 | 验收标准 |
|--------|------|----------|
| S1 | 四后端验证（wasm/wasm-gc/js/native） | `moon check --target all` + `moon test --target all` |
| S2 | 零警告验证 | `moon check --deny-warn` |
| S3 | mooncakes.io 发布 | `moon publish` 成功 |
| S4 | 最终 README + 示例仓库 | 一句话介绍 + 5 分钟上手 |
| S5 | 最终验证 + 发布 | 80+ 核心测试 + 60+ 子包测试，全通过 |

**交付线**：全部四条交付线正式发布

---

## 里程碑与风险

| 版本 | 风险 | 缓解 |
|------|------|------|
| v0.1.0 | 🟢 低 | 核心类型简单，无外部依赖 |
| v0.2.0 | 🟡 中 | commit/alt 语义需与 Angstrom 对齐，10+ 专项测试 |
| v0.3.0 | 🟢 低 | 重复组合子模式固定 |
| v0.4.0 | 🟡 中 | JSON 规范边界多（数字精度/Unicode/转义） |
| v0.5.0 | 🟡 中 | HTTP 规范宽松，需限定子集 |
| v0.6.0 | 🟢 低 | trait 机制 MoonBit 原生支持 |
| v0.7.0 | 🟢 低 | 示例为演示用，不要求性能 |
| v0.8.0 | 🟡 中 | 性能优化可能影响 API，需兼容性测试 |
| v0.9.0 | 🟢 低 | 纯文档工作 |
| v1.0.0 | 🟡 中 | 四后端 + 零警告门禁 |

## 测试累积目标

> 初版规划值；实际已达标 178（见顶部进度快照）。

| 版本 | 核心测试 | 子包测试 | 累积 |
|------|----------|----------|------|
| v0.1.0 | 20+ | — | 20 |
| v0.2.0 | 25+ | — | 45 |
| v0.3.0 | 20+ | — | 65 |
| v0.4.0 | — | 30+ | 95 |
| v0.5.0 | — | 30+ | 125 |
| v0.6.0 | 5+ | — | 130 |
| v0.7.0 | — | — | 130 |
| v0.8.0 | 5+ | — | 135 |
| v0.9.0 | — | — | 135 |
| v1.0.0 | — | — | 135+ |

## 技术参考

| 参考 | 用途 |
|------|------|
| [OCaml Angstrom](https://github.com/oauthxx/angstrom) | 位置感知组合子设计（commit/alt/位置追踪） |
| [Rust nom](https://github.com/rust-bakery/nom) | 组合子命名与 API 组织 |
| [Haskell Attoparsec](https://github.com/haskell/attoparsec) | 性能优化参考（String View） |
| [RFC 8259 (JSON)](https://datatracker.ietf.org/doc/html/rfc8259) | JSON 解析器子包规范 |
| [RFC 9110 (HTTP Semantics)](https://datatracker.ietf.org/doc/html/rfc9110) | HTTP 解析器子包规范 |
| [MoonBit 官方文档](https://docs.moonbitlang.com/) | 语言特性与 trait 机制 |
