///| 匹配单个指定字符。

///|

///| 若下一个字符等于 `expected`，成功并消耗该字符；

///| 否则在当前位置产生未承诺的错误。

///|

///| Match a single specific character.

///| Succeeds and consumes one character if it equals `expected`.

///|
/// Fails with an uncommitted error otherwise.
pub fn char(expected : Char) -> @core.Parser[Char] {
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

///| 匹配精确字符串字面量。

///|

///| 若输入从游标起等于 `expected`，成功并消耗整个字面量；

///| 否则产生未承诺的错误。

///|

///| Match an exact string literal.

///| Succeeds and consumes `expected` if the input at cursor equals it.

///|
/// Fails with an uncommitted error otherwise.
pub fn string(expected : String) -> @core.Parser[String] {
  @core.Parser::of(fn(state) {
    let len = expected.length()
    if state.remaining() < len {
      @core.Failure(
        @core.ParseError::at(pos=state.pos, expected="\"\{expected}\""),
      )
    } else {
      let actual = state.slice(state.offset, state.offset + len)
      if actual == expected {
        state.advance_by(len)
        @core.Success(expected, state)
      } else {
        @core.Failure(
          @core.ParseError::at(pos=state.pos, expected="\"\{expected}\""),
        )
      }
    }
  })
}

///| 匹配任意单个字符。

///|

///| 成功并消耗一个字符；仅在 EOF 时失败。

///|

///|
/// Match any single character. Fails only at EOF.
pub fn any_char() -> @core.Parser[Char] {
  @core.Parser::of(fn(state) {
    match state.peek() {
      Some(ch) => {
        state.advance_one()
        @core.Success(ch, state)
      }
      None =>
        @core.Failure(
          @core.ParseError::at(pos=state.pos, expected="any character"),
        )
    }
  })
}

///| 消费恰好 `n` 个字符。

///|

///| 若剩余字符不少于 `n`，返回消耗的子字符串；

///| 否则产生未承诺的错误。

///|

///| Consume exactly `n` characters from the input.

///|
/// Fails with an uncommitted error if fewer than `n` remain.
pub fn take(n : Int32) -> @core.Parser[String] {
  @core.Parser::of(fn(state) {
    if state.remaining() < n {
      @core.Failure(
        @core.ParseError::at(pos=state.pos, expected="\{n} characters"),
      )
    } else {
      let result = state.slice(state.offset, state.offset + n)
      state.advance_by(n)
      @core.Success(result, state)
    }
  })
}

///| 匹配满足谓词的单个字符。

///|

///| 查看当前字符，若 `pred` 返回 `true` 则成功消耗；

///| 否则产生未承诺的错误。`label` 参数自定义错误信息。

///|

///| Match a single character that satisfies a predicate.

///|
/// The `label` parameter customizes error messages.
pub fn satisfy(
  pred : (Char) -> Bool,
  label~ : String = "satisfy",
) -> @core.Parser[Char] {
  @core.Parser::of(fn(state) {
    match state.peek() {
      Some(ch) =>
        if pred(ch) {
          state.advance_one()
          @core.Success(ch, state)
        } else {
          @core.Failure(@core.ParseError::at(pos=state.pos, expected=label))
        }
      None => @core.Failure(@core.ParseError::at(pos=state.pos, expected=label))
    }
  })
}

///| 仅在输入末尾成功。

///|

///| 匹配零个字符，当游标在 EOF 时成功；有剩余输入时失败。

///|

///| Succeed only at the end of input.

///|
/// Matches zero characters and succeeds when the cursor is at EOF.
pub fn end_of_input() -> @core.Parser[Unit] {
  @core.Parser::of(fn(state) {
    if state.is_eof() {
      @core.Success((), state)
    } else {
      @core.Failure(
        @core.ParseError::at(pos=state.pos, expected="end of input"),
      )
    }
  })
}

///| 前瞻 — 运行 `p` 但不消耗输入。

///|

///| 在状态的**快照**上运行 `p`；若成功返回其值但**不**推进游标；

///| 若失败，失败直接传递。

///|

///| Look ahead without consuming input.

///| Runs `p` on a snapshot of the state; if `p` succeeds, returns its

///|
/// value but does not advance the cursor.
pub fn[T] peek(p : @core.Parser[T]) -> @core.Parser[T] {
  @core.Parser::of(fn(state) {
    let saved_offset = state.offset
    let saved_pos : @core.Pos = {
      line: state.pos.line,
      column: state.pos.column,
      offset: state.pos.offset,
    }
    match (p.run)(state) {
      @core.Success(value, _) => {
        state.offset = saved_offset
        state.pos = saved_pos
        @core.Success(value, state)
      }
      @core.Failure(err) => @core.Failure(err)
    }
  })
}

///| 运行 `p` 并消耗输入，但丢弃结果。

///|

///| 用于需要跳过分隔符但不关心其值的场景。

///|

///| Run `p` and discard its result, but consume the input.

///|
/// Useful when you need to advance past a delimiter.
pub fn[T] skip(p : @core.Parser[T]) -> @core.Parser[Unit] {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Success(_, st) => @core.Success((), st)
      @core.Failure(err) => @core.Failure(err)
    }
  })
}

///| 匹配闭区间 `[lo, hi]` 内的单个字符。

///|

///| 若下一个字符不在范围内则失败。

///|

///| Parse a single character in the inclusive range [lo, hi].

///|
/// Fails if the next character is outside the range.
pub fn char_range(lo : Char, hi : Char) -> @core.Parser[Char] {
  let label_ = "char in [" + lo.to_string() + "-" + hi.to_string() + "]"
  @core.Parser::of(fn(state) {
    match state.peek() {
      Some(ch) if ch >= lo && ch <= hi => {
        state.advance_one()
        @core.Success(ch, state)
      }
      _ => @core.Failure(@core.ParseError::at(pos=state.pos, expected=label_))
    }
  })
}

///| 匹配满足谓词的单个字符（带自定义标签）。

///|

///| 最灵活的单字符解析器：传入任意 `(Char) -> Bool`

///| 定义自定义字符类（如十六进制数字、标识符起始等）。

///|

///| Parse a single character matching a predicate function with a custom label.

///|
/// Use for named character classes (hex digits, identifier starts, etc.).
pub fn char_class(pred : (Char) -> Bool, label_ : String) -> @core.Parser[Char] {
  @core.Parser::of(fn(state) {
    match state.peek() {
      Some(ch) if pred(ch) => {
        state.advance_one()
        @core.Success(ch, state)
      }
      _ => @core.Failure(@core.ParseError::at(pos=state.pos, expected=label_))
    }
  })
}

///| 消费满足谓词的连续字符，返回拼接字符串。

///| 零次匹配也成功（返回空字符串）。

///|

///| Consume consecutive characters satisfying `pred`, returning the matched string.

///|
/// Succeeds with an empty string on zero matches.
pub fn take_while(pred : (Char) -> Bool) -> @core.Parser[String] {
  @core.Parser::of(fn(state) {
    let start = state.offset
    take_while_step(pred, state)
    let result = state.slice(start, state.offset)
    @core.Success(result, state)
  })
}

///|
fn take_while_step(pred : (Char) -> Bool, state : @core.State) -> Unit {
  match state.peek() {
    Some(ch) if pred(ch) => {
      state.advance_one()
      take_while_step(pred, state)
    }
    _ => ()
  }
}

///| 消费满足谓词的连续字符（至少一个），返回拼接字符串。

///| 零次匹配时产生未承诺的错误。

///|

///| Consume consecutive characters satisfying `pred` (at least one).

///|
/// Fails with an uncommitted error on zero matches.
pub fn take_while1(
  pred : (Char) -> Bool,
  label~ : String = "take_while1",
) -> @core.Parser[String] {
  @core.Parser::of(fn(state) {
    match state.peek() {
      Some(ch) if pred(ch) => {
        let start = state.offset
        state.advance_one()
        take_while_step(pred, state)
        let result = state.slice(start, state.offset)
        @core.Success(result, state)
      }
      _ => @core.Failure(@core.ParseError::at(pos=state.pos, expected=label))
    }
  })
}
