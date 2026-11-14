/// ============================================================================
/// stdlib JSON（moonbitlang/core/json）对照基准 — 同 workload 对比 astrolabe JSON
/// ============================================================================

///| stdlib JSON 解析并序列化，返回长度（失败返回 -1）。
///|
///| Parse with moonbitlang/core/json and stringify, returning the length
///| (or -1 on failure) — mirrors bench_json_parse for a fair comparison.
fn stdjson_parse_count(input : String) -> Int32 {
  try {
    @stdjson.parse(input).stringify().length()
  } catch {
    _ => -1
  }
}

///|
test (b : @bench.T) {
  let obj50 = make_json_object(50)
  let obj100 = make_json_object(100)
  let arr100 = make_json_array(100)
  let nested10 = make_json_nested(10)
  b.bench(name="stdlib_json_object_50", fn() {
    b.keep(stdjson_parse_count(obj50))
  })
  b.bench(name="stdlib_json_object_100", fn() {
    b.keep(stdjson_parse_count(obj100))
  })
  b.bench(name="stdlib_json_array_100", fn() {
    b.keep(stdjson_parse_count(arr100))
  })
  b.bench(name="stdlib_json_nested_10", fn() {
    b.keep(stdjson_parse_count(nested10))
  })
}
