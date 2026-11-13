///| Traced[T] — 带调用日志的 ParserLike 扩展示例。

///| 演示第三方类型如何通过暴露 `run_fn` 方法接入

///| astrolabe 的通用组合子（`pmap`/`pbind`/`palt`/`poption`）：

///| 每次运行前在 `log` 中记录当前位置，可用于调试、统计或缓存。

///|

///| `Traced[T]` — a ParserLike extension example with invocation logging.

///| Shows how a third-party type plugs into astrolabe's generic combinators

///| (`pmap`/`pbind`/`palt`/`poption`) by exposing a `run_fn` method:

///| every run records the current position in `log`, useful for debugging,

///| statistics, or caching.
pub(all) struct Traced[T] {
  inner : @core.Parser[T]
  mut log : Array[String]
}

///| 创建一个带空日志的 `Traced` 包装。

///|

///| Create a `Traced` wrapper with an empty log.
pub fn[T] Traced::new(inner : @core.Parser[T]) -> Traced[T] noraise {
  { inner, log: [], }
}

///| 读取调用日志（每次运行追加一条）。

///|

///| Read the invocation log (one entry appended per run).
pub fn[T] Traced::entries(self : Traced[T]) -> Array[String] noraise {
  self.log
}

///| `Traced` 的 ParserLike 扩展点 — 返回记录日志的运行函数。

///| 该函数可直接传给 `@core.pmap` / `@core.pbind` / `@core.palt` / `@core.poption`。

///|

///| The ParserLike extension point for `Traced` — returns a logging run

///| function, directly usable with `@core.pmap` / `@core.pbind` /

///| `@core.palt` / `@core.poption`.
pub fn[T] Traced::run_fn(
  self : Traced[T],
) -> (@core.State) -> @core.ParseResult[T] noraise {
  fn(state) {
    self.log.push("run at offset \{state.offset}")
    (self.inner.run)(state)
  }
}
