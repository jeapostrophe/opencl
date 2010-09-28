#lang racket
(require "../../c.ss")
(require "../utils/utils.rkt")
(require ffi/cvector)
(require ffi/unsafe/cvector)
(require ffi/unsafe)

; defines, project
(define MEMCOPY_ITERATIONS  100)
(define DEFAULT_SIZE        (* 32 (arithmetic-shift 1 20)))    ;32 M
(define DEFAULT_INCREMENT   (arithmetic-shift 1 22))           ;4 M
(define CACHE_CLEAR_SIZE    (arithmetic-shift 1 24))           ;16 M

; shmoo mode defines
(define SHMOO_MEMSIZE_MAX     (arithmetic-shift 1 26))         ;64 M
(define SHMOO_MEMSIZE_START   (arithmetic-shift 1 10))         ;1 KB
(define SHMOO_INCREMENT_1KB   (arithmetic-shift 1 10))         ;1 KB
(define SHMOO_INCREMENT_2KB   (arithmetic-shift 1 11))         ;2 KB
(define SHMOO_INCREMENT_10KB  (* 10 (arithmetic-shift 1 10)))  ;10KB
(define SHMOO_INCREMENT_100KB (* 100 (arithmetic-shift 1 10))) ;100 KB
(define SHMOO_INCREMENT_1MB   (arithmetic-shift 1 20))         ;1 MB
(define SHMOO_INCREMENT_2MB   (arithmetic-shift 1 21))         ;2 MB
(define SHMOO_INCREMENT_4MB   (arithmetic-shift 1 22))         ;4 MB
(define SHMOO_LIMIT_20KB      (* 20 (arithmetic-shift 1 10)))  ;20 KB
(define SHMOO_LIMIT_50KB      (* 50 (arithmetic-shift 1 10)))  ;50 KB
(define SHMOO_LIMIT_100KB     (* 100 (arithmetic-shift 1 10))) ;100 KB
(define SHMOO_LIMIT_1MB       (arithmetic-shift 1 20))         ;1 MB
(define SHMOO_LIMIT_16MB      (arithmetic-shift 1 24))         ;16 MB
(define SHMOO_LIMIT_32MB      (arithmetic-shift 1 25))         ;32 MB

;enums, project
;(define testMode '(QUICK_MODE RANGE_MODE SHMOO_MODE))
;(define memcpyKind '(DEVICE_TO_HOST HOST_TO_DEVICE DEVICE_TO_DEVICE))
;(define printMode '(USER_READABLE CSV))
;(define memoryMode '(PAGEABLE PINNED))
;(define accessMode '(MAPPED DIRECT))

;(current-command-line-arguments 
 ;#("--help"))
 ; #("--access" "mapped" "--memory" "pinned" "--mode" "shmoo"))
; #("--mode" "shmoo"))

(define device (make-parameter 0))
(define accMode (make-parameter 'DIRECT))
(define memMode (make-parameter 'PAGEABLE))
(define testMode (make-parameter 'QUICK_MODE))
(define htod (make-parameter #f))
(define dtoh (make-parameter #f))
(define dtod (make-parameter #f))
(define start (make-parameter DEFAULT_SIZE))
(define end (make-parameter DEFAULT_SIZE))
(define increment (make-parameter DEFAULT_INCREMENT))

(define startDevice (make-parameter 0))
(define endDevice (make-parameter 0))

(define queue #f)

(command-line
 #:program "oclBandwidthTest"
 #:help-labels
 "Options:"
 #:once-each
 ["--device" deviceNo
             ("Specify the device to be used"
              "all - compute cumulative bandwidth on all the devices"
              "0,1,2,...,n - Specify any particular device to be used")
             (if (string->number deviceNo) 
                 (device (string->number deviceNo)) 
                 (device deviceNo))]
 ["--access" accessMode
             ("Specify which memory access mode to use"
              "direct   - direct device memory"
              "mapped   - mapped device memory")
             (accMode (string->symbol (string-upcase accessMode)))]
 ["--memory" memoryMode
             ("Specify which memory mode to use"
              "pagable   - pageble memory"
              "pinned    - pinned memory")
             (memMode (string->symbol (string-upcase memoryMode)))]
 ["--mode" mode
           ("Specify the mode to use"
            "quick - performs a quick measurement"
            "range - measures a user-specified range of values"
            "shmoo - performs an intense shmoo of a large range of values")
           (testMode (string->symbol (string-append (string-upcase mode) "_MODE")))]
 ["--htod" "Measure host to device transfers"
           (htod #t)]
 ["--dtoh" "Measure device to host transfers"
           (dtoh #t)]
 ["--dtod" "Measure device to device transfers"
           (dtod #t)]
 #:help-labels
 "Range Mode Options:"
 #:once-each
 ["--start" size
            "Starting transfer size in bytes"
            (start (string->number size))]
 ["--end" size
          "Ending transfer size in bytes"
          (end (string->number size))]
 ["--increment" size
                "Increment size in bytes"
                (increment (string->number size))])

;definition of createQueue
(define (createQueue device)
  (when queue (clReleaseCommandQueue queue))
  (set! queue (clCreateCommandQueue context device 'CL_QUEUE_PROFILING_ENABLE)))

;definition of testHostToDeviceTransfer
(define (testHostToDeviceTransfer memSize)
  (define h_data #f)
  (define cmDevData #f)
  (define cmPinnedData #f)
  (define dm_idata #f)
  (define event #f)
  (if (equal? (memMode) 'PINNED)
      (begin
        (set! cmPinnedData (clCreateBuffer context '(CL_MEM_READ_WRITE CL_MEM_ALLOC_HOST_PTR) memSize #f))
        (set!-values (event h_data) (clEnqueueMapBuffer queue cmPinnedData 'CL_TRUE 'CL_MAP_WRITE 0 memSize (make-vector 0)))
        (for ([i (in-range (/ memSize (ctype-sizeof _int)))])
          (ptr-set! h_data _int i i))
        (clEnqueueUnmapMemObject queue cmPinnedData h_data (make-vector 0)))
      (begin
        (set! h_data (malloc memSize 'raw))
        (for ([i (in-range (/ memSize (ctype-sizeof _int)))])
          (ptr-set! h_data _int i i))))
  ;allocate device memory
  (set! cmDevData (clCreateBuffer context 'CL_MEM_READ_WRITE memSize #f))
  (clFinish queue)
  (deltaT 0)
  (if (equal? (accMode) 'DIRECT)
      (begin
        (when (equal? (memMode) 'PINNED)
          (set!-values (event h_data) (clEnqueueMapBuffer queue cmPinnedData 'CL_TRUE 'CL_MAP_WRITE 0 memSize (make-vector 0))))
        (for ([i (in-range MEMCOPY_ITERATIONS)])
          (clEnqueueWriteBuffer queue cmDevData 'CL_FALSE 0 memSize h_data (make-vector 0)))
        (clFinish queue))
      (begin
        (set!-values (event dm_idata) (clEnqueueMapBuffer queue cmDevData 'CL_TRUE 'CL_MAP_READ 0 memSize (make-vector 0)))
        (for ([i (in-range MEMCOPY_ITERATIONS)])
          (memcpy dm_idata h_data memSize))))
  (define elapsedTimeInSeconds (deltaT 0))
  (define bandwidthInMBs (/ (* memSize MEMCOPY_ITERATIONS) (* elapsedTimeInSeconds (arithmetic-shift 1 20))))
  ;free memory
  (when cmDevData (clReleaseMemObject cmDevData))
  (when cmPinnedData
    (clEnqueueUnmapMemObject queue cmPinnedData h_data (make-vector 0))
    (clReleaseMemObject cmPinnedData))
  bandwidthInMBs)  

;definition of testDeviceToHostTransfer
(define (testDeviceToHostTransfer memSize)
  (define h_data #f)
  (define cmDevData #f)
  (define cmPinnedData #f)
  (define dm_idata #f)
  (define event #f)
  (if (equal? (memMode) 'PINNED)
      (begin
        (set! cmPinnedData (clCreateBuffer context '(CL_MEM_READ_WRITE CL_MEM_ALLOC_HOST_PTR) memSize #f))
        (set!-values (event h_data) (clEnqueueMapBuffer queue cmPinnedData 'CL_TRUE 'CL_MAP_WRITE 0 memSize (make-vector 0)))
        (for ([i (in-range (/ memSize (ctype-sizeof _int)))])
          (ptr-set! h_data _int i i))
        (clEnqueueUnmapMemObject queue cmPinnedData h_data (make-vector 0)))
      (begin
        (set! h_data (malloc memSize 'raw))
        (for ([i (in-range (/ memSize (ctype-sizeof _int)))])
          (ptr-set! h_data _int i i))))
  ;allocate device memory
  (set! cmDevData (clCreateBuffer context 'CL_MEM_READ_WRITE memSize #f))
  ;initialize device memory
  (if (equal? (memMode) 'PINNED)
      (begin
        (set!-values (event h_data) (clEnqueueMapBuffer queue cmPinnedData 'CL_TRUE 'CL_MAP_WRITE 0 memSize (make-vector 0)))
        (clEnqueueWriteBuffer queue cmDevData 'CL_FALSE 0 memSize h_data (make-vector 0)))
      (clEnqueueWriteBuffer queue cmDevData 'CL_FALSE 0 memSize h_data (make-vector 0)))
  (clFinish queue)
  (deltaT 0)
  (if (equal? (accMode) 'DIRECT)
      (begin
        (for ([i (in-range MEMCOPY_ITERATIONS)])
          (clEnqueueReadBuffer queue cmDevData 'CL_FALSE 0 memSize h_data (make-vector 0)))
        (clFinish queue))
      (begin
        (set!-values (event dm_idata) (clEnqueueMapBuffer queue cmDevData 'CL_TRUE 'CL_MAP_READ 0 memSize (make-vector 0)))
        (for ([i (in-range MEMCOPY_ITERATIONS)])
          (memcpy dm_idata h_data memSize))))
  (define elapsedTimeInSeconds (deltaT 0))
  (define bandwidthInMBs (/ (* memSize MEMCOPY_ITERATIONS) (* elapsedTimeInSeconds (arithmetic-shift 1 20))))
  ;free memory
  (when cmDevData (clReleaseMemObject cmDevData))
  (when cmPinnedData
    (clEnqueueUnmapMemObject queue cmPinnedData h_data (make-vector 0))
    (clReleaseMemObject cmPinnedData))
  bandwidthInMBs)

;definition of testDeviceToDeviceTransfer
(define (testDeviceToDeviceTransfer memSize)
  (define h_idata (malloc memSize 'raw))
  (for ([i (in-range (/ memSize (ctype-sizeof _int)))])
    (ptr-set! h_idata _int i i))
  ;allocate device input and output memory and initialize the device input memory
  (define d_idata (clCreateBuffer context 'CL_MEM_READ_ONLY memSize #f))
  (define d_odata (clCreateBuffer context 'CL_MEM_WRITE_ONLY memSize #f))
  (clEnqueueWriteBuffer queue d_idata 'CL_TRUE 0 memSize h_idata (make-vector 0))
  (clFinish queue)
  (deltaT 0)
  (for ([i (in-range MEMCOPY_ITERATIONS)])
    (clEnqueueCopyBuffer queue d_idata d_odata 0 0 memSize (make-vector 0)))
  (clFinish queue)
  (define elapsedTimeInSeconds (deltaT 0))
  ;Calculate bandwidth in MB/s 
  ;  This is for kernels that read and write GMEM simultaneously 
  ;  Obtained Throughput for unidirectional block copies will be 1/2 of this #
  (define bandwidthInMBs (* 2.0 (/ (* memSize MEMCOPY_ITERATIONS) (* elapsedTimeInSeconds (arithmetic-shift 1 20)))))
  ;clean up
  (free h_idata)
  (clReleaseMemObject d_idata)
  (clReleaseMemObject d_odata)
  bandwidthInMBs)

;definition of printResults
(define (printResults memSizesReversed bandwidthsReversed count memcpyKind numDevices)
  (define memSizes (reverse memSizesReversed))
  (define bandwidths (reverse bandwidthsReversed))
  (cond
    [(equal? memcpyKind 'DEVICE_TO_DEVICE)
     (printf "Device to Device Bandwidth, ~a Device(s)~n" numDevices)]
    [else
     (cond
       [(equal? memcpyKind 'DEVICE_TO_HOST)
        (printf "Device to Host Bandwidth, ~a Device(s), " numDevices)]
       [(equal? memcpyKind 'HOST_TO_DEVICE)
        (printf "Host to Device Bandwidth, ~a Device(s), " numDevices)])
     (cond
       [(equal? (memMode) 'PAGEABLE)
        (printf "Paged memory")]
       [(equal? (memMode) 'PINNED)
        (printf "Pinned memory")])
     (cond
       [(equal? (accMode) 'DIRECT) 
        (printf ", direct access~n")]
       [(equal? (accMode) 'MAPPED)
        (printf ", mapped access~n")])])
  (printf "   Transfer Size (Bytes)\tBandwidth(MB/s)~n")
  (for ([i (in-range count)])
    (printf "   ~a\t\t\t~a~a~n" (list-ref memSizes i) (if (< (list-ref memSizes i) 10000) "\t" "") (real->decimal-string (list-ref bandwidths i) 1)))
  (display "\n"))

;definition of testBandwidthRange
(define (testBandwidthRange memcpyKind)
  (define count (+ 1 (/ (- (end) (start)) (increment))))
  (define memSizes '())
  (define bandwidths '())
  (for ([device deviceVec])
    (createQueue device)
    (for ([i (in-range count)])
      (set! memSizes (cons (+ (start) (* i (increment))) memSizes))
      (match memcpyKind
        ['HOST_TO_DEVICE
         (set! bandwidths (cons (testHostToDeviceTransfer (first memSizes)) bandwidths))]
        ['DEVICE_TO_HOST
         (set! bandwidths (cons (testDeviceToHostTransfer (first memSizes)) bandwidths))]
        ['DEVICE_TO_DEVICE
         (set! bandwidths (cons (testDeviceToDeviceTransfer (first memSizes)) bandwidths))])))
  (printResults memSizes bandwidths count memcpyKind (+ 1 (- (endDevice) (startDevice)))))

;definition of testBandwidthQuick
(define (testBandwidthQuick memcpyKind)
  (parameterize
      ([start DEFAULT_SIZE]
       [end DEFAULT_SIZE]
       [increment DEFAULT_INCREMENT])
    (testBandwidthRange memcpyKind)))

;definition of testBandwidthShmoo
(define (testBandwidthShmoo memcpyKind)
  (define count (truncate (+ 1 (/ SHMOO_LIMIT_20KB SHMOO_INCREMENT_1KB)
                             (/ (- SHMOO_LIMIT_50KB SHMOO_LIMIT_20KB) SHMOO_INCREMENT_2KB)
                             (/ (- SHMOO_LIMIT_100KB SHMOO_LIMIT_50KB) SHMOO_INCREMENT_10KB)
                             (/ (- SHMOO_LIMIT_1MB SHMOO_LIMIT_100KB) SHMOO_INCREMENT_100KB)
                             (/ (- SHMOO_LIMIT_16MB SHMOO_LIMIT_1MB) SHMOO_INCREMENT_1MB)
                             (/ (- SHMOO_LIMIT_32MB SHMOO_LIMIT_16MB) SHMOO_INCREMENT_2MB)
                             (/ (- SHMOO_MEMSIZE_MAX SHMOO_LIMIT_32MB) SHMOO_INCREMENT_4MB))))
  (define memSizes '())
  (define bandwidths '())
  (for ([device deviceVec])
    (createQueue device)
    
    (define-syntax-rule (while test body-e ...)
      (let loop ()
        (when test
          body-e
          ...
          (loop))))
    
    (define memSize 0)
    (while (memSize . <= . SHMOO_MEMSIZE_MAX)
           (cond
             [(< memSize SHMOO_LIMIT_20KB) (set! memSize (+ memSize SHMOO_INCREMENT_1KB))]
             [(< memSize SHMOO_LIMIT_50KB) (set! memSize (+ memSize SHMOO_INCREMENT_2KB))]
             [(< memSize SHMOO_LIMIT_100KB) (set! memSize (+ memSize SHMOO_INCREMENT_10KB))]
             [(< memSize SHMOO_LIMIT_1MB) (set! memSize (+ memSize SHMOO_INCREMENT_100KB))]
             [(< memSize SHMOO_LIMIT_16MB) (set! memSize (+ memSize SHMOO_INCREMENT_1MB))]
             [(< memSize SHMOO_LIMIT_32MB) (set! memSize (+ memSize SHMOO_INCREMENT_2MB))]
             [else (set! memSize (+ memSize SHMOO_INCREMENT_4MB))])
           (set! memSizes (cons memSize memSizes))
           (match memcpyKind
             ['HOST_TO_DEVICE
              (set! bandwidths (cons (testHostToDeviceTransfer (first memSizes)) bandwidths))]
             ['DEVICE_TO_HOST
              (set! bandwidths (cons (testDeviceToHostTransfer (first memSizes)) bandwidths))]
             ['DEVICE_TO_DEVICE
              (set! bandwidths (cons (testDeviceToDeviceTransfer (first memSizes)) bandwidths))])))
  (printResults memSizes bandwidths count memcpyKind (+ 1 (- (endDevice) (startDevice)))))

;definition of testBandwidth
(define (testBandwidth memcpyKind)
  (match (testMode)
    ['QUICK_MODE
     (testBandwidthQuick memcpyKind)]
    ['RANGE_MODE
     (testBandwidthRange memcpyKind)]
    ['SHMOO_MODE
     (testBandwidthShmoo memcpyKind)]))

;Start main program execution
(display "oclBandwidthTest Starting...\n\n")

;get platform
(define firstPlatform (cvector-ref (clGetPlatformIDs:vector) 0))

;get OpenCL devices
(define devices (clGetDeviceIDs:vector firstPlatform 'CL_DEVICE_TYPE_GPU))

;set begin and end device
(cond [(equal? (device) "all")
       (endDevice (- (cvector-length devices) 1))]
      [else (startDevice (device))
            (endDevice (device))])

;display devices used in test
(display "Running on...\n")
(for ([device (in-list (cvector->list devices))]
      [i (in-range (+ (endDevice) 1))])
  (printf "~a~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_NAME)))
(display "\n")

;display mode
(printf "~a~n~n"
        (regexp-replace "_"
                        (string-titlecase (symbol->string (testMode)))
                        " "))

;set transfer modes if none specified on command line
(unless (or (htod) (dtoh) (dtod))
  (htod #t)
  (dtoh #t)
  (dtod #t))

;create OpenCL context                
(define deviceVec (cvector->vector devices) #;(list->vector (cvector->list devices))) ;shouldn't have to do this
(define context (clCreateContext deviceVec)) ;change to devices when fixed

;run tests
(when (htod)
  (testBandwidth 'HOST_TO_DEVICE))
(when (dtoh)
  (testBandwidth 'DEVICE_TO_HOST))
(when (dtod)
  (testBandwidth 'DEVICE_TO_DEVICE))

;cleanup
(when queue (clReleaseCommandQueue queue))
(when context (clReleaseContext context))

(display "\n\nPassed")