#lang racket
(require "../../c.ss"
         "../utils/utils.rkt"
         ffi/cvector
         ffi/unsafe/cvector
         ffi/unsafe
         racket/runtime-path)

(define BLOCK_DIM 4)
(define-runtime-path cSourceFile "transpose.cl")

(define (compute-gold reference data sizeX sizeY)
  ;transpose matrix
  (for ([y (in-range sizeY)])
    (for ([x (in-range sizeX)])
      (ptr-set! reference _float (+ y (* x sizeY)) (ptr-ref data _float (+ x (* y sizeX)))))))

(define (transposeGPU kernel useLocalMem h_idata h_odata sizeX sizeY commandQueue)
  (print "transposeGPU"))

(define (runTest)
  (define sizeX 2048)
  (define sizeY 2048)
  (define memSize (* 2048 2048 (ctype-sizeof _float)))
  
  ;get platform
  (define platform (cvector-ref (clGetPlatformIDs:vector) 0))
  ;get devices
  (define devices (clGetDeviceIDs:vector platform 'CL_DEVICE_TYPE_GPU))
  ;create context
  (define context (clCreateContext (cvector->vector devices)))
  ;create command queue
  (define commandQueue (clCreateCommandQueue context (cvector-ref devices 0) '()))
  
  (define h_idata (malloc memSize 'raw))
  (define h_odata (malloc memSize 'raw))
  (fillArray h_idata (* sizeX sizeY))
  
  (define sourceBytes (file->bytes cSourceFile))
  (define program (clCreateProgramWithSource context (make-vector 1 sourceBytes)))
  (clBuildProgram program (cvector->vector devices)  #"-cl-fast-relaxed-math")
  
  (transposeGPU "transpose_naive" #f h_idata h_odata sizeX sizeY commandQueue)
  
  (define reference (malloc memSize 'raw))
  (compute-gold reference h_idata sizeX sizeY)
  (display "\nComparing results with CPU computation... \n\n")
  (printf "~a~n~n" (if (compareArrays reference h_odata (* sizeX sizeY)) "Passed" "Failed"))
  
  (transposeGPU "transpose" #t h_idata h_odata sizeX sizeY commandQueue)
  
  (display "\nComparing results with CPU computation... \n\n")
  (printf "~a~n~n" (if (compareArrays reference h_odata (* sizeX sizeY)) "Passed" "Failed"))
  
  ;cleanup
  (free h_idata)
  (free h_odata)
  (free reference)
  (clReleaseProgram program)
  (clReleaseCommandQueue commandQueue)
  (clReleaseContext context))

(display "oclTranspose Starting...\n\n")
(runTest)