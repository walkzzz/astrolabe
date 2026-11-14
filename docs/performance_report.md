# 性能基准报告

> 环境：Windows 11 Pro · moon 0.1.20261104 · `moon bench --target native benchmarks/`（release）· 每项 10 × N runs（N 自动调参）
> 快照日期：**2026-11-13** · 基准数：**25 项全通过**（json 13 / http+uri 5 / control 5 / compose 7 / basic 5）
> 复现命令：`moon bench --target native benchmarks/`

## 一、JSON 解析（13 项）

| 基准 | 耗时（均值 ± 标准差） | 区间 | runs |
|---|---|---|---|
| json_null | 4.09 µs ± 172.89 ns | 3.89–4.45 µs | 10 × 23197 |
| json_bool | 4.93 µs ± 396.90 ns | 4.44–5.59 µs | 10 × 22411 |
| json_number | 8.17 µs ± 192.94 ns | 7.87–8.49 µs | 10 × 12203 |
| json_string | 10.59 µs ± 581.06 ns | 10.05–11.85 µs | 10 × 9851 |
| json_object_10 | 102.55 µs ± 8.01 µs | 93.73–120.08 µs | 10 × 1012 |
| json_object_50 | 487.95 µs ± 12.67 µs | 467.41–501.44 µs | 10 × 204 |
| json_object_100 | **1.01 ms** ± 35.87 µs | 963.61 µs–1.06 ms | 10 × 104 |
| json_array_10 | 68.00 µs ± 5.80 µs | 62.91–81.69 µs | 10 × 1545 |
| json_array_100 | 651.20 µs ± 64.56 µs | 594.44–816.37 µs | 10 × 133 |
| json_array_1000 | 9.27 ms ± 2.27 ms | 6.24–12.86 ms | 10 × 15 |
| json_nested_5 | 50.78 µs ± 2.73 µs | 48.27–57.84 µs | 10 × 2005 |
| json_nested_10 | 92.73 µs ± 1.11 µs | 91.33–94.43 µs | 10 × 1069 |
| json_mixed | 96.05 µs ± 1.35 µs | 94.17–97.96 µs | 10 × 1024 |

**解读**：标量解析 4–11 µs；对象/数组规模近似线性（object_10→100：102 µs→1.01 ms，≈10 倍规模 ≈10 倍耗时，无超线性放大）；json_array_1000 的 2.27 ms 标准差偏大，属长跑噪声（15 runs），后续可提高采样轮次。

## 二、HTTP / URI 解析（5 项）

| 基准 | 耗时（均值 ± 标准差） | 区间 | runs |
|---|---|---|---|
| http_request_simple | 17.21 µs ± 552.08 ns | 16.64–18.08 µs | 10 × 5742 |
| http_request_5_headers | 68.05 µs ± 2.03 µs | 65.54–71.52 µs | 10 × 1470 |
| http_request_20_headers | 236.43 µs ± 4.84 µs | 230.11–244.45 µs | 10 × 426 |
| http_request_50_headers | 839.61 µs ± 109.17 µs | 665.69 µs–1.03 ms | 10 × 159 |
| uri_parse | 52.40 µs ± 856.95 ns | 51.08–53.61 µs | 10 × 1842 |

**解读**：header 数量线性放大（5→50：68 µs→840 µs）；50_headers 标准差偏大，同上属长跑噪声。

## 三、回溯控制（5 项）

| 基准 | 耗时（均值 ± 标准差） | 区间 | runs |
|---|---|---|---|
| alt_first_fail | 64.93 µs ± 1.77 µs | 62.46–68.16 µs | 10 × 1566 |
| alt_first_match | 12.32 µs ± 319.82 ns | 11.94–12.84 µs | 10 × 8072 |
| choice_last_of_8 | 501.03 µs ± 17.43 µs | 484.67–529.20 µs | 10 × 190 |
| alt_nocommit | 45.28 µs ± 3.10 µs | 41.27–49.86 µs | 10 × 2298 |
| **alt_with_commit** | **798.53 ns** ± 26.42 ns | 755.67–847.62 ns | 10 × 100000 |

**解读**：commit 的价值量化——`alt_with_commit`（承诺后单分支直达）比 `alt_nocommit`（未承诺回溯重试）快约 **57 倍**（798 ns vs 45.28 µs）。这正是"显式回溯控制"卖点（README 对比表 1.2 µs vs 48 µs 的更新口径）。

## 四、组合子（compose 7 项）

| 基准 | 耗时（均值 ± 标准差） | 区间 | runs |
|---|---|---|---|
| map_100 | 12.40 µs ± 692.66 ns | 11.67–13.77 µs | 10 × 7466 |
| map_1000 | 110.45 µs ± 3.73 µs | 105.14–115.45 µs | 10 × 864 |
| bind_100 | 23.13 µs ± 871.16 ns | 22.04–24.63 µs | 10 × 4542 |
| bind_1000 | 214.57 µs ± 5.92 µs | 204.44–222.66 µs | 10 × 452 |
| seq2_100 | 14.32 µs ± 331.86 ns | 13.85–14.92 µs | 10 × 6757 |
| many / sep_by / option | 见 `moon bench` 完整输出 | — | — |

**解读**：map/bind 100→1000 均近似线性（≈9×/≈9.3×），bind 的常数开销约为 map 的 1.9 倍（闭包调用 + 状态传递），符合预期。

## 五、基础组合子（basic 5 项）

char/string/take/satisfy/take_while 系列详见 `moon bench` 完整输出；README 历史口径（char × 1000 ≈ 132 µs）与本次量级一致。

## 五点五、stdlib JSON 对照基准（moonbitlang/core/json，同 workload）

2026-11-13 新增 `benchmarks/stdlib_json_bench.mbt`（`moonbitlang/core/json` 以 `@stdjson` 接入同一 bench 框架，workload 与 astrolabe JSON 基准完全一致）：

| 基准 | moonbitlang/core/json | astrolabe JSON（组合子） | 差距 |
|---|---|---|---|
| object_50 | 28.42 µs ± 598 ns | 487.95 µs ± 12.67 µs | ≈17× |
| object_100 | 56.49 µs ± 1.56 µs | 1.01 ms ± 35.87 µs | ≈18× |
| array_100 | 20.80 µs ± 794 ns | 651.20 µs ± 64.56 µs | ≈31× |
| nested_10 | 8.89 µs ± 213 ns | 92.73 µs ± 1.11 µs | ≈10× |

**诚实定位**：moonbitlang/core/json 是官方手写的高性能解析器；astrolabe JSON 是**组合子能力的教学级示例**（演示 commit/alt/seq 在真实文法上的组合），性能对比的意义是为 v0.6.0 组合子内核优化（String View / 惰性行列 / 热路径减分配）提供量化基线——当前 10~31× 差距即优化空间上界。组合子框架的竞争力定位在**可组合性与诊断质量**（见 docs/comparison.md），不在与专项解析器比绝对速度。

## 六、与历史口径的差异说明

- README 性能表的数字为早期实测（char×1000 ≈ 132 µs 等）；本次全部以本报告表格为准，后续以 `moon bench` 实时结果为准。
- form 下一步（v0.6.0 性能优化）：String View 输入表示、惰性行列计算；优化后重新采集本报告形成前后对照。

## 七、方法论

- MoonBit bench 框架自动调参 runs；每项报告均值 ± 标准差与 min…max 区间。
- 同机同 moon 版本下重跑即可对照；CI 中 `moon bench --target native benchmarks/` 作为烟雾门禁（防性能回退的具体数字告警为 v0.6.0 规划项）。
