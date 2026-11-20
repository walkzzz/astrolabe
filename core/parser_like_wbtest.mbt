///|
/// 覆盖率补强 — ParserLike 扩展点（pmap/pbind/palt/poption/run_fn）
/// Coverage-gap tests for the ParserLike extension point.

///|
fn pl_char(expected : Char) -> Parser[Char] {
  Parser::of(fn(st) {
    match st.peek() {
      Some(ch) =>
        if ch == expected {
          st.advance_one()
          Success(ch, st)
        } else {
          Failure(ParseError::at(pos=st.pos, expected="'\{expected}'"))
        }
      None => Failure(ParseError::at(pos=st.pos, expected="'\{expected}'"))
    }
  })
}

///|
test "pmap maps success and passes failure" {
  let mapped = pmap(pl_char('a').run_fn(), fn(c) { c.to_int() })
  match mapped.parse("a") {
    Ok(v) => assert_eq(v, 'a'.to_int())
    Err(_) => fail("expected Ok")
  }
  match mapped.parse("b") {
    Ok(_) => fail("expected Err")
    Err(_) => ()
  }
}

///|
test "pbind sequences and commits second failure" {
  let bound = pbind(pl_char('a').run_fn(), fn(_c) { pl_char('b') })
  match bound.parse("ab") {
    Ok(v) => assert_eq(v, 'b')
    Err(_) => fail("expected Ok")
  }
  match bound.parse("ac") {
    Ok(_) => fail("expected Err")
    Err(err) => assert_true(err.committed())
  }
}

///|
test "palt backtracks and aggregates" {
  let alt_p = palt(pl_char('a').run_fn(), pl_char('b').run_fn())
  match alt_p.parse("b") {
    Ok(ch) => assert_eq(ch, 'b')
    Err(_) => fail("expected Ok")
  }
  match alt_p.parse("c") {
    Ok(_) => fail("expected Err")
    Err(err) => assert_true(err.expected().length() >= 1)
  }
}

///|
test "poption falls back on uncommitted failure" {
  assert_true(poption(pl_char('z').run_fn(), 'd').parse("a") is Ok('d'))
  assert_true(poption(pl_char('a').run_fn(), 'd').parse("a") is Ok('a'))
}
