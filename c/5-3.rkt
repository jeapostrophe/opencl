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
(define-opencl clCreateSampler
  (_fun [context : _cl_context]
        [normalized_coords : _cl_bool]
        [addressing_mode : _cl_addressing_mode]
        [filter_mode : _cl_filter_mode]
        [errcode_ret : (_ptr o _cl_int)]
        -> [sample : _cl_sampler/null]
        ->
        (cond
          [(= errcode_ret CL_SUCCESS)
           sample]
          [(= errcode_ret CL_INVALID_CONTEXT)
           (error 'clCreateSampler "context is not a valid context")]
          [(= errcode_ret CL_INVALID_VALUE)
           (error 'clCreateSampler "addressing_mode, filter_mode or normalized_coords or combination of these argument values are not valid")]
          [(= errcode_ret CL_INVALID_OPERATION)
           (error 'clCreateSampler "images are not supported by any device associated with context")]
          [(= errcode_ret CL_OUT_OF_HOST_MEMORY)
           (error 'clCreateSampler "there is a failure to allocate resources required by the OpenCL implementation on the host")]
          [else
           (error 'clCreateSampler "Invalid error code: ~e" errcode_ret)])))
(provide/doc
 [proc-doc 
  clCreateSampler
  (([ctxt _cl_context/c]
    [normalized? _cl_bool/c]
    [addressing-mode _cl_addressing_mode/c]
    [filter-mode _cl_filter_mode/c])
   ()
   . ->d .
   [sampler _cl_sampler/c])
  @{}])

;;;;
(define-opencl clRetainSampler
  (_fun [sampler : _cl_sampler]
        -> [status : _cl_int]
        -> (cond [(= status CL_SUCCESS) (void)]
                 [(= status CL_INVALID_SAMPLER)
                  (error 'clRetainSampler "sampler is not a valid sampler object")]
                 [else
                  (error 'clRetainSampler "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc 
  clRetainSampler
  (([sampler _cl_sampler/c])
   ()
   . ->d .
   [v void])
  @{}])

;;;;
(define-opencl clReleaseSampler
  (_fun [sampler : _cl_sampler]
        -> [status : _cl_int]
        -> (cond [(= status CL_SUCCESS) (void)]
                 [(= status CL_INVALID_SAMPLER)
                  (error 'clReleaseSampler "sampler is not a valid sampler object")]
                 [else
                  (error 'clReleaseSampler "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc 
  clReleaseSampler
  (([sampler _cl_sampler/c])
   ()
   . ->d .
   [v void])
  @{}])

;;;;
(define-opencl-info clGetSamplerInfo
  (clGetSamplerInfo:length clGetSamplerInfo:generic)
  _cl_sampler_info _cl_sampler_info/c
  (args [sampler : _cl_sampler _cl_sampler/c])
  (error status 
         (cond [(= status CL_INVALID_VALUE)
                (error 'clGetSamplerInfo "param_name is not valid or if size in bytes specified by param_value_size is < size of return type and param_value is not NULL")]
               [(= status CL_INVALID_SAMPLER)
                (error 'clGetSamplerInfo "sampler is not a valid sampler object")]
               [else
                (error 'clGetSamplerInfo "Invalid error code: ~e" status)]))
  (variable param_value_size)
  (fixed [_cl_uint _cl_uint/c CL_SAMPLER_REFERENCE_COUNT]
         [_cl_context _cl_context/c CL_SAMPLER_CONTEXT]
         [_cl_addressing_mode _cl_addressing_mode/c CL_SAMPLER_ADDRESSING_MODE]
         [_cl_filter_mode _cl_filter_mode/c CL_SAMPLER_FILTER_MODE]
         [_cl_bool _cl_bool/c CL_SAMPLER_NORMALIZED_COORDS]))