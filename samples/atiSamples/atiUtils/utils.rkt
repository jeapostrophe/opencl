#lang racket
(require "../../../c.rkt"
         ffi/cvector
         ffi/unsafe/cvector
         ffi/unsafe)

(provide cvector->vector)
(provide init-cl)
(provide time-real)
(provide printArray)

(define (printArray arrayName arrayData length)
  (define numElementsToPrint (if (< 256 length) 256 length))
  (printf "~n~a:~n" arrayName)
  (for ([i (in-range numElementsToPrint)])
    (printf "~a " (ptr-ref arrayData _cl_uint i)))
  (display "\n"))

(define (time-real proc)
  (define-values (a b t c) (time-apply proc '()))
  (/ t 1000))

(define (init-cl source #:deviceType [deviceType 'CL_DEVICE_TYPE_GPU] #:queueProperties [queueProperties '()] #:buildOptions [buildOptions (make-bytes 0)])
  (define platform (cvector-ref (clGetPlatformIDs:vector) 0))
  (define devices (clGetDeviceIDs:vector platform deviceType))
  (define context (clCreateContext (cvector->vector devices)))
  (define commandQueue (clCreateCommandQueue context (cvector-ref devices 0) queueProperties))
  (define program (clCreateProgramWithSource context (vector (file->bytes source))))
  (clBuildProgram program (make-vector 0) buildOptions)
  (values devices context commandQueue program))

(define (cvector->vector cv)
  (build-vector (cvector-length cv)
                (curry cvector-ref cv)))