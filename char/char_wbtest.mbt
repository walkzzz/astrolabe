///|
/// 测试 char 组合器成功匹配指定字符
/// Test char combinator successfully matches the specified character
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
/// 测试 char 组合器在字符不匹配时失败
/// Test char combinator fails when character does not match
test "char failure wrong char" {
  let p = char('a')
  let s = @core.State::new("xyz")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("'a'"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
/// 测试 char 组合器在输入结束时失败
/// Test char combinator fails at end of input
test "char failure eof" {
  let p = char('a')
  let s = @core.State::new("")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("'a'"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
/// 测试 string 组合器成功匹配指定字符串
/// Test string combinator successfully matches the specified string
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
/// 测试 string 组合器在字符串不匹配时失败
/// Test string combinator fails when string does not match
test "string failure" {
  let p = string("hello")
  let s = @core.State::new("world")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("\"hello\""))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
/// 测试 any_char 成功消耗任意一个字符
/// Test any_char successfully consumes any single character
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
/// 测试 any_char 在空输入时失败
/// Test any_char fails on empty input
test "any_char failure eof" {
  let p = any_char()
  let s = @core.State::new("")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("any character"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
/// 测试 take 成功截取指定数量的字符
/// Test take successfully slices the specified number of characters
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
/// 测试 take 在输入不足时失败
/// Test take fails when input is insufficient
test "take failure insufficient" {
  let p = take(5)
  let s = @core.State::new("hi")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("5 characters"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
/// 测试 satisfy 成功匹配满足谓词的字符
/// Test satisfy successfully matches a character satisfying the predicate
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
/// 测试 satisfy 在无字符满足谓词时失败
/// Test satisfy fails when no character satisfies the predicate
test "satisfy failure" {
  let p = satisfy(fn(c) { c >= 'a' && c <= 'z' }, label="lowercase")
  let s = @core.State::new("ABC")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("lowercase"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
/// 测试 end_of_input 在空输入时成功
/// Test end_of_input succeeds on empty input
test "end_of_input success" {
  let p = end_of_input()
  let s = @core.State::new("")
  match (p.run)(s) {
    @core.Success(unit, _) => ignore(unit)
    @core.Failure(_) => fail("expected success")
  }
}

///|
/// 测试 end_of_input 在有剩余输入时失败
/// Test end_of_input fails when input remains
test "end_of_input failure" {
  let p = end_of_input()
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("end of input"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
/// 测试 peek 预览字符但不消耗输入
/// Test peek previews a character without consuming input
test "peek success no consume" {
  let p = peek(char('a'))
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Success(ch, st) => {
      assert_eq(ch, 'a')
      assert_eq(st.offset, 0)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
/// 测试 peek 在内部解析器失败时传播错误
/// Test peek propagates error when inner parser fails
test "peek failure" {
  let p = peek(char('x'))
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("'x'"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
/// 测试 skip 消耗输入但丢弃结果
/// Test skip consumes input but discards the result
test "skip success" {
  let p = skip(char('a'))
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Success(unit, st) => {
      ignore(unit)
      assert_eq(st.offset, 1)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
/// 测试 skip 在内部解析器失败时传播错误
/// Test skip propagates error when inner parser fails
test "skip failure" {
  let p = skip(char('x'))
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("'x'"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
/// 测试 char_range 匹配范围中的小写字母
/// Test char_range matches lowercase letter within range
test "char_range lowercase" {
  let p = char_range('a', 'z')
  let s = @core.State::new("hello")
  match (p.run)(s) {
    @core.Success(ch, st) => {
      assert_eq(ch, 'h')
      assert_eq(st.offset, 1)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
/// 测试 char_range 匹配数字字符
/// Test char_range matches digit character within range
test "char_range digit" {
  let p = char_range('0', '9')
  let s = @core.State::new("42")
  match (p.run)(s) {
    @core.Success(ch, _) => assert_eq(ch, '4')
    @core.Failure(_) => fail("expected success")
  }
}

///|
/// 测试 char_range 在字符超出范围时失败
/// Test char_range fails when character is out of range
test "char_range failure out of range" {
  let p = char_range('a', 'z')
  let s = @core.State::new("Z")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("char in [a-z]"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
/// 测试 char_range 在下边界成功匹配
/// Test char_range matches at lower boundary
test "char_range boundary_lo" {
  let p = char_range('a', 'z')
  let s = @core.State::new("a")
  match (p.run)(s) {
    @core.Success(ch, _) => assert_eq(ch, 'a')
    @core.Failure(_) => fail("expected success at lo boundary")
  }
}

///|
/// 测试 char_range 在上边界成功匹配
/// Test char_range matches at upper boundary
test "char_range boundary_hi" {
  let p = char_range('a', 'z')
  let s = @core.State::new("z")
  match (p.run)(s) {
    @core.Success(ch, _) => assert_eq(ch, 'z')
    @core.Failure(_) => fail("expected success at hi boundary")
  }
}

///|
/// 测试 char_class 匹配十六进制数字
/// Test char_class matches hex digit characters
test "char_class hex_digit" {
  let hex_digit = char_class(
    fn(c) {
      (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')
    },
    "hex digit",
  )
  let s = @core.State::new("aF3")
  match (hex_digit.run)(s) {
    @core.Success(ch, st) => {
      assert_eq(ch, 'a')
      assert_eq(st.offset, 1)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
/// 测试 char_class 匹配标识符起始字符
/// Test char_class matches identifier start characters
test "char_class identifier_start" {
  let ident_start = char_class(
    fn(c) { (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_' },
    "identifier start",
  )
  let s = @core.State::new("_foo")
  match (ident_start.run)(s) {
    @core.Success(ch, _) => assert_eq(ch, '_')
    @core.Failure(_) => fail("expected success")
  }
}

///|
/// 测试 char_class 在无字符满足条件时失败
/// Test char_class fails when no character satisfies the condition
test "char_class failure" {
  let ident_start = char_class(
    fn(c) { (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_' },
    "identifier start",
  )
  let s = @core.State::new("123")
  match (ident_start.run)(s) {
    @core.Failure(err) =>
      assert_true(err.expected().contains("identifier start"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
/// 测试通过 Parser::of 构建自定义解析器 — 消耗恰好两个十六进制字符
/// Test building a custom parser via Parser::of — consuming exactly 2 hex chars
test "custom_parser_via_of" {
  let hex_char = char_class(
    fn(c) {
      (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')
    },
    "hex digit",
  )
  let hex_byte = @sequence.seq2(hex_char, hex_char)
  let s = @core.State::new("4A")
  match (hex_byte.run)(s) {
    @core.Success((c1, c2), st) => {
      assert_eq(c1, '4')
      assert_eq(c2, 'A')
      assert_eq(st.offset, 2)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
/// 测试 take_while 零次或多次匹配数字字符
/// Test take_while matches zero or more digit characters
test "take_while digits" {
  let p = take_while(fn(c) { c >= '0' && c <= '9' })
  let s = @core.State::new("123abc")
  match (p.run)(s) {
    @core.Success(val, st) => {
      assert_eq(val, "123")
      assert_eq(st.offset, 3)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
/// 测试 take_while 在零次匹配时返回空字符串
/// Test take_while returns empty string on zero matches
test "take_while zero matches" {
  let p = take_while(fn(c) { c >= '0' && c <= '9' })
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Success(val, st) => {
      assert_eq(val, "")
      assert_eq(st.offset, 0)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
/// 测试 take_while1 一次或多次匹配数字字符
/// Test take_while1 matches one or more digit characters
test "take_while1 digits" {
  let p = take_while1(fn(c) { c >= '0' && c <= '9' }, label="digit")
  let s = @core.State::new("123abc")
  match (p.run)(s) {
    @core.Success(val, st) => {
      assert_eq(val, "123")
      assert_eq(st.offset, 3)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
/// 测试 take_while1 在零次匹配时失败
/// Test take_while1 fails on zero matches
test "take_while1 failure no match" {
  let p = take_while1(fn(c) { c >= '0' && c <= '9' }, label="digit")
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("digit"))
    @core.Success(_, _) => fail("expected failure")
  }
}
