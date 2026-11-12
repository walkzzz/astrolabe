///| HTTP 方法枚举。

///|

///|
/// HTTP method as an enum.
#derive(Debug, Eq)
pub(all) enum Method {
  GET
  POST
  PUT
  DELETE
  HEAD
  OPTIONS
  PATCH
  CONNECT
  TRACE
}

///|
pub extend Method with Eq::{not_equal, equal}

///|
pub extend Method with @debug.Debug::{to_repr}

///|
/// 实现 `Show` 特征，支持 `.to_string()` 点调用。
pub impl Show for Method with fn output(self, logger) {
  match self {
    GET => logger.write_string("GET")
    POST => logger.write_string("POST")
    PUT => logger.write_string("PUT")
    DELETE => logger.write_string("DELETE")
    HEAD => logger.write_string("HEAD")
    OPTIONS => logger.write_string("OPTIONS")
    PATCH => logger.write_string("PATCH")
    CONNECT => logger.write_string("CONNECT")
    TRACE => logger.write_string("TRACE")
  }
}

///|
pub extend Method with Show::{output, to_string}

///| HTTP 版本。

///|

///|
/// HTTP version.
#derive(Debug, Eq)
pub(all) struct Version {
  major : Int32
  minor : Int32
}

///|
pub extend Version with Eq::{not_equal, equal}

///|
pub extend Version with @debug.Debug::{to_repr}

///|
/// 实现 `Show` 特征，输出如 `"HTTP/1.1"`。
pub impl Show for Version with fn output(self, logger) {
  logger.write_string("HTTP/")
  logger.write_string(self.major.to_string())
  logger.write_string(".")
  logger.write_string(self.minor.to_string())
}

///|
pub extend Version with Show::{output, to_string}

///| HTTP 请求行：方法 + 路径 + 版本。

///|

///|
/// HTTP request line: method + path + version.
#derive(Debug, Eq)
pub(all) struct RequestLine {
  req_method : Method
  uri : String
  version : Version
}

///|
pub extend RequestLine with Eq::{not_equal, equal}

///|
pub extend RequestLine with @debug.Debug::{to_repr}

///| HTTP 头 — 键值对。

///|

///|
/// HTTP header as a key-value pair.
#derive(Debug, Eq)
pub(all) struct Header {
  name : String
  value : String
}

///|
pub extend Header with Eq::{not_equal, equal}

///|
pub extend Header with @debug.Debug::{to_repr}

///| 已解析的 HTTP 请求（请求行 + 头部）。

///|

///|
/// Parsed HTTP request (request line + headers).
#derive(Debug, Eq)
pub(all) struct Request {
  req_method : Method
  uri : String
  version : Version
  headers : Array[Header]
}

///|
pub extend Request with Eq::{not_equal, equal}

///|
pub extend Request with @debug.Debug::{to_repr}

///| URI 组件。

///|

///|
/// URI components (RFC 3986 subset).
#derive(Debug, Eq)
pub(all) struct Uri {
  scheme : String
  host : String
  port : Int32?
  path : String
  query : String?
  fragment : String?
}

///|
pub extend Uri with Eq::{not_equal, equal}

///|
pub extend Uri with @debug.Debug::{to_repr}

///| 将请求行格式化为字符串，如 `"GET /path HTTP/1.1"`。

///|

///|
/// Format the request line as a string.
pub fn RequestLine::to_string(self : RequestLine) -> String {
  "\{self.req_method} \{self.uri} \{self.version.to_string()}"
}

///| 将头部格式化为字符串，如 `"Content-Type: text/html"`。

///|

///|
/// Format the header as a string.
pub fn Header::to_string(self : Header) -> String {
  "\{self.name}: \{self.value}"
}

///| 将完整请求格式化为字符串。

///|

///|
/// Format the complete request as a string.
pub fn Request::to_string(self : Request) -> String {
  let line = "\{self.req_method} \{self.uri} \{self.version.to_string()}"
  let headers = self.headers.map(fn(h) { h.to_string() }).join("\r\n")
  if headers == "" {
    line + "\r\n\r\n"
  } else {
    line + "\r\n" + headers + "\r\n\r\n"
  }
}

///| 将 URI 格式化为完整字符串。

///|

///|
/// Format the URI as a complete string.
pub fn Uri::to_string(self : Uri) -> String {
  let mut s = "\{self.scheme}://\{self.host}"
  match self.port {
    Some(p) => s = s + ":\{p}"
    None => ()
  }
  s = s + self.path
  match self.query {
    Some(q) => s = s + "?\{q}"
    None => ()
  }
  match self.fragment {
    Some(f) => s = s + "#\{f}"
    None => ()
  }
  s
}

///|
fn take_while(pred : (Char) -> Bool, label_ : String) -> @core.Parser[String] {
  @compose.map(@compose.many(@basic.satisfy(pred, label=label_)), fn(chars) {
    let mut s : String = ""
    for c in chars {
      s = s + c.to_string()
    }
    s
  })
}

///|
fn take_while1(pred : (Char) -> Bool, label_ : String) -> @core.Parser[String] {
  @compose.map(@compose.many1(@basic.satisfy(pred, label=label_)), fn(chars) {
    chars.fold(fn(acc, c) { acc + c.to_string() }, init="")
  })
}

///|
fn crlf() -> @core.Parser[Unit] {
  @control.alt(
    @compose.map(@basic.string("\r\n"), fn(_) { () }),
    @compose.map(@basic.string("\n"), fn(_) { () }),
  )
}

///|
fn try_parse_int(s : String) -> Int32? {
  Some(@string.parse_int(s.to_string_view())) catch {
    _ => None
  }
}

///|
fn digits1() -> @core.Parser[String] {
  take_while1(fn(c) { c >= '0' && c <= '9' }, "digit")
}

///|
fn http_method() -> @core.Parser[Method] {
  @compose.bind(take_while1(fn(c) { c >= 'A' && c <= 'Z' }, "HTTP method"), fn(
    tok,
  ) {
    match tok {
      "GET" => @compose.pure(GET)
      "POST" => @compose.pure(POST)
      "PUT" => @compose.pure(PUT)
      "DELETE" => @compose.pure(DELETE)
      "HEAD" => @compose.pure(HEAD)
      "OPTIONS" => @compose.pure(OPTIONS)
      "PATCH" => @compose.pure(PATCH)
      "CONNECT" => @compose.pure(CONNECT)
      "TRACE" => @compose.pure(TRACE)
      _ =>
        @core.Parser::of(fn(state) {
          @core.Failure(
            @core.ParseError::at(pos=state.pos, expected="HTTP method"),
          )
        })
    }
  })
}

///|
fn request_target() -> @core.Parser[String] {
  take_while1(fn(c) { c != ' ' && c != '\r' && c != '\n' }, "request target")
}

///|
fn http_version() -> @core.Parser[Version] {
  @compose.bind(@basic.string("HTTP/"), fn(_) {
    @compose.bind(digits1(), fn(major_s) {
      let major = match try_parse_int(major_s) {
        Some(n) => n
        None => 0
      }
      @compose.bind(@basic.char('.'), fn(_) {
        @compose.map(digits1(), fn(minor_s) {
          let minor = match try_parse_int(minor_s) {
            Some(n) => n
            None => 0
          }
          { major, minor, }
        })
      })
    })
  })
}

///| 解析 HTTP 请求行：`METHOD /path HTTP/1.1\r\n`

///|

///|
/// Parse an HTTP request line: `METHOD /path HTTP/1.1\r\n`
pub fn parse_request_line() -> @core.Parser[RequestLine] {
  @compose.bind(http_method(), fn(m) {
    @compose.bind(@basic.char(' '), fn(_) {
      @compose.bind(request_target(), fn(uri) {
        @compose.bind(@basic.char(' '), fn(_) {
          @compose.bind(http_version(), fn(v) {
            @compose.map(crlf(), fn(_) { { req_method: m, uri, version: v, } })
          })
        })
      })
    })
  })
}

///| 解析单个头部行：`Key: Value\r\n`

///|

///|
/// Parse a single header line: `Key: Value\r\n`
pub fn parse_header() -> @core.Parser[Header] {
  @compose.bind(
    take_while1(fn(c) { c != ':' && c != '\r' && c != '\n' }, "header name"),
    fn(name) {
      @compose.bind(@basic.char(':'), fn(_) {
        @compose.bind(@basic.char(' '), fn(_) {
          @compose.bind(
            take_while(fn(c) { c != '\r' && c != '\n' }, "header value"),
            fn(value_) {
              @compose.map(crlf(), fn(_) { { name, value: value_, } })
            },
          )
        })
      })
    },
  )
}

///| 解析所有头部，直到空行。

///|

///|
/// Parse all headers until the empty line.
pub fn parse_headers() -> @core.Parser[Array[Header]] {
  parse_headers_step([])
}

///|
fn parse_headers_step(acc : Array[Header]) -> @core.Parser[Array[Header]] {
  @control.alt(
    @compose.map(crlf(), fn(_) { acc }),
    @compose.bind(parse_header(), fn(h : Header) {
      let new_acc = acc.copy()
      new_acc.push(h)
      parse_headers_step(new_acc)
    }),
  )
}

///| 解析完整的 HTTP 请求：请求行 + 头部 + 空行。

///|

///|
/// Parse a complete HTTP request: request line + headers + empty line.
pub fn parse_request() -> @core.Parser[Request] {
  @compose.bind(parse_request_line(), fn(rl) {
    @compose.bind(parse_headers(), fn(headers) {
      @core.Parser::of(fn(state) {
        @core.Success(
          {
            req_method: rl.req_method,
            uri: rl.uri,
            version: rl.version,
            headers,
          },
          state,
        )
      })
    })
  })
}

///|
fn uri_scheme() -> @core.Parser[String] {
  take_while1(fn(c) { c != ':' }, "scheme")
}

///|
fn uri_host() -> @core.Parser[String] {
  take_while1(fn(c) { c != ':' && c != '/' && c != '?' && c != '#' }, "host")
}

///|
fn uri_port() -> @core.Parser[Int32?] {
  @control.alt(
    @compose.bind(@basic.char(':'), fn(_) {
      @compose.map(digits1(), fn(s) {
        match try_parse_int(s) {
          Some(n) => Some(n)
          None => None
        }
      })
    }),
    @compose.pure(None),
  )
}

///|
fn uri_path() -> @core.Parser[String] {
  @control.alt(
    @compose.bind(@basic.char('/'), fn(_) {
      @compose.map(take_while(fn(c) { c != '?' && c != '#' }, "path char"), fn(
        rest,
      ) {
        "/" + rest
      })
    }),
    @compose.pure("/"),
  )
}

///|
fn uri_query() -> @core.Parser[String?] {
  @control.alt(
    @compose.bind(@basic.char('?'), fn(_) {
      @compose.map(take_while(fn(c) { c != '#' }, "query char"), fn(s) {
        Some(s)
      })
    }),
    @compose.pure(None),
  )
}

///|
fn uri_fragment() -> @core.Parser[String?] {
  @control.alt(
    @compose.bind(@basic.char('#'), fn(_) {
      @compose.map(take_while(fn(c) { c != '\n' }, "fragment char"), fn(s) {
        Some(s)
      })
    }),
    @compose.pure(None),
  )
}

///| 解析 URI 为其组件。

///|

///|
/// Parse a URI into its components.
pub fn parse_uri() -> @core.Parser[Uri] {
  @compose.bind(uri_scheme(), fn(scheme) {
    @compose.bind(@basic.string("://"), fn(_) {
      @compose.bind(uri_host(), fn(host) {
        @compose.bind(uri_port(), fn(port) {
          @compose.bind(uri_path(), fn(path) {
            @compose.bind(uri_query(), fn(query) {
              @compose.map(uri_fragment(), fn(fragment) {
                { scheme, host, port, path, query, fragment, }
              })
            })
          })
        })
      })
    })
  })
}

///| 便捷函数：将 URI 字符串解析为 `Result`。

///|

///|
/// Convenience: parse a URI string into Result.
pub fn parse_uri_string(input : String) -> Result[Uri, @core.ParseError] {
  @core.Parser::parse(parse_uri(), input)
}

///| 便捷函数：将 HTTP 请求字符串解析为 `Result`。

///|

///|
/// Convenience: parse an HTTP request string into Result.
pub fn parse_request_string(
  input : String,
) -> Result[Request, @core.ParseError] {
  @core.Parser::parse_full(parse_request(), input)
}
