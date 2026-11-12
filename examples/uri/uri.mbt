/// ============================================================================
/// URI Parser Example — parse RFC 3986 subset URIs with Astrolabe
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
fn parse_and_show(input : String) -> Unit {
  println("Input: \{input}")
  match @http.parse_uri_string(input) {
    Ok(uri) =>
      println(
        "  scheme=\{uri.scheme}  host=\{uri.host}  \{show_int_option(uri.port, "port")}  path=\{uri.path}  \{show_string_option(uri.query, "query")}  \{show_string_option(uri.fragment, "fragment")}",
      )
    Err(e) => println("  Error: \{e.format_with_input(input)}")
  }
  println("")
}

///|
fn main {
  println("=== Astrolabe URI Parser Example ===")
  println("")

  parse_and_show("https://example.com/path?q=1#frag")
  parse_and_show("http://localhost:8080/api/v2")
  parse_and_show("ftp://files.server.org/downloads/file.txt")
  parse_and_show("https://api.example.com:443/users?limit=10&offset=20#results")
  parse_and_show("not-a-uri")
}
