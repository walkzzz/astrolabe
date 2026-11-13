///| ParserLike — 解析器扩展点的通用组合子集。

///| MoonBit 中 `Parser[T]` 本质是 `(State) -> ParseResult[T]` 的函数包装，

///| 因此"任何能给出该函数的自定义类型"都可以直接接入 astrolabe 组合子：

///|

///| - 直接传裸运行函数：`@astrolabe.pmap(my_run_fn, f)`

///|   （`my_run_fn : (State) -> ParseResult[A]`）

///| - 包装类型暴露 `run_fn(self)` 方法后同理（见 `examples/ext` 的 `Traced[T]`）

///|

///| 典型扩展场景：带调用日志/计数的包装解析器、缓存/memoized 解析器、

///| 与其他解析库的适配层。

///|

///| 设计说明：MoonBit 的 trait 不支持"实现类型与结果类型分离"的参数化

///| （`trait ParserLike[A]` 不合法），因此本扩展点采用函数式约定 —

///| 这也是 MoonBit 惯用的扩展方式（`Parser::of` 即同一扩展点）。

///|

///| The ParserLike extension-point combinator set. In MoonBit, `Parser[T]` is

///| a wrapper over `(State) -> ParseResult[T]`, so any custom type that can

///| expose such a function plugs into astrolabe combinators directly: pass a

///| bare run-function to `pmap`/`pbind`/`palt`/`poption`, or expose a

///| `run_fn(self)` method on your wrapper type (see `Traced[T]` in

///| `examples/ext`). Typical scenarios: logging/counting wrappers, memoized

///| parsers, adapters for other parser libraries. Design note: MoonBit traits

///| do not support parameterization separating the implementing type from the

///| result type, so this extension point uses the functional convention —

///| the same extension point as `Parser::of`.

///| 获取 `Parser` 的运行函数 — ParserLike 扩展点的标准入口。

///|

///| Extract the run-function from a `Parser` — the standard entry to the

///| ParserLike extension point.

pub fn[T] Parser::run_fn(self : Parser[T]) -> (State) -> ParseResult[T] noraise {
  self.run
}

///| 对任意 `ParserLike` 运行函数应用变换 — 通用组合子扩展点。

///| 返回具体 `Parser[B]`；失败语义与 `map` 一致（原样传递）。

///|

///| Apply a transform to any ParserLike run-function — generic combinator

///| extension. Returns a concrete `Parser[B]`; failure semantics match `map`.

pub fn[A, B] pmap(
  run : (State) -> ParseResult[A],
  f : (A) -> B,
) -> Parser[B] noraise {
  Parser::of(fn(state) {
    match run(state) {
      Success(value, st) => Success(f(value), st)
      Failure(err) => Failure(err)
    }
  })
}

///| 对任意 `ParserLike` 运行函数做单调绑定 — 第二个解析器依赖第一个的结果。

///| 序列承诺语义与 `bind` 一致：第一解析器成功后，第二解析器的失败被承诺。

///|

///| Monadic bind over any ParserLike run-function — the second parser

///| depends on the first's result. Sequence-commit semantics match `bind`:

///| after the first parser succeeds, failures from the continuation are

///| committed.

pub fn[A, B] pbind(
  run : (State) -> ParseResult[A],
  f : (A) -> Parser[B],
) -> Parser[B] noraise {
  Parser::of(fn(state) {
    match run(state) {
      Failure(err) => Failure(err)
      Success(value, st) =>
        match (f(value).run)(st) {
          Success(v2, st2) => Success(v2, st2)
          Failure(err2) => Failure(err2.commit())
        }
    }
  })
}

///| 对任意两个 `ParserLike` 运行函数做有序选择 — 未承诺失败时回溯，

///| 两分支都失败时通过 `ParseError::merge` 聚合错误（与 `alt` 一致）。

///|

///| Ordered choice over any two ParserLike run-functions — backtracks on

///| uncommitted failure and aggregates errors via `ParseError::merge` when

///| both branches fail (same semantics as `alt`).

pub fn[A] palt(
  run1 : (State) -> ParseResult[A],
  run2 : (State) -> ParseResult[A],
) -> Parser[A] noraise {
  Parser::of(fn(state) {
    match run1(state) {
      Success(value, st) => Success(value, st)
      Failure(err) =>
        if err.committed() {
          Failure(err)
        } else {
          match run2(state) {
            Success(value, st) => Success(value, st)
            Failure(err2) => Failure(err.merge(err2))
          }
        }
    }
  })
}

///| 对任意 `ParserLike` 运行函数在未承诺失败时回退到 `default`。

///| 承诺失败仍然传播（与 `option` 语义一致）。

///|

///| Fall back to `default` when any ParserLike run-function fails

///| uncommitted. Committed failures still propagate (same semantics as

///| `option`).

pub fn[A] poption(
  run : (State) -> ParseResult[A],
  default : A,
) -> Parser[A] noraise {
  Parser::of(fn(state) {
    match run(state) {
      Success(value, st) => Success(value, st)
      Failure(err) =>
        if err.committed() {
          Failure(err)
        } else {
          Success(default, state)
        }
    }
  })
}
