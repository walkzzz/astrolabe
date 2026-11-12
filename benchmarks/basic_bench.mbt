/// ============================================================================
/// Basic combinator benchmarks
/// ============================================================================

///|
test (b : @bench.T) {
  let input100 = "a".repeat(100)
  let input1000 = "a".repeat(1000)
  b.bench(name="char_100", fn() {
    let p = @astro.many(@astro.char('a'))
    b.keep(result_arr_len(p.parse(input100)))
  })
  b.bench(name="char_1000", fn() {
    let p = @astro.many(@astro.char('a'))
    b.keep(result_arr_len(p.parse(input1000)))
  })
}

///|
test (b : @bench.T) {
  let input100 = "ab".repeat(50)
  let input1000 = "ab".repeat(500)
  b.bench(name="string_100", fn() {
    let p = @astro.many(@astro.string("ab"))
    b.keep(result_arr_len(p.parse(input100)))
  })
  b.bench(name="string_1000", fn() {
    let p = @astro.many(@astro.string("ab"))
    b.keep(result_arr_len(p.parse(input1000)))
  })
}

///|
test (b : @bench.T) {
  let input100 = "abcdefghij".repeat(10)
  let input1000 = "abcdefghij".repeat(100)
  b.bench(name="satisfy_100", fn() {
    let p = @astro.many(
      @astro.satisfy(fn(c) { c >= 'a' && c <= 'z' }, label="lower"),
    )
    b.keep(result_arr_len(p.parse(input100)))
  })
  b.bench(name="satisfy_1000", fn() {
    let p = @astro.many(
      @astro.satisfy(fn(c) { c >= 'a' && c <= 'z' }, label="lower"),
    )
    b.keep(result_arr_len(p.parse(input1000)))
  })
}

///|
test (b : @bench.T) {
  let input100 = "abcdefghij".repeat(10)
  let input1000 = "abcdefghij".repeat(100)
  b.bench(name="take_10_of_100", fn() {
    let p = @astro.take(10)
    b.keep(result_str_len(p.parse(input100)))
  })
  b.bench(name="take_100_of_1000", fn() {
    let p = @astro.take(100)
    b.keep(result_str_len(p.parse(input1000)))
  })
}

///|
test (b : @bench.T) {
  let input = "hello world"
  b.bench(name="end_of_input", fn() {
    let p = @astro.bind(@astro.string("hello world"), fn(_) {
      @astro.end_of_input()
    })
    b.keep(result_is_ok(@astro.parse_full(p, input)))
  })
}
