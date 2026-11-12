/// ============================================================================
/// JSON parser benchmarks
/// ============================================================================

///|
fn bench_json_parse(input : String) -> Int32 {
  match @json.parse(input) {
    Ok(v) => v.stringify().length()
    Err(_) => -1
  }
}

///|
fn make_json_object(n : Int32) -> String {
  let parts : Array[String] = []
  for i in 0..<n {
    parts.push("\"key\{i}\": \{i}")
  }
  "{\{parts.join(", ")}}"
}

///|
fn make_json_array(n : Int32) -> String {
  let items : Array[String] = []
  for i in 0..<n {
    items.push(i.to_string())
  }
  "[\{items.join(", ")}]"
}

///|
fn make_json_nested(depth : Int32) -> String {
  if depth <= 0 {
    "42"
  } else {
    "{\"v\": \{make_json_nested(depth - 1)}}"
  }
}

///|
test (b : @bench.T) {
  b.bench(name="json_null", fn() { b.keep(bench_json_parse("null")) })
  b.bench(name="json_bool", fn() { b.keep(bench_json_parse("true")) })
  b.bench(name="json_number", fn() { b.keep(bench_json_parse("3.14159")) })
  b.bench(name="json_string", fn() {
    b.keep(bench_json_parse("\"hello world\""))
  })
}

///|
test (b : @bench.T) {
  let obj10 = make_json_object(10)
  let obj50 = make_json_object(50)
  let obj100 = make_json_object(100)
  b.bench(name="json_object_10", fn() { b.keep(bench_json_parse(obj10)) })
  b.bench(name="json_object_50", fn() { b.keep(bench_json_parse(obj50)) })
  b.bench(name="json_object_100", fn() { b.keep(bench_json_parse(obj100)) })
}

///|
test (b : @bench.T) {
  let arr10 = make_json_array(10)
  let arr100 = make_json_array(100)
  let arr1000 = make_json_array(1000)
  b.bench(name="json_array_10", fn() { b.keep(bench_json_parse(arr10)) })
  b.bench(name="json_array_100", fn() { b.keep(bench_json_parse(arr100)) })
  b.bench(name="json_array_1000", fn() { b.keep(bench_json_parse(arr1000)) })
}

///|
test (b : @bench.T) {
  let nested5 = make_json_nested(5)
  let nested10 = make_json_nested(10)
  b.bench(name="json_nested_5", fn() { b.keep(bench_json_parse(nested5)) })
  b.bench(name="json_nested_10", fn() { b.keep(bench_json_parse(nested10)) })
}

///|
test (b : @bench.T) {
  let mixed = "{\"name\": \"Alice\", \"age\": 30, \"scores\": [95, 87, 92], \"active\": true, \"address\": {\"city\": \"Beijing\", \"zip\": \"100000\"}}"
  b.bench(name="json_mixed", fn() { b.keep(bench_json_parse(mixed)) })
}
