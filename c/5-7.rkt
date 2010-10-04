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

;;;; clWaitForEvents
(define-opencl clWaitForEvents
  (_fun [num_events : _cl_uint = (vector-length event_list)]
        [event_list : (_vector i _cl_event)]
        -> [status : _cl_int]
        ->
        (cond [(= status CL_SUCCESS) 
               (void)]
              [(= status CL_INVALID_VALUE)
               (error 'clWaitForEvents "num_events is zero")]
              [(= status CL_INVALID_CONTEXT)
               (error 'clWaitForEvents "events specified in event_list do not belong to the same context")]
              [(= status CL_INVALID_EVENT)
               (error 'clWaitForEvents "event objects specified in event_list are not valid event objects")]
              [else
               (error 'clWaitForEvents "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc/names clWaitForEvents
           (c:-> (vectorof _cl_event/c) void)
           (wait-list)
           @{}])

;;;; clGetEventInfo
(define-opencl-info
  clGetEventInfo
  (clGetEventInfo:length clGetEventInfo:generic)
  _cl_event_info _cl_event_info/c
  (args [event : _cl_event _cl_event/c])
  (error status 
         (cond [(= status CL_INVALID_VALUE)
                (error 'clGetEventInfo "param_name is not valid or if size in bytes specified by param_value_size is < size of return type and param_value is not NULL")]
               [(= status CL_INVALID_EVENT)
                (error 'clGetEventInfo "event is not a valid event object")]
               [else
                (error 'clGetEventInfo "Invalid error code: ~e" status)]))
  (variable param_value_size)
  (fixed [_cl_command_queue _cl_command_queue/c CL_EVENT_COMMAND_QUEUE]
         [_cl_command_type _cl_command_type/c CL_EVENT_COMMAND_TYPE]
         [_command_execution_status _command_execution_status/c CL_EVENT_COMMAND_EXECUTION_STATUS]
         [_cl_uint _cl_uint/c CL_EVENT_REFERENCE_COUNT]))

;;;;
(define-opencl clRetainEvent
  (_fun [event : _cl_event]
        -> [status : _cl_int]
        -> (cond [(= status CL_SUCCESS) (void)]
                 [(= status CL_INVALID_EVENT)
                  (error 'clRetainEvent "event is not a valid event object")]
                 [else
                  (error 'clRetainEvent "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc/names clRetainEvent (c:-> _cl_event/c void)
                 (evt) @{}])
(define-opencl clReleaseEvent
  (_fun [event : _cl_event]
        -> [status : _cl_int]
        -> (cond [(= status CL_SUCCESS) (void)]
                 [(= status CL_INVALID_EVENT)
                  (error 'clReleaseEvent "event is not a valid event object")]
                 [else
                  (error 'clReleaseEvent "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc/names clReleaseEvent (c:-> _cl_event/c void)
                 (evt) @{}])
