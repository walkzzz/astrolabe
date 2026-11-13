# Changelog

All notable changes to this project will be documented in this file.

## [0.1.16] - 2026-11-13

### Added
- `suberror ParseError` — ParseError is now a `suberror` (not `struct`), auto-upcasting to `Error`
- Accessor methods: `ParseError::pos()`, `ParseError::expected()`, `ParseError::committed()`, `ParseError::context()`
- `Parser::parse_raise()` / `Parser::parse_full_raise()` — raise-based API for `try...catch` usage
- Facade `parse_raise()` / `parse_full_raise()` in root package
- `#warnings("-result_error_return")` on `Result`-returning parse APIs (intentional data-returning design)

### Changed
- `ParseError` changed from `struct` to `suberror ParseError { ParseError(Pos, Array[String], Bool, String) }`
- `ParseError::format()` and `format_with_input()` rewritten to use pattern matching
- `ParseError::commit()` rewritten to use pattern matching
- `control::label()` constructs `ParseError` via constructor instead of struct literal
- All field accesses (`err.committed`, `err.expected`, etc.) changed to method calls (`err.committed()`, `err.expected()`)

## [0.1.15] - 2026-11-13

### Added
- `#alias(return_, deprecated="Use pure instead")` on `pure` — eliminates separate `return_` function
- `#non_exhaustive` on `Method` enum — forward-compatible for future HTTP methods
- `#inline` on `ParseError::commit()` and 14 facade wrapper functions

### Changed
- `return_` is now an alias (deprecated) for `pure` instead of a separate function
- Manual `impl Show for Method` kept (MoonBit deprecated `derive(Show)`, recommends manual impl)

### Removed
- `return_` function definitions in compose/compose.mbt and astrolabe.mbt (replaced by #alias)

## [0.1.14] - 2026-11-12

### Added
- Bilingual doc comments for proof/proof.mbt (7 verified properties)
- Bilingual doc comments for json/json.mbt internal functions
- Bilingual doc comments for http/http.mbt internal functions
- Comprehensive README.md rewrite with bilingual sections

### Changed
- README.md: updated badge to 0.1.13+, added Features section, commitment propagation table,
  formal verification table, expanded HTTP type methods, MoonBit idioms section

## [0.1.13] - 2026-11-12

### Added
- Bilingual (中文/English) doc comments for all public API:
  - `core/core.mbt`: Pos, State, ParseError, Parser, ParseResult
  - `basic/basic.mbt`: char, string, any_char, take, satisfy, end_of_input, peek, skip, char_range, char_class
  - `compose/compose.mbt`: map, bind, pure, return_, seq2/3/4, many/many1, sep_by/sep_by1, count, many_till
  - `control/control.mbt`: commit, alt, choice, label
  - `http/http.mbt`: Method, Version, RequestLine, Header, Request, Uri, parsers, to_string methods
  - `json/json.mbt`: JValue, stringify, value, parse
  - `astrolabe.mbt`: Root facade re-exports

## [0.1.10] - 2026-11-12

### Added
- Z3 SMT formal verification of core semantics (commit/alt backtracking, sequence commits)
- Formal specification documented in `docs/formal-spec.md`
- Comprehensive documentation suite (API reference, tutorial, migration guide)
- Benchmark suite (25 benchmarks across 5 categories)
- CLI demo + 3 examples (URI, CSV, calculator)

### Changed
- License changed from Apache-2.0 to MIT

## [0.9.0] - 2026-11-12

### Added
- Full documentation: README, API reference, tutorial, migration guide
- CHANGELOG.md and CONTRIBUTING.md

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
