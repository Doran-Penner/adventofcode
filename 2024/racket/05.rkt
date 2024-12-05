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
