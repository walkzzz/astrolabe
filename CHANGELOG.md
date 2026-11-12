# Changelog

All notable changes to this project will be documented in this file.

## [0.8.0] - 2026-11-12

### Added
- Benchmark suite (25 benchmarks) across 5 categories:
  - `basic_bench`: char, string, satisfy, take, end_of_input
  - `compose_bench`: map, bind, seq2, many, many1, sep_by1, count
  - `control_bench`: alt, choice, commit, label
  - `json_bench`: JSON scalars, objects (10/50/100), arrays (10/100/1000), nested, mixed
  - `http_bench`: HTTP request, headers, URI
- Run via `moon bench --target native benchmarks/`

## [0.7.0] - 2026-11-12

### Added
- CLI demo (`moon run cmd/main`) with interactive JSON/URI/HTTP/CSV/calc showcase
- Example: URI parser (`examples/uri/`)
- Example: CSV header parser (`examples/csv_header/`)
- Example: Arithmetic calculator (`examples/calc/`)
- `Method::to_string()` in HTTP subpackage

## [0.6.0] - 2026-11-12

### Added
- Custom parser extension points via `Parser::of(fn)`
- `char_range(lo, hi)` combinator
- `char_class(pred, label)` combinator
- 5+ custom combinator tests

## [0.5.0] - 2026-11-12

### Added
- HTTP parser subpackage (`@astrolabe/http`):
  - Method, Version, RequestLine, Header, Request, Uri types
  - `parse_request_line()`, `parse_header()`, `parse_headers()`, `parse_request()`
  - `parse_uri()`, `parse_uri_string()`, `parse_request_string()`
- 41 HTTP-specific tests

## [0.4.0] - 2026-11-12

### Added
- JSON parser subpackage (`@astrolabe/json`):
  - `JValue` enum (JNull, JBool, JNum, JStr, JArr, JObj)
  - `parse(input)` and `JValue::stringify()`
  - Full escape sequence support including `\uXXXX`
- 21 JSON-specific tests

## [0.3.0] - 2026-11-12

### Added
- `many`, `many1`, `sep_by`, `sep_by1`, `count` combinators
- `many_till(p, end_)` — repeat until end marker (end not consumed)
- `peek(p)` — look ahead without consuming
- `skip(p)` — run and discard result
- `ParseError::format_with_input(err, input)` — error with context snippet and caret

## [0.2.0] - 2026-11-12

### Added
- `map`, `bind`, `pure`, `return_` combinators
- `seq2`, `seq3`, `seq4` sequence combinators
- `commit`, `alt`, `choice`, `label` control combinators
- Commitment semantics: sequences commit on second-parser failure

## [0.1.0] - 2026-11-12

### Added
- Core types: `Pos`, `State`, `ParseError`, `Parser[T]`, `ParseResult[T]`
- Basic combinators: `char`, `string`, `any_char`, `take`, `satisfy`, `end_of_input`
- Root facade package with `pub fn` re-exports
- 30 tests across 4 backends (wasm, wasm-gc, js, native)

## [0.0.1] - 2026-11-12

### Added
- Initial project scaffold
- Published to mooncakes.io as `walkzzz/astrolabe@0.0.1`
