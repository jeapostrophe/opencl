#lang at-exp racket/base
(require ffi/unsafe
         (except-in racket/contract ->)
         (prefix-in c: racket/contract)
         scribble/srcdoc  
         "include/cl.rkt"
         "lib.rkt"
         "types.rkt")
(require/doc racket/base
             scribble/manual
             (for-label "types.rkt"))

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
 [proc-doc/names clFlush (c:-> _cl_command_queue/c void)
                 (cq) @{}])
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
 [proc-doc/names
  clFinish (c:-> _cl_command_queue/c void)
  (cq) @{}])
