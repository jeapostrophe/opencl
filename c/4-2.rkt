#lang racket/base
(require ffi/unsafe
         (file "include/cl.rkt")
         (file "syntax.rkt")
         (file "types.rkt"))
(require scribble/srcdoc)
(require/doc racket/base
             scribble/manual
             (for-label (file "../../c/types.rkt")))

;;; clGetDeviceIDs
(define-opencl-count
  clGetDeviceIDs
  (clGetDeviceIDs:count clGetDeviceIDs:vector)  
  ([platform : _cl_platform_id/null _cl_platform_id/null/c]
   [device_type : _cl_device_type _cl_device_type/c])
  _cl_device_id _cl_device_id_vector/c
  (error status
         (cond
           [(= status CL_INVALID_PLATFORM)
            (error 'clGetDeviceIDs "platform is not a valid platform")]
           [(= status CL_INVALID_DEVICE_TYPE)
            (error 'clGetDeviceIDs "device_type is not a valid value")]
           [(= status CL_INVALID_VALUE)
            (error 'clGetDeviceIDs "num_entries is equal to zero and devices is not NULL or both num_devices and devices are NULL")]
           [(= status CL_DEVICE_NOT_FOUND)
            (error 'clGetDeviceIDs "No OpenCL devices that matched device_type were found")]
           [else
            (error 'clGetDeviceIDs "Undefined error: ~e"
                   status)])))

;;;; clGetDeviceInfo
(define-opencl-info
  clGetDeviceInfo
  (clGetDeviceInfo:length clGetDeviceInfo:generic)  
  _cl_device_info _cl_device_info/c
  (args [device : _cl_device_id _cl_device_id/c])
  (error status
         (cond
           [(= status CL_INVALID_DEVICE)
            (error 'clGetDeviceInfo "device is an invalid device")]
           [(= status CL_INVALID_VALUE)
            (error 'clGetDeviceInfo "param_name is an invalid value or param_value_size is the wrong size")]
           [else
            (error 'clGetDeviceInfo "Undefined error: ~e"
                   status)]))
  (variable
   param_value_size
   [_size_t* (_cvector o _size_t param_value_size) (make-cvector _size_t 0)
             _size_t_vector/c
             CL_DEVICE_MAX_WORK_ITEM_SIZES]
   [_char* (_bytes o param_value_size) #""
           bytes?
           CL_DEVICE_NAME
           CL_DEVICE_VENDOR
           CL_DRIVER_VERSION
           CL_DEVICE_PROFILE
           CL_DEVICE_VERSION
           CL_DEVICE_EXTENSIONS])
  (fixed
   [_cl_device_type _cl_device_type/c
                    CL_DEVICE_TYPE]
   [_cl_uint _cl_uint/c
             CL_DEVICE_VENDOR_ID
             CL_DEVICE_MAX_COMPUTE_UNITS
             CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS
             CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR
             CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT
             CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT
             CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG
             CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT
             CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE
             CL_DEVICE_MAX_CLOCK_FREQUENCY
             CL_DEVICE_ADDRESS_BITS
             CL_DEVICE_MAX_READ_IMAGE_ARGS
             CL_DEVICE_MAX_WRITE_IMAGE_ARGS
             CL_DEVICE_MAX_SAMPLERS
             CL_DEVICE_MEM_BASE_ADDR_ALIGN
             CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE
             CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE]
   [_size_t _size_t/c
            CL_DEVICE_MAX_WORK_GROUP_SIZE
            CL_DEVICE_IMAGE2D_MAX_WIDTH
            CL_DEVICE_IMAGE2D_MAX_HEIGHT
            CL_DEVICE_IMAGE3D_MAX_WIDTH
            CL_DEVICE_IMAGE3D_MAX_HEIGHT
            CL_DEVICE_IMAGE3D_MAX_DEPTH
            CL_DEVICE_MAX_PARAMETER_SIZE
            CL_DEVICE_MAX_CONSTANT_ARGS
            CL_DEVICE_PROFILING_TIMER_RESOLUTION]
   [_cl_ulong _cl_ulong/c
              CL_DEVICE_MAX_MEM_ALLOC_SIZE
              CL_DEVICE_GLOBAL_MEM_CACHE_SIZE
              CL_DEVICE_GLOBAL_MEM_SIZE
              CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE
              CL_DEVICE_LOCAL_MEM_SIZE]
   [_cl_bool _cl_bool/c
             CL_DEVICE_IMAGE_SUPPORT
             CL_DEVICE_ERROR_CORRECTION_SUPPORT
             CL_DEVICE_ENDIAN_LITTLE
             CL_DEVICE_AVAILABLE
             CL_DEVICE_COMPILER_AVAILABLE]
   [_cl_device_fp_config _cl_device_fp_config/c
                         CL_DEVICE_SINGLE_FP_CONFIG]
   [_cl_device_mem_cache_type _cl_device_mem_cache_type/c
                              CL_DEVICE_GLOBAL_MEM_CACHE_TYPE]
   [_cl_device_local_mem_type _cl_device_local_mem_type/c
                              CL_DEVICE_LOCAL_MEM_TYPE]
   [_cl_device_exec_capabilities _cl_device_exec_capabilities/c
                                 CL_DEVICE_EXECUTION_CAPABILITIES]
   [_cl_command_queue_properties _cl_command_queue_properties/c
                                 CL_DEVICE_QUEUE_PROPERTIES]
   [_cl_platform_id _cl_platform_id/c
                    CL_DEVICE_PLATFORM]))