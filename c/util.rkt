#lang racket
(require ffi/unsafe
         ffi/unsafe/cvector
         (prefix-in c: racket/contract))

(define ((cvector-of? type) cv)
  (and (cvector? cv)
       (equal? (cvector-type cv) type)))

(provide/contract
 [cvector-of? (ctype? . c:-> . (any/c . c:-> . boolean?))])