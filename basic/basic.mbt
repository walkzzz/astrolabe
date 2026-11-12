///| Match a single specific character.

///|

///| Succeeds and consumes one character if it equals `expected`.

///|
/// Fails with an uncommitted error at the current position otherwise.
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

///| Match an exact string literal.

///|

///| Succeeds and consumes `expected` if the input starting at the cursor

///|
/// equals `expected`.  Fails with an uncommitted error otherwise.
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

///| Match any single character.

///|

///| Succeeds and consumes exactly one character from the input.

///|
/// Fails with an uncommitted error at EOF.
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

///| Consume exactly `n` characters from the input.

///|

///| Succeeds if at least `n` characters remain, returning the consumed

///| substring.  Fails with an uncommitted error if fewer than `n`

///|
/// characters are available.
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

///| Match a single character that satisfies a predicate.

///|

///| Peeks at the current character; succeeds and consumes it if `pred`

///| returns `true`.  Fails with an uncommitted error otherwise.

///|

///| The `label` parameter controls the error message — use it to give

///|
/// a human-readable description of what was expected.
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

///| Succeed only at the end of input.

///|

///| Matches zero characters and succeeds when the cursor is at EOF.

///|
/// Fails with an uncommitted error if any input remains.
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

///| Look ahead at the next character without consuming input.

///|

///| Runs `p` on a **snapshot** of the state; if `p` succeeds, returns its

///| value but does **not** advance the cursor.  If `p` fails, the

///|
/// failure passes through unchanged.
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

///| Run `p` and discard its result, but consume the input.

///|

///| Useful when you need to advance past a delimiter but don't care

///|
/// about its value.  Returns `Unit` on success.
pub fn[T] skip(p : @core.Parser[T]) -> @core.Parser[Unit] {
  @core.Parser::of(fn(state) {
    match (p.run)(state) {
      @core.Success(_, st) => @core.Success((), st)
      @core.Failure(err) => @core.Failure(err)
    }
  })
}
