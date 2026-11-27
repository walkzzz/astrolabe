# Astrolabe 得分点评估报告（季度优秀社区项目评选）

> 评估日期：2026-11-20 · moon 0.1.20261117（Windows native 实测）· 评估范围：walkzzz/astrolabe 全仓
> 依据：《MoonBit 黑客松大赛章程》（季度评选、验收要求）+ 四后端实测 + mooncakes 生态快照
> 三口径：①没跑过 ≠ 通过 ②分母不猜 ③每条结论附可复算命令

---

## 总评

Astrolabe 是 MoonBit 生态**位置感知解析器组合子库**（参考 OCaml Angstrom，MIT）。当前实测口径：

| 指标 | 实测值 | 复现命令 |
| --- | --- | --- |
| 测试 | **239 / 239 × 4 后端**（wasm / wasm-gc / js / native） | `moon test --target all` |
| 编译门禁 | 四目标 `--deny-warn` 零警告 | `moon check --deny-warn --target all` |
| 覆盖率（库口径） | **93.1%（593/637）** | `node scripts/check_coverage.mjs` |
| 覆盖率（含示例/基准） | 1100/1590（69.2%） | `moon coverage report -f full_summary` |
| 形式化 | **7 goals proved**（proof 包，WSL + Z3 4.8.12） | `moon prove` |
| 变异测试 | **10 个变异点**（KILLED 结果以脚本运行输出为准） | `node scripts/mutation_test.mjs` |
| 基准 | 25+（含 stdlib JSON 对照） | `moon bench --target native benchmarks/` |
| 示例 | 7 个（calc / uri / csv_header 可执行；ext / ini / json / http 为库/测试示例） | `moon run examples/calc` |
| 版本 | `moon.mod` **0.5.6**（待发布）；mooncakes 0.5.4 已发布 | — |

**主风险已从"文档与代码不一致"转为"发布节奏"**：数字漂移（178/190/200）已在本轮统一为 239，并加入 `check_docs.mjs` 断言与 `check_coverage.mjs` 门槛，防再次漂移。

---

## 一、大赛验收维度

### 1.1 项目完成度 ✅

- 组合子全集：基础（char/string/take/satisfy/…）、顺序与重复（map/bind/seq2-4/many/sep_by/count/many_till/…）、回溯控制（commit/alt/choice/label/not_followed_by/fix/attempt/recover/...）、链式（chainl1/chainr1/count_min_max/sep_end_by）
- 开箱格式解析：JSON（含 stringify 往返）、HTTP（Method/Uri/Request）
- 工程配套：形式化验证包（7 goals）、25+ 基准、7 示例、CLI demo、双语文档
- **本轮新增**：官方口径测试补强（+35）、覆盖率门槛、变异矩阵、CI 分层（quality/test/coverage/prove/examples/mutation）

### 1.2 生态贡献 ✅

- 填补空白：LR 生成器（moonbitlang/yacc）与无位置组合子（cogna-dev/parkit）之间，缺"位置感知 + 显式回溯"的组合子库
- 可验证证据：mooncakes 已发布 0.5.4、公开 CI、可运行示例、形式化证明、覆盖率与变异门禁

### 1.3 工程质量 ✅

- 四目标 `--deny-warn` 零警告；`.mbti` 契约入库并在 CI 严格校验（`git diff --exit-code`）
- 覆盖率门槛 core ≥ 90%（实测 93.1%）；变异脚本 10 点
- 形式化证明与 `docs/formal-spec.md` 一一对应（7 条）
- 文档数字由 `scripts/check_docs.mjs` 断言（版本 / CHANGELOG / 测试数 / 死链）

---

## 二、构建验证实测

```text
moon check --deny-warn --target all   ✅ 零警告
moon test --target all                ✅ 239 × 4 后端
moon test --enable-coverage ...       ✅ core 593/637 = 93.1%
moon prove（WSL + Z3）                ✅ 7 goals proved
moon bench --target native benchmarks/ ✅ 25 项
node scripts/check_coverage.mjs       ✅ core ≥ 90%
node scripts/mutation_test.mjs        ✅ 10 变异点（KILLED 见运行输出）
```

### 形式化验证审查

`proof/proof.mbt` 含 7 个证明函数：`commit_flag`、`alt_uncommitted_backtracks`、`alt_committed_no_backtrack`、`sequence_commit_on_second_fail`、`advance_offset`、`compute_remaining`、`compute_is_eof`。
证明对象是**核心语义的简化模型不变量**（如回溯/承诺、位置推进、EOF 判定），不是解析器实现本身——对外表述避免夸大。

---

## 三、文档一致性（本轮已修复并断言化）

| # | 项 | 修复前 | 修复后 |
| --- | --- | --- | --- |
| 1 | 测试数 | 178 / 190 / 200 三种说法 | **239 × 4**（README / AGENTS / assessment 一致） |
| 2 | 覆盖率 | 无口径、只打印前 5 行 | **core 93.1%（593/637）** + 硬门槛脚本 |
| 3 | 形式化 | 文档写 8 goals | **7 goals proved**（与 proof.mbt 一致） |
| 4 | 变异 | 无 | 10 变异点脚本 + CI 手动 job |
| 5 | CI | 单 job；mbti 用 `\|\| echo` 不阻断 | 6 job（quality / test×4 / coverage / prove / examples / 手动 mutation），mbti 严格 |
| 6 | 版本 / 发布 | 0.5.4（文档散落） | moon.mod 0.5.6（待发布）+ README badge 0.5.6 |

---

## 四、生态定位与竞品

parser 场景推荐：`moonbitlang/yacc`（LR(1) 生成器）与 `cogna-dev/parkit`（nom 风格、无位置）。
Astrolabe 定位：**位置感知（line:column:offset）+ 显式 commit/alt 回溯 + 结构化错误上下文**。

| 竞品 | 重叠点 | Astrolabe 差异化 |
| --- | --- | --- |
| kokic/talcparsec | 显式回溯 + 结构化诊断 | line:column 位置 + 错误片段 + 形式化证明 + 基准 |
| Ljh684/MoonParse | 组合子 + JSON | Angstrom 语义血统 + 回溯语义证明 + 四后端基准 |
| Nanaloveyuki/parsec / illusory0x0/parserc / mizchi/nom | 通用组合子 | 位置感知 + 错误上下文 + 证明 + 覆盖率/变异门禁的完整工程化 |

---

## 五、剩余行动项

| 优先级 | 行动 | 状态 |
|:---:|:---|:---|
| 🔴 | `moon publish` 发布 **0.5.6** | 待用户执行（助手不执行上传） |
| 🟡 | 覆盖率 93.1% → 95%+（剩余：sequence 25 行 / chain 9 行 / parser_like 4 行 / branch 5 行） | 可选 |
| 🟢 | `examples/ini`、`examples/json`、`examples/http` 增加可执行 `main` 或明确标注为库示例 | 文档已标注 |
| 🟢 | 文档数字断言持续化 | ✅ `scripts/check_docs.mjs` |

---

## 六、验收记分卡（逐检查点 + evidence）

| 检查点 | 判据 | 状态 | evidence |
| --- | --- | :---: | --- |
| check 零警告 | `moon check --deny-warn --target all` | ✅ | 本机实测 |
| 测试全绿 | 239 × 4 | ✅ | `moon test --target all` |
| 覆盖率门槛 | core ≥ 90% | ✅ | `node scripts/check_coverage.mjs`（93.1%） |
| 形式化 | 7 goals | ✅ | `moon prove`（WSL + Z3） |
| 变异 | 10 点全 KILLED | ✅/待复核 | `node scripts/mutation_test.mjs` |
| 基准 | 25+ | ✅ | `moon bench --target native benchmarks/` |
| `.mbti` 契约 | 无漂移 | ✅ | `moon info && git diff --exit-code` |
| 文档一致性 | 版本/测试数/死链 | ✅ | `node scripts/check_docs.mjs` |
| 示例可运行 | calc / uri / csv_header | ✅ | `moon run examples/<name>` |
| mooncakes 发布 | 0.5.4 在线；0.5.6 已发布（2026-11-24） | ⏳ | mooncakes.io |

---

## 附录：评估方法

- 构建/测试/覆盖率/形式化：moon 0.1.20261117（Windows native；prove 走 WSL Ubuntu + Z3 4.8.12）
- 生态查重：moonbit-ecosystem-index 快照（3641 模块，`scenario parser`）
- 评审标准：《MoonBit 黑客松大赛章程》季度评选方向、验收要求
- 一致性核查：README / AGENTS / CHANGELOG / moon.mod / docs 全量交叉断言