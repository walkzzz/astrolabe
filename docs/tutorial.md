# Tutorial: From Zero to JSON Parser

A step-by-step guide to building a JSON parser with Astrolabe. By the end, you'll understand the core combinators and how they compose.

## Prerequisites

```bash
moon add walkzzz/astrolabe
```

## 1. Your First Parser

The simplest parser matches a single character:

```moonbit
let a = @astrolabe.char('a')

inspect!(a.parse("abc"), content="Ok('a')")
inspect!(a.parse("bbc"), content="Err(ParseError)")
```

`parse` allows trailing input. Use `parse_full` to require the entire input is consumed:

```moonbit
inspect!(a.parse_full("abc"), content="Err(ParseError)")
inspect!(a.parse_full("a"), content="Ok('a')")
```

## 2. Combining Parsers with `map`

`map` transforms a parser's result:

```moonbit
let upper = @astrolabe.map(@astrolabe.char('a'), fn(c) { c.to_upper() })
inspect!(upper.parse("abc"), content="Ok('A')")
```

## 3. Sequencing with `bind`

`bind` chains parsers where the second depends on the first:

```moonbit
let two_chars = @astrolabe.bind(@astrolabe.char('a'), fn(a) {
  @astrolabe.bind(@astrolabe.char('b'), fn(b) {
    @astrolabe.pure([a, b])
  })
})
inspect!(two_chars.parse("abc"), content="Ok(['a', 'b'])")
```

For independent parsers, `seq2` is cleaner:

```moonbit
let pair = @astrolabe.seq2(@astrolabe.char('a'), @astrolabe.char('b'))
inspect!(pair.parse("abc"), content="Ok(('a', 'b'))")
```

## 4. Choice with `alt`

`alt` tries the first parser, backtracks on failure to try the second:

```moonbit
let letter = @astrolabe.alt(
  @astrolabe.char_range('a', 'z'),
  @astrolabe.char_range('A', 'Z'),
)
inspect!(letter.parse("H"), content="Ok('H')")
inspect!(letter.parse("z"), content="Ok('z')")
```

## 5. Repetition with `many` / `many1`

```moonbit
let digits = @astrolabe.many1(@astrolabe.char_range('0', '9'))
let result = digits.parse("123abc")
// Ok(['1', '2', '3'])

let digits_str = @astrolabe.map(digits, fn(arr) {
  arr.fold(fn(acc, c) { acc + c.to_string() }, init="")
})
inspect!(digits_str.parse("123abc"), content="Ok(\"123\")")
```

## 6. Separated Values with `sep_by1`

```moonbit
let csv = @astrolabe.sep_by1(@astrolabe.char_range('a', 'z'), @astrolabe.char(','))
let result = csv.parse("a,b,c")
// Ok(['a', 'b', 'c'])
```

## 7. Error Messages with `label`

```moonbit
let digit = @astrolabe.label(@astrolabe.char_range('0', '9'), "digit")
match digit.parse_full("x") {
  Err(e) => println(@astrolabe.format_error(e))
  // line 1, column 1 (offset 0):
  // expected digit
  _ => ()
}
```

## 8. Commitment: Preventing Exponential Backtracking

This is Astrolabe's key insight from Angstrom. Consider parsing a two-character prefix:

```moonbit
// BAD: alt backtracks, tries all combinations
let prefix = @astrolabe.alt(
  @astrolabe.string("ab"),
  @astrolabe.string("ac"),
)
// Input "ad" → tries "ab" (fails after 'a'), backtracks, tries "ac" (fails after 'a')
// With many alternatives, this is exponential!
```

With `commit`, once we've consumed 'a', we commit and don't backtrack:

```moonbit
// GOOD: commit prevents backtracking past consumed input
let prefix = @astrolabe.alt(
  @astrolabe.bind(@astrolabe.char('a'), fn(_) {
    @astrolabe.commit(@astrolabe.alt(
      @astrolabe.char('b'),
      @astrolabe.char('c'),
    ))
  }),
  // other alternatives that DON'T start with 'a'
)
```

**Rule of thumb**: Use `commit` after you've consumed enough input to know you're in the right branch. The `bind` combinator automatically commits when the second parser fails ("sequence commits").

## 9. Building a Mini JSON Parser

Now let's build a simplified JSON parser step by step.

### 9.1 Whitespace

```moonbit
fn ws() -> @astrolabe.Parser[Unit] {
  @astrolabe.skip(
    @astrolabe.many(
      @astrolabe.satisfy(fn(c) { c == ' ' || c == '\t' || c == '\n' || c == '\r' }, label="whitespace"),
    ),
  )
}
```

### 9.2 Null & Bool

```moonbit
let null_p = @astrolabe.map(@astrolabe.string("null"), fn(_) { "null" })

let bool_p = @astrolabe.alt(
  @astrolabe.map(@astrolabe.string("true"), fn(_) { true }),
  @astrolabe.map(@astrolabe.string("false"), fn(_) { false }),
)
```

### 9.3 Strings

```moonbit
let string_p : @astrolabe.Parser[String] = @astrolabe.Parser::of(fn(state) {
  match @astrolabe.char('"').parse(state.input) {
    Ok(_) => {
      // simplified: collect until closing quote
      let body = @astrolabe.many1(@astrolabe.satisfy(fn(c) { c != '"' }, label="string char"))
      @astrolabe.bind(body, fn(chars) {
        @astrolabe.map(@astrolabe.char('"'), fn(_) {
          chars.fold(fn(acc, c) { acc + c.to_string() }, init="")
        })
      })
      |> .parse(state.input)  // simplified for tutorial
    }
    Err(e) => Err(e)
  }
})
```

### 9.4 The Full Parser

The real implementation in `@astrolabe/json` handles all JSON types, escape sequences, and nested structures. Use it directly:

```moonbit
let result = @astrolabe/json.parse("{\"name\": \"Alice\"}")
match result {
  Ok(v) => println(v.stringify())
  Err(e) => println(@astrolabe.format_error_with_input(e, input))
}
```

## 10. Next Steps

- Read the [API Reference](./api.md) for the full combinator list
- Check `examples/` for URI, CSV, and arithmetic calculator examples
- Read the [Migration Guide](./migration.md) if coming from yacc or other parser tools
