#!/usr/bin/env node
// bump_version.mjs — 一次改完 astrolabe 全部版本引用点
//
// 用法：
//   node scripts/bump_version.mjs --to 0.5.7                # 改 9 处 + 在 CHANGELOG 顶部补条目骨架
//   node scripts/bump_version.mjs --to 0.5.7 --dry-run      # 只打印将改什么，不落盘
//
// 与 check_version.mjs 共用同一份 VERSION_POINTS，保证「能查的地方就能一次改完」。
// CHANGELOG 已有该版本条目时只改其余 8 处，不重复插入。
// 退出码：成功 0；版本格式非法 / 不大于当前版本 1。

import { readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { VERSION_POINTS } from './version_points.mjs';

const ROOT = path.resolve(import.meta.dirname, '..');
const readText = (rel) => readFile(path.join(ROOT, rel), 'utf8');
const writeText = (rel, text) => writeFile(path.join(ROOT, rel), text, 'utf8');

const args = process.argv.slice(2);
const toIdx = args.indexOf('--to');
const target = toIdx >= 0 ? args[toIdx + 1] : '';
const dryRun = args.includes('--dry-run');

if (!/^\d+\.\d+\.\d+$/.test(target ?? '')) {
  console.error('用法: node scripts/bump_version.mjs --to <x.y.z> [--dry-run]');
  process.exit(1);
}

const current = (await readText('moon.mod')).match(/^version = "([\d.]+)"/m)?.[1];
const cmp = (a, b) => {
  const pa = a.split('.').map(Number);
  const pb = b.split('.').map(Number);
  for (let i = 0; i < 3; i++) {
    if (pa[i] !== pb[i]) return pa[i] - pb[i];
  }
  return 0;
};
if (cmp(target, current) <= 0) {
  console.error(`新版本 ${target} 必须大于当前 ${current}`);
  process.exit(1);
}

const date = new Date().toISOString().slice(0, 10);
const changed = [];

for (const p of VERSION_POINTS) {
  if (p.id === 'CHANGELOG latest') continue; // 由下方单独插入条目处理
  const text = await readText(p.file);
  const m = text.match(p.re);
  if (!m) {
    console.error(`未找到 ${p.id}（${p.file}）的版本引用，请先修 check_version 的规则`);
    process.exit(1);
  }
  const next = text.replace(p.re, (whole, ver) => whole.replace(ver, target));
  if (next === text) {
    changed.push({ point: p.id, file: p.file, from: m[1], to: target, note: 'already' });
    continue;
  }
  if (!dryRun) await writeText(p.file, next);
  changed.push({ point: p.id, file: p.file, from: m[1], to: target });
}

const cl = await readText('CHANGELOG.md');
const hasEntry = new RegExp(`^## \\[${target.replace(/\./g, '\\.')}\\] - `, 'm').test(cl);
if (!hasEntry) {
  const body = cl.replace(
    /(All notable changes to this project will be documented in this file\.\n\n)/,
    `$1## [${target}] - ${date}\n\n### Changed\n\n- （待填写）\n\n`,
  );
  if (body !== cl) {
    if (!dryRun) await writeText('CHANGELOG.md', body);
    changed.push({ point: 'CHANGELOG new entry', file: 'CHANGELOG.md', from: '-', to: target });
  }
} else {
  changed.push({ point: 'CHANGELOG new entry', file: 'CHANGELOG.md', from: '-', to: target, note: 'already' });
}

console.log(
  JSON.stringify(
    { schema: 'version-bump@1', ok: true, dryRun, from: current, to: target, date, changed },
    null,
    2,
  ),
);
