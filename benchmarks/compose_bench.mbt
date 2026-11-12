/// ============================================================================
/// Composition combinator benchmarks
/// ============================================================================

///|
test (b : @bench.T) {
  let digit = @astro.satisfy(fn(c) { c >= '0' && c <= '9' }, label="digit")
  let input100 = "1234567890".repeat(10)
  let input1000 = "1234567890".repeat(100)
  b.bench(name="map_100", fn() {
    let p = @astro.many(@astro.map(digit, fn(c) { c.to_int() }))
    b.keep(result_arr_len(p.parse(input100)))
  })
  b.bench(name="map_1000", fn() {
    let p = @astro.many(@astro.map(digit, fn(c) { c.to_int() }))
    b.keep(result_arr_len(p.parse(input1000)))
  })
}

///|
test (b : @bench.T) {
  let digit = @astro.satisfy(fn(c) { c >= '0' && c <= '9' }, label="digit")
  let input100 = "1234567890".repeat(10)
  let input1000 = "1234567890".repeat(100)
  b.bench(name="bind_100", fn() {
    let p = @astro.many(@astro.bind(digit, fn(c) { @astro.pure(c.to_int()) }))
    b.keep(result_arr_len(p.parse(input100)))
  })
  b.bench(name="bind_1000", fn() {
    let p = @astro.many(@astro.bind(digit, fn(c) { @astro.pure(c.to_int()) }))
    b.keep(result_arr_len(p.parse(input1000)))
  })
}

///|
test (b : @bench.T) {
  let ab = @astro.seq2(@astro.char('a'), @astro.char('b'))
  let input100 = "ab".repeat(50)
  let input1000 = "ab".repeat(500)
  b.bench(name="seq2_100", fn() {
    let p = @astro.many(@astro.map(ab, fn(_) { 0 }))
    b.keep(result_arr_len(p.parse(input100)))
  })
  b.bench(name="seq2_1000", fn() {
    let p = @astro.many(@astro.map(ab, fn(_) { 0 }))
    b.keep(result_arr_len(p.parse(input1000)))
  })
}

///|
test (b : @bench.T) {
  let letter = @astro.satisfy(fn(c) { c >= 'a' && c <= 'z' }, label="letter")
  let input100 = "abc".repeat(34)
  let input1000 = "abc".repeat(334)
  b.bench(name="many_100", fn() {
    let p = @astro.many(letter)
    b.keep(result_arr_len(p.parse(input100)))
  })
  b.bench(name="many_1000", fn() {
    let p = @astro.many(letter)
    b.keep(result_arr_len(p.parse(input1000)))
  })
}

///|
test (b : @bench.T) {
  let letter = @astro.satisfy(fn(c) { c >= 'a' && c <= 'z' }, label="letter")
  let input100 = "abc".repeat(34)
  let input1000 = "abc".repeat(334)
  b.bench(name="many1_100", fn() {
    let p = @astro.many1(letter)
    b.keep(result_arr_len(p.parse(input100)))
  })
  b.bench(name="many1_1000", fn() {
    let p = @astro.many1(letter)
    b.keep(result_arr_len(p.parse(input1000)))
  })
}

///|
test (b : @bench.T) {
  let digit = @astro.satisfy(fn(c) { c >= '0' && c <= '9' }, label="digit")
  let comma = @astro.char(',')
  let input100 = "1,2,3,4,5,6,7,8,9,0".repeat(5)
  let input1000 = "1,2,3,4,5,6,7,8,9,0".repeat(50)
  b.bench(name="sep_by1_100", fn() {
    let p = @astro.sep_by1(digit, comma)
    b.keep(result_arr_len(p.parse(input100)))
  })
  b.bench(name="sep_by1_1000", fn() {
    let p = @astro.sep_by1(digit, comma)
    b.keep(result_arr_len(p.parse(input1000)))
  })
}

///|
test (b : @bench.T) {
  let letter = @astro.satisfy(fn(c) { c >= 'a' && c <= 'z' }, label="letter")
  let input100 = "a".repeat(100)
  let input1000 = "a".repeat(1000)
  b.bench(name="count_50_of_100", fn() {
    let p = @astro.count(50, letter)
    b.keep(result_arr_len(p.parse(input100)))
  })
  b.bench(name="count_500_of_1000", fn() {
    let p = @astro.count(500, letter)
    b.keep(result_arr_len(p.parse(input1000)))
  })
}
