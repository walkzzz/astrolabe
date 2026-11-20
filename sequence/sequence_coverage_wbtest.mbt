///|
/// 覆盖率补强 — sequence 包（many/sep_by/count/many_till/option/skip/between/seq）
/// Coverage-gap tests for the sequence package.

///|
fn seq_char(expected : Char) -> @core.Parser[Char] {
  @core.Parser::of(fn(st) {
    match st.peek() {
      Some(ch) =>
        if ch == expected {
          st.advance_one()
          @core.Success(ch, st)
        } else {
          @core.Failure(
            @core.ParseError::at(pos=st.pos, expected="'\{expected}'"),
          )
        }
      None =>
        @core.Failure(
          @core.ParseError::at(pos=st.pos, expected="'\{expected}'"),
        )
    }
  })
}

///|
test "many collects repeated matches and zero matches" {
  match many(seq_char('a')).parse("aaab") {
    Ok(v) => assert_eq(v.length(), 3)
    Err(_) => fail("expected Ok")
  }
  match many(seq_char('a')).parse("bbb") {
    Ok(v) => assert_eq(v.length(), 0)
    Err(_) => fail("expected Ok")
  }
}

///|
test "many1 fails on zero matches" {
  match many1(seq_char('a')).parse("bbb") {
    Ok(_) => fail("expected Err")
    Err(_) => ()
  }
}

///|
test "sep_by handles empty and separated lists" {
  match sep_by(seq_char('a'), seq_char(',')).parse("a,a,a") {
    Ok(v) => assert_eq(v.length(), 3)
    Err(_) => fail("expected Ok")
  }
  match sep_by(seq_char('a'), seq_char(',')).parse("") {
    Ok(v) => assert_eq(v.length(), 0)
    Err(_) => fail("expected Ok")
  }
}

///|
test "sep_by1 fails on empty input" {
  match sep_by1(seq_char('a'), seq_char(',')).parse("") {
    Ok(_) => fail("expected Err")
    Err(_) => ()
  }
}

///|
test "count handles zero and exact repetitions" {
  match count(0, seq_char('a')).parse("bbb") {
    Ok(v) => assert_eq(v.length(), 0)
    Err(_) => fail("expected Ok")
  }
  match count(2, seq_char('a')).parse("aa") {
    Ok(v) => assert_eq(v.length(), 2)
    Err(_) => fail("expected Ok")
  }
  match count(2, seq_char('a')).parse("a") {
    Ok(_) => fail("expected Err")
    Err(_) => ()
  }
}

///|
test "many_till stops before the terminator" {
  match many_till(seq_char('a'), seq_char(';')).parse("aaa;rest") {
    Ok(v) => assert_eq(v.length(), 3)
    Err(_) => fail("expected Ok")
  }
}

///|
test "option falls back on uncommitted failure" {
  assert_eq(option(seq_char('z'), 'd').parse("abc") is Ok('d'), true)
  assert_eq(option(seq_char('a'), 'd').parse("abc") is Ok('a'), true)
}

///|
test "skip_many1 requires at least one match" {
  match skip_many1(seq_char('a')).parse("aa") {
    Ok(_) => ()
    Err(_) => fail("expected Ok")
  }
  match skip_many1(seq_char('a')).parse("bb") {
    Ok(_) => fail("expected Err")
    Err(_) => ()
  }
}

///|
test "between wraps delimiters" {
  match between(seq_char('['), seq_char('a'), seq_char(']')).parse("[a]") {
    Ok(ch) => assert_eq(ch, 'a')
    Err(_) => fail("expected Ok")
  }
}

///|
test "seq3 combines three parsers" {
  match seq3(seq_char('a'), seq_char('b'), seq_char('c')).parse("abc") {
    Ok(v) => {
      let (a, _b, c) = v
      assert_eq(a, 'a')
      assert_eq(c, 'c')
    }
    Err(_) => fail("expected Ok")
  }
}

///|
test "seq4 combines four parsers" {
  let p = seq4(seq_char('a'), seq_char('b'), seq_char('c'), seq_char('d'))
  match p.parse("abcd") {
    Ok(v) => {
      let (_, _, _, d) = v
      assert_eq(d, 'd')
    }
    Err(_) => fail("expected Ok")
  }
}
