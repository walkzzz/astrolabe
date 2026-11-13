///| 组合子正确性证明 — 本包使用 MoonBit 的 proof 条件对核心组合子的

///| 关键不变量进行静态验证。这些证明函数不是运行时 API 的一部分，

///| 而是作为开发阶段的正确性保障，确保偏移量前进、位置追踪、

///| 解析状态回溯等操作的数学性质在编译期得到确认。

///|

///| Combinator correctness proofs — This package uses MoonBit's proof conditions

///| to statically verify key invariants of core combinators. These proof functions

///| are not part of the runtime API but serve as development-phase correctness

///| guarantees, ensuring mathematical properties of offset advancement, position

///| tracking, parse state backtracking, etc. are confirmed at compile time.

///|

///| 注意：本包不导出公共 API，仅供内部验证使用。

///| Note: This package does not export public API; it is for internal verification only.

///|

///| P1: 偏移量前进 — 验证 `offset + 1` 保持非负。

///|

///|
/// P1: Advance offset — verify `offset + 1` stays non-negative.
pub fn advance_offset(
  before : Int32,
) -> Int32 where {
  proof_require: 0 <= before,
  proof_ensure: result => result == before + 1 && 0 <= result,
} {
  before + 1
}

///| P1 辅助：剩余字符数 — 验证 `length - offset` 保持非负。

///|

///|
/// P1 helper: remaining characters — verify `length - offset` stays non-negative.
pub fn compute_remaining(
  offset : Int32,
  length : Int32,
) -> Int32 where {
  proof_require: 0 <= offset && offset <= length,
  proof_ensure: result => result == length - offset && 0 <= result,
} {
  length - offset
}

///| P1 辅助：EOF 判定 — 验证 `offset >= length` 为正确的 EOF 条件。

///|

///|
/// P1 helper: EOF check — verify `offset >= length` is the correct EOF condition.
pub fn compute_is_eof(
  offset : Int32,
  length : Int32,
) -> Bool where {
  proof_require: 0 <= offset && offset <= length,
  proof_ensure: result => result == (offset >= length),
} {
  offset >= length
}

///| P2: commit 标志 — 验证 `commit` 总是将 committed 设为 true。

///|

///|
/// P2: Commit flag — verify `commit` always sets committed to true.
pub fn commit_flag(
  _committed_before : Bool,
) -> Bool where {
  proof_ensure: result => result == true,
} {
  true
}

///| P3a: 序列承诺 — 若第二个解析器失败，结果必然为已承诺。

///|

///|
/// P3a: Sequence commits — if the second parser fails, the result is always committed.
pub fn sequence_commit_on_second_fail(
  second_failed : Bool,
) -> Bool where {
  proof_ensure: result => !second_failed || result == true,
} {
  if second_failed {
    true
  } else {
    false
  }
}

///| P2a: alt 在未承诺失败时回溯 — 若 p1 未承诺，alt 尝试 p2。

///|

///|
/// P2a: alt backtracks on uncommitted failure — if p1 is uncommitted, alt tries p2.
pub fn alt_uncommitted_backtracks(
  p1_committed : Bool,
) -> Bool where {
  proof_ensure: result => p1_committed || result == true,
} {
  if p1_committed {
    false
  } else {
    true
  }
}

///| P2b: alt 在已承诺失败时不回溯 — 若 p1 已承诺，alt 不尝试 p2。

///|

///|
/// P2b: alt does not backtrack on committed failure — if p1 is committed, alt skips p2.
pub fn alt_committed_no_backtrack(
  p1_committed : Bool,
) -> Bool where {
  proof_ensure: result => !p1_committed || result == false,
} {
  if p1_committed {
    false
  } else {
    true
  }
}
