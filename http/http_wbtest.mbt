///|
test "method_get" {
  let state = @core.State::new("GET ")
  match (http_method().run)(state) {
    @core.Success(GET, st) => assert_true(st.offset == 3)
    _ => assert_true(false, msg="expected GET")
  }
}

///|
test "method_post" {
  let state = @core.State::new("POST ")
  match (http_method().run)(state) {
    @core.Success(POST, _) => assert_true(true)
    _ => assert_true(false, msg="expected POST")
  }
}

///|
test "method_put" {
  let state = @core.State::new("PUT ")
  match (http_method().run)(state) {
    @core.Success(PUT, _) => assert_true(true)
    _ => assert_true(false, msg="expected PUT")
  }
}

///|
test "method_delete" {
  let state = @core.State::new("DELETE ")
  match (http_method().run)(state) {
    @core.Success(DELETE, _) => assert_true(true)
    _ => assert_true(false, msg="expected DELETE")
  }
}

///|
test "method_head" {
  let state = @core.State::new("HEAD ")
  match (http_method().run)(state) {
    @core.Success(HEAD, _) => assert_true(true)
    _ => assert_true(false, msg="expected HEAD")
  }
}

///|
test "method_options" {
  let state = @core.State::new("OPTIONS ")
  match (http_method().run)(state) {
    @core.Success(OPTIONS, _) => assert_true(true)
    _ => assert_true(false, msg="expected OPTIONS")
  }
}

///|
test "method_patch" {
  let state = @core.State::new("PATCH ")
  match (http_method().run)(state) {
    @core.Success(PATCH, _) => assert_true(true)
    _ => assert_true(false, msg="expected PATCH")
  }
}

///|
test "request_line_get" {
  let state = @core.State::new("GET /index.html HTTP/1.1\n")
  match (parse_request_line().run)(state) {
    @core.Success(rl, _) => {
      assert_true(rl.req_method == GET)
      assert_eq(rl.uri, "/index.html")
      assert_true(rl.version.major == 1 && rl.version.minor == 1)
    }
    _ => assert_true(false, msg="expected request line")
  }
}

///|
test "request_line_post_crlf" {
  let state = @core.State::new("POST /api/data HTTP/1.0\r\n")
  match (parse_request_line().run)(state) {
    @core.Success(rl, _) => {
      assert_true(rl.req_method == POST)
      assert_eq(rl.uri, "/api/data")
      assert_true(rl.version.major == 1 && rl.version.minor == 0)
    }
    _ => assert_true(false, msg="expected request line")
  }
}

///|
test "request_line_with_query" {
  let state = @core.State::new("GET /search?q=hello HTTP/2.0\n")
  match (parse_request_line().run)(state) {
    @core.Success(rl, _) => {
      assert_eq(rl.uri, "/search?q=hello")
      assert_true(rl.version.major == 2 && rl.version.minor == 0)
    }
    _ => assert_true(false, msg="expected request line")
  }
}

///|
test "request_line_delete" {
  let state = @core.State::new("DELETE /resource/42 HTTP/1.1\n")
  match (parse_request_line().run)(state) {
    @core.Success(rl, _) => {
      assert_true(rl.req_method == DELETE)
      assert_eq(rl.uri, "/resource/42")
    }
    _ => assert_true(false, msg="expected request line")
  }
}

///|
test "header_single" {
  let state = @core.State::new("Content-Type: text/html\n")
  match (parse_header().run)(state) {
    @core.Success(h, _) => {
      assert_eq(h.name, "Content-Type")
      assert_eq(h.value, "text/html")
    }
    _ => assert_true(false, msg="expected header")
  }
}

///|
test "header_host" {
  let state = @core.State::new("Host: example.com\n")
  match (parse_header().run)(state) {
    @core.Success(h, _) => {
      assert_eq(h.name, "Host")
      assert_eq(h.value, "example.com")
    }
    _ => assert_true(false, msg="expected header")
  }
}

///|
test "header_content_length" {
  let state = @core.State::new("Content-Length: 42\n")
  match (parse_header().run)(state) {
    @core.Success(h, _) => {
      assert_eq(h.name, "Content-Length")
      assert_eq(h.value, "42")
    }
    _ => assert_true(false, msg="expected header")
  }
}

///|
test "header_with_crlf" {
  let state = @core.State::new("Accept: */*\r\n")
  match (parse_header().run)(state) {
    @core.Success(h, _) => {
      assert_eq(h.name, "Accept")
      assert_eq(h.value, "*/*")
    }
    _ => assert_true(false, msg="expected header")
  }
}

///|
test "header_accept_encoding" {
  let state = @core.State::new("Accept-Encoding: gzip, deflate\n")
  match (parse_header().run)(state) {
    @core.Success(h, _) => {
      assert_eq(h.name, "Accept-Encoding")
      assert_eq(h.value, "gzip, deflate")
    }
    _ => assert_true(false, msg="expected header")
  }
}

///|
test "headers_multiple" {
  let state = @core.State::new("Host: example.com\nContent-Type: text/html\n\n")
  match (parse_headers().run)(state) {
    @core.Success(arr, _) => assert_eq(arr.length(), 2)
    _ => assert_true(false, msg="expected 2 headers")
  }
}

///|
test "headers_multiple_crlf" {
  let state = @core.State::new(
    "Host: example.com\r\nContent-Type: text/html\r\n\r\n",
  )
  match (parse_headers().run)(state) {
    @core.Success(arr, _) => assert_eq(arr.length(), 2)
    _ => assert_true(false, msg="expected 2 headers with CRLF")
  }
}

///|
test "headers_empty_lf" {
  let state = @core.State::new("\n")
  match (parse_headers().run)(state) {
    @core.Success(arr, _) => assert_eq(arr.length(), 0)
    _ => assert_true(false, msg="expected 0 headers")
  }
}

///|
test "headers_empty_crlf" {
  let state = @core.State::new("\r\n")
  match (parse_headers().run)(state) {
    @core.Success(arr, _) => assert_eq(arr.length(), 0)
    _ => assert_true(false, msg="expected 0 headers with CRLF")
  }
}

///|
test "parse_request_full" {
  let input = "GET /index.html HTTP/1.1\nHost: example.com\nAccept: text/html\n\n"
  match parse_request_string(input) {
    Ok(req) => {
      assert_true(req.req_method == GET)
      assert_eq(req.uri, "/index.html")
      assert_true(req.version.major == 1 && req.version.minor == 1)
      assert_eq(req.headers.length(), 2)
    }
    Err(e) => assert_true(false, msg="parse failed: " + e.format())
  }
}

///|
test "parse_request_post" {
  let input = "POST /api HTTP/1.1\nContent-Type: application/json\nContent-Length: 13\n\n"
  match parse_request_string(input) {
    Ok(req) => {
      assert_true(req.req_method == POST)
      assert_eq(req.headers.length(), 2)
    }
    Err(_) => assert_true(false, msg="expected success")
  }
}

///|
test "parse_request_crlf" {
  let input = "GET /path HTTP/1.1\r\nHost: localhost\r\n\r\n"
  match parse_request_string(input) {
    Ok(req) => {
      assert_true(req.req_method == GET)
      assert_eq(req.headers.length(), 1)
    }
    Err(_) => assert_true(false, msg="expected success with CRLF")
  }
}

///|
test "uri_simple" {
  let state = @core.State::new("http://example.com/path")
  match (parse_uri().run)(state) {
    @core.Success(uri, _) => {
      assert_eq(uri.scheme, "http")
      assert_eq(uri.host, "example.com")
      assert_eq(uri.path, "/path")
      assert_true(uri.port == None)
      assert_true(uri.query == None)
      assert_true(uri.fragment == None)
    }
    _ => assert_true(false, msg="expected URI")
  }
}

///|
test "uri_https" {
  let state = @core.State::new("https://secure.site.com/endpoint")
  match (parse_uri().run)(state) {
    @core.Success(uri, _) => {
      assert_eq(uri.scheme, "https")
      assert_eq(uri.host, "secure.site.com")
      assert_eq(uri.path, "/endpoint")
    }
    _ => assert_true(false, msg="expected HTTPS URI")
  }
}

///|
test "uri_with_port" {
  let state = @core.State::new("https://example.com:8443/secure")
  match (parse_uri().run)(state) {
    @core.Success(uri, _) => {
      assert_eq(uri.scheme, "https")
      assert_eq(uri.host, "example.com")
      assert_eq(uri.port, Some(8443))
      assert_eq(uri.path, "/secure")
    }
    _ => assert_true(false, msg="expected URI with port")
  }
}

///|
test "uri_with_query" {
  let state = @core.State::new("http://example.com/search?q=hello")
  match (parse_uri().run)(state) {
    @core.Success(uri, _) => {
      assert_eq(uri.query, Some("q=hello"))
      assert_true(uri.fragment == None)
    }
    _ => assert_true(false, msg="expected URI with query")
  }
}

///|
test "uri_with_fragment" {
  let state = @core.State::new("http://example.com/page#section")
  match (parse_uri().run)(state) {
    @core.Success(uri, _) => {
      assert_eq(uri.path, "/page")
      assert_true(uri.query == None)
      assert_eq(uri.fragment, Some("section"))
    }
    _ => assert_true(false, msg="expected URI with fragment")
  }
}

///|
test "uri_full" {
  let state = @core.State::new(
    "https://example.com:8080/api/v1?key=val&x=2#top",
  )
  match (parse_uri().run)(state) {
    @core.Success(uri, _) => {
      assert_eq(uri.scheme, "https")
      assert_eq(uri.host, "example.com")
      assert_eq(uri.port, Some(8080))
      assert_eq(uri.path, "/api/v1")
      assert_eq(uri.query, Some("key=val&x=2"))
      assert_eq(uri.fragment, Some("top"))
    }
    _ => assert_true(false, msg="expected full URI")
  }
}

///|
test "uri_no_path" {
  let state = @core.State::new("http://example.com")
  match (parse_uri().run)(state) {
    @core.Success(uri, _) => {
      assert_eq(uri.scheme, "http")
      assert_eq(uri.host, "example.com")
      assert_eq(uri.path, "/")
    }
    _ => assert_true(false, msg="expected URI with default path")
  }
}

///|
test "parse_uri_string_convenience" {
  match
    parse_uri_string("https://api.example.com:443/v2/users?limit=10#results") {
    Ok(uri) => {
      assert_eq(uri.scheme, "https")
      assert_eq(uri.host, "api.example.com")
      assert_eq(uri.port, Some(443))
      assert_eq(uri.path, "/v2/users")
      assert_eq(uri.query, Some("limit=10"))
      assert_eq(uri.fragment, Some("results"))
    }
    Err(e) => assert_true(false, msg="parse failed: " + e.format())
  }
}

///|
test "version_to_string" {
  let v : Version = { major: 1, minor: 1, }
  assert_eq(v.to_string(), "HTTP/1.1")
}

///|
test "request_line_error_bad_method" {
  let state = @core.State::new("BADMETHOD / HTTP/1.1\n")
  match (parse_request_line().run)(state) {
    @core.Failure(_) => assert_true(true)
    @core.Success(_, _) => assert_true(false, msg="should fail on bad method")
  }
}

///|
test "header_error_no_colon" {
  let state = @core.State::new("NoColonHere\n")
  match (parse_header().run)(state) {
    @core.Failure(_) => assert_true(true)
    @core.Success(_, _) => assert_true(false, msg="should fail on no colon")
  }
}

///|
test "uri_error_no_scheme" {
  let state = @core.State::new("example.com/path")
  match (parse_uri().run)(state) {
    @core.Failure(_) => assert_true(true)
    @core.Success(_, _) => assert_true(false, msg="should fail without scheme")
  }
}

///|
test "take_until_comma" {
  let state = @core.State::new("hello,world")
  match (take_while(fn(c) { c != ',' }, "until comma").run)(state) {
    @core.Success(s, _) => assert_eq(s, "hello")
    _ => assert_true(false, msg="expected 'hello'")
  }
}

///|
test "take_while_digits" {
  let state = @core.State::new("123abc")
  match (take_while(fn(c) { c >= '0' && c <= '9' }, "digit").run)(state) {
    @core.Success(s, _) => assert_eq(s, "123")
    _ => assert_true(false, msg="expected '123'")
  }
}

///|
test "digits1_parser" {
  let state = @core.State::new("42abc")
  match (digits1().run)(state) {
    @core.Success(s, _) => assert_eq(s, "42")
    _ => assert_true(false, msg="expected '42'")
  }
}

///|
test "http_token_parser" {
  let state = @core.State::new("GET ")
  match (take_while1(fn(c) { c >= 'A' && c <= 'Z' }, "uppercase").run)(state) {
    @core.Success(s, _) => assert_eq(s, "GET")
    _ => assert_true(false, msg="expected 'GET' token")
  }
}

///|
test "crlf_lf" {
  let state = @core.State::new("\nabc")
  match (crlf().run)(state) {
    @core.Success(_, st) => assert_eq(st.offset, 1)
    _ => assert_true(false, msg="expected LF consumed")
  }
}

///|
test "crlf_crlf" {
  let state = @core.State::new("\r\nabc")
  match (crlf().run)(state) {
    @core.Success(_, st) => assert_eq(st.offset, 2)
    _ => assert_true(false, msg="expected CRLF consumed")
  }
}
