#!/usr/bin/env node
// check_version.mjs — astrolabe 版本一致性门禁
//
// 校验 9 个版本引用点全部等于 moon.mod 的 version：
//   moon.mod / CHANGELOG 最新条目 / README mooncakes badge /
//   docs/index.html 品牌版本与安装命令 / playground astrolabe_version /
//   AGENTS.md / docs/architecture.md 标题 / docs/security.md 标题
//
// 为什么需要它：astrolabe 的版本号散落在 9 处（含一处硬编码在 playground 源码里），
// 升版本漏改任一处都会让页面、文档与 registry 口径互相矛盾。脚本是唯一真值来源。
//
// 用法：node scripts/check_version.mjs
// 退出码：一致 0；任一不一致 1（并打印不一致清单）。

import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { VERSION_POINTS } from './version_points.mjs';

const ROOT = path.resolve(import.meta.dirname, '..');
const readText = (rel) => readFile(path.join(ROOT, rel), 'utf8');

function cap(re, text, file, what) {
  const m = text.match(re);
  if (!m) throw new Error(`${what}: not found in ${file}`);
  return m[1];
}

const versions = {};
for (const p of VERSION_POINTS) {
  versions[p.id] = cap(p.re, await readText(p.file), p.file, p.what);
}

const unique = [...new Set(Object.values(versions))];
if (unique.length !== 1) {
  const diff = Object.entries(versions)
    .filter(([, v]) => v !== unique[0])
    .map(([k, v]) => `${k}=${v}`);
  console.error(
    JSON.stringify({ schema: 'version-gate@1', ok: false, versions, mismatched: diff }, null, 2),
  );
  console.error(`版本不一致: ${unique.join(', ')} → 修正: node scripts/bump_version.mjs --to <x.y.z>`);
  process.exit(1);
}
console.log(
  JSON.stringify(
    { schema: 'version-gate@1', ok: true, version: unique[0], checked: Object.keys(versions).length },
    null,
    2,
  ),
);
