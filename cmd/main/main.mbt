/// ============================================================================
/// Astrolabe CLI Demo — interactive parser showcase
/// ============================================================================

///|
fn show_int_option(opt : Int32?, label : String) -> String {
  match opt {
    Some(v) => "\{label}=\{v}"
    None => "\{label}=None"
  }
}

///|
fn show_string_option(opt : String?, label : String) -> String {
  match opt {
    Some(v) => "\{label}=\{v}"
    None => "\{label}=None"
  }
}

///|
fn demo_json(input : String) -> Unit {
  println("=== JSON Parser ===")
  println("Input: \{input}")
  match @json.parse(input) {
    Ok(v) => println("  => \{v.stringify()}")
    Err(e) => println("  => Error: \{e.format_with_input(input)}")
  }
  println("")
}

///|
fn demo_uri(input : String) -> Unit {
  println("=== URI Parser ===")
  println("Input: \{input}")
  match @http.parse_uri_string(input) {
    Ok(uri) =>
      println(
        "  => scheme=\{uri.scheme} host=\{uri.host} \{show_int_option(uri.port, "port")} path=\{uri.path} \{show_string_option(uri.query, "query")} \{show_string_option(uri.fragment, "fragment")}",
      )
    Err(e) => println("  => Error: \{e.format_with_input(input)}")
  }
  println("")
}

///|
fn demo_http(input : String) -> Unit {
  println("=== HTTP Request Parser ===")
  println("Input:")
  println(input)
  match @http.parse_request_string(input) {
    Ok(req) =>
      println(
        "  => \{req.req_method.to_string()} \{req.uri} \{req.version.to_string()} (\{req.headers.length()} headers)",
      )
    Err(e) => println("  => Error: \{e.format_with_input(input)}")
  }
  println("")
}

///|
fn csv_field() -> @core.Parser[String] {
  @astro.map(
    @astro.many(
      @astro.satisfy(fn(c) { c != ',' && c != '\n' }, label="field char"),
    ),
    fn(chars) {
      let mut s : String = ""
      for c in chars {
        s = s + c.to_string()
      }
      s.trim().to_owned()
    },
  )
}

///|
fn demo_csv_header(input : String) -> Unit {
  println("=== CSV Header Parser ===")
  println("Input: \{input}")
  let csv_header = @astro.sep_by1(csv_field(), @astro.char(','))
  match @astro.parse_full(csv_header, input) {
    Ok(fields) =>
      println(
        "  => \{fields.length()} fields: \{fields.map(fn(f) { "[" + f + "]" }).join(", ")}",
      )
    Err(e) => println("  => Error: \{e.format_with_input(input)}")
  }
  println("")
}

/// ============================================================================
/// Calc parser — recursive descent via top-level step functions
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
fn demo_calc(input : String) -> Unit {
  println("=== Simple Calc Parser ===")
  println("Input: \{input}")
  match @astro.parse_full(calc_expr(), input) {
    Ok(result) => println("  => \{result}")
    Err(e) => println("  => Error: \{e.format_with_input(input)}")
  }
  println("")
}

///|
fn main {
  println("Astrolabe — Position-Aware Parser Combinators for MoonBit")
  println("==========================================================")
  println("")

  demo_json("null")
  demo_json("true")
  demo_json("42")
  demo_json("\"hello\"")
  demo_json("[1, 2, 3]")
  demo_json("{\"name\": \"Alice\", \"age\": 30}")
  demo_json("{bad input")

  demo_uri("https://example.com/path?q=1#frag")
  demo_uri("http://localhost:8080/api")
  demo_uri("ftp://host")

  demo_http(
    "GET /index.html HTTP/1.1\r\nHost: example.com\r\nAccept: text/html\r\n\r\n",
  )

  demo_csv_header("name,age,email")
  demo_csv_header("  x  ,  y  ,  z  ")

  demo_calc("1+2*3")
  demo_calc("(1+2)*3")
  demo_calc("10-4/2")
  demo_calc("2*3+4*5")
}
