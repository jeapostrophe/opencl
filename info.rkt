#lang setup/infotab
(define name "OpenCL")
(define blurb
  (list "An FFI for OpenCL"))
#;(define scribblings '(["scribblings/opencl.scrbl" (multi-page)]))
(define categories '(devtools))
(define primary-file "racket.rkt")
(define compile-omit-paths '("examples" "tests" "samples"))
(define version "1.0.48")
(define release-notes 
  (list
   '(ul (li "Racketizing")
        (li "Better contracts")
        (li "Linux & ATI support"))))
(define repositories '("4.x"))
