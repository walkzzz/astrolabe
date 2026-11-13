///|
fn char(expected : Char) -> @core.Parser[Char] {
  @core.Parser::of(fn(state) {
    match state.peek() {
      Some(ch) =>
        if ch == expected {
          state.advance_one()
          @core.Success(ch, state)
        } else {
          @core.Failure(
            @core.ParseError::at(pos=state.pos, expected="'\{expected}'"),
          )
        }
      None =>
        @core.Failure(
          @core.ParseError::at(pos=state.pos, expected="'\{expected}'"),
        )
    }
  })
}

///|
fn digit_val() -> @core.Parser[Int32] {
  @core.Parser::of(fn(state) {
    match state.peek() {
      Some(ch) if ch >= '0' && ch <= '9' => {
        state.advance_one()
        @core.Success(ch.to_int() - '0'.to_int(), state)
      }
      _ => @core.Failure(@core.ParseError::at(pos=state.pos, expected="digit"))
    }
  })
}

///|
test "filter passes matching value" {
  let p = filter(digit_val(), fn(v) { v > 5 }, label="digit > 5")
  let s = @core.State::new("7")
  match (p.run)(s) {
    @core.Success(v, st) => {
      assert_eq(v, 7)
      assert_eq(st.offset, 1)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "filter rejects non-matching value" {
  let p = filter(digit_val(), fn(v) { v > 5 }, label="digit > 5")
  let s = @core.State::new("3")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("digit > 5"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "validate transforms Ok result" {
  let p = validate(
    digit_val(),
    fn(v) { if v > 0 { Ok(v * 2) } else { Err("positive digit") } },
    label="positive",
  )
  let s = @core.State::new("3")
  match (p.run)(s) {
    @core.Success(v, _) => assert_eq(v, 6)
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "validate fails on Err result" {
  let p = validate(
    digit_val(),
    fn(v) { if v > 0 { Ok(v * 2) } else { Err("positive digit") } },
    label="positive",
  )
  let s = @core.State::new("0")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("positive"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "chainl1 left-associative addition" {
  let add_op = @core.Parser::of(fn(state) {
    match state.peek() {
      Some('+') => {
        state.advance_one()
        @core.Success(fn(l : Int32, r : Int32) { l + r }, state)
      }
      _ => @core.Failure(@core.ParseError::at(pos=state.pos, expected="'+'"))
    }
  })
  let p = chainl1(digit_val(), add_op)
  let s = @core.State::new("1+2+3")
  match (p.run)(s) {
    @core.Success(v, st) => {
      assert_eq(v, 6)
      assert_eq(st.offset, 5)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "chainr1 right-associative exponent" {
  let pow_op = @core.Parser::of(fn(state) {
    match state.peek() {
      Some('^') => {
        state.advance_one()
        @core.Success(
          fn(l : Int32, r : Int32) {
            let mut result = 1
            for _ in 0..<r {
              result = result * l
            }
            result
          },
          state,
        )
      }
      _ => @core.Failure(@core.ParseError::at(pos=state.pos, expected="'^'"))
    }
  })
  let p = chainr1(digit_val(), pow_op)
  let s = @core.State::new("2^3^1")
  match (p.run)(s) {
    @core.Success(v, st) => {
      assert_eq(v, 8)
      assert_eq(st.offset, 5)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "count_min_max within bounds" {
  let p = count_min_max(min=2, max=4, char('a'))
  let s = @core.State::new("aaa")
  match (p.run)(s) {
    @core.Success(arr, st) => {
      assert_eq(arr.length(), 3)
      assert_eq(st.offset, 3)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "count_min_max exceeds max" {
  let p = count_min_max(min=1, max=2, char('a'))
  let s = @core.State::new("aaa")
  match (p.run)(s) {
    @core.Success(arr, st) => {
      assert_eq(arr.length(), 2)
      assert_eq(st.offset, 2)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "count_min_max below min fails" {
  let p = count_min_max(min=3, max=5, char('a'))
  let s = @core.State::new("aa")
  match (p.run)(s) {
    @core.Failure(_) => ()
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "sep_end_by with trailing separator" {
  let p = sep_end_by(char('a'), char(','))
  let s = @core.State::new("a,a,")
  match (p.run)(s) {
    @core.Success(arr, st) => {
      assert_eq(arr.length(), 2)
      assert_eq(st.offset, 4)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "sep_end_by without trailing separator" {
  let p = sep_end_by(char('a'), char(','))
  let s = @core.State::new("a,a")
  match (p.run)(s) {
    @core.Success(arr, st) => {
      assert_eq(arr.length(), 2)
      assert_eq(st.offset, 3)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "sep_end_by empty input" {
  let p = sep_end_by(char('a'), char(','))
  let s = @core.State::new("")
  match (p.run)(s) {
    @core.Success(arr, st) => {
      assert_eq(arr.length(), 0)
      assert_eq(st.offset, 0)
    }
    @core.Failure(_) => fail("expected success with empty array")
  }
}

///|
test "sep_end_by1 requires at least one" {
  let p = sep_end_by1(char('a'), char(','))
  let s = @core.State::new("")
  match (p.run)(s) {
    @core.Failure(_) => ()
    @core.Success(_, _) => fail("expected failure for empty input")
  }
}
