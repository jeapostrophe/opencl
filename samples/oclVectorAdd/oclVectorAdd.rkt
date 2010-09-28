#lang racket
(require "../../c.ss")
(require "../utils/utils.rkt")
(require ffi/cvector)
(require ffi/unsafe/cvector)
(require ffi/unsafe)

(define iNumElements 11444777)    ;Length of float arrays to process (odd # for illustration)

(display "Starting...\n\n")
(printf "# of float elements per Array \t= ~a~n" iNumElements)

;set and log Global and Local work size dimensions
(define szLocalWorkSize 128)
(define szGlobalWorkSize (roundUp szLocalWorkSize iNumElements))  ; rounded up to the nearest multiple of the LocalWorkSize
(printf "Global Work Size \t\t= ~a~nLocal Work Size \t\t= ~a~n# of Work Groups \t\t= ~a~n~n"
        szGlobalWorkSize szLocalWorkSize (/ szGlobalWorkSize szLocalWorkSize))

(display "Allocate and Init Host Mem...\n")

(define srcA (malloc _cl_float szGlobalWorkSize))
(define srcB (malloc _cl_float szGlobalWorkSize))
(define dst (malloc _cl_float szGlobalWorkSize))
(define Golden (malloc _cl_float iNumElements))
;shrFillArray((float*)srcA, iNumElements);
;shrFillArray((float*)srcB, iNumElements);