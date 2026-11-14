# 陷阱目录（pitfall-catalog）

> 准入标准（借鉴 flutter-ohos-expert-agent）：**只收"复现过并修好"的条目**，来源标【实测】并附编译器错误码 / 复现命令；报告不许写「预计可行」「理论上支持」。
> 编号分段：`M*` = MoonBit 语法演进（跨项目通用）· `S*` = astrolabe 解析器语义（本项目特有）。同号不复用。

---

## M 系列 · MoonBit 语法演进（moon 0.1.20261104 实测）

### M1 `try?` 语法已移除

- **现象**：`match try? f() { ... }` 编译失败。
- **判别**：编译器直接提示 `try? has been removed. Replace 'try? expr' with 'try Ok(expr) catch { e => Err(e) }'`。
- **修法**：
  ```moonbit
  let r : Result[T, E] = try { Ok(f()) } catch { e => Err(e) }
  ```
- **来源**：【实测】examples/ini 编译错误（ini_to_json_string 重构时）。
- **可自动化**：✅ 编译器已给出替换建议。

### M2 `inspect!` 宏已移除，且 `inspect` 的 Show 版本已弃用

- **现象**：`inspect!(expr, content=)` 解析错 `unexpected f!(..)`；改为 `inspect(expr, content=)` 后对 `Result` 类型触发 `[0020] deprecated: Use Debug instead of Show for debugging purposes`（note 指向 `moonbitlang/core/builtin/show.mbt:357` 的 Result Show impl）。
- **根因**：moonbitlang/core 将 `Result` 的 `Show` 弃用——调试场景全面转向 `Debug`（`debug_inspect`）。
- **判别**：inspect 快照断言在 CI `--deny-warn` 下变红。
- **修法**：测试断言改用 `T raise E` 风格 API + `to_string()` / 插值断言；或实现 `Debug` 后用 `debug_inspect`。README 展示性代码改 `match + println` 风格。
- **来源**：【实测】examples/ini/experiment_show.mbt 对照实验（编译错误 3002 + 4018 双实锤）。
- **可自动化**：✅（CI --deny-warn 即红）。

### M3 命名参数传值语法是 `label=`，不是 `label~=`

- **现象**：`take_while1(pred, label~="INI key")` 编译错 `[3016] The syntax 'label~=..' is invalid, the correct syntax is 'label=..'`。
- **判别**：3016 错误码。
- **修法**：`label="INI key"`。
- **来源**：【实测】examples/ini pair_line。
- **可自动化**：✅。

### M4 `not(expr)` 已弃用

- **现象**：`[0020] deprecated: Use !expr instead`（--deny-warn 下为错误）。
- **修法**：`!started`。
- **来源**：【实测】examples/ini build_ini_doc。
- **可自动化**：✅。

### M5 `StringBuilder::new()` 已弃用

- **现象**：`[0020] deprecated: Use 'StringBuilder()' instead`。
- **修法**：`let buf : StringBuilder = StringBuilder()`。
- **来源**：【实测】examples/ini json_escape_string。
- **可自动化**：✅。

### M6 MoonBit trait 不支持类型参数（类型类方案不可行）

- **现象**：`pub trait ParserLike[A] { ... }` 编译错 `[3002] unexpected '[', you may expect '{'`；impl 处 `ParserLike[T] for Parser[T]` 同样 `unexpected '['`。
- **根因**：MoonBit trait 无类型参数化能力——无法表达"实现类型与结果类型分离"的抽象（`Parser[T]` 的 run 返回 `ParseResult[T]`，T 不在 Self 中）。
- **修法**：函数式扩展点——裸函数 `(State) -> ParseResult[A]` 直接作组合子参数（与 `Parser::of` 同一扩展点）；见 `core/parser_like.mbt` 设计说明。
- **来源**：【实测】v0.5.0 ParserLike 类型类方案被编译器推翻，重写为函数式（见 git 历史）。
- **可自动化**：❌ 设计约束，需人工识别（详见 memory：astrolabe v0.5.0 设计）。

### M7 `Char` 的 Show 输出无引号

- **现象**：inspect 快照 `content="Ok('a')"` 失败，diff 显示实际 `Ok(a)`。
- **根因**：`Char` 的 Show 输出裸字符（不带单引号）。
- **判别**：moon test 快照 diff（`-Ok('a')` / `+Ok(a)`）。
- **修法**：快照断言以实测为准（`content="Ok(a)"`）；或用 `moon test --update` 自动对齐。
- **来源**：【实测】README 快速开始示例断言。
- **可自动化**：✅。

### M8 `impl Show` 的隐式方法提升已弃用（implicit promotion）

- **现象**：`[0079] implicit_impl_as_method: The methods output from 'impl Show for X' are implicit promoted... deprecated`（--deny-warn 下为错误）。
- **判别**：0079 错误码，警告点名 `output` 方法。
- **修法**：显式 `pub extend X with Show::{output, to_string}`（补 output 与 to_string 两个方法）。
- **来源**：【实测】image core/types LoadError 实现 Show 时触发（0079）。
- **可自动化**：✅。

### M9 `Result` 的 Show 已弃用——failable API 推荐 `T raise E`

- **现象**：`[0078] result_error_return: Prefer 'T raise E' for failable APIs. Return 'Result[T, E]' only when success/failure must be represented as ordinary data`（--deny-warn 下为错误）；M2 的 inspect deprecated 同源（Result Show 弃用）。
- **判别**：0078 错误码 + inspect deprecated 警告（M2）。
- **修法**：API 签名改 `-> T raise E`（内部 `match ... { Ok(v) => v; Err(e) => raise e }`）；测试断言改 `to_string()` / 插值。
- **来源**：【实测】examples/ini parse_ini / ini_to_json_string 签名重构。
- **可自动化**：✅。

---

## S 系列 · astrolabe 解析器语义（本项目特有）

### S1 序列承诺传染：可选前缀消费后的失败会"承诺化"，导致 `many` 无法退出

- **现象**：INI 解析器 `pair_line = seq3(seq3(ws, take_while1(key), ws), '=', value)`——行首空白被 `ws` 消费后 `take_while1` 失败，错误 `committed=true`；`many(ini_line())` 收到承诺失败直接传播，顶层 `parse_full` 整体失败（而非在行边界优雅停止）。
- **复现**：输入 `"  k1  =  v1  \n"`（行首空格）→ `moon test` 报顶层失败。
- **根因**：`seq`/`seq3`/`bind` 的序列承诺语义（README 承诺表：第 N（N>1）个解析器失败 → committed=true）——**这是正确语义，不是 bug**；错在文法把"可选前缀"放进了承诺域。
- **判别**：`e.committed() == true` 且失败点在可选前缀处。
- **修法**：`peek` 首字符分派（无承诺歧义）+ 行首空白移出承诺域；见 `examples/ini/ini.mbt` 的 `ini_line()`（`Parser::of` 手写分派 + 组合子子解析器混合风格）。
- **来源**：【实测】moon test 193/195 → 修复后 196/196 全绿（git 历史可查）。
- **可自动化**：✅ 负向测试（行首空格用例）。

### S2 `label` 会抹掉 `alt` 的多候选聚合

- **现象**：`label(alt(alt(a,b), alt(c,d)), "INI line...")` 失败时 `expected()` 只剩 `["INI line..."]` 单候选——v0.4.0 错误聚合的多候选诊断被 label 的"替换错误信息"语义覆盖。
- **复现**：对照实验——带 label 版测试断言 `expected().length() >= 2` 失败（`false is not true`）；去掉 label 后错误变为 `expected '[' or INI key`（聚合生效）。
- **根因**：`label` 的设计语义就是替换 expected。
- **判别**：错误 expected 为单候选且文本等于 label。
- **修法**：label 放在**分支内部**（对单个组合子），不要包住聚合性 alt；或不用 label。
- **来源**：【实测】对照实验（去 label 前后 moon test 输出对比）。
- **可自动化**：✅（expected 长度断言）。

### S3 `take_while` 消费会推进状态——错误位置在 furthest 处而非起点

- **现象**：`ini_line().parse("[unclosed")` 的错误 `pos().offset == 9`（`'['` 之后 take_while 消费 "unclosed"，`]` 在 offset 9 处缺失），直觉断言 `offset == 0` 失败（`9 != 0`）。
- **根因**：`take_while` 消费推进 `state`（无 save-restore），错误 `ParseError::at(pos=state.pos)` 记录消费后位置——这正是 v0.4.0 furthest-position 聚合语义的设计（指到真正缺失处）。
- **判别**：断言值 = 输入前缀长度。
- **修法**：测试断言与 furthest 语义对齐（`offset == 9` 是**更好的诊断**，不要改回起点）。
- **来源**：【实测】ini 测试 `9 != 0` 失败 → 断言修正。
- **可自动化**：✅。

### S4 facade 是显式列表——core 新增 pub fn 不会自动进根包门面

- **现象**：core 新增 `pmap/pbind/palt/poption` 后，根包 `@astrolabe.pmap` 报 `[4021] not found`。
- **根因**：`astrolabe.mbt` 的 `pub using @core { ... }` 是显式函数/类型列表。
- **修法**：facade 块手动追加函数名。
- **来源**：【实测】v0.5.0 parser_like 落地时。
- **可自动化**：❌（CI 的 `moon info` + mbti 漂移校验可提示——已进 ci.yml）。

### S5 组合子分包前缀：`@core.take_while` 报 4021 not found

- **现象**：`Value take_while not found in package core`（4021）。
- **根因**：组合子分散三包——`char`（char/string/take_while/take_while1/end_of_input）、`sequence`（map/bind/seq2/seq3/many/option/between）、`branch`（alt/label/commit/choice/attempt/recover）；core 只含类型与四入口方法。
- **判别**：4021 + mooncakes API 表的分包归属（docs/api.md）。
- **修法**：按分包前缀调用（`@char.take_while` / `@sequence.seq2` / `@branch.alt`）。
- **来源**：【实测】examples/ini 4021 错误群。
- **可自动化**：❌（文档化：docs/api.md 已按包组织）。

### S6 `parse_full` 是 `Parser` 方法，不是 core 顶层函数

- **现象**：`@core.parse_full(p, input)` 报 4021 not found。
- **根因**：四入口（parse/parse_full/parse_raise/parse_full_raise）是 `Parser` 的方法（mooncakes API 表 "p.parse_full(input)"）。
- **修法**：`p.parse_full(input)` 方法调用。
- **来源**：【实测】examples/ini parse_ini 重构。
- **可自动化**：✅（编译器）。

### S7 `many`/`many1` 零消耗匹配 = 无限循环；防护的比较必须用运行前快照

- **现象**：`many(p)` 中 `p` 零消耗成功（如 `pure` 包装、`option(default)` 零宽回退）→ 尾递归 `many_step(p, st, acc)` 在同位置无限递归 → 请求挂起。
- **防护实现陷阱**：`State` 是 mut 引用，`p.run(state)` **原地推进**——防护比较写成 `st.offset == state.offset` 时，`st` 与 `state` 是同一对象，**恒为 true**，反而把每次成功匹配都误判为零消耗（回归期 http 的 many1 用例全红）。
- **修法**：在 `p.run` **之前**取 `let before = state.offset` 快照，运行后比较 `st.offset == before`——before 是 Int 值，不受原地推进影响。
- **判别**：防护未生效时零消耗用例挂起；防护误伤时全部 many 用例失败。
- **来源**：【实测】v0.5.2 many 防护（初版错误 → 快照修正 → 198×4 全绿 + 正反向防护测试）。
- **可自动化**：✅ 正反向测试（examples/ini ini_wbtest）。

### M10 组合子链的类型错误 FAQ（4014 泛型约束报错判别）

- **现象**：组合子链构建期的 `[4014] Expr Type Mismatch` 报错晦涩（`has type : X, wanted : Y` 不直接指到根因）。
- **常见模式与判别**：
  1. **map/bind 的闭包返回类型与后续期望不符**：检查 lambda 的返回类型注解；
  2. **alt 两分支类型不统一**：`alt(p1 : Parser[A], p2 : Parser[B])` 要求 A == B，分支结果类型必须收敛；
  3. **`Parser::of` 闭包返回的 `Success(value, state)` 中 value 类型与 `Parser[T]` 的 T 不一致**；
  4. **`take_while1(pred, label=...)` 的 pred 必须是 `(Char) -> Bool`**，lambda 参数缺类型注解时推断失败；
  5. **`p.parse(input)` 与 `(p.run)(state)` 混用**：parse 吃 `String`、run 吃 `State`——传错即 4014（本仓库实测：ini_wbtest 的 `p.parse(s)` 误用）。
- **修法**：给 lambda 显式类型注解；把复杂组合子链拆为带类型注解的中间 `let`；按 4014 的 note 定位期望类型。
- **来源**：【实测】examples/ini / examples/http 组合子链构建期 + ini_wbtest 的 parse/run 混用（2026-11-13）。
- **可自动化**：❌（依赖 IDE 类型提示；moon check 的 4014 note 提供定位）。

---

## 维护规则（照 flutter-ohos-expert 准入流程）

1. 新条目只收"复现过并修好"的，附编译器错误码或测试红绿证据，标【实测】。
2. 编号从各段最大号往后接（M* / S*），不跨段复用。
3. M 系列与 image/docs/pitfall-catalog.md 的 M 系列同源（两项目各自收录）；S/I 系列项目特有。
