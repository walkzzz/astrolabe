///|
/// 验证 ParseError 实现 Show：to_string / 字符串插值 / inspect 全链路（下游调试体验）
/// Verify ParseError implements Show: to_string / interpolation / inspect chain
test "ParseError implements Show" {
  let p = @char.char('a')
  match p.parse("123") {
    Err(e) => {
      let s = e.to_string()
      assert_true(s.contains("expected"))
      assert_true(s.contains("offset"))
      let interpolated = "\{e}"
      assert_true(interpolated.contains("expected"))
    }
    Ok(_) => fail("expected failure")
  }
}

///|
/// 验证 README 快速开始的 match/println 用法（ParseError Show 使插值可用）
/// Verify the README quick-start match/println usage (ParseError Show enables interpolation)
test "README quick-start pattern works" {
  let p = @char.char('a')
  match p.parse("abc") {
    Ok(c) => {
      let msg = "parsed: \{c}"
      assert_true(msg.contains("parsed: a"))
    }
    Err(e) => fail("unexpected: \{e.format()}")
  }
}
