#lang scheme
(require (planet jaymccarthy/opencl/scheme)
         scheme/foreign
         scheme/runtime-path)
(unsafe!)

(define (cvector->vector cv)
  (list->vector (cvector->list cv)))

(define (power-of-two? x)
  (define n (inexact->exact x))
  (zero? (bitwise-and n (sub1 n))))

(define (pow-two x)
  (floor (/ (exp x) (exp 2))))

;;;;;
(define GROUP-SIZE 256)
(define NUM_BANKS 16)
(define MAX_ERROR 1e-7)

(define iterations 1000)
(define count (* 1024 1024))

(define float-data (malloc _float count 'raw))
(for ([i (in-range count)])
  (ptr-set! float-data _float i (* 10 (random))))

(define devices (platform-devices #f 'CL_DEVICE_TYPE_GPU))
(define device-id (cvector-ref devices 0))

(define max-workgroup-size (device-info device-id 'CL_DEVICE_MAX_WORK_GROUP_SIZE))

(set! GROUP-SIZE (min GROUP-SIZE max-workgroup-size))

(define vendor-name (device-info device-id 'CL_DEVICE_VENDOR))
(define device-name (device-info device-id 'CL_DEVICE_NAME))

(printf "Connecting to ~a ~a~n" vendor-name device-name)

(printf "Loading program~n")
(define-runtime-path program-source-path "scan_kernel.cl")
(define program-source (file->bytes program-source-path))

(define context (devices->context (vector device-id)))
(define queue (make-command-queue context device-id empty))
(define program (make-program/source context (vector program-source)))
(program-build! program (vector device-id) #"")

(define kernel-names 
  (list #"PreScanKernel"
        #"PreScanStoreSumKernel"
        #"PreScanStoreSumNonPowerOfTwoKernel"
        #"PreScanNonPowerOfTwoKernel"
        #"UniformAddKernel"))
(define kernels
  (for/hash ([kn (in-list kernel-names)])
    (define k (program-kernel program kn))
    (set! GROUP-SIZE 
          (min GROUP-SIZE (kernel-work-group-info k device-id 'CL_KERNEL_WORK_GROUP_SIZE)))
    (values kn k)))

(printf "Setting up buffers~n")
(define buffer-size (* (ctype-sizeof _float) count))
(define input (make-buffer context 'CL_MEM_READ_WRITE buffer-size #f))

(define inputw-evt (enqueue-write-buffer! queue input 'CL_TRUE 0 buffer-size float-data (vector)))
(event-release! inputw-evt)

(define output (make-buffer context 'CL_MEM_READ_WRITE buffer-size #f))

(define result (malloc _float count 'raw))
(memset result 0 0 count _float)

(define outputw-evt (enqueue-write-buffer! queue output 'CL_TRUE 0 buffer-size result (vector)))
(event-release! outputw-evt)

(define scan-partial-sums #f)
(define elements-allocated 0)
(define levels-allocated 0)

(define-syntax-rule (while test body)
  (let loop ()
    (when test
      body
      (loop))))
(define-syntax-rule (do-while body test)
  (begin body (while test body)))
(define-syntax-rule (++ id)
  (begin0 id
          (set! id (add1 id))))
(define (create-partial-sum-buffers count)
  (set! elements-allocated count)
  (local [(define group-size GROUP-SIZE)
          (define element-count count)
          (define level 0)]
    (do-while
     (local [(define group-count (max 1 (ceiling (/ element-count (* 2 group-size)))))]
       (when (> group-count 1)
         (++ level))
       (set! element-count group-count))
     (> element-count 1))
    (set! scan-partial-sums (make-vector level #f))
    (set! levels-allocated level)
    (set! element-count count)
    (set! level 0)
    (do-while
     (local [(define group-count (max 1 (ceiling (/ element-count (* 2 group-size)))))]
       (when (> group-count 1)
         (local [(define bufer-size (* group-count (ctype-sizeof _float)))]
           (vector-set! scan-partial-sums
                        (++ level)
                        (make-buffer context 'CL_MEM_READ_WRITE buffer-size #f))))
       (set! element-count group-count))
     (> element-count 1))))

(printf "Creating partial sums~n")
(create-partial-sum-buffers count)

(define (pre-scan global local-work shared output-data input-data n group-index base-index)
  (define k (hash-ref kernels #"PreScanKernel"))
  (set-kernel-arg:_cl_mem! k 0 output-data)
  (set-kernel-arg:_cl_mem! k 1 input-data)
  (set-kernel-arg:local! k 2 shared)
  (set-kernel-arg:_cl_int! k 3 group-index)
  (set-kernel-arg:_cl_int! k 4 base-index)
  (set-kernel-arg:_cl_int! k 5 n)
  (enqueue-nd-range-kernel! queue k 1 global local-work (vector)))

(define (pre-scan-store-sum global local-work shared output-data input-data partial-sums n group-index base-index)
  (define k (hash-ref kernels #"PreScanStoreSumKernel"))
  (set-kernel-arg:_cl_mem! k 0 output-data)
  (set-kernel-arg:_cl_mem! k 1 input-data)
  (set-kernel-arg:_cl_mem! k 2 partial-sums)
  (set-kernel-arg:local! k 3 shared)
  (set-kernel-arg:_cl_int! k 4 group-index)
  (set-kernel-arg:_cl_int! k 5 base-index)
  (set-kernel-arg:_cl_int! k 6 n)
  (enqueue-nd-range-kernel! queue k 1 global local-work (vector)))

(define (pre-scan-store-sum-non-power-of-two global local-work shared output-data input-data partial-sums n group-index base-index)
  (define k (hash-ref kernels #"PreScanStoreSumNonPowerOfTwoKernel"))
  (set-kernel-arg:_cl_mem! k 0 output-data)
  (set-kernel-arg:_cl_mem! k 1 input-data)
  (set-kernel-arg:_cl_mem! k 2 partial-sums)
  (set-kernel-arg:local! k 3 shared)
  (set-kernel-arg:_cl_int! k 4 group-index)
  (set-kernel-arg:_cl_int! k 5 base-index)
  (set-kernel-arg:_cl_int! k 6 n)
  (enqueue-nd-range-kernel! queue k 1 global local-work (vector)))

(define (pre-scan-non-power-of-two global local-work shared output-data input-data n group-index base-index)
  (define k (hash-ref kernels #"PreScanNonPowerOfTwoKernel"))
  (set-kernel-arg:_cl_mem! k 0 output-data)
  (set-kernel-arg:_cl_mem! k 1 input-data)
  (set-kernel-arg:local! k 2 shared)
  (set-kernel-arg:_cl_int! k 3 group-index)
  (set-kernel-arg:_cl_int! k 4 base-index)
  (set-kernel-arg:_cl_int! k 5 n)
  (enqueue-nd-range-kernel! queue k 1 global local-work (vector)))

(define (uniform-add global local-work output-data partial-sums n group-offset base-index)
  (define k (hash-ref kernels #"UniformAddKernel"))
  (set-kernel-arg:_cl_mem! k 0 output-data)
  (set-kernel-arg:_cl_mem! k 1 partial-sums)
  (set-kernel-arg:local! k 2 (ctype-sizeof _float))
  (set-kernel-arg:_cl_int! k 3 group-offset)
  (set-kernel-arg:_cl_int! k 4 base-index)
  (set-kernel-arg:_cl_int! k 5 n)
  (enqueue-nd-range-kernel! queue k 1 global local-work (vector)))

(define (pre-scan-buffer-rec output-data input-data max-group-size max-work-item-count element-count level)
  (define group-size max-group-size)
  (define group-count (max 1.0 (ceiling (/ element-count (* 2.0 group-size)))))
  (define work-item-count
    (min max-work-item-count
         (cond [(> group-size 1)
                group-size]
               [(power-of-two? element-count)
                (/ element-count 2)]
               [else
                (pow-two element-count)])))
  (define element-count-per-group (* work-item-count 2))
  (define last-group-element-count 
    (- element-count (* (sub1 group-count) element-count-per-group)))
  (define remaining-work-item-count
    (min max-work-item-count (max 1.0 (/ last-group-element-count 2))))
  (define remainder 0)
  (define last-shared 0)
  (unless (= last-group-element-count 
             element-count-per-group)
    (set! remainder 1)
    (unless (power-of-two? last-group-element-count)
      (set! remaining-work-item-count
            (min max-work-item-count
                 (pow-two last-group-element-count))))
    (set! last-shared 
          (* (ctype-sizeof _float)
             2
             (+ remaining-work-item-count 
                (/ (* 2 remaining-work-item-count)
                   NUM_BANKS)))))
  
  (local [(define global (vector (inexact->exact (* (max 1 (- group-count remainder)) work-item-count)) 1))
          (define local-work (vector (inexact->exact work-item-count) 1))
          (define shared
            (* (ctype-sizeof _float)
               (+ element-count-per-group
                  (/ element-count-per-group NUM_BANKS))))]
    (cond
      [(> group-count 1)
       (local [(define partial-sums (vector-ref scan-partial-sums level))]
         (pre-scan-store-sum global local-work shared
                             output-data input-data
                             partial-sums 
                             (inexact->exact (* work-item-count 2))
                             0 0)
         (unless (zero? remainder)
           (local [(define last-global (vector (* 1 remaining-work-item-count) 1))
                   (define last-local (vector remaining-work-item-count 1))]
             (pre-scan-store-sum-non-power-of-two
              last-global last-local last-shared
              output-data input-data partial-sums
              (inexact->exact last-group-element-count)
              (inexact->exact (sub1 group-count))
              (inexact->exact (- element-count last-group-element-count)))))
         (pre-scan-buffer-rec partial-sums partial-sums 
                              max-group-size max-work-item-count
                              group-count (add1 level))
         (uniform-add global local-work output-data partial-sums
                      (inexact->exact (- element-count last-group-element-count))
                      0 0)
         (unless (zero? remainder)
           (local [(define last-global (vector (* 1 remaining-work-item-count) 1))
                   (define last-local (vector remaining-work-item-count 1))]
             (uniform-add last-global last-local
                          output-data partial-sums
                          (inexact->exact last-group-element-count)
                          (inexact->exact (sub1 group-count))
                          (inexact->exact (- element-count last-group-element-count))))))]
      [(power-of-two? element-count)
       (pre-scan global local-work shared output-data input-data
                 (inexact->exact (* 2 work-item-count)) 0 0)]
      [else
       (pre-scan-non-power-of-two global local-work shared output-data input-data
                                  (inexact->exact element-count) 0 0)])))

(define (pre-scan-buffer output-data input-data max-group-size max-work-item-count element-count)
  (pre-scan-buffer-rec output-data input-data max-group-size max-work-item-count element-count 0))

(printf "Prescanning~n")
(pre-scan-buffer output input GROUP-SIZE GROUP-SIZE count)

(printf "Starting timing run of ~a iterations~n" iterations)
(define t0 (current-inexact-milliseconds))
(for ([i (in-range iterations)])
  (pre-scan-buffer output input GROUP-SIZE GROUP-SIZE count))

(command-queue-finish! queue)
(define t1 (current-inexact-milliseconds))

(define t (- t1 t0))
(printf "Exec Time: ~a ms~n" (/ t iterations))
(printf "Throughput: ~a GB/sec~n" (/ (* 1e-9 buffer-size iterations) t))

(define outputr-evt (enqueue-read-buffer! queue output 'CL_TRUE 0 buffer-size result (vector)))
(event-release! outputr-evt)

(define reference (malloc _float count 'raw))

(define (scan-reference reference input count)
  (define total-sum 0)
  (ptr-set! reference _float 0 0.0)
  (for ([i (in-range count)])
    (define last-i (ptr-ref input _float (sub1 i)))
    (set! total-sum (+ total-sum last-i))
    (ptr-set! reference _float i (+ last-i (ptr-ref reference _float (sub1 i)))))
  (unless (= total-sum (ptr-ref reference _float (sub1 count)))
    (fprintf (current-error-port) "Warning: Exceeding single-precision accuracy. Scan will be inaccurate~n")))

(scan-reference reference float-data count)

(define error -inf.0)
(for ([i (in-range count)])
  (define diff 
    (abs (- (ptr-ref reference _float i)
            (ptr-ref result _float i))))
  (set! error (max error diff)))

(printf "Maximum error: ~a~n" error)

(define (release-partial-sums)
  (for ([i (in-range levels-allocated)])
    (memobj-release! (vector-ref scan-partial-sums i)))
  (set! elements-allocated 0)
  (set! levels-allocated 0))

(release-partial-sums)
(free result)
(memobj-release! output)
(memobj-release! input)
(for ([k (in-hash-values kernels)])
  (kernel-release! k))
(program-release! program)
(command-queue-release! queue)
(context-release! context)
(free float-data)