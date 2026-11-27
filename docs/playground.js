var $reinterpret_view = new DataView(new ArrayBuffer(8));
function $i64_reinterpret_f64(a) {
  $reinterpret_view.setBigUint64(0, BigInt.asUintN(64, a), false);
  return $reinterpret_view.getFloat64(0, false);
}
function _M0TPC16string10StringView(param0, param1, param2) {
  this.str = param0;
  this.start = param1;
  this.end = param2;
}
function $oob() {
  throw new Error("Index out of bounds");
}
class $PanicError extends Error {}
function $panic(message) {
  throw new $PanicError(message);
}
function _M0TPB13StringBuilder(param0) {
  this.val = param0;
}
var _M0FPB12random__seed = () => {
  const cryptoObj = globalThis.crypto;
  if (cryptoObj != null && typeof cryptoObj.getRandomValues === "function") {
    try {
      const array = new Uint32Array(1);
      cryptoObj.getRandomValues(array);
      return array[0] | 0; // Convert to signed 32
    } catch (_) {
      // The host refuses Web Crypto here, e.g. Workers at module load
    }
  }
  return Math.floor(Math.random() * 0x100000000) | 0; // Fallback to Math.random
};
var _M0FPB19int__to__string__js = (x, radix) => {
  return x.toString(radix);
};
function _M0TPB4IterGUsRPC14json4JsonEE(param0, param1) {
  this.f = param0;
  this.size_hint = param1;
}
function _M0TPB5ArrayGcE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function $make_array_len_and_init(a, b) {
  const arr = new Array(a);
  arr.fill(b);
  return arr;
}
function _M0TPB3MapGsRPC14json4JsonE(param0, param1, param2, param3, param4, param5, param6) {
  this.entries = param0;
  this.size = param1;
  this.capacity = param2;
  this.capacity_mask = param3;
  this.grow_at = param4;
  this.head = param5;
  this.tail = param6;
}
function _M0TPB5EntryGsRPC14json4JsonE(param0, param1, param2, param3, param4, param5) {
  this.prev = param0;
  this.next = param1;
  this.psl = param2;
  this.hash = param3;
  this.key = param4;
  this.value = param5;
}
function _M0TPB8MutLocalGORPB5EntryGsRPC14json4JsonEE(param0) {
  this.val = param0;
}
function _M0TPB8MutLocalGiE(param0) {
  this.val = param0;
}
function _M0TPB9ArrayViewGsE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function _M0DTPC14json4Json4Null() {}
_M0DTPC14json4Json4Null.prototype.$tag = 0;
function _M0DTPC14json4Json4True() {}
_M0DTPC14json4Json4True.prototype.$tag = 1;
var _M0DTPC14json4Json4True__ = new _M0DTPC14json4Json4True();
function _M0DTPC14json4Json5False() {}
_M0DTPC14json4Json5False.prototype.$tag = 2;
var _M0DTPC14json4Json5False__ = new _M0DTPC14json4Json5False();
function _M0DTPC14json4Json6Number(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
_M0DTPC14json4Json6Number.prototype.$tag = 3;
function _M0DTPC14json4Json6String(param0) {
  this._0 = param0;
}
_M0DTPC14json4Json6String.prototype.$tag = 4;
function _M0DTPC14json4Json5Array(param0) {
  this._0 = param0;
}
_M0DTPC14json4Json5Array.prototype.$tag = 5;
function _M0DTPC14json4Json6Object(param0) {
  this._0 = param0;
}
_M0DTPC14json4Json6Object.prototype.$tag = 6;
function _M0TPB9ArrayViewGUsRPC14json4JsonEE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function _M0TPB5ArrayGsE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function _M0TPB5ArrayGRPC14json10WriteFrameE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function _M0DTPC14json10WriteFrame5Array(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
_M0DTPC14json10WriteFrame5Array.prototype.$tag = 0;
function _M0DTPC14json10WriteFrame6Object(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
_M0DTPC14json10WriteFrame6Object.prototype.$tag = 1;
function _M0TP37walkzzz9astrolabe4core6ParserGcE(param0) {
  this.run = param0;
}
function _M0TP37walkzzz9astrolabe4core6ParserGsE(param0) {
  this.run = param0;
}
function _M0DTPC15error5Error52walkzzz_2fastrolabe_2fcore_2eParseError_2eParseError(param0, param1, param2, param3) {
  this._0 = param0;
  this._1 = param1;
  this._2 = param2;
  this._3 = param3;
}
_M0DTPC15error5Error52walkzzz_2fastrolabe_2fcore_2eParseError_2eParseError.prototype.$tag = 0;
function _M0TP37walkzzz9astrolabe4core3Pos(param0, param1, param2) {
  this.line = param0;
  this.column = param1;
  this.offset = param2;
}
function _M0TP37walkzzz9astrolabe4core5State(param0, param1, param2) {
  this.input = param0;
  this.offset = param1;
  this.pos = param2;
}
function _M0DTPB6ResultGsRP37walkzzz9astrolabe4core10ParseErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPB6ResultGsRP37walkzzz9astrolabe4core10ParseErrorE3Err.prototype.$tag = 0;
function _M0DTPB6ResultGsRP37walkzzz9astrolabe4core10ParseErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPB6ResultGsRP37walkzzz9astrolabe4core10ParseErrorE2Ok.prototype.$tag = 1;
function _M0DTPB6ResultGUcsERP37walkzzz9astrolabe4core10ParseErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPB6ResultGUcsERP37walkzzz9astrolabe4core10ParseErrorE3Err.prototype.$tag = 0;
function _M0DTPB6ResultGUcsERP37walkzzz9astrolabe4core10ParseErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPB6ResultGUcsERP37walkzzz9astrolabe4core10ParseErrorE2Ok.prototype.$tag = 1;
function _M0DTPB6ResultGUssERP37walkzzz9astrolabe4core10ParseErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPB6ResultGUssERP37walkzzz9astrolabe4core10ParseErrorE3Err.prototype.$tag = 0;
function _M0DTPB6ResultGUssERP37walkzzz9astrolabe4core10ParseErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPB6ResultGUssERP37walkzzz9astrolabe4core10ParseErrorE2Ok.prototype.$tag = 1;
function _M0DTP37walkzzz9astrolabe4core11ParseResultGsE7Success(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
_M0DTP37walkzzz9astrolabe4core11ParseResultGsE7Success.prototype.$tag = 0;
function _M0DTP37walkzzz9astrolabe4core11ParseResultGsE7Failure(param0) {
  this._0 = param0;
}
_M0DTP37walkzzz9astrolabe4core11ParseResultGsE7Failure.prototype.$tag = 1;
function _M0DTP37walkzzz9astrolabe4core11ParseResultGcE7Success(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
_M0DTP37walkzzz9astrolabe4core11ParseResultGcE7Success.prototype.$tag = 0;
function _M0DTP37walkzzz9astrolabe4core11ParseResultGcE7Failure(param0) {
  this._0 = param0;
}
_M0DTP37walkzzz9astrolabe4core11ParseResultGcE7Failure.prototype.$tag = 1;
function _M0DTP37walkzzz9astrolabe4core11ParseResultGRPB5ArrayGsEE7Success(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
_M0DTP37walkzzz9astrolabe4core11ParseResultGRPB5ArrayGsEE7Success.prototype.$tag = 0;
function _M0DTP37walkzzz9astrolabe4core11ParseResultGRPB5ArrayGsEE7Failure(param0) {
  this._0 = param0;
}
_M0DTP37walkzzz9astrolabe4core11ParseResultGRPB5ArrayGsEE7Failure.prototype.$tag = 1;
function _M0TPB5ArrayGRPC14json4JsonE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function $f64_convert_i64(a) {
  return Number(BigInt.asIntN(64, a));
}
function _M0DTP37walkzzz9astrolabe4core11ParseResultGRPB5ArrayGRPC14json4JsonEE7Success(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
_M0DTP37walkzzz9astrolabe4core11ParseResultGRPB5ArrayGRPC14json4JsonEE7Success.prototype.$tag = 0;
function _M0DTP37walkzzz9astrolabe4core11ParseResultGRPB5ArrayGRPC14json4JsonEE7Failure(param0) {
  this._0 = param0;
}
_M0DTP37walkzzz9astrolabe4core11ParseResultGRPB5ArrayGRPC14json4JsonEE7Failure.prototype.$tag = 1;
var _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger = { method_0: _M0IPB13StringBuilderPB6Logger13write__string, method_1: _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE, method_2: _M0IPB13StringBuilderPB6Logger11write__view, method_3: _M0IPB13StringBuilderPB6Logger11write__char, method_4: _M0IP016_24default__implPB6Logger28write__string__interpolationGRPB13StringBuilderE, method_5: _M0IP016_24default__implPB6Logger5writeGRPB13StringBuilderE };
var _M0FPB18double__max__value = $i64_reinterpret_f64(9218868437227405311n);
var _M0FPB18double__min__value = $i64_reinterpret_f64(18442240474082181119n);
var _M0MPB4Iter4nextN6constrS186GUsRPC14json4JsonEE = 0;
var _M0MPB4Iter4nextN6constrS187GUsRPC14json4JsonEE = 0;
var _M0MPB4Iter4IterN6constrS196GUsRPC14json4JsonEE = 0;
var _M0MP37walkzzz9astrolabe4core10ParseError16expected__joinedN6recordS611 = new _M0TPC16string10StringView(" | ", 0, 3);
var _M0FPB4seed = _M0FPB12random__seed();
var _M0MP37walkzzz9astrolabe4core10ParseError6formatN6recordS620 = new _M0TPC16string10StringView(" or ", 0, 4);
var _M0MP37walkzzz9astrolabe4core10ParseError6formatN6recordS621 = new _M0TPC16string10StringView(" > ", 0, 3);
function _M0FPB13consume4__acc(acc, input) {
  const _p = (acc >>> 0) + ((Math.imul(input, -1028477379) | 0) >>> 0) | 0;
  return Math.imul(_p << 17 | (_p >>> 15 | 0), 668265263) | 0;
}
function _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGcEE(dst, dst_offset, src, src_offset, len) {
  if (dst === src && dst_offset < src_offset) {
    let _tmp = 0;
    while (true) {
      const i = _tmp;
      if (i < len) {
        const _tmp$2 = dst_offset + i | 0;
        const _tmp$3 = src_offset + i | 0;
        if (_tmp$2 >>> 0 < dst.length) {
          dst[_tmp$2] = _tmp$3 >>> 0 < src.length ? src[_tmp$3] : $oob();
        } else {
          $oob();
        }
        _tmp = i + 1 | 0;
        continue;
      } else {
        return;
      }
    }
  } else {
    let _tmp = len - 1 | 0;
    let _tmp$2 = len > 0;
    while (true) {
      const i = _tmp;
      const _more = _tmp$2;
      if (_more) {
        const _tmp$3 = dst_offset + i | 0;
        const _tmp$4 = src_offset + i | 0;
        if (_tmp$3 >>> 0 < dst.length) {
          dst[_tmp$3] = _tmp$4 >>> 0 < src.length ? src[_tmp$4] : $oob();
        } else {
          $oob();
        }
        _tmp = i - 1 | 0;
        _tmp$2 = i > 0;
        continue;
      } else {
        return;
      }
    }
  }
}
function _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGsEE(dst, dst_offset, src, src_offset, len) {
  if (dst === src && dst_offset < src_offset) {
    let _tmp = 0;
    while (true) {
      const i = _tmp;
      if (i < len) {
        const _tmp$2 = dst_offset + i | 0;
        const _tmp$3 = src_offset + i | 0;
        if (_tmp$2 >>> 0 < dst.length) {
          dst[_tmp$2] = _tmp$3 >>> 0 < src.length ? src[_tmp$3] : $oob();
        } else {
          $oob();
        }
        _tmp = i + 1 | 0;
        continue;
      } else {
        return;
      }
    }
  } else {
    let _tmp = len - 1 | 0;
    let _tmp$2 = len > 0;
    while (true) {
      const i = _tmp;
      const _more = _tmp$2;
      if (_more) {
        const _tmp$3 = dst_offset + i | 0;
        const _tmp$4 = src_offset + i | 0;
        if (_tmp$3 >>> 0 < dst.length) {
          dst[_tmp$3] = _tmp$4 >>> 0 < src.length ? src[_tmp$4] : $oob();
        } else {
          $oob();
        }
        _tmp = i - 1 | 0;
        _tmp$2 = i > 0;
        continue;
      } else {
        return;
      }
    }
  }
}
function _M0MPB18UninitializedArray12unsafe__blitGcE(dst, dst_offset, src, src_offset, len) {
  _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGcEE(dst, dst_offset, src, src_offset, len);
}
function _M0MPB18UninitializedArray12unsafe__blitGsE(dst, dst_offset, src, src_offset, len) {
  _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGsEE(dst, dst_offset, src, src_offset, len);
}
function _M0MPB18UninitializedArray23unsafe__make__and__blitGcE(src, allocate_len, src_offset, dst_offset, blit_len) {
  const dst = new Array(allocate_len);
  _M0MPB18UninitializedArray12unsafe__blitGcE(dst, dst_offset, src, src_offset, blit_len);
  return dst;
}
function _M0MPB18UninitializedArray23unsafe__make__and__blitGsE(src, allocate_len, src_offset, dst_offset, blit_len) {
  const dst = new Array(allocate_len);
  _M0MPB18UninitializedArray12unsafe__blitGsE(dst, dst_offset, src, src_offset, blit_len);
  return dst;
}
function _M0MPB13StringBuilder13write__objectGcE(self, obj) {
  _M0IP016_24default__implPB4Show6outputGcE(obj, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPB13StringBuilder13write__objectGiE(self, obj) {
  _M0IP016_24default__implPB4Show6outputGiE(obj, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPB13StringBuilder13write__objectGsE(self, obj) {
  _M0IP016_24default__implPB4Show6outputGsE(obj, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPB13StringBuilder13write__objectGdE(self, obj) {
  _M0IP016_24default__implPB4Show6outputGdE(obj, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPB18UninitializedArray23make__and__blit_2einnerGcE(src, allocate_len, len, src_offset, dst_offset) {
  let _tmp;
  if (allocate_len >= 0) {
    let _tmp$2;
    if (len >= 0) {
      let _tmp$3;
      const _p = src.length;
      if (src_offset >= 0 && src_offset <= (_p - len | 0)) {
        _tmp$3 = dst_offset >= 0 && dst_offset <= (allocate_len - len | 0);
      } else {
        _tmp$3 = false;
      }
      _tmp$2 = _tmp$3;
    } else {
      _tmp$2 = false;
    }
    _tmp = _tmp$2;
  } else {
    _tmp = false;
  }
  if (_tmp) {
    return _M0MPB18UninitializedArray23unsafe__make__and__blitGcE(src, allocate_len, src_offset, dst_offset, len);
  } else {
    const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(8);
    const _p = "bounds check failed: allocate_len = ";
    _string_builder.val = `${_string_builder.val}${_p}`;
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, allocate_len);
    const _p$2 = ", src_offset = ";
    _string_builder.val = `${_string_builder.val}${_p$2}`;
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, src_offset);
    const _p$3 = ", dst_offset = ";
    _string_builder.val = `${_string_builder.val}${_p$3}`;
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, dst_offset);
    const _p$4 = ", len = ";
    _string_builder.val = `${_string_builder.val}${_p$4}`;
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, len);
    const _p$5 = ", src.length = ";
    _string_builder.val = `${_string_builder.val}${_p$5}`;
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, src.length);
    return $panic(_string_builder.val);
  }
}
function _M0MPB18UninitializedArray23make__and__blit_2einnerGsE(src, allocate_len, len, src_offset, dst_offset) {
  let _tmp;
  if (allocate_len >= 0) {
    let _tmp$2;
    if (len >= 0) {
      let _tmp$3;
      const _p = src.length;
      if (src_offset >= 0 && src_offset <= (_p - len | 0)) {
        _tmp$3 = dst_offset >= 0 && dst_offset <= (allocate_len - len | 0);
      } else {
        _tmp$3 = false;
      }
      _tmp$2 = _tmp$3;
    } else {
      _tmp$2 = false;
    }
    _tmp = _tmp$2;
  } else {
    _tmp = false;
  }
  if (_tmp) {
    return _M0MPB18UninitializedArray23unsafe__make__and__blitGsE(src, allocate_len, src_offset, dst_offset, len);
  } else {
    const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(8);
    const _p = "bounds check failed: allocate_len = ";
    _string_builder.val = `${_string_builder.val}${_p}`;
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, allocate_len);
    const _p$2 = ", src_offset = ";
    _string_builder.val = `${_string_builder.val}${_p$2}`;
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, src_offset);
    const _p$3 = ", dst_offset = ";
    _string_builder.val = `${_string_builder.val}${_p$3}`;
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, dst_offset);
    const _p$4 = ", len = ";
    _string_builder.val = `${_string_builder.val}${_p$4}`;
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, len);
    const _p$5 = ", src.length = ";
    _string_builder.val = `${_string_builder.val}${_p$5}`;
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, src.length);
    return $panic(_string_builder.val);
  }
}
function _M0MPB13StringBuilder21StringBuilder_2einner(capacity) {
  return capacity >= 0 ? new _M0TPB13StringBuilder("") : $panic("capacity must be non-negative");
}
function _M0IPB13StringBuilderPB6Logger11write__char(self, ch) {
  self.val = `${self.val}${String.fromCodePoint(ch)}`;
}
function _M0IPB13StringBuilderPB6Logger13write__string(self, str) {
  self.val = `${self.val}${str}`;
}
function _M0FPB32code__point__of__surrogate__pair(leading, trailing) {
  return (((Math.imul(leading - 55296 | 0, 1024) | 0) + trailing | 0) - 56320 | 0) + 65536 | 0;
}
function _M0MPC14byte4Byte7to__hexN14to__hex__digitS155(i) {
  if (i < 10) {
    const _p = (i + 48 | 0) & 255;
    return _p;
  } else {
    const _p = (i + 97 | 0) & 255;
    const _p$2 = (_p - 10 | 0) & 255;
    return _p$2;
  }
}
function _M0MPC14byte4Byte7to__hex(b) {
  const _self = _M0MPB13StringBuilder21StringBuilder_2einner(8);
  _M0IPB13StringBuilderPB6Logger11write__char(_self, _M0MPC14byte4Byte7to__hexN14to__hex__digitS155((b / 16 | 0) & 255));
  _M0IPB13StringBuilderPB6Logger11write__char(_self, _M0MPC14byte4Byte7to__hexN14to__hex__digitS155((b % 16 | 0) & 255));
  const _p = _self;
  return _p.val;
}
function _M0FPB14avalanche__acc(acc) {
  let acc$2 = acc;
  acc$2 = acc$2 ^ (acc$2 >>> 15 | 0);
  acc$2 = Math.imul(acc$2, -2048144777) | 0;
  acc$2 = acc$2 ^ (acc$2 >>> 13 | 0);
  acc$2 = Math.imul(acc$2, -1028477379) | 0;
  acc$2 = acc$2 ^ (acc$2 >>> 16 | 0);
  return acc$2;
}
function _M0FPB13finalize__acc(acc) {
  return _M0FPB14avalanche__acc(acc);
}
function _M0IP016_24default__implPB6Logger28write__string__interpolationGRPB13StringBuilderE(self, show) {
  show.method_table.method_0(show.self, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0IP016_24default__implPB6Logger5writeGRPB13StringBuilderE(self, show) {
  show.method_table.method_0(show.self, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPC16string6String21clamped__view_2einner(self, start, end) {
  const len = self.length;
  let lo;
  if (start <= 0) {
    lo = 0;
  } else {
    if (start >= len) {
      lo = len;
    } else {
      let _tmp;
      const _p = self.charCodeAt(start);
      if (_p >= 56320 && _p <= 57343) {
        const _p$2 = self.charCodeAt(start - 1 | 0);
        _tmp = _p$2 >= 55296 && _p$2 <= 56319;
      } else {
        _tmp = false;
      }
      if (_tmp) {
        lo = start + 1 | 0;
      } else {
        lo = start;
      }
    }
  }
  let hi;
  if (end === undefined) {
    hi = len;
  } else {
    const _Some = end;
    const _e = _Some;
    if (_e <= 0) {
      hi = 0;
    } else {
      if (_e >= len) {
        hi = len;
      } else {
        let _tmp;
        const _p = self.charCodeAt(_e);
        if (_p >= 56320 && _p <= 57343) {
          const _p$2 = self.charCodeAt(_e - 1 | 0);
          _tmp = _p$2 >= 55296 && _p$2 <= 56319;
        } else {
          _tmp = false;
        }
        if (_tmp) {
          hi = _e - 1 | 0;
        } else {
          hi = _e;
        }
      }
    }
  }
  return lo >= hi ? new _M0TPC16string10StringView(self, lo, lo) : new _M0TPC16string10StringView(self, lo, hi);
}
function _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE(self, value, start, len) {
  _M0IPB13StringBuilderPB6Logger11write__view(self, _M0MPC16string6String21clamped__view_2einner(value, start, start + len | 0));
}
function _M0IP016_24default__implPB4Show6outputGcE(self, logger) {
  logger.method_table.method_0(logger.self, _M0IPC14char4CharPB4Show10to__string(self));
}
function _M0IP016_24default__implPB4Show6outputGiE(self, logger) {
  logger.method_table.method_0(logger.self, _M0IPC13int3IntPB4Show10to__string(self));
}
function _M0IP016_24default__implPB4Show6outputGsE(self, logger) {
  logger.method_table.method_0(logger.self, self);
}
function _M0IP016_24default__implPB4Show6outputGdE(self, logger) {
  logger.method_table.method_0(logger.self, _M0IPC16double6DoublePB4Show10to__string(self));
}
function _M0MPB4Iter4nextGUsRPC14json4JsonEE(self) {
  const _func = self.f;
  const result = _func();
  const _bind = self.size_hint;
  if (result === undefined) {
    self.size_hint = _M0MPB4Iter4nextN6constrS187GUsRPC14json4JsonEE;
  } else {
    if (_bind === undefined) {
    } else {
      const _Some = _bind;
      const _n = _Some;
      self.size_hint = _n > 0 ? _n - 1 | 0 : _M0MPB4Iter4nextN6constrS186GUsRPC14json4JsonEE;
    }
  }
  return result;
}
function _M0MPC13int3Int18to__string_2einner(self, radix) {
  return _M0FPB19int__to__string__js(self, radix);
}
function _M0MPB4Iter4IterGUsRPC14json4JsonEE(f, size_hint) {
  let size_hint$2;
  if (size_hint === undefined) {
    size_hint$2 = undefined;
  } else {
    const _Some = size_hint;
    const _n = _Some;
    size_hint$2 = _n > 0 ? _n : _M0MPB4Iter4IterN6constrS196GUsRPC14json4JsonEE;
  }
  return new _M0TPB4IterGUsRPC14json4JsonEE(f, size_hint$2);
}
function _M0MPC16string10StringView9to__owned(self) {
  return self.str.substring(self.start, self.end);
}
function _M0MPC16string6String19exact__view_2einner(self, start, end) {
  const len = self.length;
  let end$2;
  if (end === undefined) {
    end$2 = len;
  } else {
    const _Some = end;
    const _end = _Some;
    end$2 = _end;
  }
  if (start >= 0 && (start <= end$2 && end$2 <= len)) {
    if (start < len) {
      const _p = self.charCodeAt(start);
      if (!(_p >= 56320 && _p <= 57343)) {
      } else {
        $panic();
      }
    }
    if (end$2 < len) {
      const _p = self.charCodeAt(end$2);
      if (!(_p >= 56320 && _p <= 57343)) {
      } else {
        $panic();
      }
    }
    return new _M0TPC16string10StringView(self, start, end$2);
  } else {
    return $panic();
  }
}
function _M0IPB13StringBuilderPB6Logger11write__view(self, str) {
  self.val = `${self.val}${_M0MPC16string10StringView9to__owned(str)}`;
}
function _M0MPC16string6String6repeat(self, n) {
  if (n < 0) {
    return $panic("negative repeat count");
  } else {
    if (n === 0) {
      return "";
    } else {
      if (n === 1) {
        return self;
      } else {
        const len = self.length;
        const total = Math.imul(len, n) | 0;
        if (len === 0 || (total / n | 0) === len) {
          const buf = _M0MPB13StringBuilder21StringBuilder_2einner(total);
          const str = self;
          let _tmp = 0;
          while (true) {
            const _ = _tmp;
            if (_ < n) {
              buf.val = `${buf.val}${str}`;
              _tmp = _ + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          return buf.val;
        } else {
          return $panic("repeat result too large");
        }
      }
    }
  }
}
function _M0MPC15array5Array13Array_2einnerGcE(capacity) {
  return capacity >= 0 ? (capacity === 0 ? new _M0TPB5ArrayGcE([], 0) : new _M0TPB5ArrayGcE(new Array(capacity), 0)) : $panic("capacity must be non-negative");
}
function _M0FPB23array__growth__capacity(current, len, required) {
  if (required < len) {
    $panic("Array capacity overflow");
  }
  const start = current === 0 ? 8 : current;
  let _tmp = start;
  while (true) {
    const space = _tmp;
    if (space < required) {
      const next = Math.imul(space, 2) | 0;
      if (next <= space) {
        return required;
      }
      _tmp = next;
      continue;
    } else {
      return space;
    }
  }
}
function _M0MPC15array5Array8capacityGcE(self) {
  return self.buf.length;
}
function _M0MPC15array5Array8capacityGsE(self) {
  return self.buf.length;
}
function _M0MPC15array5Array14resize__bufferGcE(self, new_capacity) {
  const old_buf = self.buf;
  self.buf = [];
  const len = self.len;
  const copy_len = len < new_capacity ? len : new_capacity;
  const new_buf = _M0MPB18UninitializedArray23make__and__blit_2einnerGcE(old_buf, new_capacity, copy_len, 0, 0);
  self.buf = new_buf;
}
function _M0MPC15array5Array14resize__bufferGsE(self, new_capacity) {
  const old_buf = self.buf;
  self.buf = [];
  const len = self.len;
  const copy_len = len < new_capacity ? len : new_capacity;
  const new_buf = _M0MPB18UninitializedArray23make__and__blit_2einnerGsE(old_buf, new_capacity, copy_len, 0, 0);
  self.buf = new_buf;
}
function _M0MPC15array5Array7reallocGcE(self, required) {
  const old_cap = _M0MPC15array5Array8capacityGcE(self);
  const new_cap = _M0FPB23array__growth__capacity(old_cap, self.len, required);
  _M0MPC15array5Array14resize__bufferGcE(self, new_cap);
}
function _M0MPC15array5Array7reallocGsE(self, required) {
  const old_cap = _M0MPC15array5Array8capacityGsE(self);
  const new_cap = _M0FPB23array__growth__capacity(old_cap, self.len, required);
  _M0MPC15array5Array14resize__bufferGsE(self, new_cap);
}
function _M0MPC15array5Array4pushGcE(self, value) {
  if (self.len === self.buf.length) {
    _M0MPC15array5Array7reallocGcE(self, self.len + 1 | 0);
  }
  const length = self.len;
  self.buf[length] = value;
  self.len = length + 1 | 0;
}
function _M0MPC15array5Array4pushGsE(self, value) {
  if (self.len === self.buf.length) {
    _M0MPC15array5Array7reallocGsE(self, self.len + 1 | 0);
  }
  const length = self.len;
  self.buf[length] = value;
  self.len = length + 1 | 0;
}
function _M0IPC14char4CharPB4Show10to__string(self) {
  return String.fromCodePoint(self);
}
function _M0MPC16string6String9get__char(self, idx) {
  if (idx >= 0 && idx < self.length) {
    const c = self.charCodeAt(idx);
    if (c >= 55296 && c <= 56319) {
      if ((idx + 1 | 0) < self.length) {
        const next = self.charCodeAt(idx + 1 | 0);
        return next >= 56320 && next <= 57343 ? _M0FPB32code__point__of__surrogate__pair(c, next) : -1;
      } else {
        return -1;
      }
    } else {
      return c >= 56320 && c <= 57343 ? -1 : c;
    }
  } else {
    return -1;
  }
}
function _M0IPC16string6StringPB12ToStringView16to__string__view(self) {
  return new _M0TPC16string10StringView(self, 0, self.length);
}
function _M0FPB19join__string__viewsGsE(parts, separator) {
  if ((parts.end - parts.start | 0) === 0) {
    return "";
  } else {
    if ((parts.end - parts.start | 0) === 1) {
      const _one = parts.buf[parts.start];
      return _M0MPC16string10StringView9to__owned(_M0IPC16string6StringPB12ToStringView16to__string__view(_one));
    } else {
      const _first = parts.buf[parts.start];
      const _x_buf = parts.buf;
      const _x_start = 1 + parts.start | 0;
      const _x_end = parts.end;
      const separator$2 = _M0MPC16string10StringView9to__owned(separator);
      let result = _M0MPC16string10StringView9to__owned(_M0IPC16string6StringPB12ToStringView16to__string__view(_first));
      const _bind = _x_end - _x_start | 0;
      let _tmp = 0;
      while (true) {
        const _ = _tmp;
        if (_ < _bind) {
          const part = _x_buf[_x_start + _ | 0];
          result = `${result}${separator$2}`;
          result = `${result}${_M0MPC16string10StringView9to__owned(_M0IPC16string6StringPB12ToStringView16to__string__view(part))}`;
          _tmp = _ + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      return result;
    }
  }
}
function _M0MPC16string6String9to__array(self) {
  const chars = _M0MPC15array5Array13Array_2einnerGcE(self.length);
  const _bind = self.length;
  let _tmp = 0;
  while (true) {
    const _string_index = _tmp;
    if (_string_index < _bind) {
      let _decoded_next_string_index;
      let _decoded_char;
      _L: {
        const _bind$2 = self.charCodeAt(_string_index);
        if (_bind$2 >= 55296 && _bind$2 <= 56319 && (_string_index + 1 | 0) < _bind) {
          const _bind$3 = self.charCodeAt(_string_index + 1 | 0);
          if (_bind$3 >= 56320 && _bind$3 <= 57343) {
            const _tmp$2 = _string_index + 2 | 0;
            const _p = (((Math.imul(_bind$2 - 55296 | 0, 1024) | 0) + _bind$3 | 0) - 56320 | 0) + 65536 | 0;
            _decoded_next_string_index = _tmp$2;
            _decoded_char = _p;
            break _L;
          } else {
            const _tmp$2 = _string_index + 1 | 0;
            const _p = _bind$2;
            _decoded_next_string_index = _tmp$2;
            _decoded_char = _p;
            break _L;
          }
        } else {
          const _tmp$2 = _string_index + 1 | 0;
          const _p = _bind$2;
          _decoded_next_string_index = _tmp$2;
          _decoded_char = _p;
          break _L;
        }
      }
      _M0MPC15array5Array4pushGcE(chars, _decoded_char);
      _tmp = _decoded_next_string_index;
      continue;
    } else {
      break;
    }
  }
  return chars;
}
function _M0IPC13int3IntPB4Show10to__string(self) {
  return _M0MPC13int3Int18to__string_2einner(self, 10);
}
function _M0MPC15array9ArrayView4joinGsE(self, separator) {
  return _M0FPB19join__string__viewsGsE(self, separator);
}
function _M0FPB21calc__grow__threshold(capacity) {
  return (Math.imul(capacity / 16 | 0, 13) | 0) + ((Math.imul(capacity % 16 | 0, 13) | 0) / 16 | 0) | 0;
}
function _M0MPC13int3Int20next__power__of__two(self) {
  if (self >= 0) {
    if (self <= 1) {
      return 1;
    }
    if (self > 1073741824) {
      return 1073741824;
    }
    return (2147483647 >> (Math.clz32(self - 1 | 0) - 1 | 0)) + 1 | 0;
  } else {
    return $panic();
  }
}
function _M0FPB8new__mapGsRPC14json4JsonE(capacity) {
  const capacity$2 = _M0MPC13int3Int20next__power__of__two(capacity);
  const _bind = capacity$2 - 1 | 0;
  const _bind$2 = _M0FPB21calc__grow__threshold(capacity$2);
  const _bind$3 = $make_array_len_and_init(capacity$2, undefined);
  const _bind$4 = undefined;
  return new _M0TPB3MapGsRPC14json4JsonE(_bind$3, 0, capacity$2, _bind, _bind$2, _bind$4, -1);
}
function _M0FPB21capacity__for__length(length) {
  if (length <= _M0FPB21calc__grow__threshold(1073741824)) {
    let capacity = _M0MPC13int3Int20next__power__of__two(length);
    if (length > _M0FPB21calc__grow__threshold(capacity)) {
      capacity = Math.imul(capacity, 2) | 0;
    }
    return capacity;
  } else {
    return $panic("Map capacity overflow");
  }
}
function _M0MPB3Map20add__entry__to__tailGsRPC14json4JsonE(self, idx, entry) {
  const _bind = self.tail;
  if (_bind === -1) {
    self.head = entry;
  } else {
    const _tmp = self.entries;
    const _p = _bind >>> 0 < _tmp.length ? _tmp[_bind] : $oob();
    let _tmp$2;
    if (_p === undefined) {
      _tmp$2 = $panic();
    } else {
      const _p$2 = _p;
      _tmp$2 = _p$2;
    }
    _tmp$2.next = entry;
  }
  self.tail = idx;
  self.entries[idx] = entry;
  self.size = self.size + 1 | 0;
}
function _M0MPB3Map10set__entryGsRPC14json4JsonE(self, entry, new_idx) {
  const _bind = entry.next;
  if (_bind === undefined) {
    self.tail = new_idx;
  } else {
    const _Some = _bind;
    const _next = _Some;
    _next.prev = new_idx;
  }
  self.entries[new_idx] = entry;
}
function _M0MPB3Map10push__awayGsRPC14json4JsonE(self, idx, entry) {
  let _tmp = entry.psl + 1 | 0;
  let _tmp$2 = idx + 1 & self.capacity_mask;
  let _tmp$3 = entry;
  while (true) {
    const psl = _tmp;
    const idx$2 = _tmp$2;
    const entry$2 = _tmp$3;
    const _bind = self.entries[idx$2];
    if (_bind === undefined) {
      entry$2.psl = psl;
      _M0MPB3Map10set__entryGsRPC14json4JsonE(self, entry$2, idx$2);
      return;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (psl > _curr_entry.psl) {
        entry$2.psl = psl;
        _M0MPB3Map10set__entryGsRPC14json4JsonE(self, entry$2, idx$2);
        _tmp = _curr_entry.psl + 1 | 0;
        _tmp$2 = idx$2 + 1 & self.capacity_mask;
        _tmp$3 = _curr_entry;
        continue;
      } else {
        _tmp = psl + 1 | 0;
        _tmp$2 = idx$2 + 1 & self.capacity_mask;
        continue;
      }
    }
  }
}
function _M0MPB3Map20rehash__place__entryGsRPC14json4JsonE(self, outer) {
  const hash = outer.hash;
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const psl = _tmp;
    const idx = _tmp$2;
    const _bind = self.entries[idx];
    if (_bind === undefined) {
      outer.psl = psl;
      outer.prev = self.tail;
      _M0MPB3Map20add__entry__to__tailGsRPC14json4JsonE(self, idx, outer);
      return undefined;
    } else {
      const _Some = _bind;
      const _curr = _Some;
      if (psl > _curr.psl) {
        _M0MPB3Map10push__awayGsRPC14json4JsonE(self, idx, _curr);
        outer.psl = psl;
        outer.prev = self.tail;
        _M0MPB3Map20add__entry__to__tailGsRPC14json4JsonE(self, idx, outer);
        return undefined;
      } else {
        _tmp = psl + 1 | 0;
        _tmp$2 = idx + 1 & self.capacity_mask;
        continue;
      }
    }
  }
}
function _M0MPB3Map4growGsRPC14json4JsonE(self) {
  const old_head = self.head;
  const new_capacity = self.capacity << 1;
  self.entries = $make_array_len_and_init(new_capacity, undefined);
  self.capacity = new_capacity;
  self.capacity_mask = new_capacity - 1 | 0;
  self.grow_at = _M0FPB21calc__grow__threshold(self.capacity);
  self.size = 0;
  self.head = undefined;
  self.tail = -1;
  let _tmp = old_head;
  while (true) {
    const x = _tmp;
    if (x === undefined) {
      return;
    } else {
      const _Some = x;
      const _e = _Some;
      const next_in_chain = _e.next;
      _e.next = undefined;
      _M0MPB3Map20rehash__place__entryGsRPC14json4JsonE(self, _e);
      _tmp = next_in_chain;
      continue;
    }
  }
}
function _M0MPB3Map15set__with__hashGsRPC14json4JsonE(self, key, value, hash) {
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const psl = _tmp;
    const idx = _tmp$2;
    const _bind = self.entries[idx];
    if (_bind === undefined) {
      if (self.size >= self.grow_at) {
        _M0MPB3Map4growGsRPC14json4JsonE(self);
        _tmp = 0;
        _tmp$2 = hash & self.capacity_mask;
        continue;
      }
      const _bind$2 = self.tail;
      const _bind$3 = undefined;
      const entry = new _M0TPB5EntryGsRPC14json4JsonE(_bind$2, _bind$3, psl, hash, key, value);
      _M0MPB3Map20add__entry__to__tailGsRPC14json4JsonE(self, idx, entry);
      return undefined;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (_curr_entry.hash === hash && _curr_entry.key === key) {
        _curr_entry.value = value;
        return undefined;
      }
      if (psl > _curr_entry.psl) {
        if (self.size >= self.grow_at) {
          _M0MPB3Map4growGsRPC14json4JsonE(self);
          _tmp = 0;
          _tmp$2 = hash & self.capacity_mask;
          continue;
        }
        _M0MPB3Map10push__awayGsRPC14json4JsonE(self, idx, _curr_entry);
        const _bind$2 = self.tail;
        const _bind$3 = undefined;
        const entry = new _M0TPB5EntryGsRPC14json4JsonE(_bind$2, _bind$3, psl, hash, key, value);
        _M0MPB3Map20add__entry__to__tailGsRPC14json4JsonE(self, idx, entry);
        return undefined;
      }
      _tmp = psl + 1 | 0;
      _tmp$2 = idx + 1 & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map3setGsRPC14json4JsonE(self, key, value) {
  _M0MPB3Map15set__with__hashGsRPC14json4JsonE(self, key, value, _M0IPC16string6StringPB4Hash4hash(key));
}
function _M0MPB3Map3MapGsRPC14json4JsonE(arr, capacity) {
  const length = arr.end - arr.start | 0;
  let capacity$2;
  if (capacity === undefined) {
    capacity$2 = length === 0 ? 8 : _M0FPB21capacity__for__length(length);
  } else {
    const _Some = capacity;
    const _capacity = _Some;
    capacity$2 = _capacity >= 0 ? _M0FPB21capacity__for__length(_capacity > length ? _capacity : length) : $panic("capacity must be non-negative");
  }
  const m = _M0FPB8new__mapGsRPC14json4JsonE(capacity$2);
  const _bind = arr.end - arr.start | 0;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const e = arr.buf[arr.start + _ | 0];
      _M0MPB3Map3setGsRPC14json4JsonE(m, e._0, e._1);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return m;
}
function _M0MPB3Map4iterGsRPC14json4JsonE(self) {
  const curr_entry = new _M0TPB8MutLocalGORPB5EntryGsRPC14json4JsonEE(self.head);
  const len = self.size;
  const remaining = new _M0TPB8MutLocalGiE(len);
  return _M0MPB4Iter4IterGUsRPC14json4JsonEE(() => {
    _L: {
      if (remaining.val > 0) {
        const _bind = curr_entry.val;
        if (_bind === undefined) {
          break _L;
        } else {
          const _Some = _bind;
          const _x = _Some;
          const _key = _x.key;
          const _value = _x.value;
          const _next = _x.next;
          curr_entry.val = _next;
          remaining.val = remaining.val - 1 | 0;
          return { _0: _key, _1: _value };
        }
      } else {
        break _L;
      }
    }
    return undefined;
  }, len);
}
function _M0MPB3Map5iter2GsRPC14json4JsonE(self) {
  return _M0MPB3Map4iterGsRPC14json4JsonE(self);
}
function _M0MPB5Iter24nextGsRPC14json4JsonE(self) {
  return _M0MPB4Iter4nextGUsRPC14json4JsonEE(self);
}
function _M0IPC16string6StringPB4Hash4hash(self) {
  let acc = (_M0FPB4seed >>> 0) + (374761393 >>> 0) | 0;
  const _bind = self.length;
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < _bind) {
      acc = (acc >>> 0) + (4 >>> 0) | 0;
      const v = self.charCodeAt(i);
      acc = _M0FPB13consume4__acc(acc, v);
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0FPB13finalize__acc(acc);
}
function _M0IPC16double6DoublePB4Show10to__string(self) {
  return String(self);
}
function _M0MPC15array5Array3popGRPC14json10WriteFrameE(self) {
  const len = self.len;
  if (len === 0) {
    return undefined;
  } else {
    const index = len - 1 | 0;
    const v = self.buf[index];
    self.len = index;
    return v;
  }
}
function _M0MPC15array5Array8containsGsE(self, value) {
  const _bind = self.len;
  const _bind$2 = self.buf;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const v = _bind$2[_];
      if (v === value) {
        return true;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      return false;
    }
  }
}
function _M0MPC15array5Array4joinGsE(self, separator) {
  return _M0MPC15array9ArrayView4joinGsE(new _M0TPB9ArrayViewGsE(self.buf, 0, self.len), separator);
}
function _M0MPC14json4Json4JsonGsE(value) {
  return new _M0DTPC14json4Json6String(value);
}
function _M0MPC14json4Json4JsonGdE(value) {
  return _M0IPC16double6DoublePC14json6ToJson8to__json(value);
}
function _M0MPC14json4Json4JsonGbE(value) {
  return _M0IPC14bool4BoolPC14json6ToJson8to__json(value);
}
function _M0IPC14bool4BoolPC14json6ToJson8to__json(self) {
  return self ? _M0DTPC14json4Json4True__ : _M0DTPC14json4Json5False__;
}
function _M0IPC16double6DoublePC14json6ToJson8to__json(self) {
  if (self !== self) {
    const _p = "NaN";
    return new _M0DTPC14json4Json6String(_p);
  } else {
    if (self > $i64_reinterpret_f64(9218868437227405311n)) {
      const _p = "Infinity";
      return new _M0DTPC14json4Json6String(_p);
    } else {
      if (self < $i64_reinterpret_f64(18442240474082181119n)) {
        const _p = "-Infinity";
        return new _M0DTPC14json4Json6String(_p);
      } else {
        const _p = undefined;
        return new _M0DTPC14json4Json6Number(self, _p);
      }
    }
  }
}
function _M0IPB3MapPC14json6ToJson8to__jsonGsRPC14json4JsonE(self) {
  const _bind = [];
  const object = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind, 0, 0), self.size);
  const _it = _M0MPB3Map5iter2GsRPC14json4JsonE(self);
  while (true) {
    const _bind$2 = _M0MPB5Iter24nextGsRPC14json4JsonE(_it);
    if (_bind$2 === undefined) {
      break;
    } else {
      const _Some = _bind$2;
      const _x = _Some;
      const _k = _x._0;
      const _v = _x._1;
      _M0MPB3Map3setGsRPC14json4JsonE(object, _k, _v);
      continue;
    }
  }
  return new _M0DTPC14json4Json6Object(object);
}
function _M0FPC14json20need__escape__scalar(str, escape_slash, start, end) {
  let _tmp = start;
  while (true) {
    const i = _tmp;
    if (i < end) {
      const _p = str.charCodeAt(i);
      if (_p === 34 || (_p === 92 || (_p < 32 || escape_slash && _p === 47))) {
        return true;
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return false;
}
function _M0FPC14json12need__escape(str, escape_slash) {
  return _M0FPC14json20need__escape__scalar(str, escape_slash, 0, str.length);
}
function _M0FPC14json13write__escape(buf, code) {
  switch (code) {
    case 34: {
      const _p = "\\\"";
      buf.val = `${buf.val}${_p}`;
      return;
    }
    case 92: {
      const _p$2 = "\\\\";
      buf.val = `${buf.val}${_p$2}`;
      return;
    }
    case 47: {
      const _p$3 = "\\/";
      buf.val = `${buf.val}${_p$3}`;
      return;
    }
    case 10: {
      const _p$4 = "\\n";
      buf.val = `${buf.val}${_p$4}`;
      return;
    }
    case 13: {
      const _p$5 = "\\r";
      buf.val = `${buf.val}${_p$5}`;
      return;
    }
    case 8: {
      const _p$6 = "\\b";
      buf.val = `${buf.val}${_p$6}`;
      return;
    }
    case 9: {
      const _p$7 = "\\t";
      buf.val = `${buf.val}${_p$7}`;
      return;
    }
    case 12: {
      const _p$8 = "\\f";
      buf.val = `${buf.val}${_p$8}`;
      return;
    }
    default: {
      const _p$9 = "\\u00";
      buf.val = `${buf.val}${_p$9}`;
      _M0MPB13StringBuilder13write__objectGsE(buf, _M0MPC14byte4Byte7to__hex(code & 255));
      return;
    }
  }
}
function _M0FPC14json14write__escaped(buf, str, escape_slash) {
  if (!_M0FPC14json12need__escape(str, escape_slash)) {
    buf.val = `${buf.val}${str}`;
    return undefined;
  }
  const _bind = str.length;
  let _tmp = 0;
  let _tmp$2 = 0;
  while (true) {
    const i = _tmp;
    const run_start = _tmp$2;
    if (i < _bind) {
      const code = str.charCodeAt(i);
      if (code === 34 || (code === 92 || (code < 32 || escape_slash && code === 47))) {
        _M0IPB13StringBuilderPB6Logger11write__view(buf, _M0MPC16string6String19exact__view_2einner(str, run_start, i));
        _M0FPC14json13write__escape(buf, code);
        _tmp = i + 1 | 0;
        _tmp$2 = i + 1 | 0;
        continue;
      } else {
        _tmp = i + 1 | 0;
        continue;
      }
    } else {
      _M0IPB13StringBuilderPB6Logger11write__view(buf, _M0MPC16string6String19exact__view_2einner(str, run_start, undefined));
      return;
    }
  }
}
function _M0FPC14json13write__indent(buf, cache, level, indent) {
  while (true) {
    if (cache.len <= level) {
      if (cache.len >= 1) {
        const _bind = cache.len - 1 | 0;
        const _last = cache.buf[_bind];
        _M0MPC15array5Array4pushGsE(cache, `${_last}${_M0MPC16string6String6repeat(" ", indent)}`);
      } else {
        _M0MPC15array5Array4pushGsE(cache, "\n");
      }
      continue;
    } else {
      break;
    }
  }
  if (level < 0 || level >= cache.len) {
    $panic();
  }
  const _p = cache.buf[level];
  buf.val = `${buf.val}${_p}`;
}
function _M0MPC14json4Json17stringify_2einner(self, escape_slash, indent, replacer) {
  const buf = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  const indent_cache = new _M0TPB5ArrayGsE([], 0);
  const stack = new _M0TPB5ArrayGRPC14json10WriteFrameE([], 0);
  let depth = 0;
  let _tmp = self;
  _L: while (true) {
    const x = _tmp;
    if (x === undefined) {
      if (stack.len === 0) {
        break;
      } else {
        const _bind = stack.len - 1 | 0;
        const _x = stack.buf[_bind];
        if (_x.$tag === 0) {
          const _Array = _x;
          const _arr = _Array._0;
          const _i = _Array._1;
          if (_i < _arr.len) {
            if (_i < 0 || _i >= _arr.len) {
              $panic();
            }
            const element = _arr.buf[_i];
            _Array._1 = _i + 1 | 0;
            if (_i > 0) {
              _M0IPB13StringBuilderPB6Logger11write__char(buf, 44);
              if (indent > 0) {
                _M0FPC14json13write__indent(buf, indent_cache, depth, indent);
              }
            }
            _tmp = element;
            continue;
          } else {
            depth = depth - 1 | 0;
            _M0MPC15array5Array3popGRPC14json10WriteFrameE(stack);
            if (indent > 0) {
              _M0FPC14json13write__indent(buf, indent_cache, depth, indent);
            }
            _M0IPB13StringBuilderPB6Logger11write__char(buf, 93);
            _tmp = undefined;
            continue;
          }
        } else {
          const _Object = _x;
          const _iterator = _Object._0;
          const _first = _Object._1;
          const _bind$2 = _M0MPB4Iter4nextGUsRPC14json4JsonEE(_iterator);
          if (_bind$2 === undefined) {
            depth = depth - 1 | 0;
            _M0MPC15array5Array3popGRPC14json10WriteFrameE(stack);
            if (indent > 0 && !_first) {
              _M0FPC14json13write__indent(buf, indent_cache, depth, indent);
            }
            _M0IPB13StringBuilderPB6Logger11write__char(buf, 125);
            _tmp = undefined;
            continue;
          } else {
            const _Some = _bind$2;
            const _x$2 = _Some;
            const _k = _x$2._0;
            const _v = _x$2._1;
            let v2 = _v;
            if (replacer === undefined) {
            } else {
              const _Some$2 = replacer;
              const _replacer = _Some$2;
              const _func = _replacer.f;
              const _bind$3 = _func(_k, _v);
              if (_bind$3 === undefined) {
                _tmp = undefined;
                continue;
              } else {
                const _Some$3 = _bind$3;
                const _v$2 = _Some$3;
                v2 = _v$2;
              }
            }
            if (!_first) {
              _M0IPB13StringBuilderPB6Logger11write__char(buf, 44);
            }
            if (indent > 0) {
              _M0FPC14json13write__indent(buf, indent_cache, depth, indent);
            }
            _M0IPB13StringBuilderPB6Logger11write__char(buf, 34);
            _M0FPC14json14write__escaped(buf, _k, escape_slash);
            const _p = "\":";
            buf.val = `${buf.val}${_p}`;
            if (indent > 0) {
              _M0IPB13StringBuilderPB6Logger11write__char(buf, 32);
            }
            _Object._1 = false;
            _tmp = v2;
            continue;
          }
        }
      }
    } else {
      const _Some = x;
      const _value = _Some;
      switch (_value.$tag) {
        case 6: {
          const _Object = _value;
          const _members = _Object._0;
          if (_members.size === 0) {
            const _p = "{}";
            buf.val = `${buf.val}${_p}`;
          } else {
            depth = depth + 1 | 0;
            _M0IPB13StringBuilderPB6Logger11write__char(buf, 123);
            _M0MPC15array5Array4pushGsE(stack, new _M0DTPC14json10WriteFrame6Object(_M0MPB3Map4iterGsRPC14json4JsonE(_members), true));
          }
          break;
        }
        case 5: {
          const _Array = _value;
          const _arr = _Array._0;
          if (_arr.len === 0) {
            const _p = "[]";
            buf.val = `${buf.val}${_p}`;
          } else {
            depth = depth + 1 | 0;
            _M0IPB13StringBuilderPB6Logger11write__char(buf, 91);
            if (indent > 0) {
              _M0FPC14json13write__indent(buf, indent_cache, depth, indent);
            }
            _M0MPC15array5Array4pushGsE(stack, new _M0DTPC14json10WriteFrame5Array(_arr, 0));
          }
          break;
        }
        case 4: {
          const _String = _value;
          const _s = _String._0;
          _M0IPB13StringBuilderPB6Logger11write__char(buf, 34);
          _M0FPC14json14write__escaped(buf, _s, escape_slash);
          _M0IPB13StringBuilderPB6Logger11write__char(buf, 34);
          break;
        }
        case 3: {
          const _Number = _value;
          const _n = _Number._0;
          const _repr = _Number._1;
          if (_repr === undefined) {
            if (!(_n >= _M0FPB18double__min__value && _n <= _M0FPB18double__max__value)) {
              _tmp = _M0MPC14json4Json4JsonGdE(_n);
              continue _L;
            } else {
              _M0MPB13StringBuilder13write__objectGdE(buf, _n);
            }
          } else {
            const _Some$2 = _repr;
            const _r = _Some$2;
            buf.val = `${buf.val}${_r}`;
          }
          break;
        }
        case 1: {
          const _p = "true";
          buf.val = `${buf.val}${_p}`;
          break;
        }
        case 2: {
          const _p$2 = "false";
          buf.val = `${buf.val}${_p$2}`;
          break;
        }
        default: {
          const _p$3 = "null";
          buf.val = `${buf.val}${_p$3}`;
        }
      }
      _tmp = undefined;
      continue;
    }
  }
  return buf.val;
}
function _M0MP37walkzzz9astrolabe4core6Parser2ofGcE(f) {
  return new _M0TP37walkzzz9astrolabe4core6ParserGcE(f);
}
function _M0MP37walkzzz9astrolabe4core6Parser2ofGsE(f) {
  return new _M0TP37walkzzz9astrolabe4core6ParserGsE(f);
}
function _M0MP37walkzzz9astrolabe4core10ParseError6commit(self) {
  const _ParseError = self;
  const _pos = _ParseError._0;
  const _expected = _ParseError._1;
  const _contexts = _ParseError._3;
  return new _M0DTPC15error5Error52walkzzz_2fastrolabe_2fcore_2eParseError_2eParseError(_pos, _expected, true, _contexts);
}
function _M0MP37walkzzz9astrolabe4core10ParseError9committed(self) {
  const _ParseError = self;
  return _ParseError._2;
}
function _M0MP37walkzzz9astrolabe4core10ParseError8contexts(self) {
  const _ParseError = self;
  return _ParseError._3;
}
function _M0MP37walkzzz9astrolabe4core10ParseError8expected(self) {
  const _ParseError = self;
  return _ParseError._1;
}
function _M0MP37walkzzz9astrolabe4core10ParseError3pos(self) {
  const _ParseError = self;
  return _ParseError._0;
}
function _M0MP37walkzzz9astrolabe4core10ParseError5merge(self, other) {
  const self_offset = _M0MP37walkzzz9astrolabe4core10ParseError3pos(self).offset;
  const other_offset = _M0MP37walkzzz9astrolabe4core10ParseError3pos(other).offset;
  if (self_offset > other_offset) {
    return self;
  } else {
    if (other_offset > self_offset) {
      return other;
    } else {
      const merged = new _M0TPB5ArrayGsE([], 0);
      const _bind = _M0MP37walkzzz9astrolabe4core10ParseError8expected(self);
      const _bind$2 = _bind.len;
      const _bind$3 = _bind.buf;
      let _tmp = 0;
      while (true) {
        const _ = _tmp;
        if (_ < _bind$2) {
          const label = _bind$3[_];
          if (!_M0MPC15array5Array8containsGsE(merged, label)) {
            _M0MPC15array5Array4pushGsE(merged, label);
          }
          _tmp = _ + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      const _bind$4 = _M0MP37walkzzz9astrolabe4core10ParseError8expected(other);
      const _bind$5 = _bind$4.len;
      const _bind$6 = _bind$4.buf;
      let _tmp$2 = 0;
      while (true) {
        const _ = _tmp$2;
        if (_ < _bind$5) {
          const label = _bind$6[_];
          if (!_M0MPC15array5Array8containsGsE(merged, label)) {
            _M0MPC15array5Array4pushGsE(merged, label);
          }
          _tmp$2 = _ + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      return new _M0DTPC15error5Error52walkzzz_2fastrolabe_2fcore_2eParseError_2eParseError(_M0MP37walkzzz9astrolabe4core10ParseError3pos(self), merged, _M0MP37walkzzz9astrolabe4core10ParseError9committed(self) || _M0MP37walkzzz9astrolabe4core10ParseError9committed(other), _M0MP37walkzzz9astrolabe4core10ParseError8contexts(self));
    }
  }
}
function _M0MP37walkzzz9astrolabe4core3Pos7initial() {
  return new _M0TP37walkzzz9astrolabe4core3Pos(1, 1, 0);
}
function _M0MP37walkzzz9astrolabe4core3Pos7advance(self, ch) {
  return ch === 10 ? new _M0TP37walkzzz9astrolabe4core3Pos(self.line + 1 | 0, 1, self.offset + 1 | 0) : new _M0TP37walkzzz9astrolabe4core3Pos(self.line, self.column + 1 | 0, self.offset + 1 | 0);
}
function _M0MP37walkzzz9astrolabe4core3Pos10to__string(self) {
  const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(8);
  _M0MPB13StringBuilder13write__objectGiE(_string_builder, self.line);
  const _p = ":";
  _string_builder.val = `${_string_builder.val}${_p}`;
  _M0MPB13StringBuilder13write__objectGiE(_string_builder, self.column);
  const _p$2 = "@";
  _string_builder.val = `${_string_builder.val}${_p$2}`;
  _M0MPB13StringBuilder13write__objectGiE(_string_builder, self.offset);
  return _string_builder.val;
}
function _M0MP37walkzzz9astrolabe4core5State3new(input) {
  return new _M0TP37walkzzz9astrolabe4core5State(input, 0, _M0MP37walkzzz9astrolabe4core3Pos7initial());
}
function _M0MP37walkzzz9astrolabe4core5State4peek(self) {
  return self.offset >= self.input.length ? -1 : _M0MPC16string6String9get__char(self.input, self.offset);
}
function _M0MP37walkzzz9astrolabe4core5State12advance__one(self) {
  if (!(self.offset >= self.input.length)) {
    const _p = _M0MPC16string6String9get__char(self.input, self.offset);
    const ch = _p === -1 ? $panic() : _p;
    self.pos = _M0MP37walkzzz9astrolabe4core3Pos7advance(self.pos, ch);
    self.offset = self.offset + 1 | 0;
    return;
  } else {
    return;
  }
}
function _M0MP37walkzzz9astrolabe4core5State11advance__by(self, n) {
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < n) {
      _M0MP37walkzzz9astrolabe4core5State12advance__one(self);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0MP37walkzzz9astrolabe4core5State5slice(self, start, end) {
  return _M0MPC16string10StringView9to__owned(_M0MPC16string6String21clamped__view_2einner(self.input, start, end));
}
function _M0MP37walkzzz9astrolabe4core10ParseError2at(pos, expected) {
  return new _M0DTPC15error5Error52walkzzz_2fastrolabe_2fcore_2eParseError_2eParseError(pos, new _M0TPB5ArrayGsE([expected], 1), false, new _M0TPB5ArrayGsE([], 0));
}
function _M0MP37walkzzz9astrolabe4core10ParseError16expected__joined(self) {
  const out = new _M0TPB5ArrayGsE([], 0);
  const _bind = _M0MP37walkzzz9astrolabe4core10ParseError8expected(self);
  const _bind$2 = _bind.len;
  const _bind$3 = _bind.buf;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const item = _bind$3[_];
      if (!_M0MPC15array5Array8containsGsE(out, item)) {
        _M0MPC15array5Array4pushGsE(out, item);
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out.len === 0 ? "unknown" : _M0MPC15array5Array4joinGsE(out, _M0MP37walkzzz9astrolabe4core10ParseError16expected__joinedN6recordS611);
}
function _M0MP37walkzzz9astrolabe4core10ParseError6format(self) {
  const _ParseError = self;
  const _pos = _ParseError._0;
  const _expected = _ParseError._1;
  const _contexts = _ParseError._3;
  const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(8);
  const _p = "line ";
  _string_builder.val = `${_string_builder.val}${_p}`;
  _M0MPB13StringBuilder13write__objectGiE(_string_builder, _pos.line);
  const _p$2 = ", column ";
  _string_builder.val = `${_string_builder.val}${_p$2}`;
  _M0MPB13StringBuilder13write__objectGiE(_string_builder, _pos.column);
  const _p$3 = " (offset ";
  _string_builder.val = `${_string_builder.val}${_p$3}`;
  _M0MPB13StringBuilder13write__objectGiE(_string_builder, _pos.offset);
  const _p$4 = ")";
  _string_builder.val = `${_string_builder.val}${_p$4}`;
  const loc = _string_builder.val;
  const exp = _M0MPC15array5Array4joinGsE(_expected, _M0MP37walkzzz9astrolabe4core10ParseError6formatN6recordS620);
  let ctx;
  if (_contexts.len === 0) {
    ctx = "";
  } else {
    const _string_builder$2 = _M0MPB13StringBuilder21StringBuilder_2einner(8);
    const _p$5 = "\n  in ";
    _string_builder$2.val = `${_string_builder$2.val}${_p$5}`;
    _M0MPB13StringBuilder13write__objectGsE(_string_builder$2, _M0MPC15array5Array4joinGsE(_contexts, _M0MP37walkzzz9astrolabe4core10ParseError6formatN6recordS621));
    ctx = _string_builder$2.val;
  }
  const _string_builder$2 = _M0MPB13StringBuilder21StringBuilder_2einner(8);
  _M0MPB13StringBuilder13write__objectGsE(_string_builder$2, loc);
  const _p$5 = ":\nexpected ";
  _string_builder$2.val = `${_string_builder$2.val}${_p$5}`;
  _M0MPB13StringBuilder13write__objectGsE(_string_builder$2, exp);
  _M0MPB13StringBuilder13write__objectGsE(_string_builder$2, ctx);
  return _string_builder$2.val;
}
function _M0MP37walkzzz9astrolabe4core10ParseError19format__with__input(self, input) {
  const _ParseError = self;
  const _pos = _ParseError._0;
  const base = _M0MP37walkzzz9astrolabe4core10ParseError6format(self);
  const offset = _pos.offset;
  const ctx_start = offset > 20 ? offset - 20 | 0 : 0;
  const ctx_end = (offset + 20 | 0) < input.length ? offset + 20 | 0 : input.length;
  const snippet = _M0MPC16string10StringView9to__owned(_M0MPC16string6String21clamped__view_2einner(input, ctx_start, ctx_end));
  const prefix = ctx_start > 0 ? "..." : "";
  const suffix = ctx_end < input.length ? "..." : "";
  const caret_offset = (offset - ctx_start | 0) + prefix.length | 0;
  const caret = `${_M0MPC16string6String6repeat(" ", caret_offset)}^`;
  const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(8);
  _M0MPB13StringBuilder13write__objectGsE(_string_builder, base);
  const _p = "\n  ";
  _string_builder.val = `${_string_builder.val}${_p}`;
  _M0MPB13StringBuilder13write__objectGsE(_string_builder, prefix);
  _M0MPB13StringBuilder13write__objectGsE(_string_builder, snippet);
  _M0MPB13StringBuilder13write__objectGsE(_string_builder, suffix);
  const _p$2 = "\n  ";
  _string_builder.val = `${_string_builder.val}${_p$2}`;
  _M0MPB13StringBuilder13write__objectGsE(_string_builder, caret);
  return _string_builder.val;
}
function _M0MP37walkzzz9astrolabe4core6Parser5parseGsE(self, input) {
  const state = _M0MP37walkzzz9astrolabe4core5State3new(input);
  const _func = self.run;
  const _bind = _func(state);
  if (_bind.$tag === 0) {
    const _Success = _bind;
    const _value = _Success._0;
    return new _M0DTPB6ResultGsRP37walkzzz9astrolabe4core10ParseErrorE2Ok(_value);
  } else {
    const _Failure = _bind;
    const _err = _Failure._0;
    return new _M0DTPB6ResultGsRP37walkzzz9astrolabe4core10ParseErrorE3Err(_err);
  }
}
function _M0MP37walkzzz9astrolabe4core6Parser13parse__prefixGcE(self, input) {
  const state = _M0MP37walkzzz9astrolabe4core5State3new(input);
  const _func = self.run;
  const _bind = _func(state);
  if (_bind.$tag === 0) {
    const _Success = _bind;
    const _value = _Success._0;
    const _st = _Success._1;
    return new _M0DTPB6ResultGUcsERP37walkzzz9astrolabe4core10ParseErrorE2Ok({ _0: _value, _1: _M0MPC16string10StringView9to__owned(_M0MPC16string6String21clamped__view_2einner(input, _st.offset, undefined)) });
  } else {
    const _Failure = _bind;
    const _err = _Failure._0;
    return new _M0DTPB6ResultGUcsERP37walkzzz9astrolabe4core10ParseErrorE3Err(_err);
  }
}
function _M0MP37walkzzz9astrolabe4core6Parser13parse__prefixGsE(self, input) {
  const state = _M0MP37walkzzz9astrolabe4core5State3new(input);
  const _func = self.run;
  const _bind = _func(state);
  if (_bind.$tag === 0) {
    const _Success = _bind;
    const _value = _Success._0;
    const _st = _Success._1;
    return new _M0DTPB6ResultGUssERP37walkzzz9astrolabe4core10ParseErrorE2Ok({ _0: _value, _1: _M0MPC16string10StringView9to__owned(_M0MPC16string6String21clamped__view_2einner(input, _st.offset, undefined)) });
  } else {
    const _Failure = _bind;
    const _err = _Failure._0;
    return new _M0DTPB6ResultGUssERP37walkzzz9astrolabe4core10ParseErrorE3Err(_err);
  }
}
function _M0MP37walkzzz9astrolabe4core6Parser11parse__fullGsE(self, input) {
  const state = _M0MP37walkzzz9astrolabe4core5State3new(input);
  const _func = self.run;
  const _bind = _func(state);
  if (_bind.$tag === 0) {
    const _Success = _bind;
    const _value = _Success._0;
    const _st = _Success._1;
    return _st.offset >= _st.input.length ? new _M0DTPB6ResultGsRP37walkzzz9astrolabe4core10ParseErrorE2Ok(_value) : new _M0DTPB6ResultGsRP37walkzzz9astrolabe4core10ParseErrorE3Err(_M0MP37walkzzz9astrolabe4core10ParseError2at(_st.pos, "end of input"));
  } else {
    const _Failure = _bind;
    const _err = _Failure._0;
    return new _M0DTPB6ResultGsRP37walkzzz9astrolabe4core10ParseErrorE3Err(_err);
  }
}
function _M0FP37walkzzz9astrolabe6branch6commitGsE(p) {
  return _M0MP37walkzzz9astrolabe4core6Parser2ofGsE((state) => {
    const _func = p.run;
    const _bind = _func(state);
    if (_bind.$tag === 0) {
      const _Success = _bind;
      const _value = _Success._0;
      const _st = _Success._1;
      return new _M0DTP37walkzzz9astrolabe4core11ParseResultGsE7Success(_value, _st);
    } else {
      const _Failure = _bind;
      const _err = _Failure._0;
      return new _M0DTP37walkzzz9astrolabe4core11ParseResultGsE7Failure(_M0MP37walkzzz9astrolabe4core10ParseError6commit(_err));
    }
  });
}
function _M0FP37walkzzz9astrolabe6branch3altGsE(p1, p2) {
  return _M0MP37walkzzz9astrolabe4core6Parser2ofGsE((state) => {
    const _func = p1.run;
    const _bind = _func(state);
    if (_bind.$tag === 0) {
      const _Success = _bind;
      const _value = _Success._0;
      const _st = _Success._1;
      return new _M0DTP37walkzzz9astrolabe4core11ParseResultGsE7Success(_value, _st);
    } else {
      const _Failure = _bind;
      const _err = _Failure._0;
      if (_M0MP37walkzzz9astrolabe4core10ParseError9committed(_err)) {
        return new _M0DTP37walkzzz9astrolabe4core11ParseResultGsE7Failure(_err);
      } else {
        const _func$2 = p2.run;
        const _bind$2 = _func$2(state);
        if (_bind$2.$tag === 0) {
          const _Success = _bind$2;
          const _value = _Success._0;
          const _st = _Success._1;
          return new _M0DTP37walkzzz9astrolabe4core11ParseResultGsE7Success(_value, _st);
        } else {
          const _Failure$2 = _bind$2;
          const _err2 = _Failure$2._0;
          return new _M0DTP37walkzzz9astrolabe4core11ParseResultGsE7Failure(_M0MP37walkzzz9astrolabe4core10ParseError5merge(_err, _err2));
        }
      }
    }
  });
}
function _M0FP37walkzzz9astrolabe4char4char(expected) {
  return _M0MP37walkzzz9astrolabe4core6Parser2ofGcE((state) => {
    const _bind = _M0MP37walkzzz9astrolabe4core5State4peek(state);
    if (_bind === -1) {
      const _tmp = state.pos;
      const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(8);
      const _p = "'";
      _string_builder.val = `${_string_builder.val}${_p}`;
      _M0MPB13StringBuilder13write__objectGcE(_string_builder, expected);
      const _p$2 = "'";
      _string_builder.val = `${_string_builder.val}${_p$2}`;
      return new _M0DTP37walkzzz9astrolabe4core11ParseResultGcE7Failure(_M0MP37walkzzz9astrolabe4core10ParseError2at(_tmp, _string_builder.val));
    } else {
      const _Some = _bind;
      const _ch = _Some;
      if (_ch === expected) {
        _M0MP37walkzzz9astrolabe4core5State12advance__one(state);
        return new _M0DTP37walkzzz9astrolabe4core11ParseResultGcE7Success(_ch, state);
      } else {
        const _tmp = state.pos;
        const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(8);
        const _p = "'";
        _string_builder.val = `${_string_builder.val}${_p}`;
        _M0MPB13StringBuilder13write__objectGcE(_string_builder, expected);
        const _p$2 = "'";
        _string_builder.val = `${_string_builder.val}${_p$2}`;
        return new _M0DTP37walkzzz9astrolabe4core11ParseResultGcE7Failure(_M0MP37walkzzz9astrolabe4core10ParseError2at(_tmp, _string_builder.val));
      }
    }
  });
}
function _M0FP37walkzzz9astrolabe4char6string(expected) {
  return _M0MP37walkzzz9astrolabe4core6Parser2ofGsE((state) => {
    const len = expected.length;
    if ((state.input.length - state.offset | 0) < len) {
      const _tmp = state.pos;
      const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(8);
      const _p = "\"";
      _string_builder.val = `${_string_builder.val}${_p}`;
      _M0MPB13StringBuilder13write__objectGsE(_string_builder, expected);
      const _p$2 = "\"";
      _string_builder.val = `${_string_builder.val}${_p$2}`;
      return new _M0DTP37walkzzz9astrolabe4core11ParseResultGsE7Failure(_M0MP37walkzzz9astrolabe4core10ParseError2at(_tmp, _string_builder.val));
    } else {
      const actual = _M0MP37walkzzz9astrolabe4core5State5slice(state, state.offset, state.offset + len | 0);
      if (actual === expected) {
        _M0MP37walkzzz9astrolabe4core5State11advance__by(state, len);
        return new _M0DTP37walkzzz9astrolabe4core11ParseResultGsE7Success(expected, state);
      } else {
        const _tmp = state.pos;
        const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(8);
        const _p = "\"";
        _string_builder.val = `${_string_builder.val}${_p}`;
        _M0MPB13StringBuilder13write__objectGsE(_string_builder, expected);
        const _p$2 = "\"";
        _string_builder.val = `${_string_builder.val}${_p$2}`;
        return new _M0DTP37walkzzz9astrolabe4core11ParseResultGsE7Failure(_M0MP37walkzzz9astrolabe4core10ParseError2at(_tmp, _string_builder.val));
      }
    }
  });
}
function _M0FP37walkzzz9astrolabe4char11char__range(lo, hi) {
  const label_ = `char in [${_M0IPC14char4CharPB4Show10to__string(lo)}-${_M0IPC14char4CharPB4Show10to__string(hi)}]`;
  return _M0MP37walkzzz9astrolabe4core6Parser2ofGcE((state) => {
    _L: {
      const _bind = _M0MP37walkzzz9astrolabe4core5State4peek(state);
      if (_bind === -1) {
        break _L;
      } else {
        const _Some = _bind;
        const _ch = _Some;
        if (_ch >= lo && _ch <= hi) {
          _M0MP37walkzzz9astrolabe4core5State12advance__one(state);
          return new _M0DTP37walkzzz9astrolabe4core11ParseResultGcE7Success(_ch, state);
        } else {
          break _L;
        }
      }
    }
    return new _M0DTP37walkzzz9astrolabe4core11ParseResultGcE7Failure(_M0MP37walkzzz9astrolabe4core10ParseError2at(state.pos, label_));
  });
}
function _M0FP37walkzzz9astrolabe4char17take__while__step(pred, state) {
  while (true) {
    const _bind = _M0MP37walkzzz9astrolabe4core5State4peek(state);
    if (_bind === -1) {
      return;
    } else {
      const _Some = _bind;
      const _ch = _Some;
      if (pred(_ch)) {
        _M0MP37walkzzz9astrolabe4core5State12advance__one(state);
        continue;
      } else {
        return;
      }
    }
  }
}
function _M0FP37walkzzz9astrolabe4char11take__while(pred) {
  return _M0MP37walkzzz9astrolabe4core6Parser2ofGsE((state) => {
    const start = state.offset;
    _M0FP37walkzzz9astrolabe4char17take__while__step(pred, state);
    const result = _M0MP37walkzzz9astrolabe4core5State5slice(state, start, state.offset);
    return new _M0DTP37walkzzz9astrolabe4core11ParseResultGsE7Success(result, state);
  });
}
function _M0FP37walkzzz9astrolabe4char20take__while1_2einner(pred, label) {
  return _M0MP37walkzzz9astrolabe4core6Parser2ofGsE((state) => {
    _L: {
      const _bind = _M0MP37walkzzz9astrolabe4core5State4peek(state);
      if (_bind === -1) {
        break _L;
      } else {
        const _Some = _bind;
        const _ch = _Some;
        if (pred(_ch)) {
          const start = state.offset;
          _M0MP37walkzzz9astrolabe4core5State12advance__one(state);
          _M0FP37walkzzz9astrolabe4char17take__while__step(pred, state);
          const result = _M0MP37walkzzz9astrolabe4core5State5slice(state, start, state.offset);
          return new _M0DTP37walkzzz9astrolabe4core11ParseResultGsE7Success(result, state);
        } else {
          break _L;
        }
      }
    }
    return new _M0DTP37walkzzz9astrolabe4core11ParseResultGsE7Failure(_M0MP37walkzzz9astrolabe4core10ParseError2at(state.pos, label));
  });
}
function _M0FP37walkzzz9astrolabe8sequence3mapGssE(p, f) {
  return _M0MP37walkzzz9astrolabe4core6Parser2ofGsE((state) => {
    const _func = p.run;
    const _bind = _func(state);
    if (_bind.$tag === 0) {
      const _Success = _bind;
      const _value = _Success._0;
      const _st = _Success._1;
      return new _M0DTP37walkzzz9astrolabe4core11ParseResultGsE7Success(f(_value), _st);
    } else {
      const _Failure = _bind;
      const _err = _Failure._0;
      return new _M0DTP37walkzzz9astrolabe4core11ParseResultGsE7Failure(_err);
    }
  });
}
function _M0FP37walkzzz9astrolabe8sequence4bindGssE(p, f) {
  return _M0MP37walkzzz9astrolabe4core6Parser2ofGsE((state) => {
    const _func = p.run;
    const _bind = _func(state);
    if (_bind.$tag === 0) {
      const _Success = _bind;
      const _value = _Success._0;
      const _st = _Success._1;
      const next = f(_value);
      const _func$2 = next.run;
      const _bind$2 = _func$2(_st);
      if (_bind$2.$tag === 0) {
        const _Success$2 = _bind$2;
        const _result = _Success$2._0;
        const _st2 = _Success$2._1;
        return new _M0DTP37walkzzz9astrolabe4core11ParseResultGsE7Success(_result, _st2);
      } else {
        const _Failure = _bind$2;
        const _err = _Failure._0;
        return new _M0DTP37walkzzz9astrolabe4core11ParseResultGsE7Failure(_M0MP37walkzzz9astrolabe4core10ParseError6commit(_err));
      }
    } else {
      const _Failure = _bind;
      const _err = _Failure._0;
      return new _M0DTP37walkzzz9astrolabe4core11ParseResultGsE7Failure(_err);
    }
  });
}
function _M0FP37walkzzz9astrolabe8sequence13sep__by__stepGscE(p, sep, state, acc) {
  let _tmp = state;
  while (true) {
    const state$2 = _tmp;
    const _func = sep.run;
    const _bind = _func(state$2);
    if (_bind.$tag === 1) {
      return new _M0DTP37walkzzz9astrolabe4core11ParseResultGRPB5ArrayGsEE7Success(acc, state$2);
    } else {
      const _Success = _bind;
      const _st_sep = _Success._1;
      const _func$2 = p.run;
      const _bind$2 = _func$2(_st_sep);
      if (_bind$2.$tag === 1) {
        const _Failure = _bind$2;
        const _err = _Failure._0;
        return _M0MP37walkzzz9astrolabe4core10ParseError9committed(_err) ? new _M0DTP37walkzzz9astrolabe4core11ParseResultGRPB5ArrayGsEE7Failure(_err) : new _M0DTP37walkzzz9astrolabe4core11ParseResultGRPB5ArrayGsEE7Success(acc, state$2);
      } else {
        const _Success$2 = _bind$2;
        const _value = _Success$2._0;
        const _st_p = _Success$2._1;
        _M0MPC15array5Array4pushGsE(acc, _value);
        _tmp = _st_p;
        continue;
      }
    }
  }
}
function _M0FP37walkzzz9astrolabe8sequence7sep__byGscE(p, sep) {
  return _M0MP37walkzzz9astrolabe4core6Parser2ofGsE((state) => {
    const _func = p.run;
    const _bind = _func(state);
    if (_bind.$tag === 1) {
      const _Failure = _bind;
      const _err = _Failure._0;
      return _M0MP37walkzzz9astrolabe4core10ParseError9committed(_err) ? new _M0DTP37walkzzz9astrolabe4core11ParseResultGRPB5ArrayGsEE7Failure(_err) : new _M0DTP37walkzzz9astrolabe4core11ParseResultGRPB5ArrayGsEE7Success(new _M0TPB5ArrayGsE([], 0), state);
    } else {
      const _Success = _bind;
      const _first = _Success._0;
      const _st = _Success._1;
      return _M0FP37walkzzz9astrolabe8sequence13sep__by__stepGscE(p, sep, _st, new _M0TPB5ArrayGsE([_first], 1));
    }
  });
}
function _M0FP37walkzzz9astrolabe10playground11error__json(msg) {
  const _bind = [{ _0: "ok", _1: _M0MPC14json4Json4JsonGbE(false) }, { _0: "error", _1: _M0MPC14json4Json4JsonGsE(msg) }];
  const _p = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind, 0, 2), undefined);
  const j = new _M0DTPC14json4Json6Object(_p);
  return _M0MPC14json4Json17stringify_2einner(j, false, 0, undefined);
}
function _M0FP37walkzzz9astrolabe10playground9pos__json(pos) {
  const _p = pos.line + 0;
  const _p$2 = undefined;
  const _tmp = { _0: "line", _1: new _M0DTPC14json4Json6Number(_p, _p$2) };
  const _p$3 = pos.column + 0;
  const _p$4 = undefined;
  const _tmp$2 = { _0: "column", _1: new _M0DTPC14json4Json6Number(_p$3, _p$4) };
  const _p$5 = pos.offset + 0;
  const _p$6 = undefined;
  const _bind = [_tmp, _tmp$2, { _0: "offset", _1: new _M0DTPC14json4Json6Number(_p$5, _p$6) }, { _0: "label", _1: _M0MPC14json4Json4JsonGsE(_M0MP37walkzzz9astrolabe4core3Pos10to__string(pos)) }];
  const _p$7 = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind, 0, 4), undefined);
  return new _M0DTPC14json4Json6Object(_p$7);
}
function _M0FP37walkzzz9astrolabe10playground13error__detail(err, input) {
  const expected = new _M0TPB5ArrayGRPC14json4JsonE([], 0);
  const _bind = _M0MP37walkzzz9astrolabe4core10ParseError8expected(err);
  const _bind$2 = _bind.len;
  const _bind$3 = _bind.buf;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const item = _bind$3[_];
      _M0MPC15array5Array4pushGsE(expected, _M0MPC14json4Json4JsonGsE(item));
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const _bind$4 = [{ _0: "ok", _1: _M0MPC14json4Json4JsonGbE(false) }, { _0: "error", _1: _M0MPC14json4Json4JsonGsE(_M0MP37walkzzz9astrolabe4core10ParseError16expected__joined(err)) }, { _0: "pos", _1: _M0FP37walkzzz9astrolabe10playground9pos__json(_M0MP37walkzzz9astrolabe4core10ParseError3pos(err)) }, { _0: "expected", _1: new _M0DTPC14json4Json5Array(expected) }, { _0: "format", _1: _M0MPC14json4Json4JsonGsE(_M0MP37walkzzz9astrolabe4core10ParseError19format__with__input(err, input)) }];
  const _p = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind$4, 0, 5), undefined);
  return new _M0DTPC14json4Json6Object(_p);
}
function _M0FP37walkzzz9astrolabe10playground18astrolabe__version() {
  return "0.5.7";
}
function _M0FP37walkzzz9astrolabe10playground11parse__char(input, ch) {
  let c;
  if (ch.length === 1) {
    const _bind = _M0MPC16string6String9to__array(ch);
    if (0 >= _bind.len) {
      $panic();
    }
    c = _bind.buf[0];
  } else {
    return _M0FP37walkzzz9astrolabe10playground11error__json("ch must be exactly one character");
  }
  const _bind = _M0MP37walkzzz9astrolabe4core6Parser13parse__prefixGcE(_M0FP37walkzzz9astrolabe4char4char(c), input);
  if (_bind.$tag === 1) {
    const _Ok = _bind;
    const _pair = _Ok._0;
    const _tmp = { _0: "ok", _1: _M0MPC14json4Json4JsonGbE(true) };
    const _tmp$2 = { _0: "value", _1: _M0MPC14json4Json4JsonGsE(_M0IPC14char4CharPB4Show10to__string(_pair._0)) };
    const _p = undefined;
    const _bind$2 = [_tmp, _tmp$2, { _0: "consumed", _1: new _M0DTPC14json4Json6Number(1, _p) }, { _0: "rest", _1: _M0MPC14json4Json4JsonGsE(_pair._1) }];
    const _p$2 = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind$2, 0, 4), undefined);
    const j = new _M0DTPC14json4Json6Object(_p$2);
    return _M0MPC14json4Json17stringify_2einner(j, false, 0, undefined);
  } else {
    const _Err = _bind;
    const _err = _Err._0;
    return _M0MPC14json4Json17stringify_2einner(_M0FP37walkzzz9astrolabe10playground13error__detail(_err, input), false, 0, undefined);
  }
}
function _M0FP37walkzzz9astrolabe10playground13parse__string(input, lit) {
  if (lit.length === 0) {
    return _M0FP37walkzzz9astrolabe10playground11error__json("literal must not be empty");
  }
  const _bind = _M0MP37walkzzz9astrolabe4core6Parser13parse__prefixGsE(_M0FP37walkzzz9astrolabe4char6string(lit), input);
  if (_bind.$tag === 1) {
    const _Ok = _bind;
    const _pair = _Ok._0;
    const _tmp = { _0: "ok", _1: _M0MPC14json4Json4JsonGbE(true) };
    const _tmp$2 = { _0: "value", _1: _M0MPC14json4Json4JsonGsE(_pair._0) };
    const _p = lit.length + 0;
    const _p$2 = undefined;
    const _bind$2 = [_tmp, _tmp$2, { _0: "consumed", _1: new _M0DTPC14json4Json6Number(_p, _p$2) }, { _0: "rest", _1: _M0MPC14json4Json4JsonGsE(_pair._1) }];
    const _p$3 = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind$2, 0, 4), undefined);
    const j = new _M0DTPC14json4Json6Object(_p$3);
    return _M0MPC14json4Json17stringify_2einner(j, false, 0, undefined);
  } else {
    const _Err = _bind;
    const _err = _Err._0;
    return _M0MPC14json4Json17stringify_2einner(_M0FP37walkzzz9astrolabe10playground13error__detail(_err, input), false, 0, undefined);
  }
}
function _M0FP37walkzzz9astrolabe10playground12parse__range(input, lo, hi) {
  let lo_c;
  if (lo.length === 1) {
    const _bind = _M0MPC16string6String9to__array(lo);
    if (0 >= _bind.len) {
      $panic();
    }
    lo_c = _bind.buf[0];
  } else {
    return _M0FP37walkzzz9astrolabe10playground11error__json("lo must be exactly one character");
  }
  let hi_c;
  if (hi.length === 1) {
    const _bind = _M0MPC16string6String9to__array(hi);
    if (0 >= _bind.len) {
      $panic();
    }
    hi_c = _bind.buf[0];
  } else {
    return _M0FP37walkzzz9astrolabe10playground11error__json("hi must be exactly one character");
  }
  if (lo_c > hi_c) {
    return _M0FP37walkzzz9astrolabe10playground11error__json("lo must be <= hi");
  }
  const _bind = _M0MP37walkzzz9astrolabe4core6Parser13parse__prefixGcE(_M0FP37walkzzz9astrolabe4char11char__range(lo_c, hi_c), input);
  if (_bind.$tag === 1) {
    const _Ok = _bind;
    const _pair = _Ok._0;
    const _bind$2 = [{ _0: "ok", _1: _M0MPC14json4Json4JsonGbE(true) }, { _0: "value", _1: _M0MPC14json4Json4JsonGsE(_M0IPC14char4CharPB4Show10to__string(_pair._0)) }, { _0: "rest", _1: _M0MPC14json4Json4JsonGsE(_pair._1) }];
    const _p = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind$2, 0, 3), undefined);
    const j = new _M0DTPC14json4Json6Object(_p);
    return _M0MPC14json4Json17stringify_2einner(j, false, 0, undefined);
  } else {
    const _Err = _bind;
    const _err = _Err._0;
    return _M0MPC14json4Json17stringify_2einner(_M0FP37walkzzz9astrolabe10playground13error__detail(_err, input), false, 0, undefined);
  }
}
function _M0FP37walkzzz9astrolabe10playground17parse__identifierN4headS876(c) {
  return c >= 97 && c <= 122 || (c >= 65 && c <= 90 || c === 95);
}
function _M0FP37walkzzz9astrolabe10playground17parse__identifierN4tailS877(c) {
  return c >= 97 && c <= 122 || (c >= 65 && c <= 90 || (c >= 48 && c <= 57 || c === 95));
}
function _M0FP37walkzzz9astrolabe10playground17parse__identifier(input) {
  const parser = _M0FP37walkzzz9astrolabe8sequence4bindGssE(_M0FP37walkzzz9astrolabe4char20take__while1_2einner(_M0FP37walkzzz9astrolabe10playground17parse__identifierN4headS876, "identifier start"), (first) => _M0FP37walkzzz9astrolabe8sequence3mapGssE(_M0FP37walkzzz9astrolabe4char11take__while(_M0FP37walkzzz9astrolabe10playground17parse__identifierN4tailS877), (rest) => `${first}${rest}`));
  const _bind = _M0MP37walkzzz9astrolabe4core6Parser11parse__fullGsE(parser, input);
  if (_bind.$tag === 1) {
    const _Ok = _bind;
    const _value = _Ok._0;
    const _tmp = { _0: "ok", _1: _M0MPC14json4Json4JsonGbE(true) };
    const _tmp$2 = { _0: "value", _1: _M0MPC14json4Json4JsonGsE(_value) };
    const _p = _value.length + 0;
    const _p$2 = undefined;
    const _bind$2 = [_tmp, _tmp$2, { _0: "length", _1: new _M0DTPC14json4Json6Number(_p, _p$2) }];
    const _p$3 = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind$2, 0, 3), undefined);
    const j = new _M0DTPC14json4Json6Object(_p$3);
    return _M0MPC14json4Json17stringify_2einner(j, false, 0, undefined);
  } else {
    const _Err = _bind;
    const _err = _Err._0;
    return _M0MPC14json4Json17stringify_2einner(_M0FP37walkzzz9astrolabe10playground13error__detail(_err, input), false, 0, undefined);
  }
}
function _M0FP37walkzzz9astrolabe10playground10parse__intN5digitS891(c) {
  return c >= 48 && c <= 57;
}
function _M0FP37walkzzz9astrolabe10playground10parse__int(input) {
  const _bind = _M0MP37walkzzz9astrolabe4core6Parser11parse__fullGsE(_M0FP37walkzzz9astrolabe4char20take__while1_2einner(_M0FP37walkzzz9astrolabe10playground10parse__intN5digitS891, "digit"), input);
  if (_bind.$tag === 1) {
    const _Ok = _bind;
    const _text = _Ok._0;
    let value = 0n;
    const _bind$2 = _text.length;
    let _tmp = 0;
    while (true) {
      const _string_index = _tmp;
      if (_string_index < _bind$2) {
        let _decoded_next_string_index;
        let _decoded_char;
        _L: {
          const _bind$3 = _text.charCodeAt(_string_index);
          if (_bind$3 >= 55296 && _bind$3 <= 56319 && (_string_index + 1 | 0) < _bind$2) {
            const _bind$4 = _text.charCodeAt(_string_index + 1 | 0);
            if (_bind$4 >= 56320 && _bind$4 <= 57343) {
              const _tmp$2 = _string_index + 2 | 0;
              const _p = (((Math.imul(_bind$3 - 55296 | 0, 1024) | 0) + _bind$4 | 0) - 56320 | 0) + 65536 | 0;
              _decoded_next_string_index = _tmp$2;
              _decoded_char = _p;
              break _L;
            } else {
              const _tmp$2 = _string_index + 1 | 0;
              const _p = _bind$3;
              _decoded_next_string_index = _tmp$2;
              _decoded_char = _p;
              break _L;
            }
          } else {
            const _tmp$2 = _string_index + 1 | 0;
            const _p = _bind$3;
            _decoded_next_string_index = _tmp$2;
            _decoded_char = _p;
            break _L;
          }
        }
        value = BigInt.asUintN(64, BigInt.asUintN(64, value * 10n) + BigInt.asUintN(64, BigInt.asUintN(64, BigInt(_decoded_char)) - 48n));
        if (BigInt.asIntN(64, value) > BigInt.asIntN(64, 2147483647n)) {
          return _M0FP37walkzzz9astrolabe10playground11error__json("integer exceeds int32 range");
        }
        _tmp = _decoded_next_string_index;
        continue;
      } else {
        break;
      }
    }
    const _tmp$2 = { _0: "ok", _1: _M0MPC14json4Json4JsonGbE(true) };
    const _p = $f64_convert_i64(BigInt.asIntN(64, value));
    const _p$2 = undefined;
    const _tmp$3 = { _0: "value", _1: new _M0DTPC14json4Json6Number(_p, _p$2) };
    const _p$3 = _text.length + 0;
    const _p$4 = undefined;
    const _bind$3 = [_tmp$2, _tmp$3, { _0: "digits", _1: new _M0DTPC14json4Json6Number(_p$3, _p$4) }];
    const _p$5 = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind$3, 0, 3), undefined);
    const j = new _M0DTPC14json4Json6Object(_p$5);
    return _M0MPC14json4Json17stringify_2einner(j, false, 0, undefined);
  } else {
    const _Err = _bind;
    const _err = _Err._0;
    return _M0MPC14json4Json17stringify_2einner(_M0FP37walkzzz9astrolabe10playground13error__detail(_err, input), false, 0, undefined);
  }
}
function _M0FP37walkzzz9astrolabe10playground10parse__csvN11ident__charS910(c) {
  return c >= 97 && c <= 122 || (c >= 65 && c <= 90 || (c >= 48 && c <= 57 || (c === 95 || (c === 45 || c === 46))));
}
function _M0FP37walkzzz9astrolabe10playground10parse__csv(input) {
  const item = _M0FP37walkzzz9astrolabe4char20take__while1_2einner(_M0FP37walkzzz9astrolabe10playground10parse__csvN11ident__charS910, "csv item");
  const parser = _M0FP37walkzzz9astrolabe8sequence7sep__byGscE(item, _M0FP37walkzzz9astrolabe4char4char(44));
  const _bind = _M0MP37walkzzz9astrolabe4core6Parser11parse__fullGsE(parser, input);
  if (_bind.$tag === 1) {
    const _Ok = _bind;
    const _items = _Ok._0;
    const out = new _M0TPB5ArrayGRPC14json4JsonE([], 0);
    const _bind$2 = _items.len;
    const _bind$3 = _items.buf;
    let _tmp = 0;
    while (true) {
      const _ = _tmp;
      if (_ < _bind$2) {
        const item_text = _bind$3[_];
        _M0MPC15array5Array4pushGsE(out, _M0MPC14json4Json4JsonGsE(item_text));
        _tmp = _ + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    const _tmp$2 = { _0: "ok", _1: _M0MPC14json4Json4JsonGbE(true) };
    const _p = _items.len + 0;
    const _p$2 = undefined;
    const _bind$4 = [_tmp$2, { _0: "count", _1: new _M0DTPC14json4Json6Number(_p, _p$2) }, { _0: "items", _1: new _M0DTPC14json4Json5Array(out) }];
    const _p$3 = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind$4, 0, 3), undefined);
    const j = new _M0DTPC14json4Json6Object(_p$3);
    return _M0MPC14json4Json17stringify_2einner(j, false, 0, undefined);
  } else {
    const _Err = _bind;
    const _err = _Err._0;
    return _M0MPC14json4Json17stringify_2einner(_M0FP37walkzzz9astrolabe10playground13error__detail(_err, input), false, 0, undefined);
  }
}
function _M0FP37walkzzz9astrolabe10playground18parse__modes__demo(input, lit) {
  if (lit.length === 0) {
    return _M0FP37walkzzz9astrolabe10playground11error__json("literal must not be empty");
  }
  const parser = _M0FP37walkzzz9astrolabe4char6string(lit);
  const _bind = _M0MP37walkzzz9astrolabe4core6Parser5parseGsE(parser, input);
  let partial;
  if (_bind.$tag === 1) {
    const _Ok = _bind;
    const _value = _Ok._0;
    const _bind$2 = [{ _0: "ok", _1: _M0MPC14json4Json4JsonGbE(true) }, { _0: "value", _1: _M0MPC14json4Json4JsonGsE(_value) }];
    partial = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind$2, 0, 2), undefined);
  } else {
    const _Err = _bind;
    const _err = _Err._0;
    const _bind$2 = [{ _0: "ok", _1: _M0MPC14json4Json4JsonGbE(false) }, { _0: "error", _1: _M0MPC14json4Json4JsonGsE(_M0MP37walkzzz9astrolabe4core10ParseError16expected__joined(_err)) }];
    partial = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind$2, 0, 2), undefined);
  }
  const _bind$2 = _M0MP37walkzzz9astrolabe4core6Parser13parse__prefixGsE(parser, input);
  let prefixed;
  if (_bind$2.$tag === 1) {
    const _Ok = _bind$2;
    const _pair = _Ok._0;
    const _bind$3 = [{ _0: "ok", _1: _M0MPC14json4Json4JsonGbE(true) }, { _0: "value", _1: _M0MPC14json4Json4JsonGsE(_pair._0) }, { _0: "rest", _1: _M0MPC14json4Json4JsonGsE(_pair._1) }];
    prefixed = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind$3, 0, 3), undefined);
  } else {
    const _Err = _bind$2;
    const _err = _Err._0;
    const _bind$3 = [{ _0: "ok", _1: _M0MPC14json4Json4JsonGbE(false) }, { _0: "error", _1: _M0MPC14json4Json4JsonGsE(_M0MP37walkzzz9astrolabe4core10ParseError16expected__joined(_err)) }];
    prefixed = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind$3, 0, 2), undefined);
  }
  const _bind$3 = _M0MP37walkzzz9astrolabe4core6Parser11parse__fullGsE(parser, input);
  let full;
  if (_bind$3.$tag === 1) {
    const _Ok = _bind$3;
    const _value = _Ok._0;
    const _bind$4 = [{ _0: "ok", _1: _M0MPC14json4Json4JsonGbE(true) }, { _0: "value", _1: _M0MPC14json4Json4JsonGsE(_value) }];
    full = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind$4, 0, 2), undefined);
  } else {
    const _Err = _bind$3;
    const _err = _Err._0;
    const _bind$4 = [{ _0: "ok", _1: _M0MPC14json4Json4JsonGbE(false) }, { _0: "error", _1: _M0MPC14json4Json4JsonGsE(_M0MP37walkzzz9astrolabe4core10ParseError16expected__joined(_err)) }, { _0: "pos", _1: _M0FP37walkzzz9astrolabe10playground9pos__json(_M0MP37walkzzz9astrolabe4core10ParseError3pos(_err)) }];
    full = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind$4, 0, 3), undefined);
  }
  const _bind$4 = [{ _0: "ok", _1: _M0MPC14json4Json4JsonGbE(true) }, { _0: "parse", _1: _M0IPB3MapPC14json6ToJson8to__jsonGsRPC14json4JsonE(partial) }, { _0: "parse_prefix", _1: _M0IPB3MapPC14json6ToJson8to__jsonGsRPC14json4JsonE(prefixed) }, { _0: "parse_full", _1: _M0IPB3MapPC14json6ToJson8to__jsonGsRPC14json4JsonE(full) }];
  const _p = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind$4, 0, 4), undefined);
  const j = new _M0DTPC14json4Json6Object(_p);
  return _M0MPC14json4Json17stringify_2einner(j, false, 0, undefined);
}
function _M0FP37walkzzz9astrolabe10playground11error__demo(input, lit) {
  if (lit.length === 0) {
    return _M0FP37walkzzz9astrolabe10playground11error__json("literal must not be empty");
  }
  const _bind = _M0MP37walkzzz9astrolabe4core6Parser11parse__fullGsE(_M0FP37walkzzz9astrolabe4char6string(lit), input);
  if (_bind.$tag === 1) {
    const _bind$2 = [{ _0: "ok", _1: _M0MPC14json4Json4JsonGbE(true) }, { _0: "matched", _1: _M0MPC14json4Json4JsonGbE(true) }];
    const _p = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind$2, 0, 2), undefined);
    const j = new _M0DTPC14json4Json6Object(_p);
    return _M0MPC14json4Json17stringify_2einner(j, false, 0, undefined);
  } else {
    const _Err = _bind;
    const _err = _Err._0;
    return _M0MPC14json4Json17stringify_2einner(_M0FP37walkzzz9astrolabe10playground13error__detail(_err, input), false, 0, undefined);
  }
}
function _M0FP37walkzzz9astrolabe10playground15commit__vs__alt(input) {
  const backtracking = _M0FP37walkzzz9astrolabe6branch3altGsE(_M0FP37walkzzz9astrolabe4char6string("ab"), _M0FP37walkzzz9astrolabe4char6string("ac"));
  const committed = _M0FP37walkzzz9astrolabe6branch3altGsE(_M0FP37walkzzz9astrolabe6branch6commitGsE(_M0FP37walkzzz9astrolabe4char6string("ab")), _M0FP37walkzzz9astrolabe4char6string("ac"));
  const _bind = _M0MP37walkzzz9astrolabe4core6Parser11parse__fullGsE(backtracking, input);
  let plain;
  if (_bind.$tag === 1) {
    const _Ok = _bind;
    const _value = _Ok._0;
    const _bind$2 = [{ _0: "ok", _1: _M0MPC14json4Json4JsonGbE(true) }, { _0: "value", _1: _M0MPC14json4Json4JsonGsE(_value) }];
    plain = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind$2, 0, 2), undefined);
  } else {
    const _Err = _bind;
    const _err = _Err._0;
    const _bind$2 = [{ _0: "ok", _1: _M0MPC14json4Json4JsonGbE(false) }, { _0: "error", _1: _M0MPC14json4Json4JsonGsE(_M0MP37walkzzz9astrolabe4core10ParseError16expected__joined(_err)) }];
    plain = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind$2, 0, 2), undefined);
  }
  const _bind$2 = _M0MP37walkzzz9astrolabe4core6Parser11parse__fullGsE(committed, input);
  let strict;
  if (_bind$2.$tag === 1) {
    const _Ok = _bind$2;
    const _value = _Ok._0;
    const _bind$3 = [{ _0: "ok", _1: _M0MPC14json4Json4JsonGbE(true) }, { _0: "value", _1: _M0MPC14json4Json4JsonGsE(_value) }];
    strict = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind$3, 0, 2), undefined);
  } else {
    const _Err = _bind$2;
    const _err = _Err._0;
    const _bind$3 = [{ _0: "ok", _1: _M0MPC14json4Json4JsonGbE(false) }, { _0: "error", _1: _M0MPC14json4Json4JsonGsE(_M0MP37walkzzz9astrolabe4core10ParseError16expected__joined(_err)) }, { _0: "committed", _1: _M0MPC14json4Json4JsonGbE(_M0MP37walkzzz9astrolabe4core10ParseError9committed(_err)) }, { _0: "pos", _1: _M0FP37walkzzz9astrolabe10playground9pos__json(_M0MP37walkzzz9astrolabe4core10ParseError3pos(_err)) }];
    strict = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind$3, 0, 4), undefined);
  }
  const _bind$3 = [{ _0: "ok", _1: _M0MPC14json4Json4JsonGbE(true) }, { _0: "alt", _1: _M0IPB3MapPC14json6ToJson8to__jsonGsRPC14json4JsonE(plain) }, { _0: "commit", _1: _M0IPB3MapPC14json6ToJson8to__jsonGsRPC14json4JsonE(strict) }];
  const _p = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind$3, 0, 3), undefined);
  const j = new _M0DTPC14json4Json6Object(_p);
  return _M0MPC14json4Json17stringify_2einner(j, false, 0, undefined);
}
function _M0FP37walkzzz9astrolabe10playground10pos__track(input) {
  const steps = new _M0TPB5ArrayGRPC14json4JsonE([], 0);
  const parser = _M0MP37walkzzz9astrolabe4core6Parser2ofGsE((st) => {
    while (true) {
      const _bind = _M0MP37walkzzz9astrolabe4core5State4peek(st);
      if (_bind === -1) {
        break;
      } else {
        const _Some = _bind;
        const _ch = _Some;
        const _tmp = { _0: "char", _1: _M0MPC14json4Json4JsonGsE(_M0IPC14char4CharPB4Show10to__string(_ch)) };
        const _p = st.pos.line + 0;
        const _p$2 = undefined;
        const _tmp$2 = { _0: "line", _1: new _M0DTPC14json4Json6Number(_p, _p$2) };
        const _p$3 = st.pos.column + 0;
        const _p$4 = undefined;
        const _tmp$3 = { _0: "column", _1: new _M0DTPC14json4Json6Number(_p$3, _p$4) };
        const _p$5 = st.pos.offset + 0;
        const _p$6 = undefined;
        const _bind$2 = [_tmp, _tmp$2, _tmp$3, { _0: "offset", _1: new _M0DTPC14json4Json6Number(_p$5, _p$6) }];
        const _p$7 = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind$2, 0, 4), undefined);
        _M0MPC15array5Array4pushGsE(steps, new _M0DTPC14json4Json6Object(_p$7));
        _M0MP37walkzzz9astrolabe4core5State12advance__one(st);
      }
      continue;
    }
    return new _M0DTP37walkzzz9astrolabe4core11ParseResultGRPB5ArrayGRPC14json4JsonEE7Success(steps, st);
  });
  const _bind = _M0MP37walkzzz9astrolabe4core6Parser11parse__fullGsE(parser, input);
  if (_bind.$tag === 1) {
    const _Ok = _bind;
    const _items = _Ok._0;
    const _tmp = { _0: "ok", _1: _M0MPC14json4Json4JsonGbE(true) };
    const _p = _items.len + 0;
    const _p$2 = undefined;
    const _bind$2 = [_tmp, { _0: "count", _1: new _M0DTPC14json4Json6Number(_p, _p$2) }, { _0: "steps", _1: new _M0DTPC14json4Json5Array(_items) }];
    const _p$3 = _M0MPB3Map3MapGsRPC14json4JsonE(new _M0TPB9ArrayViewGUsRPC14json4JsonEE(_bind$2, 0, 3), undefined);
    const j = new _M0DTPC14json4Json6Object(_p$3);
    return _M0MPC14json4Json17stringify_2einner(j, false, 0, undefined);
  } else {
    const _Err = _bind;
    const _err = _Err._0;
    return _M0MPC14json4Json17stringify_2einner(_M0FP37walkzzz9astrolabe10playground13error__detail(_err, input), false, 0, undefined);
  }
}
export { _M0FP37walkzzz9astrolabe10playground18astrolabe__version as astrolabe_version, _M0FP37walkzzz9astrolabe10playground11parse__char as parse_char, _M0FP37walkzzz9astrolabe10playground13parse__string as parse_string, _M0FP37walkzzz9astrolabe10playground12parse__range as parse_range, _M0FP37walkzzz9astrolabe10playground17parse__identifier as parse_identifier, _M0FP37walkzzz9astrolabe10playground10parse__int as parse_int, _M0FP37walkzzz9astrolabe10playground10parse__csv as parse_csv, _M0FP37walkzzz9astrolabe10playground18parse__modes__demo as parse_modes_demo, _M0FP37walkzzz9astrolabe10playground11error__demo as error_demo, _M0FP37walkzzz9astrolabe10playground15commit__vs__alt as commit_vs_alt, _M0FP37walkzzz9astrolabe10playground10pos__track as pos_track }
