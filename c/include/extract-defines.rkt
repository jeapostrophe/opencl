#lang racket
(require racket/port
         racket/system)

(define define-regexp #rx"^#define +([^ ]+) +([^ ]+.*)$")

(define (extract-defined-names ip)
  (for/list ([b (port->bytes-lines ip)]
             #:when (regexp-match define-regexp b))
    (match (regexp-match define-regexp b)
      [(list _ name value)
       name])))

(define filename
  (command-line
   #:program "extract-defines"
   #:args (f) f))

(define all-names
  (call-with-input-file filename extract-defined-names))

(define c-code
  (path->string (path-replace-suffix filename #".c")))

(with-output-to-file c-code
  (lambda ()
    (printf #<<END
#include "~a"
#include <stdio.h>

int main(void) {
 printf("#lang racket/base\n\n");

END
           filename
           )
  
  (for ([n (in-list all-names)])
    (printf "printf(\"(define ~a %d)\\n\", ~a);~n" n n))
  
  (printf #<<END
 printf("\n(provide (all-defined-out))\n");

 return 0;
}
END
           ))
  #:exists 'replace)

(define extractor
  (path->string (path-replace-suffix filename ".bin")))

(define (sys-check v)
  (unless (zero? v)
    (error 'sys-check "Non-zero return: ~a" v)))

(sys-check
 (system*/exit-code (find-executable-path "gcc")
                    "-I" (path->string (current-directory))
                    c-code "-o" extractor))

(delete-file c-code)

(sys-check
 (system*/exit-code extractor))

(delete-file extractor)