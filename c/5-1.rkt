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

(define-opencl clCreateCommandQueue
  (_fun [context : _cl_context]
        [device : _cl_device_id]
        [properties : _cl_command_queue_properties]
        [errcode_ret : (_ptr o _cl_int)]
        -> [queue : _cl_command_queue/null]
        ->
        (cond
          [(= errcode_ret CL_SUCCESS)
           queue]
          [(= errcode_ret CL_INVALID_CONTEXT)
           (error 'clCreateCommandQueue "~e is not a valid context"
                  context)]
          [(= errcode_ret CL_INVALID_DEVICE)
           (error 'clCreateCommandQueue "~e is not a valid device or is not associated with ~e"
                  device context)]
          [(= errcode_ret CL_INVALID_VALUE)
           (error 'clCreateCommandQueue "values specified in ~e are not valid"
                  properties)]
          [(= errcode_ret CL_INVALID_QUEUE_PROPERTIES)
           (error 'clCreateCommandQueue "values specified in ~e are valid but are not supported by the device"
                  properties)]
          [(= errcode_ret CL_OUT_OF_HOST_MEMORY)
           (error 'clCreateCommandQueue "there is a failure to allocate resources required by the OpenCL implementation on the host")]
          [else
           (error 'clCreateCommandQueue "Invalid error code: ~e"
                  errcode_ret)])))
(provide/doc
 (proc-doc/names
  clCreateCommandQueue
  (c:-> _cl_context/c _cl_device_id/c _cl_command_queue_properties/c _cl_command_queue/c)
  (ctxt device properties)
  @{}))

(define-opencl clRetainCommandQueue
  (_fun [command_queue : _cl_command_queue]
        -> [status : _cl_int]
        -> (cond
             [(= status CL_SUCCESS) (void)]
             [(= status CL_INVALID_COMMAND_QUEUE)
              (error 'clRetainCommandQueue "~e is not a valid command-queue"
                     command_queue)]
             [else
              (error 'clRetainCommandQueue "Invalid error code: ~e" 
                     status)])))
(provide/doc
 (proc-doc/names
  clRetainCommandQueue
  (c:-> _cl_command_queue/c void)
  (cq)
  @{}))

;;;;
(define-opencl clReleaseCommandQueue
  (_fun [command_queue : _cl_command_queue]
        -> [status : _cl_int]
        -> (cond
             [(= status CL_SUCCESS) (void)]
             [(= status CL_INVALID_COMMAND_QUEUE)
              (error 'clReleaseCommandQueue "~e is not a valid command-queue"
                     command_queue)]
             [else
              (error 'clReleaseCommandQueue "Invalid error code: ~e" 
                     status)])))
(provide/doc
 (proc-doc/names
  clReleaseCommandQueue
  (c:-> _cl_command_queue/c void)
  (cq)
  @{}))

;;;; clGetCommandQueueInfo
(define-opencl-info clGetCommandQueueInfo
  (clGetCommandQueueInfo:length clGetCommandQueueInfo:generic)
  _cl_command_queue_info _cl_command_queue_info/c
  (args [command_queue : _cl_command_queue _cl_command_queue/c])
  (error status
         (cond [(= status CL_INVALID_COMMAND_QUEUE)
                (error 'clGetCommandQueueInfo "command_queue is not a valid command-queue")]
               [(= status CL_INVALID_VALUE)
                (error 'clGetCommandQueueInfo "param_name is not one of the supported values or if size in bytes specified by param_value_size is < size of return type and param_value is not a NULL value")]
               [else
                (error 'clGetCommandQueueInfo "Invalid error code: ~e" status)]))
  (variable param_value_size)
  (fixed [_cl_context _cl_context/c
                      CL_QUEUE_CONTEXT]
         [_cl_device_id _cl_device_id/c
                        CL_QUEUE_DEVICE]
         [_cl_uint _cl_uint/c 
                   CL_QUEUE_REFERENCE_COUNT]
         [_cl_command_queue_properties _cl_command_queue_properties/c
                                       CL_QUEUE_PROPERTIES]))

;;;;
(define-opencl clSetCommandQueueProperty
  (_fun [command_queue : _cl_command_queue]
        [properties : _cl_command_queue_properties]
        [enable : _cl_bool]
        [old_properties : (_ptr o _cl_command_queue_properties)]
        -> [status : _cl_int]
        -> (cond
             [(= status CL_SUCCESS)
              old_properties]
             [(= status CL_INVALID_COMMAND_QUEUE)
              (error 'clSetCommandQueueProperty "~e is not a valid command-queue"
                     command_queue)]
             [(= status CL_INVALID_VALUE)
              (error 'clSetCommandQueueProperty "the values specified in ~e are not valid"
                     properties)]
             [(= status CL_INVALID_QUEUE_PROPERTIES)
              (error 'clSetCommandQueueProperty "values specified in ~e are not supported by the device"
                     properties)]
             [else
              (error 'clSetCommandQueueProperty "Invalid error code: ~e"
                     status)])))
(provide/doc
 (proc-doc/names
  clSetCommandQueueProperty
  (c:-> _cl_command_queue/c _cl_command_queue_properties/c _cl_bool/c
        _cl_command_queue_properties/c)
  (cq properties enable)
  @{}))