#lang racket/base

(define TESTING #f)
(define HOW-MANY (if TESTING (* 10 1024 (expt 2 10)) (read)))
(define the-vector (make-vector HOW-MANY 0))

(for ([i (in-range HOW-MANY)])
  (vector-set! the-vector i
               (if TESTING (random) (read))))

(time
  (for ([i (in-range HOW-MANY)])
   (define e (vector-ref the-vector i))
   (vector-set! the-vector i (* e e))))
