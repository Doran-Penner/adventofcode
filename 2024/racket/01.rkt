#lang racket

(require advent-of-code/input)
(require advent-of-code/answer)

; setup to get the input
(define sesh (getenv "AOC_SESSION"))
(define day01-input (fetch-aoc-input sesh 2024 01 #:cache #t))
(define in-pairs (string-split day01-input "\n"))

; our glorious input parser: takes pairs of inputs
; and turns them into two accumulated lists
(define (pair-splitter p acc)
  (let* ([p-as-pair (string-split p)]
         [first-item (string->number (car p-as-pair))]
         [second-item (string->number (car (cdr p-as-pair)))]
         [first-list (car acc)]
         [second-list (cdr acc)])
    ; for debugging
    ; (print acc)
    ; (printf "\n")
    (cons
     (cons first-item first-list)
     (cons second-item second-list))))

; apply that parser and finally we have our two lists!
(define l1l2-pair
  (foldl pair-splitter (cons '() '()) in-pairs))
(define l1 (car l1l2-pair))
(define l2 (cdr l1l2-pair))

; sort them to make this problem easy
(define sorted-l1 (sort l1 <))
(define sorted-l2 (sort l2 <))

; now it's easy: go through the sorted lists together and calculate our result
(define (diffsum x y acc)
  (+ acc (abs (- x y))))
(define answer (foldl diffsum 0 sorted-l1 sorted-l2))

; and now auto-submit!
(define result
  (aoc-submit sesh 2024 01 1 answer))
(printf result)  ; response from server


; woohoo! now we do part 2
; we can keep the lists sorted, but may not use that fact;
; I know it'd be way faster to do that, but I'm lazy
; and learning this language
