#lang racket/base
(require racket/unsafe/ops)

(define HOW-MANY (read))
(define the-vector (make-vector HOW-MANY 0))

(for ([i (in-range HOW-MANY)])
  (unsafe-vector-set! the-vector i (read)))

(time
 (for ([i (in-range HOW-MANY)])
   (define e (unsafe-vector-ref the-vector i))
   (unsafe-vector-set! the-vector i (unsafe-fl* e e))))
