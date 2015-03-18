#lang at-exp racket/base
(require ffi/unsafe
         (except-in racket/contract ->)
         "include/cl.rkt"
         "tsyntax.rkt"
         "constants.rkt")
(require scribble/srcdoc)
(require/doc racket/base
             scribble/manual)

(define-syntax-rule (define-ctype-numeric-predicate id min max)
  (begin (define (id x) (and (number? x) (<= min x max)))
         (provide/doc 
          (thing-doc id flat-contract?
                     @{A contract for numbers between @racket['min] and @racket['max].}))))

(define-ctype-numeric-predicate _int8? CL_SCHAR_MIN CL_SCHAR_MAX)
(define-ctype-numeric-predicate _uint8? 0 CL_UCHAR_MAX)
(define-ctype-numeric-predicate _int16? CL_SHRT_MIN CL_SHRT_MAX)
(define-ctype-numeric-predicate _uint16? 0 CL_USHRT_MAX)
(define-ctype-numeric-predicate _int32? CL_INT_MIN CL_INT_MAX)
(define-ctype-numeric-predicate _uint32? 0 CL_UINT_MAX)
(define-ctype-numeric-predicate _int64? CL_LONG_MIN CL_LONG_MAX)
(define-ctype-numeric-predicate _uint64? 0 CL_ULONG_MAX)
(define-ctype-numeric-predicate _float? CL_FLT_MIN CL_FLT_MAX)
(define-ctype-numeric-predicate _double? CL_DBL_MIN CL_DBL_MAX)
; XXX
(define _intptr*
   (make-ctype _pointer
     (lambda (x) (if (cpointer? x) x (cast x _intptr _pointer)))
     (lambda (x) (error 'intptr* "can't use as an output type"))))
(define _long? number?)
(define _intptr*/c (or/c _long? cpointer?))
(provide/doc
 (thing-doc _intptr* ctype? @{A ctype for holding pointers as integers.})
 (thing-doc _intptr*/c flat-contract? @{A contract for @racket[_intptr*]}))

(define-opencl-alias _cl_char _int8 _int8?)
(define-opencl-alias _cl_uchar _uint8 _uint8?)
(define-opencl-alias _cl_short _int16 _int16?)
(define-opencl-alias _cl_ushort _uint16 _uint16?)
(define-opencl-alias _cl_int _int32 _int32?)
(define-opencl-alias _cl_uint _uint32 _uint32?)
(define-opencl-alias _cl_long _int64 _int64?)
(define-opencl-alias _cl_ulong _uint64 _uint64?)
(define-opencl-alias _cl_half _uint16 _uint16?)
(define-opencl-alias _cl_float _float _float?)
(define-opencl-alias _cl_double _double _double?)

(define-opencl-vector-alias* _cl_char 2 4 8 16)
(define-opencl-vector-alias* _cl_uchar 2 4 8 16)
(define-opencl-vector-alias* _cl_short 2 4 8 16)
(define-opencl-vector-alias* _cl_ushort 2 4 8 16)
(define-opencl-vector-alias* _cl_int 2 4 8 16)
(define-opencl-vector-alias* _cl_uint 2 4 8 16)
(define-opencl-vector-alias* _cl_long 2 4 8 16)
(define-opencl-vector-alias* _cl_ulong 2 4 8 16)
(define-opencl-vector-alias* _cl_float 2 4 8 16)
(define-opencl-vector-alias* _cl_double 2 4 8 16)

(define-opencl-enum _cl_bool _cl_uint _cl_bool-values _cl_bool/c
  (CL_FALSE CL_TRUE))

(define-opencl-pointer _cl_platform_id)

(define-opencl-enum _cl_platform_info _cl_uint _cl_platform_info-values _cl_platform_info/c
  (CL_PLATFORM_PROFILE CL_PLATFORM_VERSION CL_PLATFORM_NAME CL_PLATFORM_VENDOR CL_PLATFORM_EXTENSIONS))

(define-opencl-alias _cl_bitfield _cl_ulong _cl_ulong/c)

(define-opencl-pointer _cl_device_id)

(define-opencl-bitfield
  _cl_device_type _cl_bitfield _cl_device_type-values _cl_device_type/c
  (CL_DEVICE_TYPE_CPU CL_DEVICE_TYPE_GPU CL_DEVICE_TYPE_ACCELERATOR CL_DEVICE_TYPE_DEFAULT CL_DEVICE_TYPE_ALL))

(define-opencl-enum _cl_device_info _cl_uint _cl_device_info-values _cl_device_info/c
  (CL_DEVICE_TYPE CL_DEVICE_VENDOR_ID CL_DEVICE_MAX_COMPUTE_UNITS CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS CL_DEVICE_MAX_WORK_GROUP_SIZE CL_DEVICE_MAX_WORK_ITEM_SIZES CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE CL_DEVICE_MAX_CLOCK_FREQUENCY CL_DEVICE_ADDRESS_BITS CL_DEVICE_MAX_READ_IMAGE_ARGS CL_DEVICE_MAX_WRITE_IMAGE_ARGS CL_DEVICE_MAX_MEM_ALLOC_SIZE CL_DEVICE_IMAGE2D_MAX_WIDTH CL_DEVICE_IMAGE2D_MAX_HEIGHT CL_DEVICE_IMAGE3D_MAX_WIDTH CL_DEVICE_IMAGE3D_MAX_HEIGHT CL_DEVICE_IMAGE3D_MAX_DEPTH CL_DEVICE_IMAGE_SUPPORT CL_DEVICE_MAX_PARAMETER_SIZE CL_DEVICE_MAX_SAMPLERS CL_DEVICE_MEM_BASE_ADDR_ALIGN CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE CL_DEVICE_SINGLE_FP_CONFIG CL_DEVICE_GLOBAL_MEM_CACHE_TYPE CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE CL_DEVICE_GLOBAL_MEM_CACHE_SIZE CL_DEVICE_GLOBAL_MEM_SIZE CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE CL_DEVICE_MAX_CONSTANT_ARGS CL_DEVICE_LOCAL_MEM_TYPE CL_DEVICE_LOCAL_MEM_SIZE CL_DEVICE_ERROR_CORRECTION_SUPPORT CL_DEVICE_PROFILING_TIMER_RESOLUTION CL_DEVICE_ENDIAN_LITTLE CL_DEVICE_AVAILABLE CL_DEVICE_COMPILER_AVAILABLE CL_DEVICE_EXECUTION_CAPABILITIES CL_DEVICE_QUEUE_PROPERTIES CL_DEVICE_NAME CL_DEVICE_VENDOR CL_DRIVER_VERSION CL_DEVICE_PROFILE CL_DEVICE_VERSION CL_DEVICE_EXTENSIONS CL_DEVICE_PLATFORM))

(define-opencl-bitfield _cl_device_address_info _cl_bitfield _cl_device_address_info-values _cl_device_address_info/c
  ())

(define-opencl-bitfield
  _cl_device_fp_config _cl_bitfield _cl_device_fp_config-values _cl_device_fp_config/c
  (CL_FP_DENORM CL_FP_INF_NAN CL_FP_ROUND_TO_NEAREST CL_FP_ROUND_TO_ZERO CL_FP_ROUND_TO_INF CL_FP_FMA))

(define-opencl-enum
  _cl_device_mem_cache_type _cl_uint _cl_device_mem_cache_type-values _cl_device_mem_cache_type/c
  (CL_NONE CL_READ_ONLY_CACHE CL_READ_WRITE_CACHE))

(define-opencl-enum
  _cl_device_local_mem_type _cl_uint _cl_device_local_mem_type-values _cl_device_local_mem_type/c
  (CL_LOCAL CL_GLOBAL))

(define-opencl-bitfield
  _cl_device_exec_capabilities _cl_bitfield _cl_device_exec_capabilities-values _cl_device_exec_capabilities/c
  (CL_EXEC_KERNEL CL_EXEC_NATIVE_KERNEL))

; XXX This is probably wrong on other platforms
(define-opencl-alias _size_t _size exact-nonnegative-integer?)
(define-opencl-alias _void* _pointer cpointer?)
(define-opencl-alias _void*/null _pointer (or/c false/c cpointer?))

(define-opencl-pointer _cl_context)

(define-opencl-bitfield
  _cl_command_queue_properties _cl_bitfield _cl_command_queue_properties-values _cl_command_queue_properties/c
  (CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE CL_QUEUE_PROFILING_ENABLE))

(define-opencl-pointer _cl_command_queue)

(define-opencl-bitfield
  _cl_mem_flags _cl_bitfield _cl_mem_flags-values _cl_mem_flags/c
  (CL_MEM_READ_WRITE CL_MEM_WRITE_ONLY CL_MEM_READ_ONLY CL_MEM_USE_HOST_PTR CL_MEM_ALLOC_HOST_PTR CL_MEM_COPY_HOST_PTR))

(define-opencl-pointer _cl_mem)

(define-opencl-pointer _cl_event)

(define-opencl-enum _cl_channel_order _cl_uint _cl_channel_order-values _cl_channel_order/c
  (CL_R CL_A CL_INTENSITY CL_LUMINANCE CL_RG CL_RA CL_RGB CL_RGBA CL_ARGB CL_BGRA))

(define-opencl-enum _cl_channel_type _cl_uint _cl_channel_type-values _cl_channel_type/c
  (CL_SNORM_INT8 CL_SNORM_INT16 CL_UNORM_INT8 CL_UNORM_INT16 CL_UNORM_SHORT_565 CL_UNORM_SHORT_555 CL_UNORM_INT_101010 CL_SIGNED_INT8 CL_SIGNED_INT16 CL_SIGNED_INT32 CL_UNSIGNED_INT8 CL_UNSIGNED_INT16 CL_UNSIGNED_INT32 CL_HALF_FLOAT CL_FLOAT))

(define-opencl-enum _cl_mem_object_type _cl_uint _cl_mem_object_type-values _cl_mem_object_type/c
  (CL_MEM_OBJECT_BUFFER CL_MEM_OBJECT_IMAGE1D CL_MEM_OBJECT_IMAGE1D_BUFFER CL_MEM_OBJECT_IMAGE1D_ARRAY CL_MEM_OBJECT_IMAGE2D CL_MEM_OBJECT_IMAGE2D_ARRAY CL_MEM_OBJECT_IMAGE3D))

(define-opencl-bitfield
  _cl_map_flags _cl_bitfield _cl_map_flags-values _cl_map_flags/c
  (CL_MAP_READ CL_MAP_WRITE))

(define-opencl-pointer _cl_sampler)

(define-opencl-enum 
  _cl_addressing_mode _cl_uint _cl_addressing_mode-values _cl_addressing_mode/c
  (CL_ADDRESS_REPEAT CL_ADDRESS_CLAMP_TO_EDGE CL_ADDRESS_CLAMP CL_ADDRESS_NONE))

(define-opencl-enum 
  _cl_filter_mode _cl_uint _cl_filter_mode-values _cl_filter_mode/c
  (CL_FILTER_NEAREST CL_FILTER_LINEAR))

(define-opencl-pointer _cl_program)

(define-opencl-pointer _cl_kernel)

(define-opencl-alias _cl_context_properties _intptr* _intptr*/c)

(define-opencl-cstruct _cl_image_format
  ([image_channel_order _cl_channel_order]
   [image_channel_data_type _cl_channel_type]))

(define-opencl-enum _cl_context_info _cl_uint
  _cl_context_info-values _cl_context_info/c
  (CL_CONTEXT_REFERENCE_COUNT CL_CONTEXT_DEVICES CL_CONTEXT_PROPERTIES))

(define-opencl-enum
  _cl_command_queue_info _cl_uint _cl_command_queue_info-values _cl_command_queue_info/c
  (CL_QUEUE_CONTEXT CL_QUEUE_DEVICE CL_QUEUE_REFERENCE_COUNT CL_QUEUE_PROPERTIES))

(define-opencl-enum _cl_mem_info _cl_uint _cl_mem_info-values _cl_mem_info/c
  (CL_MEM_TYPE CL_MEM_FLAGS CL_MEM_SIZE CL_MEM_HOST_PTR CL_MEM_MAP_COUNT CL_MEM_REFERENCE_COUNT CL_MEM_CONTEXT))

(define-opencl-enum _cl_image_info _cl_uint _cl_image_info-values _cl_image_info/c
  (CL_IMAGE_FORMAT CL_IMAGE_ELEMENT_SIZE CL_IMAGE_ROW_PITCH CL_IMAGE_SLICE_PITCH CL_IMAGE_WIDTH CL_IMAGE_HEIGHT CL_IMAGE_DEPTH))

(define-opencl-enum _cl_sampler_info _cl_uint _cl_sampler_info-values _cl_sampler_info/c
  (CL_SAMPLER_REFERENCE_COUNT CL_SAMPLER_CONTEXT CL_SAMPLER_ADDRESSING_MODE CL_SAMPLER_FILTER_MODE CL_SAMPLER_NORMALIZED_COORDS))

; XXX
(define-opencl-enum
  _cl_program_info _cl_uint _cl_program_info-values _cl_program_info/c
  (CL_PROGRAM_REFERENCE_COUNT CL_PROGRAM_CONTEXT CL_PROGRAM_NUM_DEVICES CL_PROGRAM_DEVICES CL_PROGRAM_SOURCE CL_PROGRAM_BINARY_SIZES #;CL_PROGRAM_BINARIES))

(define-opencl-enum
  _cl_program_build_info _cl_uint _cl_program_build_info-values _cl_program_build_info/c
  (CL_PROGRAM_BUILD_STATUS CL_PROGRAM_BUILD_OPTIONS CL_PROGRAM_BUILD_LOG))

(define-opencl-enum
  _cl_build_status _cl_int _cl_build_status-values _cl_build_status/c
  (CL_BUILD_NONE CL_BUILD_ERROR CL_BUILD_SUCCESS CL_BUILD_IN_PROGRESS))

(define-opencl-enum
  _cl_kernel_info _cl_uint _cl_kernel_info-values _cl_kernel_info/c
  (CL_KERNEL_FUNCTION_NAME CL_KERNEL_NUM_ARGS CL_KERNEL_REFERENCE_COUNT CL_KERNEL_CONTEXT CL_KERNEL_PROGRAM))

(define-opencl-enum
  _cl_kernel_work_group_info _cl_uint _cl_kernel_work_group_info-values _cl_kernel_work_group_info/c
  (CL_KERNEL_WORK_GROUP_SIZE CL_KERNEL_COMPILE_WORK_GROUP_SIZE CL_KERNEL_LOCAL_MEM_SIZE))

(define-opencl-enum
  _cl_event_info _cl_uint _cl_event_info-values _cl_event_info/c
  (CL_EVENT_COMMAND_QUEUE CL_EVENT_COMMAND_TYPE CL_EVENT_COMMAND_EXECUTION_STATUS CL_EVENT_REFERENCE_COUNT))

(define-opencl-enum
  _cl_command_type _cl_uint _cl_command_type-values _cl_command_type/c
  (CL_COMMAND_NDRANGE_KERNEL CL_COMMAND_TASK CL_COMMAND_NATIVE_KERNEL CL_COMMAND_READ_BUFFER CL_COMMAND_WRITE_BUFFER CL_COMMAND_COPY_BUFFER CL_COMMAND_READ_IMAGE CL_COMMAND_WRITE_IMAGE CL_COMMAND_COPY_IMAGE CL_COMMAND_COPY_BUFFER_TO_IMAGE CL_COMMAND_COPY_IMAGE_TO_BUFFER CL_COMMAND_MAP_BUFFER CL_COMMAND_MAP_IMAGE CL_COMMAND_UNMAP_MEM_OBJECT CL_COMMAND_MARKER CL_COMMAND_ACQUIRE_GL_OBJECTS CL_COMMAND_RELEASE_GL_OBJECTS))

(define-opencl-enum
  _command_execution_status _cl_int _command_execution_status-values _command_execution_status/c
  (CL_QUEUED CL_SUBMITTED CL_RUNNING CL_COMPLETE))

(define-opencl-enum
  _cl_profiling_info _cl_uint _cl_profiling_info-values _cl_profiling_info/c
  (CL_PROFILING_COMMAND_QUEUED CL_PROFILING_COMMAND_SUBMIT CL_PROFILING_COMMAND_START CL_PROFILING_COMMAND_END))
