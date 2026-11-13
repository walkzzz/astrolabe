///| 可扩展的解析提示 — 为解析器附加语义标注。

///| 用户可通过 `extenum ParseHint += { ... }` 添加自定义变体。

///|

///| Extensible parse hint — attach semantic annotations to parsers.

///|
/// Users can add custom variants via `extenum ParseHint += { ... }`.
pub extenum ParseHint

///| 库内建的解析提示变体。

///|

///|
/// Built-in parse hint variants.
pub extenum ParseHint += {
  /// 解析器可能消耗大量输入。
  ///|
  ///| The parser may consume a large amount of input.
  Heavy
  /// 解析器仅消耗少量输入或零消耗。
  ///|
  ///| The parser consumes little or no input.
  Light
  /// 解析器用于错误恢复，不应影响主解析路径。
  ///|
  ///| The parser is for error recovery and should not affect the main parse path.
  Recovery
}

///| 便捷工厂：`Heavy` 提示。

///|

///|
/// Convenience factory: `Heavy` hint.
pub fn ParseHint::heavy() -> ParseHint noraise {
  Heavy
}

///| 便捷工厂：`Light` 提示。

///|

///|
/// Convenience factory: `Light` hint.
pub fn ParseHint::light() -> ParseHint noraise {
  Light
}

///| 便捷工厂：`Recovery` 提示。

///|

///|
/// Convenience factory: `Recovery` hint.
pub fn ParseHint::recovery() -> ParseHint noraise {
  Recovery
}
