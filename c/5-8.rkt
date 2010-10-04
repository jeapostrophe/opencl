#lang at-exp racket/base
(require ffi/unsafe
         (except-in racket/contract ->)
         (prefix-in c: racket/contract)
         scribble/srcdoc  
         (file "include/cl.rkt")
         (file "lib.rkt")
         (file "syntax.rkt")
         (file "types.rkt"))
(require/doc racket/base
             scribble/manual
             (for-label (file "../../c/types.rkt")))

;;;; clEnqueueMarker
(define-opencl clEnqueueMarker
  (_fun [command_queue : _cl_command_queue]
        [event : (_ptr o _cl_event/null)]
        -> [status : _cl_int]
        ->
        (cond
          [(= status CL_SUCCESS) event]
          [(= status CL_INVALID_COMMAND_QUEUE)
           (error 'clEnqueueMarker "command_queue is not a valid command-queue")]
          [(= status CL_INVALID_VALUE)
           (error 'clEnqueueMarker "event is a NULL value")]
          [(= status CL_OUT_OF_HOST_MEMORY)
           (error 'clEnqueueMarker "there is a failure to allocate resources required by the OpenCL implementation on the host")]
          [else
           (error 'clEnqueueMarker "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc/names clEnqueueMarker (c:-> _cl_command_queue/c _cl_event/c)
                 (cq) @{}])

;;;; clEnqueueWaitForEvents
(define-opencl clEnqueueWaitForEvents
  (_fun [command_queue : _cl_command_queue]
        [num_events : _cl_uint = (vector-length event_list)]
        [event_list : (_vector i _cl_event)]
        -> [status : _cl_int]
        ->
        (cond
          [(= status CL_SUCCESS) (void)]
          [(= status CL_INVALID_COMMAND_QUEUE)
           (error 'clEnqueueWaitForEvents "command_queue is not a valid command-queue")]
          [(= status CL_INVALID_CONTEXT)
           (error 'clEnqueueWaitForEvents "the context associated with command_queue and events in event_list are not the same")]
          [(= status CL_INVALID_VALUE)
           (error 'clEnqueueWaitForEvents "num_events is zero or event_list is NULL")]
          [(= status CL_INVALID_EVENT)
           (error 'clEnqueueWaitForEvents "event objects specified in event_list are not valid events")]          
          [(= status CL_OUT_OF_HOST_MEMORY)
           (error 'clEnqueueWaitForEvents "there is a failure to allocate resources required by the OpenCL implementation on the host")]
          [else
           (error 'clEnqueueWaitForEvents "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc/names clEnqueueWaitForEvents 
           (c:-> _cl_command_queue/c (vectorof _cl_event/c) void)
           (cq wait-list) @{}])

;;;; clEnqueueBarrier
(define-opencl clEnqueueBarrier
  (_fun [command_queue : _cl_command_queue]
        -> [status : _cl_int]
        ->
        (cond
          [(= status CL_SUCCESS) void]
          [(= status CL_INVALID_COMMAND_QUEUE)
           (error 'clEnqueueBarrier "command_queue is not a valid command-queue")]
          [(= status CL_INVALID_VALUE)
           (error 'clEnqueueBarrier "event is a NULL value")]
          [(= status CL_OUT_OF_HOST_MEMORY)
           (error 'clEnqueueBarrier "there is a failure to allocate resources required by the OpenCL implementation on the host")]
          [else
           (error 'clEnqueueBarrier "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc/names clEnqueueBarrier (c:-> _cl_command_queue/c void)
                 (cq) @{}])
