#lang racket/base
(require racket/unsafe/ops)

(define TESTING #f)
(define HOW-MANY (if TESTING (* 10 1024 (expt 2 10)) (read)))
(define the-vector (make-vector HOW-MANY 0))

(for ([i (in-range HOW-MANY)])
  (unsafe-vector-set! the-vector i
                      (if TESTING (random) (read))))

(time
 (for ([i (in-range HOW-MANY)])
   (define e (unsafe-vector-ref the-vector i))
   (unsafe-vector-set! the-vector i (unsafe-fl* e e))))
