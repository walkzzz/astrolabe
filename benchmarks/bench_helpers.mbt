/// ============================================================================
/// Bench helpers — extract values from Result for b.keep()
/// ============================================================================

///|
fn[T] result_arr_len(r : Result[Array[T], @core.ParseError]) -> Int32 {
  match r {
    Ok(arr) => arr.length()
    Err(_) => -1
  }
}

///|
fn result_str_len(r : Result[String, @core.ParseError]) -> Int32 {
  match r {
    Ok(s) => s.length()
    Err(_) => -1
  }
}

///|
fn[T] result_is_ok(r : Result[T, @core.ParseError]) -> Int32 {
  match r {
    Ok(_) => 1
    Err(_) => 0
  }
}
