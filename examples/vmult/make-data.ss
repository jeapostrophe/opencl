#lang scheme

(define HOW-MANY (* 1024 (expt 2 10)))

(write HOW-MANY) (newline)
(for ([i (in-range HOW-MANY)])
  (write (random)) (newline))