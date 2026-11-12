///|
pub fn[T, U] map(p : Parser[T], f : (T) -> U) -> Parser[U] {
  Parser::of(fn(state) {
    match (p.run)(state) {
      Success(value, st) => Success(f(value), st)
      Failure(err) => Failure(err)
    }
  })
}

///|
pub fn[T, U] bind(p : Parser[T], f : (T) -> Parser[U]) -> Parser[U] {
  Parser::of(fn(state) {
    match (p.run)(state) {
      Success(value, st) => {
        let next = f(value)
        match (next.run)(st) {
          Success(result, st2) => Success(result, st2)
          Failure(err) =>
            Failure({
              pos: err.pos,
              expected: err.expected,
              committed: true,
              context: err.context,
            })
        }
      }
      Failure(err) => Failure(err)
    }
  })
}

///|
pub fn[T] pure(value : T) -> Parser[T] {
  Parser::of(fn(state) { Success(value, state) })
}

///|
pub fn[T] return_(value : T) -> Parser[T] {
  pure(value)
}

///|
pub fn[A, B] seq2(p1 : Parser[A], p2 : Parser[B]) -> Parser[(A, B)] {
  Parser::of(fn(state) {
    match (p1.run)(state) {
      Failure(err) => Failure(err)
      Success(a, st1) =>
        match (p2.run)(st1) {
          Failure(err) =>
            Failure({
              pos: err.pos,
              expected: err.expected,
              committed: true,
              context: err.context,
            })
          Success(b, st2) => Success((a, b), st2)
        }
    }
  })
}

///|
pub fn[A, B, C] seq3(
  p1 : Parser[A],
  p2 : Parser[B],
  p3 : Parser[C],
) -> Parser[(A, B, C)] {
  Parser::of(fn(state) {
    match (p1.run)(state) {
      Failure(err) => Failure(err)
      Success(a, st1) =>
        match (p2.run)(st1) {
          Failure(err) =>
            Failure({
              pos: err.pos,
              expected: err.expected,
              committed: true,
              context: err.context,
            })
          Success(b, st2) =>
            match (p3.run)(st2) {
              Failure(err) =>
                Failure({
                  pos: err.pos,
                  expected: err.expected,
                  committed: true,
                  context: err.context,
                })
              Success(c, st3) => Success((a, b, c), st3)
            }
        }
    }
  })
}

///|
pub fn[A, B, C, D] seq4(
  p1 : Parser[A],
  p2 : Parser[B],
  p3 : Parser[C],
  p4 : Parser[D],
) -> Parser[(A, B, C, D)] {
  Parser::of(fn(state) {
    match (p1.run)(state) {
      Failure(err) => Failure(err)
      Success(a, st1) =>
        match (p2.run)(st1) {
          Failure(err) =>
            Failure({
              pos: err.pos,
              expected: err.expected,
              committed: true,
              context: err.context,
            })
          Success(b, st2) =>
            match (p3.run)(st2) {
              Failure(err) =>
                Failure({
                  pos: err.pos,
                  expected: err.expected,
                  committed: true,
                  context: err.context,
                })
              Success(c, st3) =>
                match (p4.run)(st3) {
                  Failure(err) =>
                    Failure({
                      pos: err.pos,
                      expected: err.expected,
                      committed: true,
                      context: err.context,
                    })
                  Success(d, st4) => Success((a, b, c, d), st4)
                }
            }
        }
    }
  })
}
