#lang racket

(require advent-of-code/input)
(require advent-of-code/answer)

; setup to get the input
(define sesh (getenv "AOC_SESSION"))
(define day02-input (fetch-aoc-input sesh 2024 02 #:cache #t))
; lines is list of list of ints, hopefully
(define lines
  (map (lambda (x)
         (map string->number x))
       (map (lambda (x) (string-split x " ")) (string-split day02-input "\n"))))

; our glorious condition: computes everything through the whole list
(define (line-is-safe line prev all-incr all-decr jumps-small)
  (if (equal? line '())
      (and jumps-small (or all-incr all-decr))
      (line-is-safe
        (cdr line)
        (car line)
        (and all-incr (< prev (car line)))
        (and all-decr (> prev (car line)))
        (and jumps-small (<= 1 (abs (- prev (car line))) 3)))))

(define (line-folder line acc)
  (if (line-is-safe (cdr line) (car line) #t #t #t)
      (+ acc 1)
      acc))

(define answer1 (foldl line-folder 0 lines))

#|
(define result
  (aoc-submit sesh 2024 02 1 answer1))
(printf result)
|#
; WAHOO
