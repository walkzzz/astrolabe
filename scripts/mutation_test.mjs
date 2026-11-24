#!/usr/bin/env node
// 变异测试 — 逐条注入缺陷 → 跑全量测试 → KILLED/SURVIVED → 恢复 → 汇总。
// Mutation testing: mutate a source line, run the full suite, classify
// KILLED/SURVIVED, restore, then print the summary.
//
// 用法：node scripts/mutation_test.mjs
// 回归红线：killed == total（击杀率 100%）

import { spawnSync } from 'node:child_process';
import { readFileSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';

const ROOT = fileURLToPath(new URL('..', import.meta.url));

const MUTATIONS = [
  {
    id: 'M01',
    file: 'char/char.mbt',
    old: "ch == expected",
    new: "ch != expected",
    desc: 'char comparator inverted',
  },
  {
    id: 'M02',
    file: 'core/core.mbt',
    old: 'offset >= self.input.length()',
    new: 'offset > self.input.length()',
    desc: 'EOF boundary loosened',
  },
  {
    id: 'M03',
    file: 'core/core.mbt',
    old: 'input[ctx_start:ctx_end].to_owned()',
    new: 'input[ctx_start:ctx_start].to_owned()',
    desc: 'error snippet window collapsed',
  },
  {
    id: 'M04',
    file: 'branch/branch.mbt',
    old: 'expected="any choice"',
    new: 'expected="any"',
    desc: 'empty choice label weakened',
  },
  {
    id: 'M05',
    file: 'branch/branch.mbt',
    old: '@core.Failure(_) => @core.Success((), state)',
    new: '@core.Failure(_) => @core.Failure(@core.ParseError::at(pos=state.pos, expected="negated"))',
    desc: 'not_followed_by success branch removed',
  },
  {
    id: 'M06',
    file: 'sequence/sequence.mbt',
    old: '          @core.Success([], state)',
    new: '          @core.Failure(@core.ParseError::at(pos=state.pos, expected="sep_by"))',
    desc: 'sep_by zero-match success removed',
  },
  {
    id: 'M07',
    file: 'sequence/chain.mbt',
    old: '  if max_remaining <= 0 {',
    new: '  if max_remaining < -1 {',
    desc: 'count_min_max upper bound removed',
  },
  {
    id: 'M08',
    file: 'core/parser_like.mbt',
    old: '        if err.committed() {\n          Failure(err)\n        } else {\n          Success(default, state)\n        }',
    new: '        Failure(err)',
    desc: 'poption fallback removed',
  },
  {
    id: 'M09',
    file: 'astrolabe.mbt',
    old: '  p.parse_full_raise(input)',
    new: '  p.parse_raise(input)',
    desc: 'facade parse_full_raise loses full-consumption',
  },
  {
    id: 'M10',
    file: 'core/core.mbt',
    old: '        Err(ParseError::at(pos=st.pos, expected="end of input"))',
    new: '        Ok(value)',
    desc: 'parse_full accepts trailing input',
  },
  {
    id: 'M11',
    file: 'core/core.mbt',
    old: '    if !out.contains(item) {',
    new: '    if true {',
    desc: 'expected_joined deduplication removed',
  },
  {
    id: 'M12',
    file: 'core/core.mbt',
    old: '    Success(value, st) => Ok((value, input[st.offset:].to_owned()))',
    new: '    Success(value, st) => Ok((value, input[0:].to_owned()))',
    desc: 'parse_prefix tail slice starts at 0',
  },
];

function run(cmd) {
  const r = spawnSync(cmd, {
    shell: true,
    encoding: 'utf8',
    maxBuffer: 64 * 1024 * 1024,
    cwd: ROOT,
  });
  return { code: r.status ?? 1, out: `${r.stdout ?? ''}${r.stderr ?? ''}` };
}

console.log('=== baseline ===');
const base = run('moon test --target native');
if (base.code !== 0) {
  console.error('baseline tests are red; fix before mutation testing');
  process.exit(1);
}

let killed = 0;
let survived = 0;
let skipped = 0;
const results = [];

for (const m of MUTATIONS) {
  const path = join(ROOT, m.file);
  const original = readFileSync(path, 'utf8');
  const hits = original.split(m.old).length - 1;
  if (hits !== 1) {
    skipped++;
    results.push(`${m.id}: SKIPPED (pattern occurrences=${hits}) — ${m.desc}`);
    continue;
  }
  writeFileSync(path, original.replace(m.old, m.new), 'utf8');
  const res = run('moon test --target native');
  writeFileSync(path, original, 'utf8');
  if (res.code === 0) {
    survived++;
    results.push(`${m.id}: SURVIVED — ${m.desc}`);
  } else {
    killed++;
    results.push(`${m.id}: KILLED — ${m.desc}`);
  }
}

const finalRes = run('moon test --target native');
for (const r of results) console.log(r);
console.log('=== mutation summary ===');
console.log(`killed=${killed} survived=${survived} skipped=${skipped} total=${MUTATIONS.length}`);
if (finalRes.code !== 0) {
  console.error('WARNING: baseline tests failing after restore — manual check needed');
  process.exit(1);
}
if (survived > 0 || skipped > 0) {
  console.error('FAIL: survived/skipped mutations above zero');
  process.exit(1);
}
console.log('PASS: all mutations killed');