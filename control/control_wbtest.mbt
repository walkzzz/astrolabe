///|
/// 测试 not_followed_by 在内部解析器失败时成功（不消耗输入）
/// Test not_followed_by succeeds when inner parser fails (no consumption)
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
/// 测试 not_followed_by 在内部解析器成功时失败
/// Test not_followed_by fails when inner parser succeeds
test "not_followed_by p succeeds" {
  let p = not_followed_by(char('a'), label="not 'a'")
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("not 'a'"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
/// 辅助函数：构建匹配指定字符的解析器
/// Helper: build a parser matching a specific character
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
/// 测试 fix 实现递归嵌套括号解析
/// Test fix implements recursive nested-parentheses parsing
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
/// 测试 fix 解析单个 'x' 基本情况
/// Test fix parses single 'x' base case
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
/// 辅助函数：白盒测试用的 alt 组合器
/// Helper: alt combinator for whitebox testing
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
/// 辅助函数：白盒测试用的 map 组合器
/// Helper: map combinator for whitebox testing
fn[T, U] wb_map(p : @core.Parser[T], f : (T) -> U) -> @core.Parser[U] {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Success(value, st) => @core.Success(f(value), st)
      @core.Failure(err) => @core.Failure(err)
    }
  })
}

///|
/// 辅助函数：白盒测试用的 seq2 组合器
/// Helper: seq2 combinator for whitebox testing
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
/// 测试 with_context 向错误添加上下文
/// Test with_context adds context to error
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
/// 测试 with_context 链接多个上下文
/// Test with_context chains multiple contexts
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
/// 测试 with_context 在解析成功时不影响结果
/// Test with_context preserves success without modification
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
/// 测试 map_error 转换错误信息
/// Test map_error transforms error information
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
/// 测试 recover 从已提交失败中恢复
/// Test recover from committed failure
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
/// 测试 recover 从未提交失败中恢复
/// Test recover from uncommitted failure
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

///|
/// 测试 reject 始终产生失败
/// Test reject always produces failure
test "reject always fails" {
  let p : @core.Parser[Char] = reject("nope")
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(err.expected().contains("nope"))
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
/// 测试 succeed 始终成功且不消耗输入
/// Test succeed always succeeds without consuming input
test "succeed always succeeds" {
  let p = succeed(42)
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Success(v, st) => {
      assert_eq(v, 42)
      assert_eq(st.offset, 0)
    }
    @core.Failure(_) => fail("expected success")
  }
}

///|
/// 测试 attempt 将已提交失败降级为未提交
/// Test attempt downgrades committed failure to uncommitted
test "attempt downgrades committed to uncommitted" {
  let committed_fail : @core.Parser[Char] = @core.Parser::of(fn(state) {
    @core.Failure(@core.ParseError(state.pos, ["'a'"], true, []))
  })
  let p = attempt(committed_fail)
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Failure(err) => assert_true(!err.committed())
    @core.Success(_, _) => fail("expected failure")
  }
}

///|
/// 测试 attempt 在失败时回溯状态（恢复偏移量）
/// Test attempt resets state on failure (restores offset)
test "attempt resets state on failure" {
  let consuming_fail : @core.Parser[Char] = @core.Parser::of(fn(state) {
    state.advance_one()
    @core.Failure(@core.ParseError(state.pos, ["'x'"], true, []))
  })
  let p = attempt(consuming_fail)
  let s = @core.State::new("abc")
  match (p.run)(s) {
    @core.Failure(_) => assert_eq(s.offset, 0)
    @core.Success(_, _) => fail("expected failure")
  }
}
