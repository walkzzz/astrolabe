#!/usr/bin/env node
// version_points.mjs — astrolabe 全部版本引用点的唯一清单
//
// check_version.mjs（只读校验）与 bump_version.mjs（批量改写）共用本清单，
// 保证「能查的地方就能一次改完」，不会出现改了校验漏了改写、或反之的情况。

export const VERSION_POINTS = [
  { id: 'moon.mod', file: 'moon.mod', re: /^version = "([\d.]+)"/m, what: 'version' },
  { id: 'CHANGELOG latest', file: 'CHANGELOG.md', re: /^## \[([\d.]+)\] - /m, what: 'latest entry' },
  { id: 'README mooncakes badge', file: 'README.md', re: /mooncakes-([\d.]+)-orange/, what: 'mooncakes badge' },
  { id: 'pages brand version', file: 'docs/index.html', re: /class="brand-ver">v([\d.]+)</, what: 'brand version' },
  { id: 'pages install command', file: 'docs/index.html', re: /moon add walkzzz\/astrolabe@([\d.]+)/, what: 'install command' },
  {
    id: 'playground astrolabe_version',
    file: 'playground/playground.mbt',
    re: /pub fn astrolabe_version\(\) -> String \{\s*"([\d.]+)"/,
    what: 'astrolabe_version',
  },
  { id: 'AGENTS.md', file: 'AGENTS.md', re: /`moon\.mod` v([\d.]+)/, what: 'agents version' },
  { id: 'docs/architecture.md', file: 'docs/architecture.md', re: /^# 架构设计（astrolabe ([\d.]+)）/m, what: 'title version' },
  { id: 'docs/security.md', file: 'docs/security.md', re: /^# 安全说明（astrolabe ([\d.]+)）/m, what: 'title version' },
];
