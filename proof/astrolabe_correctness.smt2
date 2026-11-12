; Astrolabe v0.0.1 — 组合子正确性证明 (最终版)
; Z3 SMT-LIB2 | WSL + z3
;
; 结果:
;   P1: commit 切断回溯 ✅ (加约束后 unsat)
;   P2: alt 失败传播 ✅ (unsat)
;   P3: map 保结构 ✅ (unsat)
;   P4: 零消耗反例 ⚠️ (sat — 需不变量保证)

(set-option :timeout 10000)

(declare-sort Parser 0)
(declare-sort Fn 0)
(declare-sort Value 0)
(declare-sort Str 0)

(declare-datatypes () (
  (Pos (mkPos (pos_line Int) (pos_col Int) (pos_offset Int)))
))
(declare-datatypes () (
  (State (mkState (st_offset Int) (st_line Int) (st_col Int)))
))
(declare-datatypes () (
  (ParseResult
    (Success (result_val Value) (result_state State))
    (Failure (error_pos Pos) (error_expected Str) (committed Bool)))
))

(declare-fun run (Parser State) ParseResult)
(declare-fun commit (Parser) Parser)
(declare-fun alt (Parser Parser) Parser)
(declare-fun map_fn (Fn Parser) Parser)

(declare-const pA Parser)
(declare-const pB Parser)
(declare-const s0 State)
(declare-const f1 Fn)

; === commit 语义 ===
; commit(p) 成功时透传, 失败时 committed=true
(assert (=> (is-Failure (run pA s0)) (= (committed (run (commit pA) s0)) true)))
(assert (=> (is-Success (run pA s0))
            (and (is-Success (run (commit pA) s0))
                 (= (result_state (run (commit pA) s0)) (result_state (run pA s0))))))
(assert (=> (is-Failure (run pB s0)) (= (committed (run (commit pB) s0)) true)))
(assert (=> (is-Success (run pB s0))
            (and (is-Success (run (commit pB) s0))
                 (= (result_state (run (commit pB) s0)) (result_state (run pB s0))))))

; === alt 语义 ===
; p1 成功 → alt(p1,p2) = p1
; p1 失败+committed → alt(p1,p2) = p1 (不回溯)
; p1 失败+uncommitted → alt(p1,p2) = p2 (回溯)
(assert (=> (is-Success (run pA s0)) (= (run (alt pA pB) s0) (run pA s0))))
(assert (=> (and (is-Failure (run pA s0)) (= (committed (run pA s0)) true))
            (= (run (alt pA pB) s0) (run pA s0))))
(assert (=> (and (is-Failure (run pA s0)) (= (committed (run pA s0)) false))
            (= (run (alt pA pB) s0) (run pB s0))))

; === 关键约束: commit(p) 失败时, committed=true ===
; 这使 commit 的结果被 alt 识别为"不可回溯"
(assert (=> (is-Failure (run (commit pA) s0)) (= (committed (run (commit pA) s0)) true)))

; === alt 对 commit(pA) 的直接语义 ===
; commit(pA) 失败 + committed → alt 不回溯
(assert (=> (and (is-Failure (run (commit pA) s0)) (= (committed (run (commit pA) s0)) true))
            (= (run (alt (commit pA) pB) s0) (run (commit pA) s0))))
; commit(pA) 成功 → alt 返回 commit(pA)
(assert (=> (is-Success (run (commit pA) s0))
            (= (run (alt (commit pA) pB) s0) (run (commit pA) s0))))

; === map 语义 ===
(assert (=> (is-Success (run pA s0)) (is-Success (run (map_fn f1 pA) s0))))
(assert (=> (is-Failure (run pA s0)) (= (run (map_fn f1 pA) s0) (run pA s0))))

; ===========================================
; P1: commit 切断回溯
; 如果 commit(pA) 失败, 则 alt(commit(pA), pB) 不等于 run(pB)
; ===========================================
(echo "P1: commit cuts backtracking")
(push 1)
(assert (is-Failure (run (commit pA) s0)))
; 此时 committed(run(commit(pA),s0))=true
; alt 语义: pA失败+committed → alt = run(pA) ≠ run(pB) 除非恰好相等
; 我们证明: alt(commit(pA), pB) = run(commit(pA)) 即不回溯到 pB
(assert (not (= (run (alt (commit pA) pB) s0) (run (commit pA) s0))))
(check-sat)
(pop 1)

; ===========================================
; P2: alt failure propagation
; ===========================================
(echo "P2a: committed failure → no backtrack")
(push 1)
(assert (is-Failure (run pA s0)))
(assert (= (committed (run pA s0)) true))
(assert (not (= (run (alt pA pB) s0) (run pA s0))))
(check-sat)
(pop 1)

(echo "P2b: uncommitted failure → backtrack to pB")
(push 1)
(assert (is-Failure (run pA s0)))
(assert (= (committed (run pA s0)) false))
(assert (not (= (run (alt pA pB) s0) (run pB s0))))
(check-sat)
(pop 1)

; ===========================================
; P3: map preserves structure
; ===========================================
(echo "P3a: failure → map failure")
(push 1)
(assert (is-Failure (run pA s0)))
(assert (is-Success (run (map_fn f1 pA) s0)))
(check-sat)
(pop 1)

(echo "P3b: success → map success")
(push 1)
(assert (is-Success (run pA s0)))
(assert (is-Failure (run (map_fn f1 pA) s0)))
(check-sat)
(pop 1)

; ===========================================
; P4: many 终止性
; ===========================================
(echo "P4: zero-consumption parser exists (warning: need consumed>0)")
(push 1)
(assert (is-Success (run pA s0)))
(assert (= (st_offset (result_state (run pA s0))) (st_offset s0)))
(check-sat)
(pop 1)

(echo "")
(echo "=== ASTROLABE CORRECTNESS PROOF ===")
(echo "P1  unsat = commit cuts backtracking       [expect unsat]")
(echo "P2a unsat = committed failure propagates    [expect unsat]")
(echo "P2b unsat = uncommitted failure backtracks  [expect unsat]")
(echo "P3a unsat = map preserves failure           [expect unsat]")
(echo "P3b unsat = map preserves success           [expect unsat]")
(echo "P4  sat   = zero-consumption exists         [need invariant]")
