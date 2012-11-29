#lang racket
(require opencl/c
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

(define (transposeGPU kernelName useLocalMem h_idata h_odata sizeX sizeY commandQueue context program)
  ;size of memory required to store the matrix
  (define memSize (* sizeX sizeY (ctype-sizeof _float)))
  
  ;allocate device memory and copy host to device memory
  (define d_idata (clCreateBuffer context '(CL_MEM_READ_ONLY CL_MEM_COPY_HOST_PTR) memSize h_idata))
  ;create buffer to store output
  (define d_odata (clCreateBuffer context 'CL_MEM_WRITE_ONLY memSize #f))
  
  ;create the naive transpose kernel
  (define kernel (clCreateKernel program kernelName))
  ;set the args values for the naive kernel
  (clSetKernelArg:_cl_mem kernel 0 d_odata)
  (clSetKernelArg:_cl_mem kernel 1 d_idata)
  (clSetKernelArg:_cl_int kernel 2 0)
  (clSetKernelArg:_cl_int kernel 3 sizeX)
  (clSetKernelArg:_cl_int kernel 4 sizeY)
  (when useLocalMem (clSetKernelArg:local kernel 5 (* (+ BLOCK_DIM 1) BLOCK_DIM (ctype-sizeof _float))))
  
  ;set up execution configuration
  (define localSize (make-vector 2 BLOCK_DIM))
  (define globalSize (vector (roundUp BLOCK_DIM sizeX) (roundUp BLOCK_DIM sizeY)))
  
  ;execute the kernel numIterations times
  (define numIterations 100)
  (printf "~nProcessing a ~a by ~a matrix of floats...~n~n" sizeX sizeY)
  (for ([i (in-range -1 numIterations)])
    ;Start time measurement after warmup
    (when (= i 0) (deltaT 0))
    (clEnqueueNDRangeKernel commandQueue kernel 2 globalSize localSize (make-vector 0)))
  ;Block CPU till GPU is done
  (clFinish commandQueue)
  (define time (/ (deltaT 0) numIterations))
  (printf "time to complete: ~a~n" (real->decimal-string time 3))
  
  ;Copy back to host
  (clEnqueueReadBuffer commandQueue d_odata 'CL_TRUE 0 memSize h_odata (make-vector 0))
  
  ;clean up
  (clReleaseMemObject d_idata)
  (clReleaseMemObject d_odata)
  (clReleaseKernel kernel))
  
  

(define (runTest)
  (define sizeX 2048)
  (define sizeY 2048)
  (define memSize (* sizeX sizeY (ctype-sizeof _float)))
  
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
  
  (transposeGPU #"transpose_naive" #f h_idata h_odata sizeX sizeY commandQueue context program)
  
  (define reference (malloc memSize 'raw))
  (compute-gold reference h_idata sizeX sizeY)
  (display "\nComparing results with CPU computation... \n\n")
  (printf "~a~n~n" (if (compareArrays reference h_odata (* sizeX sizeY)) "Passed" "Failed"))
  
  (transposeGPU #"transpose" #t h_idata h_odata sizeX sizeY commandQueue context program)
  
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