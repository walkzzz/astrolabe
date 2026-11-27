# 发布流程（astrolabe）

> 单模块单包发布（一个根 `moon.mod`，子包随根模块一并上传），因此没有 image.mbt 那种"11 环顺序发布"的问题；
> 但"每步 update、按输出判定、升版不漏改"这三条教训是通用的。

## 1. 真值文件

| 内容 | 唯一真值 | 谁在守 |
|---|---|---|
| 版本号 | `moon.mod` 的 `version` | `scripts/check_version.mjs`（9 个引用点） |
| 测试数 / 覆盖率 / 变异 | `docs/coverage.json` | `scripts/sync_pages.mjs --check`（README 徽章 / 页面 / assessment） |
| 覆盖率门槛 | `scripts/check_coverage.mjs`（core ≥ 90%，库口径 ≥ 85%） | 同上 |
| 文档断言 | `scripts/check_docs.mjs`（A1–A7） | 同上 |

改数字先改 `docs/coverage.json`，再跑 `node scripts/sync_pages.mjs --check` 找出所有漂移点。

## 2. 升版

```sh
node scripts/check_version.mjs                 # 先看当前是否一致
node scripts/bump_version.mjs --to 0.5.7       # 一次改 9 处 + CHANGELOG 补条目骨架
node scripts/check_version.mjs                 # 复验
```

`bump_version.mjs` 与 `check_version.mjs` 共用 `scripts/version_points.mjs` 的同一份清单，
所以"能查的地方一定能一次改完"。CHANGELOG 条目骨架生成后需手工补 `### Changed` 内容。

不要手工改版本号：9 个引用点里有一处在 `playground/playground.mbt` 的源码常量
（`astrolabe_version()`，页面用它显示版本），漏改会让页面与 mooncakes 版本对不上，
且 `check_pages.mjs` 的导出断言会直接失败。

## 3. 发布前门禁

```sh
node scripts/check_release_ready.mjs --skip-slow   # 快跑（约 1 分钟，日常用）
node scripts/check_release_ready.mjs               # 全量（含 check/test/coverage/mutation/pages，发布前必跑）
```

全量清单（9 项）：version / docs / pages_numbers / fmt / check（四目标零警告）/
test（native 239）/ coverage（core ≥ 90%）/ mutation（12/12 KILLED）/ pages（结构 + 11 导出语义）。

任一项红则不得发布。CI 的 8 个 job 与本清单同源，但 CI 不替代本地全量：CI 的 coverage
只在 push 后跑，本地先跑能省一轮红灯。

## 4. 发布

```powershell
.\scripts\publish.ps1            # update -> dry-run -> publish
.\scripts\publish.ps1 -DryOnly   # 只验证打包与依赖解析
```

成功判据：`Server status: 200 OK`（正式）、`202 Accepted`（dry-run）。出现 `Error:` 行即失败。

## 5. 发布后验证

```sh
moon update && moon search "walkzzz/astrolabe"     # 不 update 会看到旧版本
```

某版本若在 registry 上长时间不出现，先 `moon update` 再查，不要重发（重复版本号会 409）。

另外核对 mooncakes 元数据（license / supported-targets / 构建状态）：

```sh
curl https://mooncakes.io/api/v0/modules/walkzzz/astrolabe
```

返回里 `build_status` 从 `queued` 走到 `success` 才算真正上架可下载。

CI：push 后等 8 个 job 全绿；Pages job 会同步部署 `docs/`。
若 quality job 红在 `check_pages` 的版本断言，说明 `docs/index.html` 的
`brand-ver` 或 `moon add ...@x.y.z` 没跟着 `bump_version.mjs` 走。

## 6. 实测踩过的坑（2026-11-27）

1. **`moon publish` 的退出码不可信**：image.mbt 侧实测出现过"exit 0 但 registry 仍是旧版本"，
   所以判据只用输出文本里的 `Server status`。`publish.ps1` 已按此实现。
2. **发布前必须 `moon update`**：否则索引陈旧，dry-run 会拿旧依赖解析（本仓无外部依赖，
   风险低于 image.mbt 的 11 环，但仍保留这一步以保证与 registry 一致）。
3. **PowerShell 5.1 的两个坑**：无 BOM 的 UTF-8 脚本会被按 ANSI 解析（本脚本因此保持纯 ASCII）；
   `& moon ... 2>&1 | Out-String` 会打印 `NativeCommandError` 噪音，而
   `$ErrorActionPreference='SilentlyContinue'` 会把 stderr 文本整个丢掉 —— 改为经 `cmd.exe`
   重定向到临时文件再读回 UTF-8，同时拿到完整文本与真实退出码。

## 7. 失败分类

| 现象 | 原因 | 处置 |
|---|---|---|
| dry-run 报 `Failed to resolve ...` | registry 索引陈旧 / 依赖未发布 | `moon update` 后重跑 |
| dry-run 报 `moon check` 失败 | 打包后的代码在新环境编译不过 | 本地 `moon check --deny-warn --target all` 复现 |
| `Server status: 409` | 该版本号已存在 | 升版后重发，不要复用版本号 |
| 上架后 `build_status: failed` | registry 侧构建失败 | 看 mooncakes 构建日志，本地用 `moon add walkzzz/astrolabe@x.y.z` 复现 |
