#lang scheme/base
(require scheme/foreign
         (file "include/cl.ss")
         (file "syntax.ss")
         (file "types.ss"))
(require scribble/srcdoc)
(require/doc scheme/base
             scribble/manual
             (for-label (file "../../c/types.ss")))

;;; clGetPlatformIDs
(define-opencl-count
  clGetPlatformIDs
  (clGetPlatformIDs:count clGetPlatformIDs:vector)
  ()
  _cl_platform_id _cl_platform_id_vector/c
  (error status
         (cond [(= status CL_INVALID_VALUE)
                (error 'clGetPlatformIDs "num_entries is zero and platforms is not NULL or num_platforms and platforms are NULL")]
               [else
                (error 'clGetPlatformIDs "Undefined error: ~e" status)])))

;;; clGetPlatformInfo
(define-opencl-info
  clGetPlatformInfo
  (clGetPlatformInfo:length clGetPlatformInfo:generic)
  _cl_platform_info _cl_platform_info/c
  (args [platform : _cl_platform_id/null _cl_platform_id/null/c])
  (error status
         (cond
           [(= status CL_INVALID_PLATFORM)
            (error 'clGetPlatformInfo "platform is an invalid platform")]
           [(= status CL_INVALID_VALUE)
            (error 'clGetPlatformInfo "param_name is an invalid value or param_value_size is the wrong size")]
           [else
            (error 'clGetPlatformInfo "Undefined error: ~e"
                   status)]))
  (variable
   param_value_size
   [_char* (_bytes o param_value_size) #""
           bytes?
           CL_PLATFORM_PROFILE
           CL_PLATFORM_VERSION
           CL_PLATFORM_NAME
           CL_PLATFORM_VENDOR
           CL_PLATFORM_EXTENSIONS])
  (fixed))