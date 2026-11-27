#!/usr/bin/env node
// 展示页自检：静态结构 + 钩子 + JS 导出 + 解析器语义 + 口径一致性。
// Pages self-check for astrolabe (structure, hooks, exports, semantics, numbers).

import { readFileSync, existsSync, copyFileSync } from 'node:fs';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';

const ROOT = fileURLToPath(new URL('..', import.meta.url));
const TRUTH = JSON.parse(readFileSync(join(ROOT, 'docs/coverage.json'), 'utf8'));
const JS_BUILD = join(ROOT, '_build/js/release/build/playground/playground.js');
const JS_DOCS = join(ROOT, 'docs/playground.js');

let failures = 0;
let total = 0;
function check(name, ok, detail) {
  total++;
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${name}${detail ? `  (${detail})` : ''}`);
  if (!ok) failures++;
}

/* ---------- 静态资源与结构 ---------- */

for (const f of ['docs/index.html', 'docs/app.js', 'docs/style.css']) {
  check(`asset exists: ${f}`, existsSync(join(ROOT, f)));
}
const html = readFileSync(join(ROOT, 'docs/index.html'), 'utf8');
const css = readFileSync(join(ROOT, 'docs/style.css'), 'utf8');
const app = readFileSync(join(ROOT, 'docs/app.js'), 'utf8');

check('index mentions astrolabe + parser', html.includes('astrolabe') && html.includes('解析器组合子'));
check('loads app.js / style.css', html.includes('app.js') && html.includes('style.css'));
check('html lang=zh-CN', html.includes('<html lang="zh-CN"'));
check('light default + dark palette', html.includes('data-theme="light"') && css.includes("html[data-theme='dark']"));
check('theme persistence key', html.includes('astrolabe-mbt-theme') && app.includes('astrolabe-mbt-theme'));
check('sticky topbar', css.includes('.topbar { position: sticky'));
check('nav six anchors', ['#features', '#demo', '#start', '#api', '#quality', '#docs'].every((h) => html.includes(`href="${h}"`)));
check('theme toggle + github', html.includes('id="theme-toggle"') && html.includes('github.com/walkzzz/astrolabe'));
check('Open Graph metadata', html.includes('property="og:title"') && html.includes('property="og:description"') && html.includes('property="og:url"'));
check('inline svg favicon', html.includes('rel="icon"'));
check('skip link', html.includes('class="skip-link"'));
check('footer mooncakes link', html.includes('mooncakes.io/docs/walkzzz/astrolabe'));
check('no external script/style CDN', !/<script[^>]+src="https?:/.test(html) && !/<link[^>]+href="https?:/.test(html));
check('hero live format block', html.includes('id="hero-format"') && html.includes('id="hero-status"'));
check('12 capability cards', (html.match(/class="feature"/g) || []).length === 12, `${(html.match(/class="feature"/g) || []).length}`);
check('9 demo cards', (html.match(/<article class="card">/g) || []).length === 9, `${(html.match(/<article class="card">/g) || []).length}`);
check('copy targets >= 6', (html.match(/data-copy-target="/g) || []).length >= 6);
check('mobile nav toggle present', html.includes('id="nav-toggle"') && html.includes('aria-controls="site-nav"') && html.includes('id="site-nav"'));
check('mobile nav drawer css', css.includes('.nav.open { display: flex; }'));
check('mobile nav js bound', app.includes('nav-toggle') && app.includes('closeNav'));

/* ---------- 演示钩子 ---------- */

const hookIds = [
  'in-char', 'arg-char', 'char-out', 'in-str', 'arg-str', 'str-out',
  'in-range', 'lo', 'hi', 'range-out', 'in-ident', 'ident-out',
  'in-int', 'int-out', 'in-csv', 'csv-out', 'in-modes', 'arg-modes', 'modes-out',
  'in-err', 'arg-err', 'err-out', 'in-commit', 'commit-out', 'in-pos', 'pos-out',
];
for (const id of hookIds) {
  check(`hook: #${id}`, html.includes(`id="${id}"`));
}
const actionRunners = {
  char: 'runChar',
  string: 'runString',
  range: 'runRange',
  ident: 'runIdent',
  int: 'runInt',
  csv: 'runCsv',
  modes: 'runModes',
  error: 'runError',
  commit: 'runCommit',
  pos: 'runPos',
};
for (const [run, fn] of Object.entries(actionRunners)) {
  check(`action: ${run}`, app.includes(fn) && html.includes(`data-run="${run}"`));
}
check('presets bound', html.includes('data-preset="range-bad"') && html.includes('data-preset="commit-ab"'));

/* ---------- 文档链接与锚点 ---------- */

for (const doc of ['tutorial', 'api', 'architecture', 'formal-spec', 'performance_report', 'comparison', 'assessment', 'proposal', 'migration', 'security', 'pitfall-catalog', 'roadmap']) {
  check(`docs link: ${doc}.md`, html.includes(`docs/${doc}.md`));
}
for (const anchor of ['features', 'demo', 'start', 'api', 'quality', 'docs', 'how', 'top']) {
  check(`section anchor: #${anchor}`, html.includes(`id="${anchor}"`));
}

/* ---------- 版本与口径 ---------- */

const mod = readFileSync(join(ROOT, 'moon.mod'), 'utf8');
const version = (mod.match(/version\s*=\s*"([^"]+)"/) || [])[1] || '';
const pct = TRUTH.coverage.percent;
const tests = TRUTH.tests.per_backend;
const backends = TRUTH.tests.backends;
const killed = TRUTH.mutation.killed;
const mutTotal = TRUTH.mutation.total;
check('version matches moon.mod', version.length > 0 && html.includes(version), version);
check('version format x.y.z', /^\d+\.\d+\.\d+$/.test(version), version);
check('badge numbers: tests = coverage.json', html.includes(`${tests} × ${backends}`), `${tests} × ${backends}`);
check('coverage number = coverage.json', html.includes(`${pct}%`), `${pct}%`);
check('mutation = coverage.json', html.includes(`${killed} / ${mutTotal}`), `${killed} / ${mutTotal}`);
check('formal 7 goals', html.includes('7') && html.includes('goals'));
check('script assets present', existsSync(join(ROOT, 'scripts/mutation_test.mjs')) && existsSync(join(ROOT, 'scripts/check_docs.mjs')));

/* ---------- 构建 playground JS ---------- */

if (!existsSync(JS_BUILD)) {
  const r = spawnSync('moon build --target js --release playground', {
    shell: true,
    encoding: 'utf8',
    cwd: ROOT,
  });
  check('build playground js', r.status === 0, (r.stderr ?? '').slice(0, 200));
}
if (existsSync(JS_BUILD)) copyFileSync(JS_BUILD, JS_DOCS);
check('docs/playground.js exists', existsSync(JS_DOCS));
if (!existsSync(JS_DOCS)) {
  console.log(`\n=== pages check: FAIL (${failures}/${total}) ===`);
  process.exit(1);
}

/* ---------- 导出与语义 ---------- */

const pg = await import(pathToFileURL(JS_DOCS).href);
const exportsList = [
  'astrolabe_version',
  'parse_char',
  'parse_string',
  'parse_range',
  'parse_identifier',
  'parse_int',
  'parse_csv',
  'parse_modes_demo',
  'error_demo',
  'commit_vs_alt',
  'pos_track',
];
for (const name of exportsList) {
  check(`export: ${name}`, typeof pg[name] === 'function');
}

check('version export matches moon.mod', pg.astrolabe_version() === version, `${pg.astrolabe_version()} vs ${version}`);

const charOk = JSON.parse(pg.parse_char('abc', 'a'));
check('char parses value + rest', charOk.ok === true && charOk.value === 'a' && charOk.rest === 'bc');
check('char consumed is 1', charOk.consumed === 1);
const charBad = JSON.parse(pg.parse_char('abc', 'z'));
check('char failure has pos + format', charBad.ok === false && charBad.pos.label === '1:1@0' && charBad.format.includes('^'));
check('char rejects multi-char argument', JSON.parse(pg.parse_char('a', 'ab')).ok === false);

const str = JSON.parse(pg.parse_string('hello world', 'hello'));
check('string parses literal + rest', str.ok === true && str.value === 'hello' && str.rest === ' world');
check('string rejects empty literal', JSON.parse(pg.parse_string('x', '')).ok === false);

const range = JSON.parse(pg.parse_range('moonbit', 'a', 'z'));
check('range parses first char', range.ok === true && range.value === 'm' && range.rest === 'oonbit');
check('range rejects reversed bounds', JSON.parse(pg.parse_range('m', 'z', 'a')).ok === false);

const ident = JSON.parse(pg.parse_identifier('foo_1'));
check('identifier parses', ident.ok === true && ident.value === 'foo_1' && ident.length === 5);
check('identifier rejects leading digit', JSON.parse(pg.parse_identifier('1abc')).ok === false);

const int = JSON.parse(pg.parse_int('12345'));
check('int parses value', int.ok === true && int.value === 12345 && int.digits === 5);
check('int rejects int32 overflow', JSON.parse(pg.parse_int('2147483648')).ok === false);
check('int rejects non-digit', JSON.parse(pg.parse_int('abc')).ok === false);

const csv = JSON.parse(pg.parse_csv('alpha,beta_2,gamma-3'));
check('csv parses items', csv.ok === true && csv.count === 3 && csv.items[1] === 'beta_2');
check('csv accepts trailing comma', JSON.parse(pg.parse_csv('a,')).count === 1);
check('csv accepts empty input', JSON.parse(pg.parse_csv('')).count === 0);
check('csv rejects double separator', JSON.parse(pg.parse_csv('a,,b')).ok === false);

const modes = JSON.parse(pg.parse_modes_demo('abc', 'ab'));
check('modes: parse succeeds', modes.parse.ok === true && modes.parse.value === 'ab');
check('modes: parse_prefix returns rest', modes.parse_prefix.ok === true && modes.parse_prefix.rest === 'c');
check('modes: parse_full rejects trailing', modes.parse_full.ok === false && modes.parse_full.pos.offset === 2);

const err = JSON.parse(pg.error_demo('abd', 'abc'));
check('error demo exposes expected', err.ok === false && err.expected.length === 1);
check('error demo caret format', err.format.includes('^'));
check('error demo no false success', JSON.parse(pg.error_demo('abc', 'abc')).matched === true);

const commit = JSON.parse(pg.commit_vs_alt('ac'));
check('commit: alt backtracks and succeeds', commit.alt.ok === true && commit.alt.value === 'ac');
check('commit: committed branch fails', commit.commit.ok === false && commit.commit.committed === true);
const commitAb = JSON.parse(pg.commit_vs_alt('ab'));
check('commit: first branch wins on ab', commitAb.alt.ok === true && commitAb.commit.ok === true);

const pos = JSON.parse(pg.pos_track('a\nb'));
check('pos track counts chars', pos.ok === true && pos.count === 3);
check('pos track advances line on newline', pos.steps[2].line === 2 && pos.steps[2].column === 1 && pos.steps[2].offset === 2, JSON.stringify(pos.steps[2]));

/* ---------- 汇总 ---------- */

console.log(`\n=== pages check: ${failures === 0 ? 'PASS' : `FAIL (${failures})`} · ${total} checks ===`);
if (failures > 0) process.exit(1);