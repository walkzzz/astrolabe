///|
pub fn advance_offset(
  before : Int32,
) -> Int32 where {
  proof_require: 0 <= before,
  proof_ensure: result => result == before + 1 && 0 <= result,
} {
  before + 1
}

///|
pub fn compute_remaining(
  offset : Int32,
  length : Int32,
) -> Int32 where {
  proof_require: 0 <= offset && offset <= length,
  proof_ensure: result => result == length - offset && 0 <= result,
} {
  length - offset
}

///|
pub fn compute_is_eof(
  offset : Int32,
  length : Int32,
) -> Bool where {
  proof_require: 0 <= offset && offset <= length,
  proof_ensure: result => result == (offset >= length),
} {
  offset >= length
}

///|
pub fn commit_flag(
  _committed_before : Bool,
) -> Bool where {
  proof_ensure: result => result == true,
} {
  true
}

///|
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

///|
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

///|
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
