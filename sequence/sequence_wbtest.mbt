///|
/// 辅助函数：构建匹配指定字符的解析器
/// Helper: build a parser matching a specific character
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
/// 辅助函数：构建匹配逗号的解析器
/// Helper: build a parser matching a comma
fn comma_parser() -> @core.Parser[Char] {
  char_parser(',')
}

///|
/// 测试 many 在零次匹配时返回空数组
/// Test many returns empty array on zero matches
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
/// 测试 many 在多次匹配时收集所有结果
/// Test many collects all results on multiple matches
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
/// 测试 many1 在至少一次匹配时成功
/// Test many1 succeeds with at least one match
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
/// 测试 many1 在零次匹配时失败（未提交）
/// Test many1 fails with uncommitted error on zero matches
test "many1 failure no match" {
  let p = many1(char_parser('a'))
  let s = @core.State::new("bbb")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(!err.committed())
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
/// 测试 many 在遇到已提交错误时停止
/// Test many stops on committed error
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
/// 测试 sep_by 在零次匹配时返回空数组
/// Test sep_by returns empty array on zero matches
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
/// 测试 sep_by 在多次匹配时收集分隔的结果
/// Test sep_by collects separated results on multiple matches
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
/// 测试 sep_by 在单次匹配时不消耗分隔符
/// Test sep_by does not consume separator on single match
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
/// 测试 sep_by1 在至少一次匹配时成功
/// Test sep_by1 succeeds with at least one match
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
/// 测试 sep_by1 在零次匹配时失败（未提交）
/// Test sep_by1 fails with uncommitted error on zero matches
test "sep_by1 failure no match" {
  let p = sep_by1(char_parser('a'), comma_parser())
  let s = @core.State::new("bbb")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(!err.committed())
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
/// 测试 count 精确匹配指定次数
/// Test count matches exactly the specified number of times
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
/// 测试 count 在输入不足时失败（已提交）
/// Test count fails with committed error when input is insufficient
test "count failure insufficient" {
  let p = count(5, char_parser('a'))
  let s = @core.State::new("aaa")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.committed())
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
/// 测试 count(0, _) 始终成功返回空数组
/// Test count(0, _) always succeeds returning empty array
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
/// 测试 many_till 在遇到结束标记时停止
/// Test many_till stops at end marker
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
/// 测试 many_till 在起始即遇结束标记时返回空数组
/// Test many_till returns empty array when end marker is at start
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
/// 测试 many_till 在元素解析器先于结束标记失败时传播错误
/// Test many_till propagates error when element parser fails before end marker
test "many_till p fails before end" {
  let p = many_till(char_parser('a'), char_parser('}'))
  let s = @core.State::new("aab}")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("'a'"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
/// 测试 option 在解析成功时返回解析值
/// Test option returns parsed value on success
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
/// 测试 option 在解析失败时返回默认值
/// Test option returns default value on failure
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
/// 测试 option 在已提交失败时传播错误
/// Test option propagates committed failure
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
/// 测试 skip_many 在零次匹配时不消耗输入
/// Test skip_many does not consume input on zero matches
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
/// 测试 skip_many 在多次匹配时跳过所有元素
/// Test skip_many skips all elements on multiple matches
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
/// 测试 skip_many1 在至少一次匹配时成功
/// Test skip_many1 succeeds with at least one match
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
/// 测试 skip_many1 在零次匹配时失败
/// Test skip_many1 fails on zero matches
test "skip_many1 failure" {
  let p = skip_many1(char_parser('a'))
  let s = @core.State::new("bbb")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(!err.committed())
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
/// 测试 between 解析括号包围的内容
/// Test between parses content enclosed by delimiters
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
/// 测试 between 在左括号匹配失败时返回未提交错误
/// Test between returns uncommitted error when open delimiter fails
test "between open fails" {
  let p = between(char_parser('('), char_parser('x'), char_parser(')'))
  let s = @core.State::new("x)")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(!err.committed())
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
/// 测试 between 在中间解析器失败时返回已提交错误
/// Test between returns committed error when middle parser fails
test "between middle fails commits" {
  let p = between(char_parser('('), char_parser('x'), char_parser(')'))
  let s = @core.State::new("(y)")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.committed())
    @core.Success(_, _) => fail("expected failure")
  }
}
