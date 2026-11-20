///|
/// 覆盖率补强 — chain 包（有界重复 / 尾分隔 / 过滤与校验）
/// Coverage-gap tests for the chain package.

///|
fn chain_char(expected : Char) -> @core.Parser[Char] {
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
test "count_min_max bounds repetitions" {
  match count_min_max(min=1, max=3, chain_char('a')).parse("aa") {
    Ok(v) => assert_eq(v.length(), 2)
    Err(_) => fail("expected Ok")
  }
  match count_min_max(min=2, max=3, chain_char('a')).parse("a") {
    Ok(_) => fail("expected Err")
    Err(_) => ()
  }
  match count_min_max(min=0, max=2, chain_char('a')).parse("bbb") {
    Ok(v) => assert_eq(v.length(), 0)
    Err(_) => fail("expected Ok")
  }
}

///|
test "sep_end_by allows trailing separator" {
  match sep_end_by(chain_char('a'), chain_char(',')).parse("a,a,") {
    Ok(v) => assert_eq(v.length(), 2)
    Err(_) => fail("expected Ok")
  }
  match sep_end_by(chain_char('a'), chain_char(',')).parse("") {
    Ok(v) => assert_eq(v.length(), 0)
    Err(_) => fail("expected Ok")
  }
}

///|
test "sep_end_by1 requires one element" {
  match sep_end_by1(chain_char('a'), chain_char(',')).parse("a,") {
    Ok(v) => assert_eq(v.length(), 1)
    Err(_) => fail("expected Ok")
  }
  match sep_end_by1(chain_char('a'), chain_char(',')).parse("") {
    Ok(_) => fail("expected Err")
    Err(_) => ()
  }
}

///|
test "filter and validate accept and reject" {
  match filter(chain_char('a'), fn(c) { c == 'a' }).parse("a") {
    Ok(ch) => assert_eq(ch, 'a')
    Err(_) => fail("expected Ok")
  }
  match filter(chain_char('a'), fn(c) { c == 'b' }).parse("a") {
    Ok(_) => fail("expected Err")
    Err(_) => ()
  }
  match validate(chain_char('a'), fn(c) { Ok(c) }).parse("a") {
    Ok(ch) => assert_eq(ch, 'a')
    Err(_) => fail("expected Ok")
  }
}

///|
test "chainl1 folds left-associative operators" {
  let digit = @core.Parser::of(fn(st) {
    match st.peek() {
      Some(ch) =>
        if ch >= '0' && ch <= '9' {
          st.advance_one()
          @core.Success(ch.to_int() - '0'.to_int(), st)
        } else {
          @core.Failure(@core.ParseError::at(pos=st.pos, expected="digit"))
        }
      None => @core.Failure(@core.ParseError::at(pos=st.pos, expected="digit"))
    }
  })
  let add : @core.Parser[(Int32, Int32) -> Int32] = @core.Parser::of(fn(st) {
    match st.peek() {
      Some('+') => {
        st.advance_one()
        @core.Success(fn(a : Int32, b : Int32) { a + b }, st)
      }
      _ => @core.Failure(@core.ParseError::at(pos=st.pos, expected="'+'"))
    }
  })
  match chainl1(digit, add).parse("1+2+3") {
    Ok(v) => assert_eq(v, 6)
    Err(_) => fail("expected Ok")
  }
}
