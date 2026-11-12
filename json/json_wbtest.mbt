///|
fn approx_eq(actual : Double, expected : Double) -> Bool {
  (actual - expected).abs() < 0.0001
}

///|
test "json_null" {
  let state = @core.State::new("null")
  match (null_().run)(state) {
    @core.Success(JNull, _) => assert_true(true)
    _ => assert_true(false, msg="expected JNull")
  }
}

///|
test "json_bool_true" {
  let state = @core.State::new("true")
  match (bool_().run)(state) {
    @core.Success(JBool(true), _) => assert_true(true)
    _ => assert_true(false, msg="expected JBool(true)")
  }
}

///|
test "json_bool_false" {
  let state = @core.State::new("false")
  match (bool_().run)(state) {
    @core.Success(JBool(false), _) => assert_true(true)
    _ => assert_true(false, msg="expected JBool(false)")
  }
}

///|
test "json_number_integer" {
  let state = @core.State::new("42")
  match (number().run)(state) {
    @core.Success(JNum(d), _) => assert_true(approx_eq(d, 42.0))
    _ => assert_true(false, msg="expected JNum(42)")
  }
}

///|
test "json_number_negative" {
  let state = @core.State::new("-3")
  match (number().run)(state) {
    @core.Success(JNum(d), _) => assert_true(approx_eq(d, -3.0))
    _ => assert_true(false, msg="expected JNum(-3)")
  }
}

///|
test "json_number_float" {
  let state = @core.State::new("3.14")
  match (number().run)(state) {
    @core.Success(JNum(d), _) => assert_true(approx_eq(d, 3.14))
    _ => assert_true(false, msg="expected JNum(3.14)")
  }
}

///|
test "json_number_exponent" {
  let state = @core.State::new("1e2")
  match (number().run)(state) {
    @core.Success(JNum(d), _) => assert_true(approx_eq(d, 100.0))
    _ => assert_true(false, msg="expected JNum(100)")
  }
}

///|
test "json_string_simple" {
  let state = @core.State::new("\"hello\"")
  match (string_().run)(state) {
    @core.Success(JStr(s), _) => assert_eq(s, "hello")
    _ => assert_true(false, msg="expected JStr(hello)")
  }
}

///|
test "json_string_escape" {
  let state = @core.State::new("\"a\\nb\"")
  match (string_().run)(state) {
    @core.Success(JStr(s), _) => assert_eq(s, "a\nb")
    _ => assert_true(false, msg="expected JStr(a\\nb)")
  }
}

///|
test "json_string_unicode_escape" {
  let state = @core.State::new("\"\\u0041\"")
  match (string_().run)(state) {
    @core.Success(JStr(s), _) => assert_eq(s, "A")
    _ => assert_true(false, msg="expected JStr(A)")
  }
}

///|
test "json_array_empty" {
  let state = @core.State::new("[]")
  match (array_().run)(state) {
    @core.Success(JArr(arr), _) => assert_eq(arr.length(), 0)
    _ => assert_true(false, msg="expected empty array")
  }
}

///|
test "json_array_values" {
  let state = @core.State::new("[1, 2, 3]")
  match (array_().run)(state) {
    @core.Success(JArr(arr), _) => assert_eq(arr.length(), 3)
    _ => assert_true(false, msg="expected array of 3")
  }
}

///|
test "json_object_empty" {
  let state = @core.State::new("{}")
  match (object_().run)(state) {
    @core.Success(JObj(pairs), _) => assert_eq(pairs.length(), 0)
    _ => assert_true(false, msg="expected empty object")
  }
}

///|
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
test "json_parse_full" {
  match parse("{\"name\":\"Alice\",\"age\":30}") {
    Ok(JObj(pairs)) => assert_eq(pairs.length(), 2)
    _ => assert_true(false, msg="expected parsed object")
  }
}

///|
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
test "json_parse_whitespace" {
  match parse("  null  ") {
    Ok(JNull) => assert_true(true)
    _ => assert_true(false, msg="expected JNull with whitespace")
  }
}

///|
test "json_parse_error" {
  match parse("{bad}") {
    Err(_) => assert_true(true)
    Ok(_) => assert_true(false, msg="expected parse error")
  }
}

///|
test "json_stringify_roundtrip" {
  let v = JObj([("key", JNum(42.0)), ("arr", JArr([JBool(true), JNull]))])
  let s = v.stringify()
  match parse(s) {
    Ok(v2) => assert_true(v == v2)
    _ => assert_true(false, msg="roundtrip failed")
  }
}

///|
test "hex4_to_char_valid" {
  assert_eq(hex4_to_char("0041"), Some('A'))
  assert_eq(hex4_to_char("0030"), Some('0'))
  assert_eq(hex4_to_char("0020"), Some(' '))
}

///|
test "hex4_to_char_invalid" {
  assert_eq(hex4_to_char(""), None)
  assert_eq(hex4_to_char("GGGG"), None)
}
