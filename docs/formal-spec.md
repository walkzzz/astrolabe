# Formal Specification & Verification

## Verified Properties (Z3 SMT)

The following core semantic properties of Astrolabe have been mechanically verified using Z3 SMT solver. The proof scripts are in `proof/`.

### P1: commit Forces Committed Flag

```
∀ e : ParseError,
  commit(e).committed == true
```

When `commit(p)` wraps a failing parser, the resulting error always has `committed = true`, regardless of the original error's commitment status.

### P2a: alt Backtracks on Uncommitted Failure

```
∀ e : ParseError,
  e.committed == false → alt(p1, p2) tries p2
```

When the first parser in `alt` fails with an uncommitted error, the second parser is tried on the original input.

### P2b: alt Does NOT Backtrack on Committed Failure

```
∀ e : ParseError,
  e.committed == true → alt(p1, p2) propagates e without trying p2
```

When the first parser fails with a committed error, `alt` immediately returns that error — no backtracking.

### P3a: map Preserves Commitment

```
∀ p : Parser[T], f : (T) → U,
  if p fails with committed=c, then map(p, f) fails with committed=c
```

`map` transforms the result value but does not alter the commitment flag.

### P3b: bind Commits on Second Failure ("Sequence Commits")

```
∀ p1 : Parser[T], f : (T) → Parser[U],
  if p1 succeeds AND f(p1.result) fails with committed=c,
  then bind(p1, f) fails with committed=true
```

This is Angstrom's key invariant: once a sequence has consumed input (p1 succeeded), any failure from the continuation is committed, preventing exponential backtracking in long chains.

### P4: label Preserves Commitment

```
∀ p : Parser[T], name : String,
  if p fails with committed=c, then label(p, name) fails with committed=c
```

`label` replaces the error message but does not alter backtracking behavior.

## Commitment Propagation Table

| Combinator | First succeeds? | Second fails? | Result committed? |
|------------|----------------|---------------|-------------------|
| `bind(p, f)` | No | — | Same as p's error |
| `bind(p, f)` | Yes | Yes | **Always true** |
| `seq2(p1, p2)` | No | — | Same as p1's error |
| `seq2(p1, p2)` | Yes | Yes | **Always true** |
| `alt(p1, p2)` | Yes | — | N/A (success) |
| `alt(p1, p2)` | No (committed) | — | **true** (no backtrack) |
| `alt(p1, p2)` | No (uncommitted) | p2 tried | Depends on p2 |
| `commit(p)` | No | — | **Always true** |
| `map(p, f)` | No | — | Same as p's error |
| `label(p, n)` | No | — | Same as p's error |
| `many(p)` | No (uncommitted) | — | false → loop ends, returns [] |
| `many(p)` | No (committed) | — | **true** → error propagates |

## MoonBit Proof-Carrying Code Note

MoonBit's `moon prove` verification frontend (as of 2026-11) does not yet support:
- Struct field access in logic predicates (`p.line`, `s.offset`)
- Char/String comparison in proof assertions
- Array indexing in logic body

These limitations prevent direct verification of Astrolabe's struct-based core types via `.mbtp` files. The Z3 proofs above verify the *integer logic* underlying the commitment semantics, which is the most critical property for correctness.

When the MoonBit proof frontend gains struct support, the following verification targets become feasible:
- `Pos::advance` correctness (line/column/offset update)
- `State` invariant preservation (0 ≤ offset ≤ input.length)
- `ParseError::at` construction (uncommitted, single expected)
