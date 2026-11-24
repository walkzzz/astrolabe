// 0.6.0 新增 API 白盒测试（Pos::to_string / ParseError::expected_joined / Parser::parse_prefix）

///|
test {
  // Pos::to_string：稳定格式 line:column@offset
  let p0 = Pos::initial()
  assert_eq(p0.to_string(), "1:1@0")
  let p1 = p0.advance('a')
  assert_eq(p1.to_string(), "1:2@1")
  let p2 = p1.advance('\n')
  assert_eq(p2.to_string(), "2:1@2")
  assert_eq(p2.advance('x').to_string(), "2:2@3")
}

///|
test {
  // expected_joined：去重保序 + 空集合为 unknown
  let e1 = ParseError::at(pos=Pos::initial(), expected="digit")
  assert_eq(ParseError::expected_joined(e1), "digit")
  let e2 = ParseError(Pos::initial(), ["digit", "letter", "digit"], false, [])
  assert_eq(ParseError::expected_joined(e2), "digit | letter")
  let e3 = ParseError(Pos::initial(), [], false, [])
  assert_eq(ParseError::expected_joined(e3), "unknown")
}

///|
test {
  // parse_prefix：返回值 + 未消费尾部
  let p = Parser::of(fn(st) {
    match st.peek() {
      Some(ch) => {
        st.advance_one()
        Success(ch, st)
      }
      None => Failure(ParseError::at(pos=st.pos, expected="any char"))
    }
  })
  match p.parse_prefix("abc") {
    Ok(pair) => {
      assert_eq(pair.0, 'a')
      assert_eq(pair.1, "bc")
    }
    Err(_) => assert_true(false)
  }
  match p.parse_prefix("") {
    Ok(_) => assert_true(false)
    Err(err) => assert_eq(ParseError::expected_joined(err), "any char")
  }
  match p.parse_prefix("z") {
    Ok(pair) => assert_eq(pair.1, "")
    Err(_) => assert_true(false)
  }
}
