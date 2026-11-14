# mooncakes.io parser 库对比

> 数据来源：mooncakes.io 各模块发布页实时核查 + mooncakes 生态索引快照（2026-11-09，3641 模块）+ 各仓库 README。
> 快照日期：**2026-11-13**

## 概览

| 库 | 版本 | 定位 | 许可证 | 位置感知 | 形式化验证 |
|---|---|---|---|---|---|
| **walkzzz/astrolabe** | 0.5.0 | 位置感知组合子库 | **MIT** | ✅ line:column(offset) | ✅ 7 proof 函数（SMT 编译期） |
| moonbitlang/yacc | 0.7.26 | LR(1) 代码生成器 | 官方 | 内置（生成器） | ❌ |
| cogna-dev/parkit | 0.1.1 | nom 风格组合子 | — | ❌ | ❌ |
| kokic/talcparsec | 0.4.0 | trait 驱动组合子框架 | **AGPL-3.0** | ✅ offset/line/column（惰性） | ❌ |
| Ljh684/MoonParse | 0.1.4 | 函数式多格式解析 | Apache-2.0 | ✅（同步行列） | ❌ |
| Nanaloveyuki/parsec | 0.1.6 | token 泛型组合子 | — | ❌ | ❌ |
| illusory0x0/simple_parserc | 0.2.2 | 简单组合子 | — | ❌ | ❌ |
| peter-jerry-ye/parser-combinator | 0.9.1 | 组合子 | — | ? | ❌ |
| yoshitsugu/parsem | 0.0.4 | 简单组合子 | — | ❌ | ❌ |
| mizchi/nom | 0.1.3 | nom 移植 | — | ❌ | ❌ |

## 核心能力矩阵

| 特性 | astrolabe | yacc | parkit | talcparsec | MoonParse | 其他组合子 |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| 位置追踪（line:column+offset） | ✅ | 生成器内置 | ❌ | ✅ | ✅ | ❌ |
| 显式回溯控制（commit/alt 语义表） | ✅ | LALR 隐式 | 消费即承诺 | 消费即承诺+attempt | ❌ | ❌ |
| 错误聚合（furthest-position + 多候选期望） | ✅ 0.4.0 | ❌ | ❌ | ✅（CanMerge） | ErrorContext 累积 | ❌ |
| 形式化验证（proof 条件 / SMT） | ✅ 7 函数 | ❌ | ❌ | ❌ | ❌ | ❌ |
| 内置 JSON 解析器（往返 stringify） | ✅ 示例子包 | ❌ | ❌ | ❌ | ✅ 内置 | ❌ |
| 内置 HTTP/URI 解析器 | ✅ 示例子包 | ❌ | ❌ | ❌ | ❌ | ❌ |
| 公开基准测试 | ✅ 25 项 × native | ❌ | ❌ | ❌ | ❌ | ❌ |
| CI 门禁（check/test/bench） | ✅ | 官方维护 | — | — | ❌ | ❌ |
| 递归文法（fix 组合子） | ✅ | LR 自动处理 | ✅ | ✅ | ✅ | 部分 |
| 双语 API 文档 | ✅ | ✅ | — | 英文 | 中文 | — |

## 定位差异

- **与 yacc**：互补而非竞争——yacc 面向完整语言语法（LR(1)，构建期代码生成）；astrolabe 面向 DSL/配置/协议等轻量解析场景，运行期组合、无代码生成步骤。
- **与 parkit**：astrolabe 的核心差异是位置追踪 + 显式 commit/alt 语义（可证明）+ 错误聚合；parkit 为 nom 风格、无位置信息。
- **与 talcparsec**：最接近的竞品。差异三点——(1) 回溯模型相反：talcparsec 默认消费即承诺（attempt 显式开启回溯），astrolabe 默认回溯（commit 显式切断），后者对使用者更直觉；(2) 许可证：AGPL-3.0 vs MIT（闭源/商用集成门槛）；(3) astrolabe 附带形式化验证与公开基准，talcparsec 在 SIMD/惰性行列等底层优化上更深。
- **与 MoonParse**：功能重叠度较高（组合子 + 内置 JSON），但 MoonParse 的 Parser 非一等值（函数传参组合）、无承诺语义、3 个月未更新；astrolabe 提供一等值 `Parser[T]` + 方法链 + 可证明的回溯语义 + 190×4 测试全绿。

## 生态位结论

mooncakes parser 场景的官方推荐方案目前仅 `moonbitlang/yacc` 与 `cogna-dev/parkit` 两个（生态索引快照 2026-11-09）。astrolabe 占据的"位置感知 + 显式回溯 + 形式化验证"组合生态位在 mooncakes 上无同定位项目；对 talcparsec/MoonParse 的差异已在 `docs/proposal.md` 第三节按章程 4.1 要求明确说明。
