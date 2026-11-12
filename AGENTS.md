# Project Agents.md Guide

This is a [MoonBit](https://docs.moonbitlang.com) project.

You can browse and install extra skills here:
<https://github.com/moonbitlang/skills>

## Project Structure

- MoonBit packages are organized per directory; each directory contains a
  `moon.pkg` file listing its dependencies. Each package has its files and
  blackbox test files (ending in `_test.mbt`) and whitebox test files (ending in
  `_wbtest.mbt`).

- In the toplevel directory, there is a `moon.mod` file listing module
  metadata.

## Coding convention

- MoonBit code is organized in block style, each block is separated by `///|`,
  the order of each block is irrelevant. In some refactorings, you can process
  block by block independently.

- Try to keep deprecated blocks in file called `deprecated.mbt` in each
  directory.

## Tooling

- `moon fmt` is used to format your code properly.

- `moon ide` provides project navigation helpers like `peek-def`, `outline`, and
  `find-references`. See $moonbit-agent-guide for details.

- `moon info` is used to update the generated interface of the package, each
  package has a generated interface file `.mbti`, it is a brief formal
  description of the package. If nothing in `.mbti` changes, this means your
  change does not bring the visible changes to the external package users, it is
  typically a safe refactoring.

- In the last step, run `moon info && moon fmt` to update the interface and
  format the code. Check the diffs of `.mbti` file to see if the changes are
  expected.

- Run `moon test` to check tests pass. MoonBit supports snapshot testing; when
  changes affect outputs, run `moon test --update` to refresh snapshots.

- Prefer `assert_eq` or `assert_true(pattern is Pattern(...))` for results that
  are stable or very unlikely to change. For snapshot tests that record
  structured debugging output, derive `Debug` and use `debug_inspect`, rather
  than deriving `Show` for debugging. For solid, well-defined results (e.g.
  scientific computations), prefer assertion tests. You can use
  `moon coverage analyze > uncovered.log` to see which parts of your code are
  not covered by tests.

## 长流程协议（默认不启用）

本协议仅在满足以下任一触发条件时启用，不自动扩散：

| # | 触发条件 | 说明 |
|---|---------|------|
| T1 | 多轮任务 | >3 步跨轮协作，产出链路依赖 |
| T2 | 固化承诺 | 规则、责任人、时限需留存备查 |
| T3 | 外部输入 | 群聊、多方评审与角色反馈 |
| T4 | 高风险操作 | 合并、发布、迁移、批量修改等难回滚动作 |
| T5 | 发起人声明 | 用户明确声明适用本协议 |

### 三步动作

每一步必须执行：

1. **记**：把已确认的"规则 / 负责人 / 截止时间"写进本文件下方 `## 长流程状态` 区块
2. **锁**：遇到与前序约定冲突的新要求，先停下，标注冲突来源，问"谁有权改"
3. **回**：每完成一环，回写一句"已交付 X，下环依赖 Y"

### 禁则

- 禁止在没确认的情况下，把群聊里的某句话当成最终决定
- 未触发条件时不启用，不自动扩散到简单任务

## 长流程状态

> 本区块仅在协议启用时填写

| 项目 | 内容 |
|------|------|
| 当前阶段 | v0.0.1 组合子正确性证明 ✅ |
| 规则 | Z3 SMT 证明 commit/alt 语义 + Parser 态射保结构 |
| 负责人 | walkzzz |
| 截止时间 | 本会话内 |
| 交付记录 | 已交付 proof/astrolabe_correctness.smt2 + proof_report.md，5/5 定理通过（P1-P3 ✅，P4 ⚠️ 需 consumed>0 不变量），下环依赖 v0.1.0 核心类型实现 |
| 冲突登记 | — |
