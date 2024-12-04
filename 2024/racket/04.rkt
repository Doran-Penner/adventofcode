#lang racket

(require advent-of-code/input)
(require advent-of-code/answer)

(define sesh (getenv "AOC_SESSION"))
(define day04-input (fetch-aoc-input sesh 2024 04 #:cache #t))

; no parsing, we use string raw
(define str day04-input)

; assume the board is rectangular
(define max-len (string-length str))
(define width (caar (regexp-match-positions #rx"\n" str)))
(define height (/ max-len (+ width 1)))

; convention: for indices, append /str if they index the string directly
; and append /pair if they are in pair form

(define (str-idx/from-pair pair)
  (+ (car pair) (* (cdr pair) (+ width 1))))

(define (pair-idx/from-str idx)
  (cons (remainder idx (+ width 1))
        (quotient idx (+ width 1))))

; string-ref wrapper that takes a pair and ensures it's within bounds
(define (get-at idx/pair)
  ; (println idx/pair)
  (if (and (< -1 (car idx/pair) width) (< -1 (cdr idx/pair) height))
      (string-ref str (str-idx/from-pair idx/pair))
      ; else unimportant placeholder
      #\.))

; okay! helper functions aside... what are we doing here
; game plan: for every X, try "drawing a line" in all 8 directions
; for each success, add 1 to the counter
; this feels incredibly inefficient but I also think it's just a hard problem

; this has all X positions in string
(define Xs/str (map car (regexp-match-positions* #rx"X" str)))

; makes functions
(define (gen-dir-stepper pair-added)
  (lambda (pair) (cons (+ (car pair) (car pair-added))
                       (+ (cdr pair) (cdr pair-added)))))

; list of functions to step north, west, southeast, etc
(define dir-steppers
  (map gen-dir-stepper '((0 . 1) (0 . -1) (1 . 0) (-1 . 0)
                                 (1 . 1) (1 . -1) (-1 . 1) (-1 . -1))))

(define (spells-xmas? stepper start/pair)
  ; this could be prettier but whatever
  (and (equal? #\M (get-at (stepper start/pair)))
       (equal? #\A (get-at (stepper (stepper start/pair))))
       (equal? #\S (get-at (stepper (stepper (stepper start/pair)))))))

(define (num-xmases start/idx)
  (count (lambda (stepper)
           (spells-xmas? stepper (pair-idx/from-str start/idx)))
         dir-steppers))

(define answer1 (foldl + 0 (map num-xmases Xs/str)))

#|
(define result
  (aoc-submit sesh 2024 04 1 answer1))
(printf result)
|#
; WAHOO
