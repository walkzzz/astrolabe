///|
fn char_parser(expected : Char) -> @core.Parser[Char] {
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
fn comma_parser() -> @core.Parser[Char] {
  char_parser(',')
}

///|
test "many zero matches" {
  let p = many(char_parser('a'))
  let s = @core.State::new("bbb")
  match (p.run)(s) {
    @core.Success(arr, st) => {
      assert_eq(arr.length(), 0)
      assert_eq(st.offset, 0)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "many multiple matches" {
  let p = many(char_parser('a'))
  let s = @core.State::new("aaab")
  match (p.run)(s) {
    @core.Success(arr, st) => {
      assert_eq(arr.length(), 3)
      assert_eq(st.offset, 3)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "many1 success" {
  let p = many1(char_parser('a'))
  let s = @core.State::new("aab")
  match (p.run)(s) {
    @core.Success(arr, st) => {
      assert_eq(arr.length(), 2)
      assert_eq(st.offset, 2)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "many1 failure no match" {
  let p = many1(char_parser('a'))
  let s = @core.State::new("bbb")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(!err.committed())
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "many stops on committed error" {
  let committed_a : @core.Parser[Char] = @core.Parser::of(fn(state) {
    match state.peek() {
      Some(ch) =>
        if ch == 'a' {
          state.advance_one()
          @core.Success(ch, state)
        } else {
          @core.Failure(@core.ParseError(state.pos, ["'a'"], true, []))
        }
      None => @core.Failure(@core.ParseError(state.pos, ["'a'"], true, []))
    }
  })
  let p = many(committed_a)
  let s = @core.State::new("bbb")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.committed())
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "sep_by zero matches" {
  let p = sep_by(char_parser('a'), comma_parser())
  let s = @core.State::new("bbb")
  match (p.run)(s) {
    @core.Success(arr, st) => {
      assert_eq(arr.length(), 0)
      assert_eq(st.offset, 0)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "sep_by multiple matches" {
  let p = sep_by(char_parser('a'), comma_parser())
  let s = @core.State::new("a,a,ab")
  match (p.run)(s) {
    @core.Success(arr, st) => {
      assert_eq(arr.length(), 3)
      assert_eq(st.offset, 5)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "sep_by single match" {
  let p = sep_by(char_parser('a'), comma_parser())
  let s = @core.State::new("ab")
  match (p.run)(s) {
    @core.Success(arr, st) => {
      assert_eq(arr.length(), 1)
      assert_eq(st.offset, 1)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "sep_by1 success" {
  let p = sep_by1(char_parser('a'), comma_parser())
  let s = @core.State::new("a,a,a")
  match (p.run)(s) {
    @core.Success(arr, st) => {
      assert_eq(arr.length(), 3)
      assert_eq(st.offset, 5)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "sep_by1 failure no match" {
  let p = sep_by1(char_parser('a'), comma_parser())
  let s = @core.State::new("bbb")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(!err.committed())
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "count exact matches" {
  let p = count(3, char_parser('a'))
  let s = @core.State::new("aaab")
  match (p.run)(s) {
    @core.Success(arr, st) => {
      assert_eq(arr.length(), 3)
      assert_eq(st.offset, 3)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "count failure insufficient" {
  let p = count(5, char_parser('a'))
  let s = @core.State::new("aaa")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.committed())
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "count zero" {
  let p = count(0, char_parser('a'))
  let s = @core.State::new("bbb")
  match (p.run)(s) {
    @core.Success(arr, st) => {
      assert_eq(arr.length(), 0)
      assert_eq(st.offset, 0)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "many_till stops at end marker" {
  let p = many_till(char_parser('a'), char_parser('}'))
  let s = @core.State::new("aaa}")
  match (p.run)(s) {
    @core.Success(arr, st) => {
      assert_eq(arr.length(), 3)
      assert_eq(st.offset, 3)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "many_till empty" {
  let p = many_till(char_parser('a'), char_parser('}'))
  let s = @core.State::new("}")
  match (p.run)(s) {
    @core.Success(arr, st) => {
      assert_eq(arr.length(), 0)
      assert_eq(st.offset, 0)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "many_till p fails before end" {
  let p = many_till(char_parser('a'), char_parser('}'))
  let s = @core.State::new("aab}")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("'a'"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "option success" {
  let p = option(char_parser('a'), 'z')
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Success(val, st) => {
      assert_eq(val, 'a')
      assert_eq(st.offset, 1)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "option fallback default" {
  let p = option(char_parser('x'), 'z')
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Success(val, st) => {
      assert_eq(val, 'z')
      assert_eq(st.offset, 0)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "option committed failure propagates" {
  let committed_x : @core.Parser[Char] = @core.Parser::of(fn(state) {
    @core.Failure(@core.ParseError(state.pos, ["'x'"], true, []))
  })
  let p = option(committed_x, 'z')
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.committed())
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "skip_many zero" {
  let p = skip_many(char_parser('a'))
  let s = @core.State::new("bbb")
  match (p.run)(s) {
    @core.Success(unit, st) => {
      ignore(unit)
      assert_eq(st.offset, 0)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "skip_many multiple" {
  let p = skip_many(char_parser('a'))
  let s = @core.State::new("aaab")
  match (p.run)(s) {
    @core.Success(unit, st) => {
      ignore(unit)
      assert_eq(st.offset, 3)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "skip_many1 success" {
  let p = skip_many1(char_parser('a'))
  let s = @core.State::new("aab")
  match (p.run)(s) {
    @core.Success(unit, st) => {
      ignore(unit)
      assert_eq(st.offset, 2)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "skip_many1 failure" {
  let p = skip_many1(char_parser('a'))
  let s = @core.State::new("bbb")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(!err.committed())
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "between parens" {
  let p = between(char_parser('('), char_parser('x'), char_parser(')'))
  let s = @core.State::new("(x)")
  match (p.run)(s) {
    @core.Success(val, st) => {
      assert_eq(val, 'x')
      assert_eq(st.offset, 3)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "between open fails" {
  let p = between(char_parser('('), char_parser('x'), char_parser(')'))
  let s = @core.State::new("x)")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(!err.committed())
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "between middle fails commits" {
  let p = between(char_parser('('), char_parser('x'), char_parser(')'))
  let s = @core.State::new("(y)")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.committed())
    @core.Success(_, _) => fail("expected failure")
  }
}
