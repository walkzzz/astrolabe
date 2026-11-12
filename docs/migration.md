# Migration Guide

Coming from other parsing approaches? This guide maps familiar concepts to Astrolabe's API.

## From yacc / parser generators

| Concept | yacc | Astrolabe |
|---------|------|-----------|
| Grammar rules | `%token`, `%%` rules | `Parser[T]` values + combinators |
| Terminal | `%token NUMBER` | `satisfy(fn(c) { c >= '0' && c <= '9' }, label="digit")` |
| Non-terminal | `expr : term '+' expr` | `bind(term(), fn(l) { bind(char('+'), fn(_) { map(expr(), fn(r) { add(l, r) }) }) })` |
| Alternatives | `expr : term \| paren` | `alt(term(), paren())` |
| Repetition | `list : item list \| empty` | `many(item())` or `sep_by(item(), char(','))` |
| Left recursion | `expr : expr '+' term` | **Must refactor** — use accumulator pattern or iterative loop |
| Error messages | `%expect`, `yyerror` | `label(p, "expected X")` |
| Commitment | N/A (LALR doesn't backtrack) | `commit(p)` — mirrors LALR's no-backtrack behavior |

### Key Difference: No Left Recursion

Parser combinators are top-down recursive descent. Left-recursive grammars cause infinite loops. Refactor using `many`/`sep_by` or an accumulator:

```moonbit
// WRONG: left-recursive
// expr = expr '+' term

// RIGHT: left-associative via many
let expr : @astrolabe.Parser[Int32] = @astrolabe.bind(term(), fn(first) {
  @astrolabe.map(
    @astrolabe.many(@astrolabe.bind(@astrolabe.char('+'), fn(_) { term() })),
    fn(rest) { rest.fold(fn(acc, t) { acc + t }, init=first) },
  )
})
```

### Key Difference: Explicit Backtracking Control

yacc-style generators don't backtrack — once a rule is chosen, it commits. In Astrolabe, `alt` backtracks by default. Use `commit` to get yacc-like behavior:

```moonbit
// Like yacc: once we see "if", we commit to the if-branch
let stmt = @astrolabe.alt(
  @astrolabe.bind(@astrolabe.string("if"), fn(_) {
    @astrolabe.commit(if_stmt())
  }),
  while_stmt(),
)
```

---

## From regex

| Concept | Regex | Astrolabe |
|---------|-------|-----------|
| Literal | `"hello"` | `string("hello")` |
| Character class | `[a-z]` | `char_range('a', 'z')` |
| Negated class | `[^0-9]` | `satisfy(fn(c) { c < '0' || c > '9' })` |
| Alternation | `a\|b` | `alt(char('a'), char('b'))` |
| Repetition | `a*` / `a+` | `many(char('a'))` / `many1(char('a'))` |
| Optional | `a?` | `alt(char('a'), pure(Unit))` |
| Group + capture | `(ab)+` | `many1(seq2(char('a'), char('b')))` |
| Anchor | `^` / `$` | `end_of_input()` for `$` |

### Key Difference: Structured Output

Regex returns strings; Astrolabe returns typed data:

```moonbit
// Regex: capture groups, string parsing
// Astrolabe: typed parse tree
let hex_color = @astrolabe.bind(@astrolabe.char('#'), fn(_) {
  @astrolabe.map(@astrolabe.count(6, char_range('0', '9')), fn(digits) {
    // digits is Array[Char] — typed, not a string to re-parse
    digits
  })
})
```

---

## From Rust nom

| Concept | nom | Astrolabe |
|---------|-----|-----------|
| Byte parser | `tag("hello")` | `string("hello")` |
| Character | `char('a')` | `char('a')` |
| Take | `take(3usize)` | `take(3)` |
| Predicate | `take_while1(\|c\| c.is_ascii_digit())` | `satisfy(fn(c) { c >= '0' && c <= '9' })` |
| Map | `map(parser, f)` | `map(parser, f)` |
| AndThen | `and_then(parser, f)` | `bind(parser, f)` |
| Alt | `alt((p1, p2, p3))` | `choice([p1, p2, p3])` |
| Many0 / Many1 | `many0(p)` / `many1(p)` | `many(p)` / `many1(p)` |
| Separated | `separated_list1(sep, p)` | `sep_by1(p, sep)` |
| Verify | `verify(parser, pred)` | `bind(parser, fn(v) { if pred(v) { pure(v) } else { fail } })` |
| Error context | `context("msg", parser)` | `label(parser, "msg")` |
| Cut (commit) | `cut(parser)` | `commit(parser)` |

### Key Difference: Position Tracking

nom tracks byte offsets but not line/column by default. Astrolabe tracks all three automatically:

```moonbit
// nom: manual line tracking or external crate
// Astrolabe: built-in
match parser.parse_full(input) {
  Err(e) => println("Error at line \{e.pos.line}, column \{e.pos.column}")
  Ok(v) => ...
}
```

---

## From OCaml Angstrom

Astrolabe is directly inspired by Angstrom. The API maps almost 1:1:

| Angstrom | Astrolabe | Notes |
|----------|-----------|-------|
| `char 'a'` | `char('a')` | Same |
| `string "hello"` | `string("hello")` | Same |
| `any_char` | `any_char()` | Same |
| `take n` | `take(n)` | Same |
| `satisfy f` | `satisfy(f, label~="satisfy")` | Optional label param |
| `end_of_input` | `end_of_input()` | Same |
| `peek p` | `peek(p)` | Same |
| `skip p` | `skip(p)` | Same |
| `map f p` | `map(p, f)` | Arg order reversed |
| `bind p f` | `bind(p, f)` | Arg order reversed |
| `pure v` | `pure(v)` | Same |
| `return v` | `return_(v)` | Trailing underscore (keyword) |
| `( <* ) p1 p2` | `seq2(p1, p2)` + map | No `<*` / `<*>` / `*>` |
| `( *> ) p1 p2` | `bind(p1, fn(_) { p2 })` | Use bind + discard |
| `( <*> ) p1 p2` | `seq2(p1, p2)` | Tuple result |
| `many p` | `many(p)` | Same |
| `many1 p` | `many1(p)` | Same |
| `sep_by p sep` | `sep_by(p, sep)` | Arg order reversed |
| `sep_by1 p sep` | `sep_by1(p, sep)` | Arg order reversed |
| `count n p` | `count(n, p)` | Same |
| `many_till p end` | `many_till(p, end_)` | Trailing underscore |
| `commit p` | `commit(p)` | Same |
| `alt p1 p2` | `alt(p1, p2)` | Same |
| `choice ps` | `choice(ps)` | Same |
| `label p name` | `label(p, name)` | Same |
| `parse_string p input` | `Parser::parse(p, input)` | Method call |
| `parse ~consume:ConsumeAll p input` | `Parser::parse_full(p, input)` | Separate method |

### Key Differences

1. **No applicative operators**: MoonBit doesn't have `<*>` / `<*` / `*>`. Use `seq2`/`seq3`/`seq4` or `bind`.
2. **No `fix` combinator**: MoonBit doesn't support lazy evaluation natively. Use top-level recursive functions or `Parser::of` with explicit recursion.
3. **`return_` not `return`**: `return` is a keyword in MoonBit; use `return_`.
4. **`many_till` doesn't consume `end_`**: The end marker is matched but the cursor is restored. In Angstrom, `end_` is consumed.
5. **Facade pattern**: All public API is accessed through `@astrolabe.xxx`, not individual subpackage imports.
