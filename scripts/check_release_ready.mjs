#!/usr/bin/env node
// check_release_ready.mjs — 发布前门禁一条命令跑完（对应 docs/release.md §3 清单）
//
// 用法：
//   node scripts/check_release_ready.mjs              # 全量（含慢项，约 8-12 分钟）
//   node scripts/check_release_ready.mjs --skip-slow  # 只跑快项（约 1 分钟）
//   node scripts/check_release_ready.mjs --json       # 机读输出
//
// 每条都是真跑、不读历史结论。任一条失败 → 退出码 1 并打印该步输出尾部。
// 发布顺序不靠记忆：本脚本绿了，再按 docs/release.md §4 执行 scripts/publish.ps1。

import { spawnSync } from 'node:child_process';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const skipSlow = process.argv.includes('--skip-slow');
const asJson = process.argv.includes('--json');
const ink = (s) => process.stdout.write(s);

const steps = [
  { id: 'version', what: '9 个版本引用点一致（moon.mod/CHANGELOG/README/页面/playground/AGENTS/两份文档标题）', cmd: ['node', 'scripts/check_version.mjs'], slow: false },
  { id: 'docs', what: '文档真值断言（A1–A7：版本/测试数/死链/覆盖率/评估口径）', cmd: ['node', 'scripts/check_docs.mjs'], slow: false },
  { id: 'pages_numbers', what: '页面/徽章/评估数字 = docs/coverage.json', cmd: ['node', 'scripts/sync_pages.mjs', '--check'], slow: false },
  { id: 'fmt', what: 'moon fmt --check', cmd: ['moon', 'fmt', '--check'], slow: false },
  { id: 'check', what: 'moon check --deny-warn --target all（四目标零警告）', cmd: ['moon', 'check', '--deny-warn', '--target', 'all'], slow: true },
  { id: 'test', what: 'moon test --target native（239）', cmd: ['moon', 'test', '--target', 'native'], slow: true },
  { id: 'coverage', what: '覆盖率门槛 core ≥ 90%（读已有 trace，不重跑测试）', cmd: ['node', 'scripts/check_coverage.mjs', '--skip-test'], slow: true },
  { id: 'mutation', what: '变异 12/12 KILLED', cmd: ['node', 'scripts/mutation_test.mjs'], slow: true },
  { id: 'pages', what: '页面门禁（结构 + 11 导出语义，构建 playground js）', cmd: ['node', 'scripts/check_pages.mjs'], slow: true },
];

function runStep(step) {
  const started = Date.now();
  const r = spawnSync(step.cmd[0], step.cmd.slice(1), {
    cwd: root,
    encoding: 'utf8',
    maxBuffer: 64 * 1024 * 1024,
    shell: process.platform === 'win32' && step.cmd[0] !== 'node',
  });
  const ms = Date.now() - started;
  const out = `${r.stdout ?? ''}${r.stderr ?? ''}`;
  const ok = r.status === 0;
  return { id: step.id, ok, ms, tail: ok ? '' : out.trim().split('\n').slice(-12).join('\n') };
}

const results = [];
for (const step of steps) {
  if (skipSlow && step.slow) {
    results.push({ id: step.id, ok: true, skipped: '--skip-slow', ms: 0 });
    continue;
  }
  if (!asJson) ink(`… ${step.id.padEnd(14)} ${step.what}\n`);
  const r = runStep(step);
  results.push(r);
  if (!asJson) {
    const tag = r.skipped ? 'skip' : r.ok ? 'ok  ' : 'FAIL';
    ink(`  ${tag} ${step.id}  ${(r.ms / 1000).toFixed(1)}s${r.skipped ? `  (${r.skipped})` : ''}\n`);
    if (!r.ok && r.tail) ink(`${r.tail}\n`);
  }
}

const failed = results.filter((r) => !r.ok);
const skipped = results.filter((r) => r.skipped);
const report = {
  schema: 'release-ready@1',
  ok: failed.length === 0,
  ran: results.length - skipped.length,
  skipped: skipped.map((r) => `${r.id}: ${r.skipped}`),
  failed: failed.map((r) => r.id),
  seconds: Math.round(results.reduce((a, r) => a + r.ms, 0) / 1000),
};
if (asJson) {
  console.log(JSON.stringify(report, null, 2));
} else {
  ink(
    `\n=== release-ready: ${report.ok ? 'PASS' : `FAIL (${failed.length})`} · ${report.ran} 项执行` +
      `${skipped.length ? ` · ${skipped.length} 项跳过` : ''} · ${report.seconds}s ===\n`,
  );
}
if (!report.ok) process.exit(1);
