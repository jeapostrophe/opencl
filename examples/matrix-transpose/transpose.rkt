#lang racket
(require (planet jaymccarthy/opencl/racket)
         racket/foreign
         racket/runtime-path)
(unsafe!)

(define PADDING 32)
(define GROUP_DIMX 32)
(define LOG_GROUP_DIMX 5)
(define GROUP_DIMY 2)
(define WIDTH 256)
(define HEIGHT 4096)

(define iterations 100)
(define width WIDTH)
(define height HEIGHT)

(printf "Initialize input data~n")
(define how-much-mem (* (ctype-sizeof _float) width height))
(define how-much-mem+padding (* (ctype-sizeof _float) width (+ height PADDING)))
(define h-data (malloc _float (* width height) 'raw))
(for* ([i (in-range height)]
       [j (in-range width)])
  (ptr-set! h-data _float (+ (* i width) j) (* 10.0 (random))))

(printf "Getting device, context, and queue~n")

(define p (first (cvector->list (system-platforms))))
(define gpu-devices (platform-devices p 'CL_DEVICE_TYPE_DEFAULT))
(define device-id (cvector-ref gpu-devices 0))

(unless device-id
 (error 'transpose "No valid GPU device found on any platform"))

(define context (devices->context (vector device-id)))
(define queue (make-command-queue context device-id empty))

(printf "Loading program~n")
(define-runtime-path program-source-path "transpose_kernel.cl")
(define program-source (file->bytes program-source-path))
(define program (make-program/source context (vector program-source)))

(printf "Building program~n")
(program-build! program (vector device-id) #"")

(printf "Extracting kernel~n")
(define kernel (program-kernel program #"transpose"))

(printf "Creating input array~n")
(define src (make-buffer context 'CL_MEM_READ_WRITE how-much-mem #f))

(printf "Filling the input array~n")
(define write-evt (enqueue-write-buffer! queue src 'CL_TRUE 0 how-much-mem h-data (vector)))
(event-release! write-evt)

(printf "Creating the output array~n")
(define dst (make-buffer context 'CL_MEM_READ_WRITE how-much-mem+padding #f))

(printf "Setting kernel arguments~n")
(set-kernel-arg:_cl_mem! kernel 0 dst)
(set-kernel-arg:_cl_mem! kernel 1 src)
(set-kernel-arg:local! kernel 2 (* (ctype-sizeof _float) GROUP_DIMX (+ 1 GROUP_DIMX)))

(printf "Execute once without timing to guarantee data is on the device~n")
(define global
  (vector (* width GROUP_DIMY)
          (/ height GROUP_DIMX)))
(define local  
  (vector (* GROUP_DIMX GROUP_DIMY)
          1))
(define kernel-evt
  (enqueue-nd-range-kernel! queue kernel 2 global local (vector)))

(printf "Waiting for the queue to finish~n")
(events-wait! (vector kernel-evt))
(event-release! kernel-evt)
; XXX Weird breakage
#;(command-queue-finish! queue)

(printf "Performing Matrix Transpose [~a x ~a]...~n" width height)
(define t0 (current-inexact-milliseconds))
(for ([k (in-range iterations)])
  (define intermediate-evt
    (enqueue-nd-range-kernel! queue kernel 2 global local (vector)))
  (event-release! intermediate-evt))

(command-queue-finish! queue)
(define t1 (current-inexact-milliseconds))

(define t (- t1 t0))
(printf "Bandwidth achieved = ~a GB/sec~n"
        (/ (/ (* how-much-mem iterations)
              (expt 1024 3))
           (/ t
              1000)))

(printf "Reading back results~n")
(define h-result (malloc _float (* width (+ height PADDING)) 'raw))
(define read-evt 
  (enqueue-read-buffer! queue dst 'CL_FALSE 0 how-much-mem+padding h-result (vector)))
(event-release! read-evt)
 
(printf "Verifying results~n")
(define reference (malloc _float (* width height) 'raw))
(for* ([k (in-range height)]
       [l (in-range width)])
  (ptr-set! reference _float
            (+ (* l height) k)
            (ptr-ref h-data _float (+ (* k width) l))))

(printf "Ensuring that read has finished~n")
(command-queue-finish! queue)

(printf "Comparing results~n")
(define max-err -inf.0)
(for* ([l (in-range width)]
       [k (in-range height)])
  (define diff 
    (abs (- (ptr-ref reference _float (+ (* l height) k))
            (ptr-ref h-result _float (+ (* l (+ height PADDING)) k)))))
  (set! max-err (max max-err diff)))

(printf "Freeing everything~n")
(free h-data)
(free h-result)

(memobj-release! src)
(memobj-release! dst)
(kernel-release! kernel)
(program-release! program)
(command-queue-release! queue)
(context-release! context)

(printf "Maximum error was ~a~n" max-err)
