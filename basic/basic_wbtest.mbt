///|
test "char success" {
  let p = char('a')
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
test "char failure wrong char" {
  let p = char('a')
  let s = @core.State::new("xyz")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected.contains("'a'"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "char failure eof" {
  let p = char('a')
  let s = @core.State::new("")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected.contains("'a'"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "string success" {
  let p = string("hello")
  let s = @core.State::new("hello world")
  match (p.run)(s) {
    @core.Success(val, st) => {
      assert_eq(val, "hello")
      assert_eq(st.offset, 5)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "string failure" {
  let p = string("hello")
  let s = @core.State::new("world")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected.contains("\"hello\""))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "any_char success" {
  let p = any_char()
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
test "any_char failure eof" {
  let p = any_char()
  let s = @core.State::new("")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected.contains("any character"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "take success" {
  let p = take(3)
  let s = @core.State::new("hello")
  match (p.run)(s) {
    @core.Success(val, st) => {
      assert_eq(val, "hel")
      assert_eq(st.offset, 3)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "take failure insufficient" {
  let p = take(5)
  let s = @core.State::new("hi")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected.contains("5 characters"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "satisfy success" {
  let p = satisfy(fn(c) { c >= 'a' && c <= 'z' }, label="lowercase")
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
test "satisfy failure" {
  let p = satisfy(fn(c) { c >= 'a' && c <= 'z' }, label="lowercase")
  let s = @core.State::new("ABC")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected.contains("lowercase"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
test "end_of_input success" {
  let p = end_of_input()
  let s = @core.State::new("")
  match (p.run)(s) {
    @core.Success(unit, _) => ignore(unit)
    @core.Failure(_) => fail("expected success")
  }
}

///|
test "end_of_input failure" {
  let p = end_of_input()
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected.contains("end of input"))
    @core.Success(_, _) => fail("expected failure")
  }
}
