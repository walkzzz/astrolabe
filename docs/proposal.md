# Astrolabe 项目申报书（季度优秀社区项目评选方向）

## 基本信息

- **项目名称**：Astrolabe — MoonBit 位置感知解析器组合子库（Position-Aware Parser Combinator Library）
- **参赛者**：蒋本雄（GitHub: walkzzz）
- **联系方式**：745244190@qq.com / 13689047817
- **GitHub 仓库链接**：https://github.com/walkzzz/astrolabe.git
- **参赛方向**：季度优秀社区项目评选方向（既有生态项目维护与升级，章程 5.2）
- **项目性质**：参考已有开源项目思想进行 MoonBit 原生实现（非代码移植，见第四节）
- **开源许可证**：MIT

## 一、项目简介

Astrolabe 为 MoonBit 生态提供**位置感知解析器组合子库**：每个解析器自动追踪行号、列号与字节偏移，失败时报告精确到字符的位置与输入上下文片段；核心的显式 `commit`/`alt` 回溯控制让使用者决定"哪里允许回溯"，避免隐式回溯带来的指数爆炸。库以根包门面（`pub using`）扁平化导出全部公共 API，`moon add walkzzz/astrolabe` 即可用；JSON / HTTP 解析器以示例子包形式提供。

本期参赛内容为**既有项目的持续维护与升级**：补齐形式化验证包、建立 25 项基准与 CI 三门禁、新增 5 个示例包与 CLI 演示、完成双语文档体系，并对文档与代码做了一致性审计修复。以下所有贡献均为本届赛事周期内的新增有效成果。

## 二、项目价值与生态定位

**观察到的痛点**：在 MoonBit 中手写词法/语法解析时，开发者反复遇到三类问题——(1) 报错只有"失败"二字，无行列号无上下文，调试全靠肉眼；(2) 隐式回溯的组合子在文法变大后性能塌陷；(3) 现有方案要么太重（LR 生成器、需构建期代码生成），要么缺位置信息。

**生态缺口**：mooncakes.io parser 场景目前的两类推荐方案——`moonbitlang/yacc`（LR(1) 生成器，适合完整语言语法）与 `cogna-dev/parkit`（nom 风格组合子，无位置追踪）——都不覆盖"轻量、位置感知、显式回溯控制"的组合子生态位。该生态位对 DSL、配置格式、协议解析、教学示例等场景是刚需。

**为什么非做不可**：解析器组合子是编译器/工具链生态的基础组件；MoonBit 正处于生态建设期，缺一个经过实测、有形式化语义背书、许可证宽松的组合子底座，会让每个需要解析的项目都重复造轮子。

## 三、与近邻竞品的差异化分析

申报前已按章程要求核查 mooncakes.io：不存在功能重合且维护良好的同定位项目。以下两个近邻项目与本库定位相邻，但差异化清晰。

### 3.1 kokic/talcparsec（v0.4.0，AGPL-3.0，8K 下载）

| 维度 | talcparsec | Astrolabe |
|:---|:---|:---|
| 回溯语义 | 消费即承诺，回溯需 `attempt` 显式开启 | Angstrom 语义：`alt` 默认回溯，`commit` 显式切断；**语义经 7 个证明函数形式化** |
| 许可证 | AGPL-3.0（传染性，闭源集成受限） | MIT（生态采用零门槛） |
| 定位 | 纯组合子框架（无格式解析器） | 组合子内核 + JSON/HTTP 开箱解析器 + 5 示例包 |
| 工程证据 | examples，无公开基准 | 190 测试 × 4 后端全绿、25 基准、CI 三门禁 |
| 错误模型 | trait 分层（可替换错误类型） | 位置 + 上下文片段 + committed 标志，raise/try 原生集成 |

**核心差异**：Astrolabe 的回溯语义有形式化背书且默认路径对使用者更直觉（需要切断时才写 `commit`）；MIT 许可证使库可被任何 MoonBit 项目无顾虑集成。

### 3.2 Ljh684/MoonParse（v0.1.4，Apache-2.0，73 下载，3 个月未更新）

| 维度 | MoonParse | Astrolabe |
|:---|:---|:---|
| API 形态 | 函数直接传参组合，Parser 非一等值 | `Parser[T]` 一等值：可存变量、传参、方法链（`p.parse_full` / `p.parse_raise`） |
| 回溯控制 | 无承诺语义，`alt` 简单顺序尝试 | 显式 commit/alt 传播表，承诺行为可预测可证明 |
| 定位 | JSON/TOML/二进制/日志格式混装单包 | 组合子内核单一职责，格式解析器分层在示例子包 |
| 维护状态 | 3 个月未更新，README 仅安装说明 | 18 个版本 CHANGELOG、CI 门禁、双语五份文档、月度活跃迭代 |

### 3.3 竞品思想吸收与合规声明

本赛事周期内，我们对上述两个竞品进行了设计层面的研究，**只吸收设计思想，未引入任何代码**（talcparsec 采用 AGPL-3.0，本库与其无任何代码血缘， SPDX 声明中亦无该依赖）。已吸收或规划吸收的思想：

1. **错误聚合（来自 talcparsec 的 CanMerge 思想）**：同位置多分支失败时合并 expected 标签、"最远位置优先"——已列入后续路线图，用于增强 `choice` 的错误信息质量；
2. **惰性行列计算（来自 talcparsec 的 line-start 表思路）**：行列号按需计算可降低解析热路径开销——列为性能优化候选方向；
3. **自定义输入抽象（来自 talcparsec 的 Cursor trait）**：与本项目路线图 v0.6.0 的 `ParserLike` trait 规划方向一致，届时同一组合子可工作于字符串与自定义 token 流；
4. **多错误累积（来自 MoonParse 的 ErrorContext）**：面向 IDE 集成场景的"一次解析报多个错"，列为远期方向；
5. **反面教训（来自 MoonParse）**：功能大杂烩会稀释核心价值——本库坚持"组合子内核单一职责，格式解析器分层为示例包"，并在文档中明确边界。

以上均为理念层面的借鉴与独立实现，符合章程第七章开源合规要求（不侵犯知识产权、遵守第三方许可证）。

### 3.4 选型自检（对照章程审核原则）

| 章程审核原则 | 本项目对照 |
|:---|:---|
| 题目真实反映客观需求 | 报错无位置、隐式回溯性能塌陷是 MoonBit 解析场景的真实痛点，本库直接解决 |
| 技术方案最优或最合适 | 组合子 + 一等值 Parser + proof 条件是 MoonBit 类型系统下的自然形态；对照 yacc（重）与 parkit（无位置）各自适用边界已在第三节论证 |
| mooncakes.io 无同质项目 | 2026-11-09 快照核查：parser 场景推荐方案为 yacc/parkit，无"位置感知 + 显式回溯 + 形式化验证"组合定位项目；近邻竞品差异已明确说明 |

## 四、参考项目说明（章程申报内容第 6/7 项）

- **项目性质**：参考 OCaml 生态 [Angstrom](https://github.com/inhabitedtype/angstrom)（MIT）的**组合子 API 设计思想**（`commit`/`alt`/`take_while`/`sep_by` 等语义模型）在 MoonBit 上的原生实现；
- **未复制任何 Angstrom 代码**；API 面向 MoonBit 惯用法重新设计（`suberror` 错误类型、`pub using` 门面、`#derive`、proof 条件、`#alias` 弃用机制等均为 MoonBit 特有实现）；
- **来源与许可证**：Angstrom — https://github.com/inhabitedtype/angstrom — MIT（思想借鉴已注明，无代码引入，许可证兼容）。

## 五、本期新增贡献（赛期内有效维护成果）

| 贡献 | 内容 | 可验证性 |
|:---|:---|:---|
| 形式化验证包 `proof/` | 7 个 proof 函数（编译期 SMT 验证）：commit 标志、alt 回溯语义 P2a/P2b、序列承诺、偏移/剩余不变量、EOF 正确性 | `moon check --target native` |
| 基准套件 `benchmarks/` | 25 项基准覆盖 basic/compose/control/json/http | `moon bench --target native benchmarks/` |
| 5 个示例包 | uri、json、http、csv_header、calc，含白盒测试 | `moon test --target all` |
| CLI 演示 `cmd/main` | JSON/URI/HTTP 交互式展示 | `moon run cmd/main` |
| CI 三门禁 | `moon check --deny-warn --target all` + `moon test --target all` + `moon bench` | `.github/workflows/ci.yml` |
| 文档一致性审计修复 | README 中英 10 处与实际包结构/API 对齐、测试数口径更新（147→190）、版本三方统一 0.2.0、形式化性质表与 proof.mbt 一一对应 | `docs/assessment.md` |
| 双语文档体系 | API 参考、教程、迁移指南、形式化规范、路线图，全 API 中英 `///` 注释 | `docs/` |

## 六、核心功能范围

**已交付**：`Parser[T]` 一等值核心 + 12 个字符原语组合子 + 11 类顺序/重复组合子 + 6 个回溯控制组合子（commit/alt/choice/label/not_followed_by/fix）；`parse`/`parse_full`/`parse_raise`/`parse_full_raise` 四种入口；JSON 解析器（parse + stringify 往返）与 HTTP 解析器（Method/Uri/Request/Show）；位置感知错误报告（行列号 + 上下文指针）。

**拟实现（下一季度）**：`ParserLike` trait 抽象（自定义输入流）；choice 错误聚合（expected 标签合并）；性能优化（惰性行列、热路径减分配）。

**明确不做**：不做代码生成（与 yacc 定位区分）；不内置全部主流格式（保持内核单一职责，格式解析走示例子包）；不做正则引擎（生态已有 moonrockz/regex）。

## 七、预期使用场景

1. **DSL 与配置格式解析**：项目内嵌 mini 语言（如查询表达式、模板指令、规则引擎条件），用组合子快速拼装文法；解析错误自带行列号与上下文指针（`e.format_with_input`），可直接展示给最终用户而无需开发者二次加工。典型用户：工具链作者、低代码平台开发者。

2. **协议与文本格式工具**：HTTP 请求/URI/CSV/日志行等结构化文本的解析。`examples/http` 与 `examples/csv_header` 即为可复制的模板：白盒测试覆盖 CRLF/LF、多 header、边界字段等真实变体。典型用户：服务端调试器、日志分析工具、网关中间件作者。

3. **编译器前端原型与教学**：递归文法用 `fix` 组合（`branch_wbtest` 中的括号匹配示例即最小模板），token 流 + AST 构建链路从 `examples/calc` 起步可完整走通；双语 API 文档 + 形式化语义表使其适合作为 MoonBit 编译原理课程的配套实验材料。典型用户：编译原理学习者、语言实验作者。

4. **错误信息敏感型产品**：IDE 插件、Playground、校验器等场景对"报错友好度"要求最高——`label` 组合子定制期望信息、`ParseError` 结构化访问器（pos/expected/committed/context）支撑自定义诊断 UI。

## 八、实现路径与技术理解

- **语义模型先行**：先固化 commit/alt 承诺传播表（README 公开），再用 proof 条件把表中的关键不变量交给编译期 SMT 验证，最后以 190 项测试（含边界与错误路径）覆盖实现——"语义 → 证明 → 测试"三层递进，这是本项目区别于同类项目的方法论。
- **门面架构**：core/char/sequence/branch 四包单一职责，根包 `pub using` 扁平化导出；格式解析器放示例子包，避免内核膨胀。
- **MoonBit 惯用法**：`suberror ParseError` 接入原生 raise/try；`#derive(Eq, Debug)` 与 `impl Show` 全覆盖；尾递归 step 函数实现重复组合子；`#inline` 零成本门面。
- **质量门禁**：CI 固化 `check --deny-warn --target all`（零警告）+ `test --target all` + `bench`，四后端回归自动化。

## 九、预期验收产物

- `walkzzz/astrolabe` v0.5.1 待发布（**0.5.0 已上线**，含 v0.4.0 错误聚合 + v0.5.0 ParserLike 全部内容），`moon add walkzzz/astrolabe` 直接可用；
- 四后端（wasm / wasm-gc / js / native）测试全绿（当前 190 × 4）、25 项基准、CI 门禁；
- 双语文档 + 评估报告（`docs/assessment.md`，含实测数据与竞品分析）+ 本申报书（`docs/proposal.md`）；
- 本期全部新增贡献在 CHANGELOG `[0.2.0]` / `[0.2.1]` 条目与 git 提交历史中可追踪。

## 使用 AI 工具的声明与人工把控

本项目按章程鼓励合理使用 AI 工具辅助开发（代码生成、测试补全、文档整理），但以下关键决策与产出均由参赛者本人完成把控：

- **回溯语义模型与承诺传播表**：核心设计决策，人工定义后由 proof 条件与测试双重验证；
- **形式化验证命题的选择**：哪些不变量值得证明（7 条）由人工判断，避免"证明易证的、跳过关键的"；
- **竞品研究与差异化定位**：talcparsec / MoonParse 的对比分析与思想吸收边界由人工调研确定；
- **文档一致性审计**：assessment.md 中发现的 README 失实项由人工逐条确认修复方案；
- **开源合规**：MIT 选型、Angstrom 思想借鉴（零代码引入）与 AGPL 规避为人工决策。

提交记录、CHANGELOG 与 CI 门禁共同保证了上述产出的连续可追踪性。

## 十、后续迭代计划

| 版本 | 内容 | 大赛维度 |
|:---|:---|:---|
| v0.4.0 ✅ | choice 错误聚合（吸收 talcparsec CanMerge 思想，独立实现）：`ParseError::merge`、多候选期望输出 | 工程质量 |
| v0.5.0 ✅ | ParserLike 函数式扩展点：`pmap`/`pbind`/`palt`/`poption` + `run_fn` 入口 + Traced[T] 扩展示例 | 项目完成度 |
| v0.6.0 | 惰性行列计算等性能优化；与 parkit / talcparsec / stdlib JSON 的三方对比基准（仅实测数据，零代码引入） | 工程质量 + 生态贡献 |
| v0.7.0 | 生态采用案例（INI/表达式求值器完整链路）与 wasm Web Playground（错误位置高亮演示） | 生态贡献 + 展示表现 |

以上路线与 `docs/roadmap.md` 的「vNext 竞争力路线图」一致；v0.4.0 / v0.5.0 为本赛期（截止 2026-11-18）冲刺目标。

---

*本申报书基于项目实测数据（moon 0.1.20261104：check 零警告、test 190×4、bench 25/25）与 mooncakes.io 生态快照（2026-11-09）撰写，竞品数据取自各项目 mooncakes 页面公开信息。*
