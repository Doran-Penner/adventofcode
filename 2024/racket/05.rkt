#lang racket

(require advent-of-code/input)
(require advent-of-code/answer)

(define sesh (getenv "AOC_SESSION"))
(define day05-input (fetch-aoc-input sesh 2024 05 #:cache #t))

; set of pairs of numbers, each pair of numbers is a rule
(define rules (list->set (map
                          (lambda (str) (let ([pair/list (string-split str "|")])
                                          (cons (string->number (car pair/list))
                                                (string->number (cadr pair/list)))))
                          (regexp-match* #rx"[0-9]+\\|[0-9]+" day05-input))))

; list of lists of numbers, each list of numbers is a propsed instruction
(define instructions (map
                      (lambda (line/str)
                        (map string->number (string-split line/str ",")))
                      (regexp-match* #rx"[0-9]+(,[0-9]+)+" day05-input)))

; strategy: make "reverse pairs" set for a line and then
; set intersect with rules, if it's empty then we're good

; "inner loop," adds (reverse) set pairs
(define (req-pairs val lst prev-acc)
  (foldl (lambda (x acc)
           (set-add acc (cons x val)))
         prev-acc
         lst))

; we want foldl but to always have access to whole rest of list
; not this is not generic to process, but whateverrrr
(define (fold/custom head tail acc)
  (if (equal? tail '())
      acc
      (fold/custom (car tail) (cdr tail) (req-pairs head tail acc))))

; this'll run in theta(n^2) time with n=length of an instruction list
; which isn't ideal but it's broken up by instruction line so it's okay
(define (instruction->req-set lst)
  ; assume lst is nonempty
  (fold/custom (car lst) (cdr lst) (list->set '())))

(define (valid-instruction? lst)
  (set-empty? (set-intersect rules (instruction->req-set lst))))

(define (get-middle-number lst)
  (list-ref lst (quotient (length lst) 2)))

; finally, filter -> map -> reduce!
(define answer1
  (foldl + 0 (map get-middle-number (filter valid-instruction? instructions))))

#|
(define result
  (aoc-submit sesh 2024 05 1 answer1))
(printf result)
|#
; WAHOO


; This is a "known" problem: finding a topological sorting
; As such we will be lazy and use wikipedia's formulation
; of Kahn's algorithm for this problem
; Work smart, not hard!

#|
S: set of int,
  starts with all possible "starting" nodes
L: list of int,
  starts empty and is our final solution (once reversed)
(hidden graph) G: mutable hash of (int, (set of int)),
  newly-created for each line (filter for relevant rules)
|#

(define (pair->set pair)
  (set (car pair) (cdr pair)))

(define (relevant-rules instruction/lst)
  (define (rule-is-relevant? rule/pair)
    (equal? 2
            (set-count (set-intersect (list->set instruction/lst)
                                      (pair->set rule/pair)))))
  (filter rule-is-relevant? (set->list rules)))

; so much work to make immutable hash from list
(define (initial-hash-set instruction)
  (apply hash
         (flatten (map (lambda (x) (cons x (set))) instruction))))

(define (graph-of instruction)
  (define init
    (initial-hash-set instruction))
  (define rel-rules
    (relevant-rules instruction))
  (foldl
   (lambda (new-rule acc-hash)
     (hash-update
      acc-hash
      (car new-rule)
      (lambda (prev-set)
        (set-add prev-set (cdr new-rule)))))
   init
   rel-rules))

(define (starting-nodes graph)
  (foldl
   (lambda (st2 acc) (set-subtract acc st2))
   (list->set (hash-keys graph))
   (hash-values graph)))

(define (kahns-loop/inner graph n safe-nodes)
  (if (set-empty? (hash-ref graph n)) (cons graph safe-nodes)
      ; else, pop some edge from graph[n] and
      ; insert it into safe-nodes if it's now safe
      (let ([m (set-first (hash-ref graph n))]
            [new-graph (hash-update graph n set-rest)])
        (kahns-loop/inner
         new-graph
         n
         (if (set-member?
              (foldl
               set-union
               (set)
               (hash-values new-graph)) m)
             safe-nodes
             (set-add safe-nodes m))))))

(define (kahns-loop/outer graph safe-nodes l)
  (if (set-empty? safe-nodes) l
      (let* ([n (set-first safe-nodes)]
             [new-l (cons n l)]
             ; we need to update safe-nodes inside the new-graph loop
             ; so we need to return both the graph and safe nodes
             [graph-safe/pair (kahns-loop/inner graph n (set-rest safe-nodes))])
        (kahns-loop/outer (car graph-safe/pair) (cdr graph-safe/pair) new-l))))

(define (ordering instruction)
  (define graph (graph-of instruction))
  (define starts (starting-nodes graph))
  (reverse (kahns-loop/outer graph starts '())))

; reduce (map (map (filter)))
(define answer2
  (foldl + 0
         (map get-middle-number
              (map ordering
                   (filter
                    (lambda (instr)
                      (not (valid-instruction? instr)))
                    instructions)))))

#|
(define result
  (aoc-submit sesh 2024 05 2 answer2))
(printf result)
|#
; I'm so done with racket
