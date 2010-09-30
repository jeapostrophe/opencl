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

;;;; clGetEventProfilingInfo
(define-opencl-info
  clGetEventProfilingInfo
  (clGetEventProfilingInfo:length clGetEventProfilingInfo:generic)
  _cl_profiling_info _cl_profiling_info/c
  (args [event : _cl_event _cl_event/c])
  (error status 
         (cond [(= status CL_PROFILING_INFO_NOT_AVAILABLE)
                (error 'clGetEventProfilingInfo "the CL_QUEUE_PROFILING_ENABLE flag is not set for the command-queue and if the profiling information is currently not available (because the command identified by event has not completed)")]
               [(= status CL_INVALID_VALUE)
                (error 'clGetEventProfilingInfo "param_name is not valid or if size in bytes specified by param_value_size is < size of return type and param_value is not NULL")]
               [(= status CL_INVALID_EVENT)
                (error 'clGetEventProfilingInfo "event is not a valid event object")]
               [else
                (error 'clGetEventProfilingInfo "Invalid error code: ~e" status)]))
  (variable param_value_size)
  (fixed [_cl_ulong _cl_ulong/c CL_PROFILING_COMMAND_QUEUED CL_PROFILING_COMMAND_SUBMIT CL_PROFILING_COMMAND_START CL_PROFILING_COMMAND_END]))