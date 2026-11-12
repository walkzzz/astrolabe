/// ============================================================================
/// Simple Calc Example — parse & evaluate arithmetic expressions
/// ============================================================================

///|
fn ws() -> @core.Parser[Unit] {
  @astro.skip(
    @astro.many(@astro.satisfy(fn(c) { c == ' ' }, label="whitespace")),
  )
}

///|
fn calc_number() -> @core.Parser[Int32] {
  @astro.bind(
    @astro.many1(@astro.satisfy(fn(c) { c >= '0' && c <= '9' }, label="digit")),
    fn(chars) {
      let mut s : String = ""
      for c in chars {
        s = s + c.to_string()
      }
      let n = Some(@string.parse_int(s.to_string_view())) catch { _ => None }
      match n {
        Some(v) => @astro.pure(v)
        None =>
          @core.Parser::of(fn(state) {
            @core.Failure(
              @core.ParseError::at(pos=state.pos, expected="number"),
            )
          })
      }
    },
  )
}

///|
fn calc_paren() -> @core.Parser[Int32] {
  @astro.bind(@astro.char('('), fn(_) {
    @astro.bind(ws(), fn(_) {
      @astro.bind(calc_expr(), fn(e) {
        @astro.bind(ws(), fn(_) {
          @astro.bind(@astro.char(')'), fn(_) { @astro.pure(e) })
        })
      })
    })
  })
}

///|
fn calc_factor() -> @core.Parser[Int32] {
  @astro.bind(ws(), fn(_) {
    @astro.label(
      @astro.alt(
        calc_paren(),
        @astro.bind(calc_number(), fn(n) { @astro.pure(n) }),
      ),
      "factor",
    )
  })
}

///|
fn calc_term_step(acc : Int32) -> @core.Parser[Int32] {
  @astro.alt(
    @astro.alt(
      @astro.bind(@astro.char('*'), fn(_) {
        @astro.bind(calc_factor(), fn(f) { calc_term_step(acc * f) })
      }),
      @astro.bind(@astro.char('/'), fn(_) {
        @astro.bind(calc_factor(), fn(f) { calc_term_step(acc / f) })
      }),
    ),
    @astro.pure(acc),
  )
}

///|
fn calc_term() -> @core.Parser[Int32] {
  @astro.bind(calc_factor(), fn(f) { calc_term_step(f) })
}

///|
fn calc_expr_step(acc : Int32) -> @core.Parser[Int32] {
  @astro.alt(
    @astro.alt(
      @astro.bind(@astro.char('+'), fn(_) {
        @astro.bind(calc_term(), fn(t) { calc_expr_step(acc + t) })
      }),
      @astro.bind(@astro.char('-'), fn(_) {
        @astro.bind(calc_term(), fn(t) { calc_expr_step(acc - t) })
      }),
    ),
    @astro.pure(acc),
  )
}

///|
fn calc_expr() -> @core.Parser[Int32] {
  @astro.bind(ws(), fn(_) {
    @astro.bind(calc_term(), fn(t) { calc_expr_step(t) })
  })
}

///|
fn eval(input : String) -> Unit {
  println("Input: \{input}")
  match @astro.parse_full(calc_expr(), input) {
    Ok(result) => println("  => \{result}")
    Err(e) => println("  Error: \{e.format_with_input(input)}")
  }
  println("")
}

///|
fn main {
  println("=== Astrolabe Calc Example ===")
  println("")

  eval("1+2*3")
  eval("(1+2)*3")
  eval("10-4/2")
  eval("2*3+4*5")
  eval("1 + + 2")
}
