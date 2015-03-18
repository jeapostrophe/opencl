#lang racket
(require ffi/unsafe
         ffi/unsafe/cvector
         opencl/c
         opencl/racket)

(define current-indent (make-parameter 0))
(define-syntax-rule (indent e ...)
  (parameterize ([current-indent (add1 (current-indent))])
    e ...))
(define (iprintf . args)
  (for ([i (in-range (current-indent))])
    (printf "\t"))
  (apply printf args))

(define kernel-source
  (string->bytes/utf-8
   #<<END
__kernel void square(                                                       
   __global float* input,                                              
   __global float* output,                                             
   const unsigned int count)                                           
{                                                                      
   int i = get_global_id(0);                                           
   if(i < count)                                                       
       output[i] = input[i] * input[i];                                 
}                                                                      
END
   ))

(define HOW-MANY (* 1024 1024 24)) 
(define input-v (malloc _float HOW-MANY 'raw))
(define output-v (malloc _float HOW-MANY 'raw))
(define how-much-mem (* HOW-MANY (ctype-sizeof _float)))

(iprintf "Initializing vector...~n")
(for ([i (in-range HOW-MANY)])
  (ptr-set! input-v _float i (random)))
(iprintf "Vector initialized...~n")

(define (test-context d ctxt)
  (clRetainContext ctxt)
  (clReleaseContext ctxt)
  
  (iprintf "Supported Image Formats~n")
  (indent
   (for ([ot (in-list valid-mem-object-types)])
     (iprintf "~a = ~a~n"
              ot (cvector->list (context-supported-image-formats ctxt empty ot)))))
  
  (local [(define program (clCreateProgramWithSource ctxt (vector kernel-source)))            
          (define cq (clCreateCommandQueue ctxt d empty))]
    (clRetainCommandQueue cq)
    (clReleaseCommandQueue cq)
    
    (iprintf "Program infos...~n")
    (indent
     (for ([pi (in-list valid-program-infos)]
           [i (in-range 5)])
       (iprintf "~a = ..." pi)
       (flush-output)
       (define piv (program-info program pi))
       (printf " = ~a\n" piv)))
    
    (iprintf "Command queue infos...~n")
    (indent
     (for ([cqi (in-list valid-command-queue-infos)])
       (iprintf "~a = ~a~n" cqi (command-queue-info cq cqi))))
    
    (iprintf "Compiling the program...~n")
    (clBuildProgram program (vector d) #"")
    
    (iprintf "Program build infos...~n")
    (indent
     (for ([pi (in-list valid-program-build-infos)])
       (iprintf "~a = ~a~n" pi (program-build-info program d pi))))
    
    (iprintf "How many kernels: ~a~n"
             (clCreateKernelsInProgram:count program))
    
    (local [(define kernel (clCreateKernel program #"square"))
            (define input (clCreateBuffer ctxt 'CL_MEM_READ_ONLY how-much-mem #f))
            (define output (clCreateBuffer ctxt 'CL_MEM_WRITE_ONLY how-much-mem #f))
            (define input-evt
              (clEnqueueWriteBuffer cq input 'CL_FALSE 0 how-much-mem input-v (vector)))]
      
      (iprintf "Kernel infos...~n")
      (indent
       (for ([ki (in-list valid-kernel-infos)])
         (iprintf "~a = ~a~n" ki (kernel-info kernel ki))))
      
      (iprintf "Kernel Work Group infos...~n")
      (indent
       (for ([ki (in-list valid-kernel-work-group-infos)])
         (iprintf "~a = ~a~n" ki (kernel-work-group-info kernel d ki))))
      
      (iprintf "Input buffer infos...~n")
      (indent
       (for ([mi (in-list valid-mem-infos)])
         (iprintf "~a = ~a~n" mi (memobj-info input mi))))
      (iprintf "Output buffer infos...~n")
      (indent
       (for ([mi (in-list valid-mem-infos)])
         (iprintf "~a = ~a~n" mi (memobj-info output mi))))
      
      (iprintf "input-evt infos...~n")
      (indent
       (for ([i (in-list valid-event-infos)])
         (iprintf "~a = ~a~n" i (event-info input-evt i))))
      
      (clSetKernelArg:_cl_mem kernel 0 input)
      (clSetKernelArg:_cl_mem kernel 1 output)
      (clSetKernelArg:_cl_uint kernel 2 HOW-MANY)
      
      (local
        [(define work-group-size (kernel-work-group-info kernel d 'CL_KERNEL_WORK_GROUP_SIZE))
         (define kernel-evt
           (clEnqueueNDRangeKernel cq kernel 1 (vector HOW-MANY) (vector work-group-size) (vector input-evt)))
         (define output-evt
           (clEnqueueReadBuffer cq output 'CL_FALSE 0 how-much-mem output-v (vector kernel-evt)))]
        
        (iprintf "kernel-evt infos...~n")
        (indent
         (for ([i (in-list valid-event-infos)])
           (iprintf "~a = ~a~n" i (event-info kernel-evt i))))
        
        (iprintf "output-evt infos...~n")
        (indent
         (for ([i (in-list valid-event-infos)])
           (iprintf "~a = ~a~n" i (event-info output-evt i))))
        
        (clFinish cq)
        
        (iprintf "kernel-evt profiling infos...~n")
        (indent
         (for ([i (in-list valid-profiling-infos)])
           (iprintf "~a = ~a~n" i
                    (with-handlers ([exn:fail? (lambda (x) "[Not available]")])
                      (event-profiling-info kernel-evt i))))))
      
      (local [(define i (random HOW-MANY))]
        (define iv (ptr-ref input-v _float i))
        (define ov (ptr-ref output-v _float i))
        (iprintf "~a. input[~a] opencl-output[~a] racket-output[~a]~n"
                 i iv ov (* iv iv)))
      
      (clReleaseMemObject input)
      (clReleaseMemObject output)
      (clReleaseKernel kernel))
    
    (clReleaseProgram program)
    (clReleaseCommandQueue cq))
  (clReleaseContext ctxt))

(define (query-context ctxt)
  (for ([ci (in-list valid-context-infos)])
    (iprintf "~a = ~a~n"
             ci (context-info ctxt ci))))

; XXX #f is supposed to be allowed by the driver, but may not be
(for ([p (in-list (cvector->list (system-platforms)))])
  (iprintf "Platform is ~a~n" p)
  (indent
   (iprintf "Platform Info~n")
   (indent
    (for ([name (in-list valid-platform-infos)])
      (iprintf "~a = ~a~n"
               name (platform-info p name))))
   (iprintf "Devices~n")
   (indent
    (for ([dty (in-list valid-device-types)])
      (iprintf "Device Type: ~a~n" dty)
      (indent
       (for ([d (in-list 
                 (with-handlers ([exn:fail? (lambda (x) empty)])
                   (cvector->list (platform-devices p dty))))])      
         (iprintf "Device ~a~n" d)
         (indent
          (for ([di (in-list valid-device-infos)])
            (iprintf "~a = ~a~n" di (device-info d di)))
          (iprintf "~n")
          (iprintf "Getting context from device: ~e~n" d)
          (indent
           (local [(define ctxt (clCreateContext #f (vector d)))]
             (query-context ctxt)
             (test-context d ctxt)))))
       (iprintf "Getting context from device type: ~e~n" dty)
       (indent
        (with-handlers ([exn:fail? void])
          (local [(define ctxt (clCreateContextFromType dty))]
            (query-context ctxt)
            (clReleaseContext ctxt)))))))))
