///|
/// 测试 HTTP GET 方法解析
/// Test HTTP GET method parsing
test "method_get" {
  let state = @core.State::new("GET ")
  match (http_method().run)(state) {
    @core.Success(GET, st) => assert_true(st.offset == 3)
    _ => assert_true(false, msg="expected GET")
  }
}

///|
/// 测试 HTTP POST 方法解析
/// Test HTTP POST method parsing
test "method_post" {
  let state = @core.State::new("POST ")
  match (http_method().run)(state) {
    @core.Success(POST, _) => assert_true(true)
    _ => assert_true(false, msg="expected POST")
  }
}

///|
/// 测试 HTTP PUT 方法解析
/// Test HTTP PUT method parsing
test "method_put" {
  let state = @core.State::new("PUT ")
  match (http_method().run)(state) {
    @core.Success(PUT, _) => assert_true(true)
    _ => assert_true(false, msg="expected PUT")
  }
}

///|
/// 测试 HTTP DELETE 方法解析
/// Test HTTP DELETE method parsing
test "method_delete" {
  let state = @core.State::new("DELETE ")
  match (http_method().run)(state) {
    @core.Success(DELETE, _) => assert_true(true)
    _ => assert_true(false, msg="expected DELETE")
  }
}

///|
/// 测试 HTTP HEAD 方法解析
/// Test HTTP HEAD method parsing
test "method_head" {
  let state = @core.State::new("HEAD ")
  match (http_method().run)(state) {
    @core.Success(HEAD, _) => assert_true(true)
    _ => assert_true(false, msg="expected HEAD")
  }
}

///|
/// 测试 HTTP OPTIONS 方法解析
/// Test HTTP OPTIONS method parsing
test "method_options" {
  let state = @core.State::new("OPTIONS ")
  match (http_method().run)(state) {
    @core.Success(OPTIONS, _) => assert_true(true)
    _ => assert_true(false, msg="expected OPTIONS")
  }
}

///|
/// 测试 HTTP PATCH 方法解析
/// Test HTTP PATCH method parsing
test "method_patch" {
  let state = @core.State::new("PATCH ")
  match (http_method().run)(state) {
    @core.Success(PATCH, _) => assert_true(true)
    _ => assert_true(false, msg="expected PATCH")
  }
}

///|
/// 测试 GET 请求行解析
/// Test GET request line parsing
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
/// 测试 POST 请求行解析（CRLF 换行）
/// Test POST request line parsing (CRLF line ending)
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
/// 测试带查询参数的请求行解析
/// Test request line parsing with query string
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
/// 测试 DELETE 请求行解析
/// Test DELETE request line parsing
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
/// 测试单个 HTTP 头部解析
/// Test single HTTP header parsing
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
/// 测试 Host 头部解析
/// Test Host header parsing
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
/// 测试 Content-Length 头部解析
/// Test Content-Length header parsing
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
/// 测试 CRLF 换行的头部解析
/// Test header parsing with CRLF line ending
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
/// 测试 Accept-Encoding 头部解析
/// Test Accept-Encoding header parsing
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
/// 测试多个头部解析（LF 换行）
/// Test multiple headers parsing (LF line endings)
test "headers_multiple" {
  let state = @core.State::new("Host: example.com\nContent-Type: text/html\n\n")
  match (parse_headers().run)(state) {
    @core.Success(arr, _) => assert_eq(arr.length(), 2)
    _ => assert_true(false, msg="expected 2 headers")
  }
}

///|
/// 测试多个头部解析（CRLF 换行）
/// Test multiple headers parsing (CRLF line endings)
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
/// 测试空头部区域（LF 换行）
/// Test empty headers section (LF line ending)
test "headers_empty_lf" {
  let state = @core.State::new("\n")
  match (parse_headers().run)(state) {
    @core.Success(arr, _) => assert_eq(arr.length(), 0)
    _ => assert_true(false, msg="expected 0 headers")
  }
}

///|
/// 测试空头部区域（CRLF 换行）
/// Test empty headers section (CRLF line ending)
test "headers_empty_crlf" {
  let state = @core.State::new("\r\n")
  match (parse_headers().run)(state) {
    @core.Success(arr, _) => assert_eq(arr.length(), 0)
    _ => assert_true(false, msg="expected 0 headers with CRLF")
  }
}

///|
/// 测试完整 HTTP GET 请求解析
/// Test full HTTP GET request parsing
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
/// 测试完整 HTTP POST 请求解析
/// Test full HTTP POST request parsing
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
/// 测试 CRLF 换行的完整请求解析
/// Test full request parsing with CRLF line endings
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
/// 测试简单 URI 解析（http + 路径）
/// Test simple URI parsing (http + path)
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
/// 测试 HTTPS URI 解析
/// Test HTTPS URI parsing
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
/// 测试带端口号的 URI 解析
/// Test URI parsing with port number
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
/// 测试带查询参数的 URI 解析
/// Test URI parsing with query string
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
/// 测试带片段标识的 URI 解析
/// Test URI parsing with fragment identifier
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
/// 测试完整 URI 解析（协议+主机+端口+路径+查询+片段）
/// Test full URI parsing (scheme+host+port+path+query+fragment)
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
/// 测试无路径的 URI 解析（默认路径为 "/"）
/// Test URI parsing without path (default path is "/")
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
/// 测试 parse_uri_string 便捷函数
/// Test parse_uri_string convenience function
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
/// 测试 Version::to_string 输出格式
/// Test Version::to_string output format
test "version_to_string" {
  let v : Version = { major: 1, minor: 1, }
  assert_eq(v.to_string(), "HTTP/1.1")
}

///|
/// 测试请求行在非法方法时报错
/// Test request line reports error on invalid method
test "request_line_error_bad_method" {
  let state = @core.State::new("BADMETHOD / HTTP/1.1\n")
  match (parse_request_line().run)(state) {
    @core.Failure(_) => assert_true(true)
    @core.Success(_, _) => assert_true(false, msg="should fail on bad method")
  }
}

///|
/// 测试头部在缺少冒号时报错
/// Test header reports error when colon is missing
test "header_error_no_colon" {
  let state = @core.State::new("NoColonHere\n")
  match (parse_header().run)(state) {
    @core.Failure(_) => assert_true(true)
    @core.Success(_, _) => assert_true(false, msg="should fail on no colon")
  }
}

///|
/// 测试 URI 在缺少协议时报错
/// Test URI reports error when scheme is missing
test "uri_error_no_scheme" {
  let state = @core.State::new("example.com/path")
  match (parse_uri().run)(state) {
    @core.Failure(_) => assert_true(true)
    @core.Success(_, _) => assert_true(false, msg="should fail without scheme")
  }
}

///|
/// 测试 take_until 解析到逗号为止
/// Test take_until parsing until comma
test "take_until_comma" {
  let state = @core.State::new("hello,world")
  match (take_while(fn(c) { c != ',' }, "until comma").run)(state) {
    @core.Success(s, _) => assert_eq(s, "hello")
    _ => assert_true(false, msg="expected 'hello'")
  }
}

///|
/// 测试 take_while 数字字符解析
/// Test take_while digit character parsing
test "take_while_digits" {
  let state = @core.State::new("123abc")
  match (take_while(fn(c) { c >= '0' && c <= '9' }, "digit").run)(state) {
    @core.Success(s, _) => assert_eq(s, "123")
    _ => assert_true(false, msg="expected '123'")
  }
}

///|
/// 测试 digits1 解析器（至少一位数字）
/// Test digits1 parser (at least one digit)
test "digits1_parser" {
  let state = @core.State::new("42abc")
  match (digits1().run)(state) {
    @core.Success(s, _) => assert_eq(s, "42")
    _ => assert_true(false, msg="expected '42'")
  }
}

///|
/// 测试 HTTP token 解析
/// Test HTTP token parsing
test "http_token_parser" {
  let state = @core.State::new("GET ")
  match (take_while1(fn(c) { c >= 'A' && c <= 'Z' }, "uppercase").run)(state) {
    @core.Success(s, _) => assert_eq(s, "GET")
    _ => assert_true(false, msg="expected 'GET' token")
  }
}

///|
/// 测试 crlf 解析 LF 换行
/// Test crlf parsing LF line ending
test "crlf_lf" {
  let state = @core.State::new("\nabc")
  match (crlf().run)(state) {
    @core.Success(_, st) => assert_eq(st.offset, 1)
    _ => assert_true(false, msg="expected LF consumed")
  }
}

///|
/// 测试 crlf 解析 CRLF 换行
/// Test crlf parsing CRLF line ending
test "crlf_crlf" {
  let state = @core.State::new("\r\nabc")
  match (crlf().run)(state) {
    @core.Success(_, st) => assert_eq(st.offset, 2)
    _ => assert_true(false, msg="expected CRLF consumed")
  }
}
