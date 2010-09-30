#lang at-exp racket/base
(require racket/foreign
         (except-in racket/contract ->)
         scribble/srcdoc  
         (file "include/cl.rkt")
         (file "lib.rkt")
         (file "syntax.rkt")
         (file "types.rkt"))
(require/doc racket/base
             scribble/manual
             (for-label (file "../../c/types.rkt")))

;;;;
(define-opencl clFlush
  (_fun [command_queue : _cl_command_queue]
        -> [status : _cl_int]
        -> (cond
             [(= status CL_SUCCESS)
              (void)]
             [(= status CL_INVALID_COMMAND_QUEUE) 
              (error 'clFlush "command_queue is not a valid command-queue")]
             [(= status CL_OUT_OF_HOST_MEMORY)
              (error 'clFlush "there is a failure to allocate resources required by the OpenCL implementation on the host")]
             [else
              (error 'clFlush "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc clFlush (->d ([cq _cl_command_queue/c]) () [_ void]) @{}])
;;;;
(define-opencl clFinish
  (_fun [command_queue : _cl_command_queue]
        -> [status : _cl_int]
        -> (cond
             [(= status CL_SUCCESS)
              (void)]
             [(= status CL_INVALID_COMMAND_QUEUE) 
              (error 'clFinish "command_queue is not a valid command-queue")]
             [(= status CL_OUT_OF_HOST_MEMORY)
              (error 'clFinish "there is a failure to allocate resources required by the OpenCL implementation on the host")]
             [else
              (error 'clFinish "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc clFinish (->d ([cq _cl_command_queue/c]) () [_ void]) @{}])