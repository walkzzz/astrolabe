#!/usr/bin/env node
// sync_pages.mjs — 页面 / 徽章 / 评估文档的数字必须等于 docs/coverage.json 真值
//
// 为什么需要它：astrolabe 的测试数、覆盖率、变异点数在 4 个地方重复出现
// （README 徽章、docs/index.html 三处、docs/assessment.md），历史上已出现
// 页面写 92.9% 而 README 写 93.1%、徽章写 10/10 而实测 12/12 的漂移。
// docs/coverage.json 是真值，本脚本保证其它位置没有偏离。
//
// 用法：
//   node scripts/sync_pages.mjs --check     # 只校验（CI / release-ready 用）
//   node scripts/sync_pages.mjs --json      # 机读输出
// 退出码：全一致 0；任一偏离 1。

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';

const ROOT = fileURLToPath(new URL('..', import.meta.url));
const asJson = process.argv.includes('--json');

const truth = JSON.parse(readFileSync(join(ROOT, 'docs/coverage.json'), 'utf8'));
const read = (rel) => readFileSync(join(ROOT, rel), 'utf8');

const tests = truth.tests.per_backend;
const backends = truth.tests.backends;
const pct = truth.coverage.percent;
const covered = truth.coverage.covered;
const total = truth.coverage.total;
const killed = truth.mutation.killed;
const mutTotal = truth.mutation.total;

const checks = [
  // README 徽章
  { id: 'README coverage badge', file: 'README.md', expect: `coverage-${pct}%25` },
  { id: 'README tests badge', file: 'README.md', expect: `tests-${tests}%20%C3%97%20${backends}%20backends` },
  // 页面
  { id: 'page 覆盖百分', file: 'docs/index.html', expect: `覆盖 ${pct}%` },
  { id: 'page stat 测试', file: 'docs/index.html', expect: `${tests} × ${backends}` },
  { id: 'page stat 覆盖百分', file: 'docs/index.html', expect: `<strong>${pct}%</strong>` },
  { id: 'page 覆盖率分数', file: 'docs/index.html', expect: `${covered}/${total}` },
  { id: 'page 变异', file: 'docs/index.html', expect: `${killed} / ${mutTotal}` },
  // 评估文档
  { id: 'assessment 覆盖百分', file: 'docs/assessment.md', expect: `${pct}%` },
  { id: 'assessment 覆盖率分数', file: 'docs/assessment.md', expect: `${covered}/${total}` },
];

const results = checks.map((c) => ({ ...c, ok: read(c.file).includes(c.expect) }));
const failed = results.filter((r) => !r.ok);

if (asJson) {
  console.log(
    JSON.stringify(
      {
        schema: 'pages-numbers@1',
        ok: failed.length === 0,
        truth: { tests: `${tests}x${backends}`, coverage: `${covered}/${total}=${pct}%`, mutation: `${killed}/${mutTotal}` },
        failed: failed.map((r) => `${r.id}: 缺 "${r.expect}"`),
        passed: results.length - failed.length,
        total: results.length,
      },
      null,
      2,
    ),
  );
} else {
  for (const r of results) {
    console.log(`${r.ok ? 'PASS' : 'FAIL'}  ${r.id}  (${r.expect})`);
  }
  console.log(
    `\n=== pages numbers: ${failed.length === 0 ? 'PASS' : `FAIL (${failed.length})`} · ${results.length - failed.length}/${results.length} ===`,
  );
}
if (failed.length > 0) process.exit(1);
