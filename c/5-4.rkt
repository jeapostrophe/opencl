#lang at-exp racket/base
(require ffi/unsafe
         ffi/unsafe/cvector
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
(define-opencl clCreateProgramWithSource
  (_fun [context : _cl_context]
        [count : _cl_uint = (vector-length strings)]
        [strings : (_vector i _bytes)]
        [lengths : (_vector i _size_t) = 
                 (build-vector count (lambda (i) (bytes-length (vector-ref strings i))))]
        [errcode_ret : (_ptr o _cl_int)]
        -> [program : _cl_program/null]
        ->
        (cond
          [(= errcode_ret CL_SUCCESS)
           program]
          [(= errcode_ret CL_INVALID_CONTEXT)
           (error 'clCreateProgramWithSource "context is not a valid context")]
          [(= errcode_ret CL_INVALID_VALUE)
           (error 'clCreateProgramWithSource "count is zero or strings or any entry in strings is NULL")]
          [(= errcode_ret CL_OUT_OF_HOST_MEMORY)
           (error 'clCreateProgramWithSource "there is a failure to allocate resources required by the OpenCL implementation on the host")]
          [else
           (error 'clCreateProgramWithSource "Invalid error code: ~e" errcode_ret)])))
(provide/doc
 [proc-doc 
  clCreateProgramWithSource
  (([ctxt _cl_context/c]
    [source (vectorof bytes?)])
   () . ->d .
   [program _cl_program/c])
  @{}])

;;;;
(define-opencl clCreateProgramWithBinary
  (_fun [context : _cl_context]
        [num_devices : _cl_uint = (vector-length device_list)]
        [device_list : (_vector i _cl_device_id)]
        [lengths : (_vector i _size_t) = 
                 (build-vector num_devices (lambda (i) (bytes-length (vector-ref binaries i))))]
        [binaries : (_vector i _bytes)]
        [binary_status : _pointer = #f #;(_cvector o _cl_int num_devices)]
        [errcode_ret : (_ptr o _cl_int)]
        -> [program : _cl_program/null]
        ->
        (cond
          [(= errcode_ret CL_SUCCESS)
           program]
          [(= errcode_ret CL_INVALID_CONTEXT)
           (error 'clCreateProgramWithBinary "context is not a valid context")]
          [(= errcode_ret CL_INVALID_VALUE)
           (error 'clCreateProgramWithBinary "device_list is NULL or num_devices is zero or lengths or binaries are NULL or if any entry in lengths[i] is zero or binaries[i] is NULL")]
          [(= errcode_ret CL_INVALID_DEVICE)
           (error 'clCreateProgramWithBinary "OpenCL devices listed in device_list are not in the list of devices associated with context")]
          [(= errcode_ret CL_INVALID_BINARY)
           ; XXX Return specifix error based on binary_status
           (error 'clCreateProgramWithBinary "an invalid program binary was encountered for some device")]
          [(= errcode_ret CL_OUT_OF_HOST_MEMORY)
           (error 'clCreateProgramWithBinary "there is a failure to allocate resources required by the OpenCL implementation on the host")]
          [else
           (error 'clCreateProgramWithBinary "Invalid error code: ~e" errcode_ret)])))
(provide/doc
 [proc-doc
  clCreateProgramWithBinary 
  (->d ([ctxt _cl_context/c]
        [devices (vectorof _cl_device_id/c)]
        [binaries (vectorof bytes?)])
       ()
       ; XXX
       #;#:pre-cond
       #;(= (vector-length devices)
            (vector-length binaries))
       [_ _cl_program/c])
  @{}])

;;;;
(define-opencl clRetainProgram
  (_fun [program : _cl_program]
        -> [status : _cl_int]
        -> (cond [(= status CL_SUCCESS) (void)]
                 [(= status CL_INVALID_PROGRAM)
                  (error 'clRetainProgram "program is not a valid program object")]
                 [else
                  (error 'clRetainProgram "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc 
  clRetainProgram
  (([program _cl_program/c]) () . ->d . [_ void])
  @{}])
(define-opencl clReleaseProgram
  (_fun [program : _cl_program]
        -> [status : _cl_int]
        -> (cond [(= status CL_SUCCESS) (void)]
                 [(= status CL_INVALID_PROGRAM)
                  (error 'clReleaseProgram "program is not a valid program object")]
                 [else
                  (error 'clReleaseProgram "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc 
  clReleaseProgram
  (([program _cl_program/c]) () . ->d . [_ void])
  @{}])

;;;;
(define-opencl clBuildProgram
  (_fun [program : _cl_program]
        [num_devices : _cl_uint = (vector-length device_list)]
        [device_list : (_vector i _cl_device_id)]
        [options : _bytes]
        [pfn_notify : _pointer = #f
                    ; XXX It is easy to make mistakes with callbacks
                    #;(_fun _cl_program _void* -> _void)]
        [user_data : _pointer = #f
                   ; XXX GC issue on callbacks
                   #; _void*]
        -> [status : _cl_int]
        ->
        (cond [(= status CL_SUCCESS) (void)]
              [(= status CL_INVALID_PROGRAM)
               (error 'clBuildProgram "program is not a valid program object")]
              [(= status CL_INVALID_VALUE)
               (error 'clBuildProgram "device_list is NULL and num_devices is greater than zero or device_list is not NULL and num_devices is zero or pfn_notify is NULL but user_data is not NULL")]
              [(= status CL_INVALID_DEVICE)
               (error 'clBuildProgram "OpenCL devices listed in device_list are not in the list of devices associated with program")]
              [(= status CL_INVALID_BINARY)
               (error 'clBuildProgram "program is created with clCreateWithProgramBinary and devices listed in device_list do not have a valid program binary loaded.")]
              [(= status CL_INVALID_BUILD_OPTIONS)
               (error 'clBuildProgram "the build options specified by options are invalid")]
              [(= status CL_INVALID_OPERATION)
               (error 'clBuildProgram "the build of a program for any of the devies listed in device_list by a previous call to clBuildProgram for program has not completed")]
              [(= status CL_COMPILER_NOT_AVAILABLE)
               (error 'clBuildProgram "program is created with clCreateProgramWithSource and a compiler is not available")]
              [(= status CL_BUILD_PROGRAM_FAILURE)
               (error 'clBuildProgram "there is a failure to build the program executable")]
              [(= status CL_INVALID_OPERATION)
               (error 'clBuildProgram "there are kernel objects attached to program")]
              [(= status CL_OUT_OF_HOST_MEMORY)
               (error 'clBuildProgram "there is a failure to allocate resources required by the OpenCL implementation on the host")]
              [else
               (error 'clBuildProgram "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc 
  clBuildProgram
  (([program _cl_program/c]
    [devices (vectorof _cl_device_id/c)]
    [options bytes?]) () . ->d . [_v void])
  @{}])

;;;;
(define-opencl clUnloadCompiler
  (_fun -> [status : _cl_int]
        -> (cond [(= status CL_SUCCESS) (void)]
                 [else (error 'clUnloadCompiler "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc clUnloadCompiler
           (->d () () [_ void])
           @{}])

;;;;
;;; XXX support CL_PROGRAM_BINARIES
(define-opencl-info
  clGetProgramInfo
  (clGetProgramInfo:length clGetProgramInfo:generic)
  _cl_program_info _cl_program_info/c
  (args [program : _cl_program _cl_program/c])
  (error status 
         (cond [(= status CL_INVALID_VALUE)
                (error 'clGetProgramInfo "param_name is not valid or if size in bytes specified by param_value_size is < size of return type and param_value is not NULL")]
               [(= status CL_INVALID_PROGRAM)
                (error 'clGetProgramInfo "program is not a valid program object")]
               [else
                (error 'clGetProgramInfo "Invalid error code: ~e" status)]))
  (variable param_value_size
            [_cl_device_id* (_cvector o _cl_device_id param_value_size)
                            (make-cvector _cl_device_id 0)
                            _cl_device_id_vector/c
                            CL_PROGRAM_DEVICES]
            [_char* (_bytes o param_value_size) #"" bytes?
                    CL_PROGRAM_SOURCE]
            [_size_t* (_cvector o _size_t param_value_size)
                      (make-cvector _size_t 0)
                      _size_t_vector/c
                      CL_PROGRAM_BINARY_SIZES])
  (fixed [_cl_uint _cl_uint/c CL_PROGRAM_REFERENCE_COUNT CL_PROGRAM_NUM_DEVICES]
         [_cl_context _cl_context/c CL_PROGRAM_CONTEXT]))

;;;; clGetProgramBuildInfo
(define-opencl-info
  clGetProgramBuildInfo
  (clGetProgramBuildInfo:length clGetProgramBuildInfo:generic)
  _cl_program_build_info _cl_program_build_info/c
  (args [program : _cl_program _cl_program/c]
        [device : _cl_device_id _cl_device_id/c])
  (error status 
         (cond [(= status CL_INVALID_DEVICE)
                (error 'clGetProgramBuildInfo "device is not in the list of devices associated with program")]
               [(= status CL_INVALID_VALUE)
                (error 'clGetProgramBuildInfo "param_name is not valid or if size in bytes specified by param_value_size is < size of return type and param_value is not NULL")]
               [(= status CL_INVALID_PROGRAM)
                (error 'clGetProgramBuildInfo "program is not a valid program object")]
               [else
                (error 'clGetProgramBuildInfo "Invalid error code: ~e" status)]))
  (variable param_value_size
            [_char* (_bytes o param_value_size) #"" bytes?
                    CL_PROGRAM_BUILD_OPTIONS CL_PROGRAM_BUILD_LOG])
  (fixed [_cl_build_status _cl_build_status/c CL_PROGRAM_BUILD_STATUS]))