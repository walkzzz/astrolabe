#!/usr/bin/env node
// check_docs.mjs — 文档数字一致性自检（最小闭环 · flutter-ohos-expert 思想 ②⑥③）
//
// 为什么需要它：badge/文档的数字全部手抄，已发生过三次漂移（badge 147→190、
// image 6526→6574、proof 5→8）。断言化根治：任何一处手抄漂移，本脚本变红。
//
// 用法：node scripts/check_docs.mjs [--self-test]
// 退出码：全绿 0；任一断言失败 1。
// 三口径：①没跑过≠通过 ②分母不猜 ③每条断言的 evidence 可第三方复算（文件路径+取值）。

import { readFile, writeFile, mkdir, rm } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const ROOT = path.resolve(import.meta.dirname, '..');

// ---- 提取器（每条带 evidence：读到的原文片段） ----
function cap(re, text, file, what) {
  const m = text.match(re);
  if (!m) throw new Error(`${what}: not found in ${file}`);
  return { value: m[1], evidence: { file, pattern: String(re), matched: m[0] } };
}

async function read(rel, root) {
  return readFile(path.join(root, rel), 'utf8');
}

function extractVersion(text) {
  const m = text.match(/^version = "([^"]+)"/m);
  if (!m) throw new Error('version not found in moon.mod');
  return m[1];
}

// ---- 断言集（id/desc/run：throw 即失败，返回即通过并携带 evidence） ----
const ASSERTIONS = [
  {
    id: 'A1', desc: 'moon.mod version == README mooncakes badge version',
    async run(root) {
      const mod = extractVersion(await read('moon.mod', root));
      const readme = await read('README.md', root);
      const badge = cap(/mooncakes-([\d.]+)-orange/, readme, 'README.md', 'mooncakes badge').value;
      if (mod !== badge) throw new Error(`moon.mod=${mod} != README badge=${badge}`);
      return { moon_mod: mod, readme_badge: badge };
    },
  },
  {
    id: 'A2', desc: 'CHANGELOG 最新条目 == moon.mod version',
    async run(root) {
      const mod = extractVersion(await read('moon.mod', root));
      const cl = await read('CHANGELOG.md', root);
      const latest = cap(/^## \[([^\]]+)\]/m, cl, 'CHANGELOG.md', 'latest entry').value;
      if (mod !== latest) throw new Error(`CHANGELOG latest=${latest} != moon.mod=${mod}`);
      return { moon_mod: mod, changelog_latest: latest };
    },
  },
  {
    id: 'A3', desc: 'README badge 测试数 == AGENTS.md 元数据测试数（防手抄漂移）',
    async run(root) {
      const readme = await read('README.md', root);
      const agents = await read('AGENTS.md', root);
      const badge = cap(/tests-([\d_]+)/, readme, 'README.md', 'tests badge').value.replace(/_/g, '');
      const agentsN = cap(/(\d+) 测试 × 4 后端/, agents, 'AGENTS.md', 'agents tests').value;
      if (badge !== agentsN) throw new Error(`README badge=${badge} != AGENTS.md=${agentsN}`);
      return { readme_badge: badge, agents: agentsN };
    },
  },
  {
    id: 'A4', desc: 'README 文档表引用的 docs/*.md 全部存在（防死链）',
    async run(root) {
      const readme = await read('README.md', root);
      const links = [...readme.matchAll(/\]\((docs\/[\w.-]+\.md)\)/g)].map(m => m[1]);
      const missing = links.filter(f => !existsSync(path.join(root, f)));
      if (missing.length) throw new Error(`missing docs: ${missing.join(', ')}`);
      return { checked: links.length, files: links };
    },
  },
];

// ---- 主流程 ----
async function runAssertions(root) {
  const results = [];
  for (const a of ASSERTIONS) {
    try {
      const evidence = await a.run(root);
      results.push({ id: a.id, desc: a.desc, ok: true, evidence });
    } catch (e) {
      results.push({ id: a.id, desc: a.desc, ok: false, fail: String(e.message) });
    }
  }
  const failed = results.filter(r => !r.ok).length;
  return { schema: 'check_docs@1', root, total: results.length, failed, results };
}

// ---- 负向自测（思想③：每条断言配"本应被拒绝"的 fixture，断言必须触发红） ----
async function selfTest() {
  const tmp = path.join(os.tmpdir(), `checkdocs-selftest-${Date.now()}`);
  await mkdir(path.join(tmp, 'docs'), { recursive: true });
  const out = [];
  const assertThrows = async (id, fixture, expectId) => {
    const r = await runAssertions(fixture);
    const hit = r.results.find(x => x.id === expectId);
    if (!hit || hit.ok !== false) throw new Error(`${id}: expected assertion ${expectId} to FAIL on fixture, but it passed`);
    out.push(`${id}: OK (${expectId} correctly failed: ${String(hit.fail).slice(0, 60)})`);
  };
  try {
    // fixture：版本不一致（moon.mod=0.9.9 vs badge=0.5.0）
    await writeFile(path.join(tmp, 'moon.mod'), 'name = "walkzzz/astrolabe"\n\nversion = "0.9.9"\n\nlicense = "MIT"\n');
    await writeFile(path.join(tmp, 'README.md'),
      '[![mooncakes.io](https://img.shields.io/badge/mooncakes-0.5.0-orange)](x)\n\n' +
      '[![tests](https://img.shields.io/badge/tests-190×4-green)]()\n\n' +
      '| [文档](docs/api.md) | x |\n');
    await writeFile(path.join(tmp, 'CHANGELOG.md'), '## [0.5.0] - 2026-11-13\n');
    await writeFile(path.join(tmp, 'AGENTS.md'), '196 测试 × 4 后端全绿\n');
    await mkdir(path.join(tmp, 'docs'), { recursive: true });
    await writeFile(path.join(tmp, 'docs', 'api.md'), '# api\n');
    await assertThrows('ST1', tmp, 'A1'); // 版本不一致 → A1 必须红
    await assertThrows('ST2', tmp, 'A2'); // CHANGELOG 0.5.0 != moon.mod 0.9.9 → A2 必须红

    // fixture：badge 测试数漂移（190 vs AGENTS 196）→ A3 必须红（本仓库曾真实发生的漂移类型）
    await writeFile(path.join(tmp, 'moon.mod'), 'name = "walkzzz/astrolabe"\n\nversion = "0.5.0"\n');
    await assertThrows('ST3', tmp, 'A3');

    // 正向：一致 fixture → A2 必须绿
    await writeFile(path.join(tmp, 'moon.mod'), 'name = "walkzzz/astrolabe"\n\nversion = "0.5.0"\n');
    const okRun = await runAssertions(tmp);
    const a2 = okRun.results.find(x => x.id === 'A2');
    if (!a2 || !a2.ok) throw new Error('ST4: expected A2 to PASS on consistent fixture');
    out.push('ST4: OK (A2 passed on consistent fixture)');

    // 负向：文档死链 → A4 必须红
    await writeFile(path.join(tmp, 'README.md'),
      '[![mooncakes.io](https://img.shields.io/badge/mooncakes-0.5.0-orange)](x)\n\n' +
      '[![tests](https://img.shields.io/badge/tests-190×4-green)]()\n\n' +
      '| [坏链](docs/ghost.md) | x |\n');
    await writeFile(path.join(tmp, 'AGENTS.md'), '190 测试 × 4 后端全绿\n');
    await assertThrows('ST5', tmp, 'A4');
  } finally {
    await rm(tmp, { recursive: true, force: true });
  }
  return { schema: 'check_docs-selftest@1', assertions: out };
}

// ---- 入口 ----
const selftest = process.argv.includes('--self-test');
if (selftest) {
  const r = await selfTest().catch(e => { console.error(String(e.message)); process.exit(1); });
  console.log(JSON.stringify({ ok: true, ...r }, null, 2));
  process.exit(0);
} else {
  const r = await runAssertions(ROOT);
  console.log(JSON.stringify(r, null, 2));
  process.exit(r.failed === 0 ? 0 : 1);
}
