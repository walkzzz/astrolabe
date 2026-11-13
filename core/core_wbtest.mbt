///|
/// 测试 Pos::initial 初始位置为 (1,1,0)
/// Test Pos::initial starts at (1,1,0)
test "Pos::initial" {
  let p = Pos::initial()
  assert_eq(p.line, 1)
  assert_eq(p.column, 1)
  assert_eq(p.offset, 0)
}

///|
/// 测试 Pos::advance 普通字符使列号+1、偏移+1
/// Test Pos::advance normal char increments column and offset
test "Pos::advance normal char" {
  let p = Pos::initial().advance('a')
  assert_eq(p.line, 1)
  assert_eq(p.column, 2)
  assert_eq(p.offset, 1)
}

///|
/// 测试 Pos::advance 换行符使行号+1、列号重置为1
/// Test Pos::advance newline increments line and resets column
test "Pos::advance newline" {
  let p = Pos::initial().advance('\n')
  assert_eq(p.line, 2)
  assert_eq(p.column, 1)
  assert_eq(p.offset, 1)
}

///|
/// 测试 Pos::advance 多字符序列的位置累积
/// Test Pos::advance accumulates position across a character sequence
test "Pos::advance sequence" {
  let p = Pos::initial().advance('H').advance('i').advance('\n').advance('!')
  assert_eq(p.line, 2)
  assert_eq(p.column, 2)
  assert_eq(p.offset, 4)
}

///|
/// 测试 State::new 初始化偏移为0、剩余长度正确
/// Test State::new initializes offset to 0 and remaining length correctly
test "State::new" {
  let s = State::new("hello")
  assert_eq(s.offset, 0)
  assert_eq(s.remaining(), 5)
  assert_true(!s.is_eof())
}

///|
/// 测试 State::peek 查看当前字符但不消耗
/// Test State::peek views current character without consuming
test "State::peek" {
  let s = State::new("abc")
  assert_eq(s.peek(), Some('a'))
  assert_eq(s.offset, 0)
}

///|
/// 测试 State::advance_one 前进一个字符
/// Test State::advance_one advances by one character
test "State::advance_one" {
  let s = State::new("abc")
  s.advance_one()
  assert_eq(s.offset, 1)
  assert_eq(s.peek(), Some('b'))
}

///|
/// 测试 State::is_eof 正确判断输入结束
/// Test State::is_eof correctly detects end of input
test "State::is_eof" {
  let s = State::new("ab")
  assert_true(!s.is_eof())
  s.advance_one()
  s.advance_one()
  assert_true(s.is_eof())
}

///|
/// 测试 State::slice 截取输入子串
/// Test State::slice extracts a substring from input
test "State::slice" {
  let s = State::new("hello world")
  assert_eq(s.slice(0, 5), "hello")
}

///|
/// 测试 ParseError::format 包含行号、列号、偏移和期望信息
/// Test ParseError::format includes line, column, offset and expected info
test "ParseError::format" {
  let err = ParseError::at(
    pos={ line: 3, column: 15, offset: 42, },
    expected="HTTP method",
  )
  let fmt = err.format()
  assert_true(fmt.contains("line 3"))
  assert_true(fmt.contains("column 15"))
  assert_true(fmt.contains("offset 42"))
  assert_true(fmt.contains("HTTP method"))
}

///|
/// 测试 ParseError::format_with_input 包含源文本位置指示符
/// Test ParseError::format_with_input includes source text position indicator
test "ParseError::format_with_input" {
  let input = "GET /path with-Payload HTTP/1.1"
  let err = ParseError::at(
    pos={ line: 1, column: 16, offset: 15, },
    expected="HTTP method",
  )
  let fmt = err.format_with_input(input)
  assert_true(fmt.contains("offset 15"))
  assert_true(fmt.contains("HTTP method"))
  assert_true(fmt.contains("^"))
}

///|
/// 测试 ParseError::merge 不同位置时保留更远的错误
/// Test ParseError::merge keeps the further error on different positions
test "ParseError::merge furthest wins" {
  let e1 = ParseError::at(pos={ line: 1, column: 1, offset: 0, }, expected="near")
  let e2 = ParseError::at(pos={ line: 1, column: 5, offset: 4, }, expected="far")
  assert_eq(e1.merge(e2).pos().offset, 4)
  assert_eq(e2.merge(e1).pos().offset, 4)
}

///|
/// 测试 ParseError::merge 同位置时合并期望标签（去重保序）
/// Test ParseError::merge merges labels at equal positions (dedup, order-preserving)
test "ParseError::merge same position" {
  let e1 = ParseError::at(pos={ line: 1, column: 1, offset: 0, }, expected="a")
  let e2 = ParseError::at(pos={ line: 1, column: 1, offset: 0, }, expected="b")
  let merged = e1.merge(e2)
  assert_eq(merged.expected(), ["a", "b"])
  assert_true(!merged.committed())
}

///|
/// 测试 ParseError::merge 同位置去重相同标签且 committed 取逻辑或
/// Test ParseError::merge dedups labels and ORs committed flags at equal positions
test "ParseError::merge dedup and commit-or" {
  let pos : Pos = { line: 1, column: 1, offset: 0, }
  let e1 = ParseError::at(pos~, expected="a")
  let e2 = ParseError(pos, ["a"], true, [])
  let merged = e1.merge(e2)
  assert_eq(merged.expected(), ["a"])
  assert_true(merged.committed())
}
