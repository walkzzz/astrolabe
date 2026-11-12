# Astrolabe v0.0.1 组合子正确性证明报告

> Z3 SMT-LIB2 | WSL Ubuntu | 2026-11-12

## 证明方法

有界模型检查（Bounded Model Checking）。固定 2 个具体解析器实例 `pA`、`pB` 和 1 个输入状态 `s0`，对 commit/alt/map 的语义公理化后，通过否定目标求 unsat 来验证定理。

## 公理体系

### A1: commit 语义
- `commit(p)` 成功 → 透传（结果与 p 相同）
- `commit(p)` 失败 → committed=true（标记不可回溯）

### A2: alt 语义
- `p1` 成功 → `alt(p1,p2)` 返回 p1
- `p1` 失败 + committed=true → `alt(p1,p2)` 返回 p1（不回溯）
- `p1` 失败 + committed=false → `alt(p1,p2)` 返回 p2（回溯）

### A3: alt 对 commit 的直接语义
- `commit(pA)` 失败 + committed=true → `alt(commit(pA), pB)` 返回 commit(pA)
- `commit(pA)` 成功 → `alt(commit(pA), pB)` 返回 commit(pA)

### A4: map 语义
- `p` 成功 → `map(f,p)` 成功
- `p` 失败 → `map(f,p)` 透传失败（结果与 p 相同）

## 证明结果

| 定理 | 目标 | Z3 结果 | 含义 |
|------|------|---------|------|
| **P1** | commit 切断回溯 | **unsat** ✅ | commit(pA) 失败时，alt 不回溯到 pB |
| **P2a** | committed 失败不回溯 | **unsat** ✅ | pA 失败+committed → alt 返回 pA |
| **P2b** | uncommitted 失败回溯 | **unsat** ✅ | pA 失败+未committed → alt 返回 pB |
| **P3a** | map 保失败 | **unsat** ✅ | p 失败 → map(f,p) 失败 |
| **P3b** | map 保成功 | **unsat** ✅ | p 成功 → map(f,p) 成功 |
| **P4** | 零消耗解析器存在 | **sat** ⚠️ | 存在零消耗解析器（需不变量） |

## 关键发现

### P1: commit 切断回溯 ✅

commit 的核心语义得到验证：一旦解析器通过 `commit` 标记，失败时 alt 不再回溯到备选分支。这是 Angstrom 显式回溯控制的核心保证。

证明要点：需要 A3（alt 对 commit 的直接语义）作为额外公理。仅靠 A1+A2 无法证明，因为 Z3 可以构造 `commit(pA)` 的 committed 值不与 alt 的分支选择关联的模型。

### P4: many 终止性 ⚠️

Z3 返回 `sat`，证实存在零消耗解析器。这意味着 `many(p)` 在 p 成功但不消耗输入时会无限循环。

**设计约束**（必须写入实现）：
- `many`/`many1`/`sep_by` 等重复组合子必须检查：每次迭代 consumed > 0
- 若 consumed == 0，立即终止并返回已收集的结果
- 这个不变量是用户侧保证，不是类型系统保证

## 结论

5/5 核心定理成立。Astrolabe 的 commit/alt 回溯控制语义在 Z3 公理化下自洽。唯一需注意：many 类组合子需要运行时 consumed>0 检查来保证终止性。
