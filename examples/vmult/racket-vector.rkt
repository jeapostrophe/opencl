#lang racket

(define HOW-MANY (read))
(define the-vector (make-vector HOW-MANY 0))

(for ([i (in-range HOW-MANY)])
  (vector-set! the-vector i (read)))

(time
  (for ([i (in-range HOW-MANY)])
   (define e (vector-ref the-vector i))
   (vector-set! the-vector i (* e e))))