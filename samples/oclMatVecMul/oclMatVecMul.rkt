#lang racket
(require "../../c.ss"
         "../utils/utils.rkt"
         ffi/cvector
         ffi/unsafe/cvector
         ffi/unsafe
         racket/runtime-path)

(define (getTargetDeviceGlobalMemSize)
  ;get platform
  (display " oclGetPlatformID...\n")
  (define platform (cvector-ref (clGetPlatformIDs:vector) 0))
  (display " clGetDeviceIDs")
  (define devices (clGetDeviceIDs:vector platform 'CL_DEVICE_TYPE_GPU))
  (display " clCreateContext...\n")
  (define context (clCreateContext (cvector->vector devices)))
  (display " clGetDeviceInfo...\n")
  (clGetDeviceInfo:generic (cvector-ref devices 0) 'CL_DEVICE_GLOBAL_MEM_SIZE))

(define (matVecMulHost M V width height W)
  (for ([i (in-range height)])
    (define sum 0)
    (for ([j (in-range width)])
      (define a (ptr-ref M _cl_float (+ j (* i width))))
      (define b (ptr-ref V _cl_float j))
      (set! sum (+ sum (* a b))))
    (ptr-set! W _cl_float i sum)))

(define-runtime-path cSourceFile "oclMatVecMul.cl")
(define event #f)
(define kernel #f)
(define width 1100)
(define MAX_HEIGHT 100000)
(define GPU_PROFILING #t)

(display "oclMatVecMul starting...\n\n")
(display "Determining Matrix height from available GPU mem...\n")
(define memSize (getTargetDeviceGlobalMemSize))
(define height (truncate (/ memSize width 16)))
(when (> height MAX_HEIGHT) (set! height MAX_HEIGHT))
(printf " Matrix width\t= ~a~n Matrix height\t= ~a~n~n" width height)

;Allocate and initialize host arrays
(display "Allocate and Init Host Mem...\n\n")
(define size (* width height))
(define memSizeM (* size (ctype-sizeof _cl_float)))
(define memSizeV (* width (ctype-sizeof _cl_float)))
(define memSizeW (truncate (* height (ctype-sizeof _cl_float))))
(define M (malloc memSizeM 'raw))
(define V (malloc memSizeV 'raw))
(define W (malloc memSizeW 'raw))
(define Golden (malloc memSizeW 'raw))
(fillArray M size)
(fillArray V width)
(matVecMulHost M V width height Golden)

;get platform
(display "Get the Platform ID...\n\n")
(define platform (cvector-ref (clGetPlatformIDs:vector) 0))

;get device info
(display "Get the Device info and select Device...\n")
(define-values (devices numDevices) (clGetDeviceIDs platform 'CL_DEVICE_TYPE_GPU 1))
(printf " # of Devices Available = ~a~n" numDevices)
(define targetDevice (cvector-ref devices 0))
(printf " Using Device 0: ~a\n" (clGetDeviceInfo:generic targetDevice 'CL_DEVICE_NAME))
(define numComputeUnits (clGetDeviceInfo:generic targetDevice 'CL_DEVICE_MAX_COMPUTE_UNITS))
(printf " # of Compute Units = ~a~n~n" numComputeUnits)

;create context
(display "clCreateContext...\n")
(define context (clCreateContext (cvector->vector devices)))

;create command queue
(display "clCreateCommandQueue...\n")
(define commandQueue (clCreateCommandQueue context targetDevice '()))
(void (when GPU_PROFILING (clSetCommandQueueProperty commandQueue 'CL_QUEUE_PROFILING_ENABLE 'CL_TRUE)))

;Allocate the OpenCL buffer memory objects for source and result on the device GMEM
(printf "clCreateBuffer (M, V and W in device global memory, mem_size_m = ~a)...~n" memSizeM)
(define cmM (clCreateBuffer context 'CL_MEM_READ_ONLY memSizeM #f))
(define cmV (clCreateBuffer context 'CL_MEM_READ_ONLY memSizeV #f))
(define cmW (clCreateBuffer context 'CL_MEM_WRITE_ONLY memSizeW #f))

;Read the OpenCL kernel in from source file
(printf "oclLoadProgSource (~a)...~n" cSourceFile)
(define sourceBytes (file->bytes cSourceFile))
(display "clCreateProgramWithSource...\n")
(define program (clCreateProgramWithSource context (make-vector 1 sourceBytes)))
(display "clBuildProgram...\n")
(clBuildProgram program (make-vector 1 targetDevice) #"-cl-fast-relaxed-math")

;Core sequence... copy input data to GPU, compute, copy results back

;Asynchronous write of data to GPU device
(display "clEnqueueWriteBuffer (M and V)...\n\n")
(set! event (clEnqueueWriteBuffer commandQueue cmM 'CL_FALSE 0 memSizeM M (make-vector 0)))
(set! event (clEnqueueWriteBuffer commandQueue cmV 'CL_FALSE 0 memSizeV V (make-vector 0)))

;kernels
(define kernels '(#"MatVecMulUncoalesced0"
                  #"MatVecMulUncoalesced1"
                  #"MatVecMulCoalesced0"
                  #"MatVecMulCoalesced1"
                  #"MatVecMulCoalesced2"
                  #"MatVecMulCoalesced3"))

(define passFlag #t)
(for ([k (in-range (length kernels))])
  (printf "Running with Kernel ~a...~n~n" (list-ref kernels k))
  
  ;clear result
  (display "  Clear result with clEnqueueWriteBuffer (W)...\n")
  (memset W 0 memSizeW)
  (set! event (clEnqueueWriteBuffer commandQueue cmW 'CL_FALSE 0 memSizeW W (make-vector 0)))
  
  ;Create the kernel
  (display "  clCreateKernel...\n")
  (when kernel (clReleaseKernel kernel))
  (set! kernel (clCreateKernel program (list-ref kernels k)))
  
  ;Set and log Global and Local work size dimensions
  (define localWorkSize 32)
  (define globalWorkSize 0)
  (if (= k 0)
      (set! globalWorkSize (roundUp localWorkSize height))
      (set! globalWorkSize (* 2 numComputeUnits localWorkSize)))
  (printf "  Global Work Size \t\t= ~a~n  Local Work Size \t\t= ~a~n  # of Work Groups \t\t= ~a~n"
          globalWorkSize localWorkSize (/ globalWorkSize localWorkSize))
  
  ;Set the Argument values
  (display "  clSetKernelArg...\n\n")
  (clSetKernelArg:_cl_mem kernel 0 cmM)
  (clSetKernelArg:_cl_mem kernel 1 cmV)
  (clSetKernelArg:_cl_int kernel 2 width)
  (clSetKernelArg:_cl_int kernel 3 height)
  (clSetKernelArg:_cl_mem kernel 4 cmW)
  (when (> k 1) (clSetKernelArg:local kernel 5 (* localWorkSize (ctype-sizeof _cl_float))))
  
  ;Launch kernel
  (printf "  clEnqueueNDRangeKernel (~a)...~n" (list-ref kernels k))
  (set! event (clEnqueueNDRangeKernel commandQueue kernel 1 (make-vector 1 globalWorkSize) (make-vector 1 localWorkSize) (make-vector 0)))
  
  ;Read back results and check accumulated errors
  (display "  clEnqueueReadBuffer (W)...\n")
  (void (clEnqueueReadBuffer commandQueue cmW 'CL_TRUE 0 memSizeW W (make-vector 0)))
  
  ;Profiling execution time
  (when GPU_PROFILING
    (clWaitForEvents (make-vector 1 event))
    ;(define start (clGetEventProfilingInfo:generic event 'CL_PROFILING_COMMAND_START))
    ;(define end (clGetEventProfilingInfo:generic event 'CL_PROFILING_COMMAND_END))
    ;(define seconds (* 1.0e-9 (- start end)))
    (let* ([start (clGetEventProfilingInfo:generic event 'CL_PROFILING_COMMAND_START)]
           [end (clGetEventProfilingInfo:generic event 'CL_PROFILING_COMMAND_END)]
           [seconds (* 1.0e-9 (- end start))])
      (printf "  Kernel execution time: ~a s~n~n" (real->decimal-string seconds 5))))
  
  ;Compare results for golden-host and report errors and pass/fail
  (display "  Comparing against Host/C++ computation...\n\n")
  (if (compareArraysL2 Golden W height)
      (display "    GPU Result MATCHES CPU Result within allowable tolerance\n\n")
      (begin (display "    GPU Result DOESN'T MATCH CPU Result within allowable tolerance\n\n")
             (set! passFlag #f))))

(printf "~n~a~n~n" (if passFlag "PASSED" "FAILED"))

;Cleanup
(display "Starting Cleanup...\n\n")
(when event (clReleaseEvent event))
(when kernel (clReleaseKernel kernel))
(when program (clReleaseProgram program))
(when commandQueue (clReleaseCommandQueue commandQueue))
(when context (clReleaseContext context))
(when cmM (clReleaseMemObject cmM))
(when cmV (clReleaseMemObject cmV))
(when cmW (clReleaseMemObject cmW))

(free M)
(free V)
(free W)
(free Golden)

(display "oclMatVecMul Exiting...\n")