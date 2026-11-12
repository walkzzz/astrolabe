/// ============================================================================
/// Control combinator benchmarks
/// ============================================================================

///|
test (b : @bench.T) {
  let pa = @astro.char('a')
  let pb = @astro.char('b')
  let input_b = "b".repeat(100)
  b.bench(name="alt_first_fail", fn() {
    let p = @astro.many(@astro.alt(pa, pb))
    b.keep(result_arr_len(p.parse(input_b)))
  })
}

///|
test (b : @bench.T) {
  let pa = @astro.char('a')
  let pb = @astro.char('b')
  let input_a = "a".repeat(100)
  b.bench(name="alt_first_match", fn() {
    let p = @astro.many(@astro.alt(pa, pb))
    b.keep(result_arr_len(p.parse(input_a)))
  })
}

///|
test (b : @bench.T) {
  let letters : Array[@core.Parser[Char]] = []
  for c in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'] {
    letters.push(@astro.char(c))
  }
  let input = "h".repeat(100)
  b.bench(name="choice_last_of_8", fn() {
    let p = @astro.many(@astro.choice(letters))
    b.keep(result_arr_len(p.parse(input)))
  })
}

///|
test (b : @bench.T) {
  let digit = @astro.satisfy(fn(c) { c >= '0' && c <= '9' }, label="digit")
  let letter = @astro.satisfy(fn(c) { c >= 'a' && c <= 'z' }, label="letter")
  let input = "a1b2c3d4e5".repeat(20)
  b.bench(name="alt_nocommit", fn() {
    let p = @astro.many(@astro.alt(digit, letter))
    b.keep(result_arr_len(p.parse(input)))
  })
  b.bench(name="alt_with_commit", fn() {
    let p = @astro.many(@astro.alt(@astro.commit(digit), letter))
    b.keep(result_arr_len(p.parse(input)))
  })
}

///|
test (b : @bench.T) {
  let digit = @astro.satisfy(fn(c) { c >= '0' && c <= '9' }, label="digit")
  let labeled = @astro.label(digit, "decimal digit")
  let input = "1234567890".repeat(10)
  b.bench(name="label_no_label", fn() {
    let p = @astro.many(digit)
    b.keep(result_arr_len(p.parse(input)))
  })
  b.bench(name="label_with_label", fn() {
    let p = @astro.many(labeled)
    b.keep(result_arr_len(p.parse(input)))
  })
}
