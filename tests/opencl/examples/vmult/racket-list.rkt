#lang racket/base
(require racket/list)

(define TESTING #f)

(define HOW-MANY (if TESTING (* 10 1024 (expt 2 10)) (read)))
(define the-list
  (if TESTING
      (for/list ([i (in-range HOW-MANY)])
        (random))
      (let loop ()
        (let ([c (read)])
          (if (eof-object? c)
              empty
              (cons c (loop)))))))

(time
 (void
  (for/list ([e (in-list the-list)])
    (* e e))))
