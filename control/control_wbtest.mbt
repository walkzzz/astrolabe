///|
test "not_followed_by p fails" {
  let always_fail : @core.Parser[Char] = @core.Parser::of(fn(state) {
    @core.Failure(@core.ParseError::at(pos=state.pos, expected="'a'"))
  })
  let p = not_followed_by(always_fail)
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Success(unit, st) => {
      ignore(unit)
      assert_eq(st.offset, 0)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "not_followed_by p succeeds" {
  let p = not_followed_by(char('a'), label="not 'a'")
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("not 'a'"))
    @core.Success(_, _) => fail("expected failure")
  }
}

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
test "fix recursive parens" {
  let expr : @core.Parser[String] = fix(fn(self) {
    wb_alt(
      wb_map(char('x'), fn(c) { c.to_string() }),
      wb_map(wb_seq2(wb_seq2(char('('), self), char(')')), fn(p) {
        let ((_, inner), _) = p
        "(" + inner + ")"
      }),
    )
  })
  let s = @core.State::new("((x))")
  match (expr.run)(s) {
    @core.Success(val, st) => {
      assert_eq(val, "((x))")
      assert_eq(st.offset, 5)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "fix single x" {
  let expr : @core.Parser[String] = fix(fn(self) {
    wb_alt(
      wb_map(char('x'), fn(c) { c.to_string() }),
      wb_map(wb_seq2(wb_seq2(char('('), self), char(')')), fn(p) {
        let ((_, inner), _) = p
        "(" + inner + ")"
      }),
    )
  })
  let s = @core.State::new("x")
  match (expr.run)(s) {
    @core.Success(val, st) => {
      assert_eq(val, "x")
      assert_eq(st.offset, 1)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
fn[T] wb_alt(p1 : @core.Parser[T], p2 : @core.Parser[T]) -> @core.Parser[T] {
  @core.Parser::of(fn(state) {
    match (p1.run)(state) {
      @core.Success(value, st) => @core.Success(value, st)
      @core.Failure(err) =>
        if err.committed() {
          @core.Failure(err)
        } else {
          (p2.run)(state)
        }
    }
  })
}

///|
fn[T, U] wb_map(p : @core.Parser[T], f : (T) -> U) -> @core.Parser[U] {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Success(value, st) => @core.Success(f(value), st)
      @core.Failure(err) => @core.Failure(err)
    }
  })
}

///|
fn[A, B] wb_seq2(
  p1 : @core.Parser[A],
  p2 : @core.Parser[B],
) -> @core.Parser[(A, B)] {
  @core.Parser::of(fn(state) {
    match (p1.run)(state) {
      @core.Failure(err) => @core.Failure(err)
      @core.Success(a, st1) =>
        match (p2.run)(st1) {
          @core.Failure(err) => @core.Failure(err.commit())
          @core.Success(b, st2) => @core.Success((a, b), st2)
        }
    }
  })
}

///|
test "with_context adds context to error" {
  let p = with_context(char('x'), "parsing field")
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Failure(err) => {
      assert_true(err.contexts().length() == 1)
      assert_true(err.contexts()[0] == "parsing field")
      assert_true(err.context() == "parsing field")
    }
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "with_context chains multiple contexts" {
  let p = with_context(with_context(char('x'), "inner"), "outer")
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Failure(err) => {
      assert_true(err.contexts().length() == 2)
      assert_true(err.contexts()[0] == "inner")
      assert_true(err.contexts()[1] == "outer")
      assert_true(err.context() == "inner > outer")
    }
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "with_context preserves success" {
  let p = with_context(char('a'), "should not appear")
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Success(ch, st) => {
      assert_eq(ch, 'a')
      assert_eq(st.offset, 1)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "map_error transforms error" {
  let p = map_error(char('x'), fn(err) {
    @core.ParseError(err.pos(), ["custom"], err.committed(), err.contexts())
  })
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected()[0] == "custom")
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "recover from committed failure" {
  let committed_a : @core.Parser[Char] = @core.Parser::of(fn(state) {
    @core.Failure(@core.ParseError(state.pos, ["'a'"], true, []))
  })
  let p = recover(committed_a, fn(_) { char('a') })
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Success(ch, st) => {
      assert_eq(ch, 'a')
      assert_eq(st.offset, 1)
    }
    @core.Failure(_) => fail("expected success via recovery")
  }
}

///|
test "recover from uncommitted failure" {
  let p = recover(char('x'), fn(_) { char('a') })
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Success(ch, st) => {
      assert_eq(ch, 'a')
      assert_eq(st.offset, 1)
    }
    @core.Failure(_) => fail("expected success via recovery")
  }
}
