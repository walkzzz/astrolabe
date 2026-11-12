/// ============================================================================
/// HTTP parser benchmarks
/// ============================================================================

///|
fn make_http_request(n_headers : Int32) -> String {
  let mut req : String = "GET /api/v1/resource HTTP/1.1\r\n"
  for i in 0..<n_headers {
    req = req + "X-Header-\{i}: value-\{i}\r\n"
  }
  req = req + "\r\n"
  req
}

///|
fn bench_http_req(input : String) -> Int32 {
  match @http.parse_request_string(input) {
    Ok(r) => r.headers.length()
    Err(_) => -1
  }
}

///|
test (b : @bench.T) {
  let simple_req = "GET / HTTP/1.1\r\nHost: localhost\r\n\r\n"
  b.bench(name="http_request_simple", fn() {
    b.keep(bench_http_req(simple_req))
  })
}

///|
test (b : @bench.T) {
  let req5 = make_http_request(5)
  let req20 = make_http_request(20)
  let req50 = make_http_request(50)
  b.bench(name="http_request_5_headers", fn() { b.keep(bench_http_req(req5)) })
  b.bench(name="http_request_20_headers", fn() { b.keep(bench_http_req(req20)) })
  b.bench(name="http_request_50_headers", fn() { b.keep(bench_http_req(req50)) })
}

///|
test (b : @bench.T) {
  let uris : Array[String] = [
    "https://example.com/path?q=1#frag", "http://localhost:8080/api/v2/users?limit=10&offset=20",
    "ftp://files.server.org/downloads/file.txt",
  ]
  b.bench(name="uri_parse", fn() {
    let mut total : Int32 = 0
    for u in uris {
      match @http.parse_uri_string(u) {
        Ok(_) => total = total + 1
        Err(_) => total = total + 0
      }
    }
    b.keep(total)
  })
}
