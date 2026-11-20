#!/usr/bin/env node
// 覆盖率门槛 — 解析 full_summary，排除 benchmarks/examples/cmd/proof，对库口径设硬门槛。
// Coverage gate: parse full_summary, exclude benchmarks/examples/cmd/proof,
// and enforce thresholds on library code.
//
// 用法：node scripts/check_coverage.mjs [--skip-test]
// 门槛：core（库代码，不含 examples/benchmarks）>= 90%；总库口径 >= 85%

import { spawnSync } from 'node:child_process';
import { readFileSync, writeFileSync, unlinkSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';

const ROOT = fileURLToPath(new URL('..', import.meta.url));
const SUMMARY = join(ROOT, 'coverage_summary.txt');

const CORE_MIN = 90.0;
const LIB_MIN = 85.0;

function run(cmd) {
  const r = spawnSync(cmd, {
    shell: true,
    encoding: 'utf8',
    maxBuffer: 64 * 1024 * 1024,
    cwd: ROOT,
  });
  if (r.status !== 0) {
    console.error(`命令失败: ${cmd}\n${r.stderr ?? ''}`);
    process.exit(1);
  }
  return r.stdout ?? '';
}

if (!process.argv.includes('--skip-test')) {
  console.log('[1/2] moon test --enable-coverage --target native');
  run('moon test --enable-coverage --target native');
}

console.log('[2/2] moon coverage report -f full_summary');
const summary = run('moon coverage report -f full_summary');
writeFileSync(SUMMARY, summary, 'utf8');

let core = 0;
let coreTotal = 0;
let lib = 0;
let libTotal = 0;
const rows = [];
for (const line of summary.split(/\r?\n/)) {
  const m = line.match(/^(.+\.mbt): (\d+)\/(\d+)$/);
  if (!m) continue;
  const file = m[1];
  const low = file.toLowerCase();
  const c = Number(m[2]);
  const t = Number(m[3]);
  if (low.includes('benchmarks') || low.includes('examples') || low.includes('cmd') || low.includes('proof')) {
    continue;
  }
  core += c;
  coreTotal += t;
  lib += c;
  libTotal += t;
  rows.push(`${file} ${c}/${t} ${((c * 100) / t).toFixed(1)}%`);
}

const pct = (a, b) => (b === 0 ? 100 : (a * 100) / b);
const corePct = pct(core, coreTotal);
const libPct = pct(lib, libTotal);

for (const r of rows) console.log('  ' + r);
console.log(`core: ${core}/${coreTotal} = ${corePct.toFixed(1)}% (threshold ${CORE_MIN}%)`);
console.log(`library: ${lib}/${libTotal} = ${libPct.toFixed(1)}% (threshold ${LIB_MIN}%)`);

if (existsSync(SUMMARY)) unlinkSync(SUMMARY);

if (corePct < CORE_MIN) {
  console.error('FAIL: core coverage below threshold');
  process.exit(1);
}
if (libPct < LIB_MIN) {
  console.error('FAIL: library coverage below threshold');
  process.exit(1);
}
console.log('PASS: coverage gate satisfied');