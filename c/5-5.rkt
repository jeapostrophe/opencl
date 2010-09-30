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
(define-opencl clCreateKernel
  (_fun [program : _cl_program]
        [kernel_name : _bytes]
        [errcode_ret : (_ptr o _cl_int)]
        -> [kernel : _cl_kernel/null]
        ->
        (cond
          [(= errcode_ret CL_SUCCESS)
           kernel]
          [(= errcode_ret CL_INVALID_PROGRAM)
           (error 'clCreateKernel "program is not a valid program object")]
          [(= errcode_ret CL_INVALID_PROGRAM_EXECUTABLE)
           (error 'clCreateKernel "there is no successfully built executable for program")]
          [(= errcode_ret CL_INVALID_KERNEL_NAME)
           (error 'clCreateKernel "kernel_name(~e) is not found in the program"
                  kernel_name)]
          [(= errcode_ret CL_INVALID_KERNEL_DEFINITION)
           (error 'clCreateKernel "the function definition for __kernel function given by kernel_name such as the number of arguments, the argument types are not the same for all devices for which the program executable has been built")]
          [(= errcode_ret CL_INVALID_VALUE)
           (error 'clCreateKernel "kernel_name is NULL")]
          [(= errcode_ret CL_OUT_OF_HOST_MEMORY)
           (error 'clCreateKernel "there is a failure to allocate resources required by the OpenCL implementation on the host")]
          [else
           (error 'clCreateKernel "Invalid error code: ~e" errcode_ret)])))
(provide/doc
 [proc-doc 
  clCreateKernel
  (->d ([program _cl_program/c]
        [kernel-name bytes?])
       ()
       [kernel _cl_kernel/c])
  @{}])

;;;; clCreateKernelsInProgram
(define-opencl-count
  clCreateKernelsInProgram
  (clCreateKernelsInProgram:count clCreateKernelsInProgram:vector)
  ([program : _cl_program _cl_program/c])
  _cl_kernel _cl_kernel_vector/c
  (error status
         (cond [(= status CL_INVALID_PROGRAM)
                (error 'clCreateKernelsInProgram "program is a not valid program object")]
               [(= status CL_INVALID_PROGRAM_EXECUTABLE)
                (error 'clCreateKernelsInProgram "there is no successfully built executable for any device in program")]
               [(= status CL_INVALID_VALUE)
                (error 'clCreateKernelsInProgram "kernels is not NULL and num_kernels is less than the number of kernels in program")]
               [(= status CL_OUT_OF_HOST_MEMORY)
                (error 'clCreateKernelsInProgram "there is a failure to allocate resources required by the OpenCL implementation on the host")]
               [else
                (error 'clCreateKernelsInProgram "Invalid error code: ~e" status)])))

;;;;
(define-opencl clRetainKernel
  (_fun [kernel : _cl_kernel]
        -> [status : _cl_int]
        -> (cond [(= status CL_SUCCESS) (void)]
                 [(= status CL_INVALID_KERNEL)
                  (error 'clRetainKernel "kernel is not a valid kernel object")]
                 [else
                  (error 'clRetainKernel "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc clRetainKernel (->d ([kernel _cl_kernel/c]) () [_ void]) @{}])
(define-opencl clReleaseKernel
  (_fun [kernel : _cl_kernel]
        -> [status : _cl_int]
        -> (cond [(= status CL_SUCCESS) (void)]
                 [(= status CL_INVALID_KERNEL)
                  (error 'clReleaseKernel "kernel is not a valid kernel object")]
                 [else
                  (error 'clReleaseKernel "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc clReleaseKernel (->d ([kernel _cl_kernel/c]) () [_ void]) @{}])

;;;;
(define (clSetKernelArg-return status)
  (cond [(= status CL_SUCCESS)
         (void)]
        [(= status CL_INVALID_KERNEL)
         (error 'clSetKernelArg "kernel is not a valid kernel object")]
        [(= status CL_INVALID_ARG_INDEX)
         (error 'clSetKernelArg "arg_index is not a valid argument index")]
        [(= status CL_INVALID_ARG_VALUE)
         (error 'clSetKernelArg "arg_value specified in NULL for an argument that is not declared with the __local qualifier or vice-versa")]
        [(= status CL_INVALID_MEM_OBJECT)
         (error 'clSetKernelArg "an argument declared to be a memory object when the specified arg_value is not a valid memory object")]
        [(= status CL_INVALID_SAMPLER)
         (error 'clSetKernelArg "an argument declared to be of type sampler_t when the specified arg_value is not a valid sampler object")]
        [(= status CL_INVALID_ARG_SIZE)
         (error 'clSetKernelArg "arg_size does not match the size of the data type for an argument is not a memory object or if the argument is a memory object and arg_size != sizeof(cl_mem) or if arg_size is zero and the argument is declared with the __local qualitifer or if the argument is a sampler and arg_size != sizeof(cl_sampler)")]
        [else
         (error 'clSetKernelArg "Invalid error code: ~e" status)]))

(define-syntax-rule (define-clSetKernelArg clSetKernelArg:_type _type _type/c)
  (begin
    (define-opencl clSetKernelArg:_type
      clSetKernelArg
      (_fun [kernel : _cl_kernel]
            [arg_index : _cl_uint]
            [arg_size : _size_t = (ctype-sizeof _type)]
            [arg_value : (_ptr i _type)]
            -> [status : _cl_int]
            -> (clSetKernelArg-return status)))
    (provide/doc
     [proc-doc
      clSetKernelArg:_type
      (->d ([kernel _cl_kernel/c]
            [arg-num _cl_uint/c]
            [val _type/c])
           ()
           [_ void])
      @{}])))

; XXX Make sure this is complete
(define-clSetKernelArg clSetKernelArg:_cl_mem _cl_mem _cl_mem/c)
(define-clSetKernelArg clSetKernelArg:_cl_uint _cl_uint _cl_uint/c)
(define-clSetKernelArg clSetKernelArg:_cl_int _cl_int _cl_int/c)

(define-opencl clSetKernelArg:local
  clSetKernelArg
  (_fun [kernel : _cl_kernel]
        [arg_index : _cl_uint]
        [arg_size : _size_t]
        [arg_value : _pointer = #f]
        -> [status : _cl_int]
        -> (clSetKernelArg-return status)))
(provide/doc
 [proc-doc
  clSetKernelArg:local
  (->d ([kernel _cl_kernel/c]
        [arg-num _cl_uint/c]
        [arg_size _size_t/c])
       ()
       [_ void])
  @{}])

;;;; clGetKernelInfo

(define-opencl-info
  clGetKernelInfo
  (clGetKernelInfo:length clGetKernelInfo:generic)
  _cl_kernel_info _cl_kernel_info/c
  (args [kernel : _cl_kernel _cl_kernel/c])
  (error status 
         (cond [(= status CL_INVALID_VALUE)
                (error 'clGetKernelInfo "param_name is not valid or if size in bytes specified by param_value_size is < size of return type and param_value is not NULL")]
               [(= status CL_INVALID_KERNEL)
                (error 'clGetKernelInfo "kernel is not a valid kernel object")]
               [else
                (error 'clGetKernelInfo "Invalid error code: ~e" status)]))
  (variable param_value_size
            [_char* (_bytes o param_value_size) #"" bytes?
                    CL_KERNEL_FUNCTION_NAME])
  (fixed [_cl_uint _cl_uint/c CL_KERNEL_NUM_ARGS CL_KERNEL_REFERENCE_COUNT]
         [_cl_context _cl_context/c CL_KERNEL_CONTEXT]
         [_cl_program _cl_program/c CL_KERNEL_PROGRAM]))

;;;; clGetKernelWorkGroupInfo

(define-opencl-info
  clGetKernelWorkGroupInfo
  (clGetKernelWorkGroupInfo:length clGetKernelWorkGroupInfo:generic)
  _cl_kernel_work_group_info _cl_kernel_work_group_info/c
  (args [kernel : _cl_kernel _cl_kernel/c]
        [device : _cl_device_id _cl_device_id/c])
  (error status 
         (cond [(= status CL_INVALID_DEVICE)
                (error 'clGetKernelWorkGroupInfo "device is not in the list of devices associated with kernel or if device is NULL but there is more than one device associated with kernel")]
               [(= status CL_INVALID_VALUE)
                (error 'clGetKernelInfo "param_name is not valid or if size in bytes specified by param_value_size is < size of return type and param_value is not NULL")]
               [(= status CL_INVALID_KERNEL)
                (error 'clGetKernelInfo "kernel is not a valid kernel object")]
               [else
                (error 'clGetKernelInfo "Invalid error code: ~e" status)]))
  (variable param_value_size
            ; XXX This is guaranteed to be 3
            [_size_t* (_cvector o _size_t param_value_size)
                      (make-cvector _size_t 3)
                      _size_t_vector/c
                      CL_KERNEL_COMPILE_WORK_GROUP_SIZE])
  (fixed [_size_t _size_t/c CL_KERNEL_WORK_GROUP_SIZE]
         [_cl_ulong _cl_ulong/c CL_KERNEL_LOCAL_MEM_SIZE]))