# Formal Specification & Verification

## Verified Properties (MoonBit Proof Conditions)

The following properties are statically proved via MoonBit's proof conditions (`proof_require` / `proof_ensure`) in [`proof/proof.mbt`](../proof/proof.mbt). At compile time, MoonBit's proof frontend discharges these obligations with its SMT backend, so every build that passes `moon check --deny-warn` re-verifies them.

The seven proof functions and the properties they certify:

| # | Proof function | Property certified |
|---|---|---|
| P1 | `commit_flag` | `commit(e)` always reports `committed == true` |
| P2a | `alt_uncommitted_backtracks` | `alt` tries p2 when p1 fails uncommitted |
| P2b | `alt_committed_no_backtrack` | `alt` propagates without trying p2 when p1 fails committed |
| P3b | `sequence_commit_on_second_fail` | second-parser failure in a sequence is committed |
| I1 | `advance_offset` | offset advance stays non-negative (`before + 1 >= 0`) |
| I2 | `compute_remaining` | remaining stays non-negative (`length - offset >= 0`) |
| I3 | `compute_is_eof` | EOF predicate is exact (`offset >= length`) |

### P1: commit Forces Committed Flag

```
forall e : ParseError,
  commit(e).committed == true
```

When `commit(p)` wraps a failing parser, the resulting error always has `committed = true`, regardless of the original error's commitment status.

### P2a: alt Backtracks on Uncommitted Failure

```
forall e : ParseError,
  e.committed == false -> alt(p1, p2) tries p2
```

When the first parser in `alt` fails with an uncommitted error, the second parser is tried on the original input.

### P2b: alt Does NOT Backtrack on Committed Failure

```
forall e : ParseError,
  e.committed == true -> alt(p1, p2) propagates e without trying p2
```

When the first parser fails with a committed error, `alt` immediately returns that error — no backtracking.

### P3b: bind Commits on Second Failure ("Sequence Commits")

```
forall p1 : Parser[T], f : (T) -> Parser[U],
  if p1 succeeds AND f(p1.result) fails with committed=c,
  then bind(p1, f) fails with committed=true
```

This is Angstrom's key invariant: once a sequence has consumed input (p1 succeeded), any failure from the continuation is committed, preventing exponential backtracking in long chains.

### I1: Offset Advance Stays Non-Negative

```
forall before : Int, 0 <= before  =>  0 <= advance_offset(before) == before + 1
```

### I2: Remaining Characters Stay Non-Negative

```
forall offset, length : Int, 0 <= offset <= length  =>  0 <= compute_remaining(offset, length) == length - offset
```

### I3: EOF Condition Is Exact

```
forall offset, length : Int, 0 <= offset <= length  =>  compute_is_eof(offset, length) == (offset >= length)
```

## Semantic-Level Guarantees (covered by tests, not separately proved)

The following guarantees are specified by the commitment propagation table below and covered by the test suite (178 tests x 4 backends), but have **no dedicated proof obligation** in `proof/proof.mbt`:

- P3a: `map` preserves the commitment flag;
- P4: `label` preserves the commitment flag and does not alter backtracking behavior;
- `many` terminates on uncommitted failure and propagates committed failure.

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

## Scope of the Verification

Each proof function in `proof/proof.mbt` distills a key semantic invariant into a direct function over integers/booleans, annotated with `proof_require` (precondition) and `proof_ensure` (postcondition); the MoonBit compiler hands these contracts to its SMT backend during type checking. This verifies the **core logic invariants of the commitment semantics** — not end-to-end correctness of the parser implementation as a whole, which is covered by the test suite (178 tests x 4 backends).

The MoonBit proof frontend (as of 2026-11) does not yet support struct field access in logic predicates, Char/String comparison in proof assertions, or array indexing in logic bodies. Once these land, the following targets become directly formalizable:

- `Pos::advance` correctness (joint line/column/offset update)
- `State` invariant preservation (0 <= offset <= input.length) across all parser operations
- `ParseError` construction discipline (uncommitted by default, single expected label)
