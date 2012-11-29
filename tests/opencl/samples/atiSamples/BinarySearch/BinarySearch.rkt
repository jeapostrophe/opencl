#lang racket
(require opencl/c
         "../atiUtils/utils.rkt"
         ffi/unsafe
         ffi/cvector
         ffi/unsafe/cvector)

(define setupTime -1)
(define totalKernelTime -1)
(define devices #f)
(define context #f)
(define commandQueue #f)
(define program #f)
(define length 2048)
(define input #f)
(define output #f)
(define inputBuffer #f)
(define outputBuffer #f)
(define kernel #f)
(define findMe 5)

(define (setupBinarySearch)
  (define inputSizeBytes (* length (ctype-sizeof _cl_uint)))
  (set! input (malloc inputSizeBytes 'raw))
  (ptr-set! input _cl_uint 0 0)
  (for ([i (in-range 1 length)])
    (ptr-set! input _cl_uint i (+ (ptr-ref input _cl_uint (- i 1)) (remainder (random 100) 2))))
  (set! output (malloc (ctype-sizeof _cl_uint4) 'raw))
  (print-array "Sorted Input" input length))


(define (setupCL)
  (set!-values (devices context commandQueue program) (init-cl "BinarySearch_Kernels.cl" #:queueProperties 'CL_QUEUE_PROFILING_ENABLE))
  (set! inputBuffer (clCreateBuffer context '(CL_MEM_READ_ONLY CL_MEM_USE_HOST_PTR) (* (ctype-sizeof _cl_uint) length) input))
  (set! outputBuffer (clCreateBuffer context '(CL_MEM_WRITE_ONLY CL_MEM_USE_HOST_PTR) (ctype-sizeof _cl_uint4) output))
  (set! kernel (clCreateKernel program #"binarySearch")))

(define (runCLKernels)
  (define device (cvector-ref devices 0))
  (define localThreads (optimum-threads kernel device 256))
  (define numSubdivisions (/ length localThreads))
  (when (< numSubdivisions localThreads) (set! numSubdivisions localThreads))
  (define globalThreads numSubdivisions)
  
  (define globalLowerBound 0)
  (define globalUpperBound (- length 1))
  (define subdivSize (/ (add1 (- globalUpperBound globalLowerBound)) numSubdivisions))
  (define isElementFound 0)
  
  (if (or (> (ptr-ref input _cl_uint 0) findMe) (< (ptr-ref input _cl_uint (- length 1)) findMe))
      (begin
        (display "here")
        (ptr-set! output _cl_uint 0 0)
        (ptr-set! output _cl_uint 1 (- length 1))
        (ptr-set! output _cl_uint 2 0))
      (begin
        (ptr-set! output _cl_uint 3 1)
        (clSetKernelArg:_cl_mem kernel 0 outputBuffer)
        (clSetKernelArg:_cl_mem kernel 1 inputBuffer)
        (clSetKernelArg:_cl_uint kernel 2 findMe)
        (let loop ()
          (when (and (> subdivSize 1) (not (= (ptr-ref output _cl_uint 3) 0)))
            (ptr-set! output _cl_uint 3 0)
            (clEnqueueWriteBuffer commandQueue outputBuffer 'CL_TRUE 0 (ctype-sizeof _cl_uint4) output (make-vector 0))
            (clSetKernelArg:_cl_uint kernel 3 globalLowerBound)
            (clSetKernelArg:_cl_uint kernel 4 globalUpperBound)
            (clSetKernelArg:_cl_uint kernel 5 subdivSize)
            (let ([event (clEnqueueNDRangeKernel commandQueue kernel 1 (vector globalThreads) (vector localThreads) (make-vector 0))])
              (clWaitForEvents (vector event))
              (clReleaseEvent event))
            (clEnqueueReadBuffer commandQueue outputBuffer 'CL_TRUE 0 (ctype-sizeof _cl_uint4) output (make-vector 0))
            (set! globalLowerBound (ptr-ref output _cl_uint 0))
            (set! globalUpperBound (ptr-ref output _cl_uint 1))
            (set! subdivSize (/ (add1 (- globalUpperBound globalLowerBound)) numSubdivisions))
            (loop)))
        (for ([i (in-range globalLowerBound (add1 globalUpperBound))])
          (when (eq? (ptr-ref input _cl_uint i) findMe)
            (ptr-set! output _cl_uint 0 i)
            (ptr-set! output _cl_uint 1 (add1 i))
            (ptr-set! output _cl_uint 2 1))))))


(define (setup)
  (setupBinarySearch)
  (set! setupTime (time-real setupCL)))

(define (run)
  (set! totalKernelTime (time-real runCLKernels))
  (printf "~nl = ~a, u = ~a, isfound = ~a, fm = ~a~n"
          (ptr-ref output _cl_uint 0) (ptr-ref output _cl_uint 1) (ptr-ref output _cl_uint 2) findMe))

(define (cleanup)
  (clReleaseKernel kernel)
  (clReleaseProgram program)
  (clReleaseMemObject inputBuffer)
  (clReleaseMemObject outputBuffer)
  (clReleaseCommandQueue commandQueue)
  (clReleaseContext context)
  (free input)
  (free output))

(define (binarySearchCPUReference verificationInput)
  (define globalLowerBound (ptr-ref output _cl_uint 0))
  (define globalUpperBound (ptr-ref output _cl_uint 1))
  (define isElementFound (ptr-ref output _cl_uint 2))
  (define passed #f)
  (if (= isElementFound 1)
      (when (= (ptr-ref input _cl_uint globalLowerBound) findMe) (set! passed #t))
      (begin
        (set! passed #t)
        (for/first ([i (in-range length)]
                    #:when (= (ptr-ref input _cl_uint globalLowerBound) findMe))
          (set! passed #f))))
  passed)

(define (verify-results)
  (define verificationInput (malloc (* length (ctype-sizeof _cl_uint)) 'raw))
  (memcpy verificationInput input (* length (ctype-sizeof _cl_uint)))
  (define verified (binarySearchCPUReference verificationInput))
  (printf "~n~a~n" (if verified "Passed" "Failed"))
  (free verificationInput))

(define (print-stats)
  (printf "~nLength: ~a, Setup Time: ~a, Kernel Time: ~a, Total Time: ~a~n"
          length 
          (real->decimal-string setupTime 3) 
          (real->decimal-string totalKernelTime 3)
          (real->decimal-string (+ setupTime totalKernelTime) 3)))

(setup)
(run)
(verify-results)
(cleanup)
(print-stats)