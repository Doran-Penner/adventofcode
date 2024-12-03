#lang racket

(require advent-of-code/input)
(require advent-of-code/answer)

; setup to get the input
(define sesh (getenv "AOC_SESSION"))
(define day03-input (fetch-aoc-input sesh 2024 03 #:cache #t))

; hurray for regex libraries!
; this is arguably inefficient but it's really easy
; to check correctness after every step

; get the "true" muls
(define mul-strs/full
  (regexp-match* #rx"mul\\([0-9]+,[0-9]+\\)" day03-input))

; cut down to just the number pairs
(define mul-strs/num-pairs
  (map
   (lambda (str) (substring str 4 (- (string-length str) 1)))
   mul-strs/full))

; turn those strings into actual pairs (still of strings)
(define num-pairs/strings
  (map
   (lambda (str) (string-split str ","))
   mul-strs/num-pairs))

; define our folder function
(define (fold-numpairs str-pair acc)
  (+ acc
     (* (string->number (car str-pair)) (string->number (car (cdr str-pair))))))

; and fold!
(define answer1 (foldl fold-numpairs 0 num-pairs/strings))

#|
(define result
  (aoc-submit sesh 2024 03 1 answer1))
(printf result)
|#
; WAHOO


; I give up on testability
; our glorious single process that does everything
(define (superfolder str start-idx active acc)
  (if active
      ; then search for "mul"s or "don't"s
      (let ([next-match (regexp-match-positions #rx"don't\\(\\)|mul\\([0-9]+,[0-9]+\\)" str start-idx)])
        (if next-match
            ; then check what it was and all the fun stuff
            (let ([next-match/pair (car next-match)])
              (if (<= (- (cdr next-match/pair) (car next-match/pair)) 7)
                  ; then swap to deactivated (☹️)
                  (superfolder str (cdr next-match/pair) #f acc)
                  ; else add to acc!
                  ; ungodly code below, watch out
                  (let ([parse-and-mult (lambda (pair)
                                          (let ([start (+ 4 (car pair))]
                                                [end (- (cdr pair) 1)])
                                            (let ([mulled-list (string-split (substring str start end) ",")])
                                              (* (string->number (car mulled-list)) (string->number (cadr mulled-list))))))])
                    (superfolder str (cdr next-match/pair) #t (+ acc
                                                            (parse-and-mult next-match/pair))))))
            ; ("if it's don't, then recurse and sad; if it's mul then multiply and continue")
            ; else return acc (end of string)
            acc))
      ; else search for "do"s
      (let ([next-do (regexp-match-positions #rx"do\\(\\)" str start-idx)])
        (if next-do
            ; then recurse with active=true and update start-idx
            (superfolder str (cdr (car next-do)) #t acc)
            ; else hit end of string, so return acc!
            acc))))

(define answer2 (superfolder day03-input 0 #t 0))

#|
(define result
  (aoc-submit sesh 2024 03 2 answer2))
(printf result)
|#
