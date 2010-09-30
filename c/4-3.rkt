#lang at-exp racket/base
(require ffi/unsafe
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
(define-opencl clCreateContext  
  (_fun [properties : _void* = #f
                    ; XXX This is shaped weird, so I don't know how to get it
                    #;(_vector i _cl_context_properties)]
        [num_devices : _cl_uint = (vector-length devices)]
        [devices : (_vector i _cl_device_id)]
        [pfn_notify : _void* = #f
                    ; XXX It is easy to make mistakes with callbacks
                    #;(_fun [errinfo : _bytes]
                            [private_info : _void*]
                            [cb : _size_t]
                            [user_data : _void*]
                            ->
                            _void)]
        [user_data : _void* = #f]
        [errcode_ret : (_ptr o _cl_int)]
        -> [context : _cl_context/null]
        ->
        (cond
          [(= errcode_ret CL_SUCCESS)
           context]
          [(= errcode_ret CL_INVALID_PLATFORM)
           (error 'clCreateContext "~e is NULL and no platform could be selected or platform value specified in ~e is not a valid platform"
                  properties properties)]
          [(= errcode_ret CL_INVALID_VALUE)
           (error 'clCreateContext "One of the following: (a) if context property name in ~e is not a supported property name, if the value specified for a supported property name is not valid, or if the same property name is specified more than once; (b) ~e is NULL; (c) ~e is equal to zero; (d) ~e is NULL but ~e is not NULL"
                  properties devices num_devices pfn_notify user_data)]
          [(= errcode_ret CL_INVALID_DEVICE)
           (error 'clCreateContext "~e contains an invalid device or are not associated with the specified platform"
                  devices)]
          [(= errcode_ret CL_DEVICE_NOT_AVAILABLE)
           (error 'clCreateContext "a device in ~e is currently not available even though the device was returned by clGetDeviceIDs"
                  devices)]
          [(= errcode_ret CL_OUT_OF_HOST_MEMORY)
           (error 'clCreateContext "there is a failure to allocate resources required by the OpenCL implementation on the host")]
          [else
           (error 'clCreateContext "Invalid error code: ~e"
                  errcode_ret)])))
(provide/doc
 (proc-doc clCreateContext
           (([devices (vectorof _cl_device_id/c)])
            ()
            . ->d .
            [ctxt _cl_context/c])
           @{}))

;;;;
(define-opencl clCreateContextFromType  
  (_fun [properties : _void* = #f
                    #;(_vector i _cl_context_properties)]
        [device_type : _cl_device_type]
        [pfn_notify : _void* = #f
                    #;(_fun [errinfo : _bytes]
                            [private_info : _void*]
                            [cb : _size_t]
                            [user_data : _void*]
                            ->
                            _void)]
        [user_data : _void* = #f]
        [errcode_ret : (_ptr o _cl_int)]
        -> [context : _cl_context/null]
        ->
        (cond
          [(= errcode_ret CL_SUCCESS)
           context]
          [(= errcode_ret CL_INVALID_PLATFORM)
           (error 'clCreateContextFromType "~e is NULL and no platform could be selected or platform value specified in ~e is not a valid platform"
                  properties properties)]
          [(= errcode_ret CL_INVALID_VALUE)
           (error 'clCreateContextFromType "One of the following: (a) if context property name in ~e is not a supported property name, if the value specified for a supported property name is not valid, or if the same property name is specified more than once; (b) ~e is NULL but ~e is not NULL"
                  properties pfn_notify user_data)]
          [(= errcode_ret CL_INVALID_DEVICE_TYPE)
           (error 'clCreateContextFromType "~e is not a valid value"
                  device_type)]
          [(= errcode_ret CL_DEVICE_NOT_AVAILABLE)
           (error 'clCreateContextFromType "no devices that match ~e are currently available"
                  device_type)]
          [(= errcode_ret CL_DEVICE_NOT_FOUND)
           (error 'clCreateContextFromType "no devices that match ~e were found"
                  device_type)]
          [(= errcode_ret CL_OUT_OF_HOST_MEMORY)
           (error 'clCreateContextFromType "there is a failure to allocate resources required by the OpenCL implementation on the host")]
          [else
           (error 'clCreateContextFromType "Invalid error code: ~e"
                  errcode_ret)])))
(provide/doc
 (proc-doc clCreateContextFromType
           (([device_type _cl_device_type/c])
            ()
            . ->d .
            [ctxt _cl_context/c])
           @{}))

;;;;
(define-opencl clRetainContext
  (_fun [context : _cl_context]
        -> [status : _cl_int]
        ->
        (cond
          [(= status CL_SUCCESS)
           (void)]
          [(= status CL_INVALID_CONTEXT)
           (error 'clRetainContext "~e is not a valid OpenCL context"
                  context)]
          [else
           (error 'clRetainContext "Invalid error code: ~e"
                  status)])))
(provide/doc
 (proc-doc clRetainContext
           (([ctxt _cl_context/c])
            ()
            . ->d .
            [v void])
           @{}))

;;;;
(define-opencl clReleaseContext
  (_fun [context : _cl_context]
        -> [status : _cl_int]
        ->
        (cond
          [(= status CL_SUCCESS)
           (void)]
          [(= status CL_INVALID_CONTEXT)
           (error 'clReleaseContext "~e is not a valid OpenCL context"
                  context)]
          [else
           (error 'clReleaseContext "Invalid error code: ~e"
                  status)])))
(provide/doc
 (proc-doc clReleaseContext
           (([ctxt _cl_context/c])
            ()
            . ->d .
            [v void])
           @{}))

;;;; clGetContextInfo
(define-opencl-info
  clGetContextInfo
  (clGetContextInfo:length clGetContextInfo:generic)
  _cl_context_info _cl_context_info/c
  (args [context : _cl_context _cl_context/c])
  (error status
         (cond
           [(= status CL_INVALID_CONTEXT)
            (error 'clGetContextInfo "context is not a valid context")]
           [(= status CL_INVALID_VALUE)
            (error 'clGetContextInfo "param_name is an invalid value or param_value_size is the wrong size")]
           [else
            (error 'clGetContextInfo "Undefined error: ~e" status)]))
  (variable
   param_value_size
   [_cl_device_id*
    (_cvector o _cl_device_id param_value_size) (make-cvector _cl_device_id 0)
    _cl_device_id_vector/c
    CL_CONTEXT_DEVICES]
   [_cl_context_properties*
    (_cvector o _cl_context_properties param_value_size)
    (make-cvector _cl_context_properties 0)
    _cl_context_properties_vector/c
    CL_CONTEXT_PROPERTIES])
  (fixed
   [_cl_uint _cl_uint/c
             CL_CONTEXT_REFERENCE_COUNT]))