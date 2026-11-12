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
