# Changelog

All notable changes to this project will be documented in this file.

## [0.5.1] - 2026-11-13

### Added
- `ParseError` implements `Show`（delegates to `format()`）— `inspect` snapshots, `"\{err}"` interpolation and `println` work out of the box
- `docs/pitfall-catalog.md` — 15 measured pitfalls（M 系列 MoonBit 语法演进 9 条 + S 系列解析器语义 6 条，含序列承诺传染 / label 抹掉 alt 多候选 / furthest 位置 / facade 显式列表）
- `docs/assessment.md` 验收记分卡 — 14 检查点逐条 evidence（三口径：没跑过≠通过 / 分母不猜 / 第三方可复算）
- `scripts/check_docs.mjs` — 文档数字一致性自检（4 正向断言 + 5 负向自测全绿；**首跑即检出 badge 190≠196 真实漂移**）

### Changed
- README 快速开始现代化：6 处弃用的 `inspect!` 语法 → `match/println` 风格（同时展示 `e.format()` 错误报告）；`Ok('a')` 快照断言按实测修正为 `Ok(a)`
- README 文档表补全 proposal / assessment / comparison / performance_report / pitfall-catalog（中英双语）
- AGENTS.md 元数据更新（196×4 / mooncakes 0.5.0 已发布）

## [0.5.0] - 2026-11-13

### Added
- `ParserLike` extension-point combinator set (`core/parser_like.mbt`): `pmap` / `pbind` / `palt` / `poption` work over any `(State) -> ParseResult[A]` run-function, so third-party parser types plug into astrolabe combinators by exposing a `run_fn` method; `Parser::run_fn` provided as the standard entry
- Worked extension example `examples/ext` — `Traced[T]`, a logging wrapper parser, with 5 white-box tests demonstrating pmap/pbind/palt/poption integration (190 total × 4 backends)
- Design note: MoonBit traits do not support parameterization separating the implementing type from the result type (`trait ParserLike[A]` is rejected by the parser); the extension point therefore uses the functional convention — the same extension point as `Parser::of`

## [0.4.0] - 2026-11-13

### Added
- `ParseError::merge` — error aggregation with furthest-position-wins semantics; equal positions merge expected labels (deduplicated, order-preserving) and OR the committed flags
- `alt`/`choice` error aggregation — when all branches fail, users see multi-candidate messages ("expected 'a' or 'b'") instead of only the last branch's error
- 7 new tests covering aggregation behavior and alt/choice regression guards (185 total × 4 backends)
- GitHub Actions CI (`.github/workflows/ci.yml`) — `moon check --deny-warn --target all` + `moon test --target all` + `moon bench --target native` gates
- Project proposal `docs/proposal.md` and engineering assessment `docs/assessment.md` (measured data + competitor analysis)

### Changed
- README fully aligned with the actual package layout (core/char/sequence/branch + examples/*), test count updated to 185 × 4 backends, version badge unified
- Formal-verification table and `docs/formal-spec.md` corrected to match `proof/proof.mbt` exactly (EOF correctness replaces the unproven map-flag property)
- Roadmap progress snapshot and vNext competitive roadmap added; benchmark table annotated as historical sample data

## [0.2.0] - 2026-11-13

### Added
- Formal verification package `proof/` — 7 proof functions via MoonBit proof conditions (SMT-backed): commit flag, alt backtrack semantics (P2a/P2b), sequence commit, offset/remaining invariants, EOF correctness
- Benchmark suite `benchmarks/` — 25 benchmarks across basic/compose/control/json/http (`moon bench --target native`)
- Five example packages under `examples/` — uri, json, http, csv_header, calc, with white-box tests
- CLI demo `cmd/main` — interactive showcase for JSON/URI/HTTP parsers

## [0.1.18] - 2026-11-13

### Changed
- README.md 全面重构：emoji 装饰、双语中/英默认中文可切换、`<details>` 折叠、徽章 `flat-square` 风格
- Tutorial (`docs/tutorial.md`) 双语化：中文在前，English 在后
- 8 个新组合子的文档注释修正为标准双语格式（中文段 → `///|` → 英文段）
- README 版本徽章更新至 0.1.17、测试数更新至 147

## [0.1.17] - 2026-11-13

### Added
- `take_while(pred)` — consume consecutive chars matching predicate, return String (always succeeds)
- `take_while1(pred, label~)` — same but requires at least one match
- `option(p, default)` — try `p`, return `default` on uncommitted failure
- `skip_many(p)` / `skip_many1(p)` — repeat `p` discarding results
- `between(open, p, close)` — match `open` + `p` + `close`, return only `p`'s result
- `not_followed_by(p, label~)` — succeed when `p` fails, without consuming input
- `fix(f)` — fixpoint combinator for recursive grammars
- All 8 new combinators exported via root package facade
- 25 new tests across basic/compose/control packages (147 total, up from 122)

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
