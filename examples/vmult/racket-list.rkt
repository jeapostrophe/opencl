#lang racket

(define HOW-MANY (read))
(define the-list
  (let loop ()
    (let ([c (read)])
      (if (eof-object? c)
          empty
          (cons c (loop))))))

(time
 (void
  (for/list ([e (in-list the-list)])
    (* e e))))