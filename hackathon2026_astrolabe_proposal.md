# Astrolabe 项目申报书

> 2026 MoonBit 国产基础软件开源大赛参赛申报 | 方向：基础库 | 申报日期：2026-11-12

---

## 基本信息

- 项目名称：Astrolabe：位置感知解析器组合子库
- 参赛者：walkzzz
- 联系方式：13689047817 745244185@qq.com
- GitHub 仓库链接：https://github.com/walkzzz/astrolabe.git
- mooncakes 包名：`walkzzz/astrolabe`
- 项目方向：基础库 — 解析器组合子
- 是否为移植项目：是（灵感源自 OCaml Angstrom，以 MoonBit 惯用法重写，非代码翻译）

---

## 项目简介

Astrolabe 是 MoonBit 生态首个**位置感知解析器组合子库**，填补 yacc（LR(1) 生成器，重）与 parkit（Nom 风格组合子，无位置追踪）之间的空白。核心特性：组合子风格（轻量可组合）+ 位置信息（行/列/偏移）+ commit/alt 显式回溯控制 + 精确到字符级的错误报告。

---

## 生态空白分析（截至 2026-11-12）

| 工具 | 风格 | 位置追踪 | 报错精度 | 适用场景 |
|---|---|---|---|---|
| `moonbitlang/yacc` | LR(1) 生成器 | 有 | 行级 | 完整语言语法，需 .mly 文件 |
| `cogna-dev/parkit` | Nom 风格组合子 | **无** | 仅"失败" | 局部格式解析 |
| **walkzzz/astrolabe** | 组合子 + 位置感知 | **有** | **字符级** | 中等复杂格式（HTTP/URI/CSV/配置） |

mooncakes.io 全量包中无任何位置感知的组合子解析器，本项目填补该空白。

---

## 技术方案

### 核心类型

```
struct Pos { line: Int, column: Int, offset: Int }
struct ParseError { pos: Pos, expected: List[String], context: String }
struct State { input: String, offset: Int, pos: Pos }
struct Parser[T] { run: (State) -> Result[(T, State), ParseError] }
```

### 组合子分层

| 层 | 组合子 | 说明 |
|---|---|---|
| 基础 | `char`/`string`/`take`/`satisfy`/`any_char`/`end_of_input` | 直接操作 State.offset |
| 组合 | `map`/`bind`/`seq2`/`seq3`/`choice`/`label` | 函数组合，不涉及输入 |
| 回溯 | `alt`（回溯）/ `commit`（切断回溯） | Angstrom 核心设计，防指数爆炸 |
| 重复 | `many`/`many1`/`sep_by`/`count`/`many_till` | 带上下界，防无限循环 |

### commit/alt 回溯控制

移植 Angstrom 关键设计：`alt(p1, p2)` 在 p1 失败时回溯尝试 p2；`commit(p)` 一旦进入不可回溯。明确区分可回溯点与不可回溯点，既保证表达力又控制性能。

### 与 OCaml Angstrom 差异

| | Angstrom (OCaml) | Astrolabe (MoonBit) |
|---|---|---|
| 输入 | Bigstringaf | String + View |
| 异步 | 原生异步流 | v1 聚焦同步，v2 可扩展 |
| 回溯 | commit/alt | 同 |
| 可扩展 | — | trait ParserLike[A] |

---

## 项目架构（3 个包）

```
astrolabe/
├── moon.mod / moon.pkg          # 根包（核心组合子 API）
├── pos.mbt                      #   Pos / State / ParseError
├── combinator.mbt               #   基础+组合+回溯+重复组合子
├── error.mbt                    #   错误格式化与上下文
├── astrolabe_wbtest.mbt         #   白盒测试
├── astrolabe_test.mbt           #   黑盒测试
├── json/                        # JSON 解析器子包（演示+实用）
│   ├── json.mbt                 #   用 Astrolabe 实现的 JSON 解析器
│   └── json_test.mbt            #   测试
├── http/                        # HTTP 解析器子包
│   ├── http.mbt                 #   请求行 + Header 解析
│   └── http_test.mbt            #   测试
├── cmd/main/                    # CLI 演示入口
├── examples/                    # 可运行示例（URI/CSV/calc）
├── AGENTS.md
├── README.md
└── LICENSE (Apache-2.0)
```

---

## 版本迭代计划

| 版本 | 内容 | 交付线 |
|---|---|---|
| v0.1.0 | Pos/State/ParseError/Parser[T] + 基础组合子 | 库 |
| v0.2.0 | 组合组合子 + commit/alt 回溯控制 | 库 |
| v0.3.0 | 重复组合子 + 错误格式化 | 库 |
| v0.4.0 | json 子包 | 库 |
| v0.5.0 | http 子包 | 库 |
| v0.6.0 | trait ParserLike + 自定义扩展 | 库 |
| v0.7.0 | CLI 演示 + 3 个示例 | 库 + CLI |
| v0.8.0 | 性能优化 + 基准测试 | 库 |
| v0.9.0 | 文档完善 + API 覆盖 | 库 |
| v1.0.0 | mooncakes.io 发布 | 全部 |

---

## 代码规模估算

| 模块 | 行数 |
|---|---|
| Pos + State + ParseError | ~200 |
| 基础组合子 | ~400 |
| 组合+回溯组合子 | ~900 |
| 重复组合子 | ~400 |
| 错误格式化 | ~200 |
| json 子包 | ~500 |
| http 子包 | ~400 |
| 测试 | ~1500 |
| **总计** | **~4500** |

---

## 验收标准对齐

| 大赛验收项 | 本项目满足方式 |
|---|---|
| MoonBit 为主 | 库 100% MoonBit 实现，零 FFI |
| 仓库公开 | GitHub 公开仓库，Sprint 迭代提交 |
| 能够运行 | README + 可运行示例 + 测试全通过 |
| 工作有效 | 填补生态空白，json/http 子包验证实用性 |
| 开源合规 | Apache-2.0，灵感来源已标注 |
| AI 可解释 | AI 辅助开发，所有组合子语义经人工审查 |

---

## 技术亮点

1. **MoonBit 首个位置感知组合子** — 填补 yacc 与 parkit 之间的空白
2. **commit/alt 回溯控制** — OCaml 外首次引入 Angstrom 显式回溯模型
3. **零 FFI** — 纯 MoonBit，wasm/js/native 全平台
4. **字符级报错** — `line 3, column 15: expected HTTP method, got 'P'`
5. **json/http 实战子包** — 证明组合子实用性，非玩具项目
6. **trait ParserLike** — 开放扩展，用户可自定义组合子

---

## 技术风险与缓解

| 风险 | 缓解 |
|---|---|
| commit/alt 语义移植偏差 | 10+ 专项回溯边界测试 |
| JSON 性能不如手写 | 定位正确+可读，非最快；README 明确说明 |
| 与 parkit 功能重叠 | parkit 无位置/无 commit/alt，差异化明确 |
| MoonBit 语言 beta-preview | 已可用于生产，不兼容变更严格评估 |

---

## 参考与设计说明

- 参考项目 1：[OCaml Angstrom](https://github.com/oauthxx/angstrom) — 位置感知组合子设计灵感（MIT 协议，2200 行）
- 参考项目 2：[Rust nom](https://github.com/rust-bakery/nom) — 组合子命名参考
- 参考项目 3：[MoonBit 官方文档](https://docs.moonbitlang.com/) — 语言特性参考
- 本项目许可证：Apache-2.0
- 设计原则：灵感源自 Angstrom，以 MoonBit 惯用法重写，非 OCaml 代码翻译
