///|
/// 公共 API 集成测试 — 验证通过 @astrolabe 门面访问的所有组合器
/// Public API integration tests — verify all combinators accessible through the @astrolabe facade
test "public API: char parse" {
  let p = @astrolabe.char('a')
  match @astrolabe.parse(p, "abc") {
    Ok(ch) => assert_eq(ch, 'a')
    Err(_) => fail("expected Ok")
  }
}

///|
/// 测试 string 组合器解析完整字符串
/// Test the string combinator parsing a full string
test "public API: string parse" {
  let p = @astrolabe.string("hello")
  match @astrolabe.parse(p, "hello world") {
    Ok(val) => assert_eq(val, "hello")
    Err(_) => fail("expected Ok")
  }
}

///|
/// 测试 take 组合器截取指定长度
/// Test the take combinator slicing a specified length
test "public API: take parse" {
  let p = @astrolabe.take(3)
  match @astrolabe.parse(p, "hello") {
    Ok(val) => assert_eq(val, "hel")
    Err(_) => fail("expected Ok")
  }
}

///|
/// 测试 ParseError 格式化输出包含期望信息
/// Test ParseError format output contains expected information
test "public API: ParseError format" {
  let p = @astrolabe.char('x')
  match @astrolabe.parse(p, "abc") {
    Err(err) => {
      let fmt = @astrolabe.format_error(err)
      assert_true(fmt.contains("'x'"))
    }
    Ok(_) => fail("expected Err")
  }
}

///|
/// 测试 parse_full 拒绝尾部多余输入
/// Test parse_full rejects trailing input
test "public API: parse_full rejects trailing" {
  let p = @astrolabe.char('a')
  match @astrolabe.parse_full(p, "ab") {
    Err(err) => assert_true(err.expected().contains("end of input"))
    Ok(_) => fail("expected Err")
  }
}

///|
/// 测试 take_while 零次或多次匹配数字
/// Test take_while matches zero or more digits
test "public API: take_while digits" {
  let p = @astrolabe.take_while(fn(c) { c >= '0' && c <= '9' })
  match @astrolabe.parse(p, "123abc") {
    Ok(val) => assert_eq(val, "123")
    Err(_) => fail("expected Ok")
  }
}

///|
/// 测试 take_while1 一次或多次匹配数字
/// Test take_while1 matches one or more digits
test "public API: take_while1 digits" {
  let p = @astrolabe.take_while1(fn(c) { c >= '0' && c <= '9' }, label="digit")
  match @astrolabe.parse(p, "123abc") {
    Ok(val) => assert_eq(val, "123")
    Err(_) => fail("expected Ok")
  }
}

///|
/// 测试 option 在解析失败时返回默认值
/// Test option returns default value on parse failure
test "public API: option with default" {
  let p = @astrolabe.option(@astrolabe.char('x'), 'z')
  match @astrolabe.parse(p, "abc") {
    Ok(val) => assert_eq(val, 'z')
    Err(_) => fail("expected Ok")
  }
}

///|
/// 测试 skip_many 跳过零次或多次空白
/// Test skip_many skips zero or more whitespace
test "public API: skip_many whitespace" {
  let ws = @astrolabe.skip_many(@astrolabe.char(' '))
  match @astrolabe.parse(ws, "   abc") {
    Ok(unit) => ignore(unit)
    Err(_) => fail("expected Ok")
  }
}

///|
/// 测试 between 解析括号包围的内容
/// Test between parses content enclosed by delimiters
test "public API: between parens" {
  let p = @astrolabe.between(
    @astrolabe.char('('),
    @astrolabe.take_while(fn(c) { c != ')' }),
    @astrolabe.char(')'),
  )
  match @astrolabe.parse(p, "(hello) world") {
    Ok(val) => assert_eq(val, "hello")
    Err(_) => fail("expected Ok")
  }
}

///|
/// 测试 not_followed_by 确保关键字边界
/// Test not_followed_by enforces keyword boundary
test "public API: not_followed_by" {
  let keyword = @astrolabe.bind(@astrolabe.string("if"), fn(_) {
    @astrolabe.not_followed_by(
      @astrolabe.char_range('a', 'z'),
      label="keyword boundary",
    )
  })
  match @astrolabe.parse(keyword, "if x") {
    Ok(_) => ()
    Err(_) => fail("expected Ok for 'if '")
  }
  match @astrolabe.parse(keyword, "ifx") {
    Err(err) => assert_true(err.expected().contains("keyword boundary"))
    Ok(_) => fail("expected Err for 'ifx'")
  }
}

///|
/// 测试 fix 实现递归嵌套括号解析
/// Test fix implements recursive nested-parentheses parsing
test "public API: fix recursive" {
  let x_parser = @astrolabe.map(@astrolabe.char('x'), fn(c) { c.to_string() })
  let expr = @astrolabe.fix(fn(self) {
    @astrolabe.alt(
      x_parser,
      @astrolabe.map(
        @astrolabe.between(@astrolabe.char('('), self, @astrolabe.char(')')),
        fn(inner) { "(" + inner + ")" },
      ),
    )
  })
  match @astrolabe.parse(expr, "((x))") {
    Ok(val) => assert_eq(val, "((x))")
    Err(_) => fail("expected Ok")
  }
}

///|
/// 测试 with_context 在错误格式化中链接上下文
/// Test with_context chains contexts in error formatting
test "public API: with_context chains contexts in format" {
  let p = @astrolabe.with_context(
    @astrolabe.with_context(@astrolabe.char('x'), "field"),
    "record",
  )
  match @astrolabe.parse(p, "abc") {
    Err(err) => {
      let fmt = @astrolabe.format_error(err)
      assert_true(fmt.contains("field > record"))
    }
    Ok(_) => fail("expected Err")
  }
}

///|
/// 测试 recover 从已提交的失败中恢复
/// Test recover continues past committed failure
test "public API: recover continues past committed failure" {
  let p = @astrolabe.recover(@astrolabe.commit(@astrolabe.char('x')), fn(_) {
    @astrolabe.char('a')
  })
  match @astrolabe.parse(p, "abc") {
    Ok(ch) => assert_eq(ch, 'a')
    Err(_) => fail("expected Ok via recovery")
  }
}

///|
/// 测试 reject 始终失败
/// Test reject always fails
test "public API: reject always fails" {
  let p : @core.Parser[Char] = @astrolabe.reject("nope")
  match @astrolabe.parse(p, "abc") {
    Err(err) => assert_true(err.expected().contains("nope"))
    Ok(_) => fail("expected Err")
  }
}

///|
/// 测试 succeed 不消耗输入即返回值
/// Test succeed returns a value without consuming input
test "public API: succeed without consuming" {
  let p = @astrolabe.succeed(99)
  match @astrolabe.parse(p, "abc") {
    Ok(v) => assert_eq(v, 99)
    Err(_) => fail("expected Ok")
  }
}

///|
/// 测试 attempt 将已提交失败回溯为未提交，使 alt 可继续
/// Test attempt backtracks committed failure to uncommitted, enabling alt fallback
test "public API: attempt backtracks committed failure" {
  let p = @astrolabe.alt(
    @astrolabe.attempt(@astrolabe.commit(@astrolabe.char('x'))),
    @astrolabe.char('a'),
  )
  match @astrolabe.parse(p, "abc") {
    Ok(ch) => assert_eq(ch, 'a')
    Err(_) => fail("expected Ok via attempt + alt")
  }
}

///|
/// 测试 with_hint 附加元数据不影响解析结果
/// Test with_hint attaches metadata without affecting parse result
test "public API: with_hint attaches metadata" {
  let p = @astrolabe.with_hint(
    @astrolabe.char('a'),
    hint=@core.ParseHint::heavy(),
  )
  match @astrolabe.parse(p, "abc") {
    Ok(ch) => assert_eq(ch, 'a')
    Err(_) => fail("expected Ok")
  }
}

///|
/// 测试 filter 拒绝不满足谓词的值
/// Test filter rejects values not satisfying the predicate
test "public API: filter rejects non-matching" {
  let p = @astrolabe.filter(
    @astrolabe.any_char(),
    fn(c) { c >= 'a' && c <= 'z' },
    label="lowercase",
  )
  match @astrolabe.parse(p, "A") {
    Err(err) => assert_true(err.expected().contains("lowercase"))
    Ok(_) => fail("expected Err")
  }
}

///|
/// 测试 sep_end_by 支持尾部分隔符
/// Test sep_end_by supports trailing separator
test "public API: sep_end_by with trailing separator" {
  let p = @astrolabe.sep_end_by(@astrolabe.char('a'), @astrolabe.char(','))
  match @astrolabe.parse(p, "a,a,") {
    Ok(arr) => assert_eq(arr.length(), 2)
    Err(_) => fail("expected Ok")
  }
}
