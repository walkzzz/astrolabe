# Contributing to Astrolabe

Thank you for your interest in contributing!

## Development Setup

```bash
git clone https://github.com/walkzzz/astrolabe.git
cd astrolabe
moon check --target all
moon test --target all
```

## Code Style

- Run `moon fmt` before committing — all formatting is automated
- Run `moon check --deny-warn` — zero warnings is a hard gate
- Keep each file under 500 lines; split into new subpackages when needed
- Use `///|` block separators between logical sections
- Put deprecated code in `deprecated.mbt` within each package

## Making Changes

1. Create a feature branch from `main`
2. Add/modify code in the appropriate subpackage
3. Add tests in `_wbtest.mbt` (whitebox) or `_test.mbt` (blackbox) files
4. Run `moon info && moon fmt` to update interfaces and format
5. Run `moon test --target all` — all 4 backends must pass
6. Run `moon check --deny-warn` — must be clean
7. Commit with a descriptive message

## Test Conventions

- Whitebox tests (`_wbtest.mbt`): access package internals, no `@pkg.` prefix needed
- Blackbox tests (`_test.mbt`): test only public API via `@astrolabe.xxx`
- Use `assert_eq!` for stable results; `inspect!` for snapshot-style output
- Double values: use custom `approx_eq` helper (no tolerance param in `assert_eq`)

## Adding a New Combinator

1. Implement in the appropriate subpackage (`basic/`, `compose/`, or `control/`)
2. Add a `pub fn` wrapper in `astrolabe.mbt` (root facade)
3. Add whitebox tests in the subpackage's `_wbtest.mbt`
4. Add blackbox tests in `astrolabe_test.mbt` if it's a public API
5. Update `docs/api.md` with signature, description, and example
6. Add a benchmark in `benchmarks/` if applicable

## Adding a New Subpackage

1. Create directory with `moon.pkg` and source files
2. Import from `astrolabe.mbt` if it should be part of the root API
3. Add `_wbtest.mbt` and/or `_test.mbt` for tests
4. Update README and docs

## Commit Messages

Use conventional format:

```
v0.X.0: Short description of what changed

- Detail 1
- Detail 2
```

## Reporting Issues

- Include MoonBit version (`moon version`)
- Include reproduction steps and minimal input
- Include error output from `moon check --deny-warn` or `moon test -v`
