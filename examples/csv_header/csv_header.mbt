/// ============================================================================
/// CSV Header Parser Example — parse comma-separated header lines
/// ============================================================================

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
#warnings("-result_error_return")
fn parse_csv_header(input : String) -> Result[Array[String], @core.ParseError] {
  let csv_header = @astro.sep_by1(csv_field(), @astro.char(','))
  @astro.parse_full(csv_header, input)
}

///|
fn parse_and_show(input : String) -> Unit {
  println("Input: \{input}")
  match parse_csv_header(input) {
    Ok(fields) =>
      println(
        "  \{fields.length()} fields: \{fields.map(fn(f) { "[" + f + "]" }).join(", ")}",
      )
    Err(e) => println("  Error: \{e.format_with_input(input)}")
  }
  println("")
}

///|
fn main {
  println("=== Astrolabe CSV Header Parser Example ===")
  println("")

  parse_and_show("name,age,email")
  parse_and_show("  x  ,  y  ,  z  ")
  parse_and_show("id")
  parse_and_show("a,b,c,d,e,f")
  parse_and_show("")
}
