///|
/// 辅助函数：浮点数近似相等比较
/// Helper: approximate equality for floating-point comparison
fn approx_eq(actual : Double, expected : Double) -> Bool {
  (actual - expected).abs() < 0.0001
}

///|
/// 测试 JSON null 解析
/// Test JSON null parsing
test "json_null" {
  let state = @core.State::new("null")
  match (null_().run)(state) {
    @core.Success(JNull, _) => assert_true(true)
    _ => assert_true(false, msg="expected JNull")
  }
}

///|
/// 测试 JSON true 布尔值解析
/// Test JSON true boolean parsing
test "json_bool_true" {
  let state = @core.State::new("true")
  match (bool_().run)(state) {
    @core.Success(JBool(true), _) => assert_true(true)
    _ => assert_true(false, msg="expected JBool(true)")
  }
}

///|
/// 测试 JSON false 布尔值解析
/// Test JSON false boolean parsing
test "json_bool_false" {
  let state = @core.State::new("false")
  match (bool_().run)(state) {
    @core.Success(JBool(false), _) => assert_true(true)
    _ => assert_true(false, msg="expected JBool(false)")
  }
}

///|
/// 测试 JSON 整数解析
/// Test JSON integer parsing
test "json_number_integer" {
  let state = @core.State::new("42")
  match (number().run)(state) {
    @core.Success(JNum(d), _) => assert_true(approx_eq(d, 42.0))
    _ => assert_true(false, msg="expected JNum(42)")
  }
}

///|
/// 测试 JSON 负数解析
/// Test JSON negative number parsing
test "json_number_negative" {
  let state = @core.State::new("-3")
  match (number().run)(state) {
    @core.Success(JNum(d), _) => assert_true(approx_eq(d, -3.0))
    _ => assert_true(false, msg="expected JNum(-3)")
  }
}

///|
/// 测试 JSON 浮点数解析
/// Test JSON floating-point number parsing
test "json_number_float" {
  let state = @core.State::new("3.14")
  match (number().run)(state) {
    @core.Success(JNum(d), _) => assert_true(approx_eq(d, 3.14))
    _ => assert_true(false, msg="expected JNum(3.14)")
  }
}

///|
/// 测试 JSON 科学计数法解析
/// Test JSON exponent notation parsing
test "json_number_exponent" {
  let state = @core.State::new("1e2")
  match (number().run)(state) {
    @core.Success(JNum(d), _) => assert_true(approx_eq(d, 100.0))
    _ => assert_true(false, msg="expected JNum(100)")
  }
}

///|
/// 测试 JSON 简单字符串解析
/// Test JSON simple string parsing
test "json_string_simple" {
  let state = @core.State::new("\"hello\"")
  match (string_().run)(state) {
    @core.Success(JStr(s), _) => assert_eq(s, "hello")
    _ => assert_true(false, msg="expected JStr(hello)")
  }
}

///|
/// 测试 JSON 转义字符解析（\\n）
/// Test JSON escape sequence parsing (\\n)
test "json_string_escape" {
  let state = @core.State::new("\"a\\nb\"")
  match (string_().run)(state) {
    @core.Success(JStr(s), _) => assert_eq(s, "a\nb")
    _ => assert_true(false, msg="expected JStr(a\\nb)")
  }
}

///|
/// 测试 JSON Unicode 转义解析（\\u0041 → 'A'）
/// Test JSON Unicode escape parsing (\\u0041 → 'A')
test "json_string_unicode_escape" {
  let state = @core.State::new("\"\\u0041\"")
  match (string_().run)(state) {
    @core.Success(JStr(s), _) => assert_eq(s, "A")
    _ => assert_true(false, msg="expected JStr(A)")
  }
}

///|
/// 测试 JSON 空数组解析
/// Test JSON empty array parsing
test "json_array_empty" {
  let state = @core.State::new("[]")
  match (array_().run)(state) {
    @core.Success(JArr(arr), _) => assert_eq(arr.length(), 0)
    _ => assert_true(false, msg="expected empty array")
  }
}

///|
/// 测试 JSON 含值数组解析
/// Test JSON array with values parsing
test "json_array_values" {
  let state = @core.State::new("[1, 2, 3]")
  match (array_().run)(state) {
    @core.Success(JArr(arr), _) => assert_eq(arr.length(), 3)
    _ => assert_true(false, msg="expected array of 3")
  }
}

///|
/// 测试 JSON 空对象解析
/// Test JSON empty object parsing
test "json_object_empty" {
  let state = @core.State::new("{}")
  match (object_().run)(state) {
    @core.Success(JObj(pairs), _) => assert_eq(pairs.length(), 0)
    _ => assert_true(false, msg="expected empty object")
  }
}

///|
/// 测试 JSON 含键值对对象解析
/// Test JSON object with key-value pairs parsing
test "json_object_pairs" {
  let state = @core.State::new("{\"a\":1,\"b\":2}")
  match (object_().run)(state) {
    @core.Success(JObj(pairs), _) => {
      assert_eq(pairs.length(), 2)
      assert_eq(pairs[0].0, "a")
      assert_eq(pairs[1].0, "b")
    }
    _ => assert_true(false, msg="expected object with 2 pairs")
  }
}

///|
/// 测试 JSON parse 完整解析带空白
/// Test JSON parse full parsing with whitespace
test "json_parse_full" {
  match parse("{\"name\":\"Alice\",\"age\":30}") {
    Ok(JObj(pairs)) => assert_eq(pairs.length(), 2)
    _ => assert_true(false, msg="expected parsed object")
  }
}

///|
/// 测试 JSON parse 嵌套结构
/// Test JSON parse nested structure
test "json_parse_nested" {
  match parse("{\"items\":[1,2,3]}") {
    Ok(JObj(pairs)) => {
      assert_eq(pairs.length(), 1)
      assert_eq(pairs[0].0, "items")
      match pairs[0].1 {
        JArr(arr) => assert_eq(arr.length(), 3)
        _ => assert_true(false, msg="expected nested array")
      }
    }
    _ => assert_true(false, msg="expected parsed nested object")
  }
}

///|
/// 测试 JSON parse 容忍前后空白
/// Test JSON parse tolerates leading/trailing whitespace
test "json_parse_whitespace" {
  match parse("  null  ") {
    Ok(JNull) => assert_true(true)
    _ => assert_true(false, msg="expected JNull with whitespace")
  }
}

///|
/// 测试 JSON parse 在非法输入时报错
/// Test JSON parse reports error on invalid input
test "json_parse_error" {
  match parse("{bad}") {
    Err(_) => assert_true(true)
    Ok(_) => assert_true(false, msg="expected parse error")
  }
}

///|
/// 测试 JSON stringify 往返一致性
/// Test JSON stringify round-trip consistency
test "json_stringify_roundtrip" {
  let v = JObj([("key", JNum(42.0)), ("arr", JArr([JBool(true), JNull]))])
  let s = v.stringify()
  match parse(s) {
    Ok(v2) => assert_true(v == v2)
    _ => assert_true(false, msg="roundtrip failed")
  }
}

///|
/// 测试 hex4_to_char 对有效输入的转换
/// Test hex4_to_char conversion for valid input
test "hex4_to_char_valid" {
  assert_eq(hex4_to_char("0041"), Some('A'))
  assert_eq(hex4_to_char("0030"), Some('0'))
  assert_eq(hex4_to_char("0020"), Some(' '))
}

///|
/// 测试 hex4_to_char 对无效输入返回 None
/// Test hex4_to_char returns None for invalid input
test "hex4_to_char_invalid" {
  assert_eq(hex4_to_char(""), None)
  assert_eq(hex4_to_char("GGGG"), None)
}
