#lang scheme
(require scheme/foreign
         (prefix-in c: scheme/contract))

(define ((cvector-of? type) cv)
  (and (cvector? cv)
       (equal? (cvector-type cv) type)))

(provide/contract
 [cvector-of? (ctype? . c:-> . (any/c . c:-> . boolean?))])