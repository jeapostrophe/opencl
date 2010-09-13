#lang racket
(require "../../c.ss")
(require ffi/cvector)
(require ffi/unsafe/cvector)
(provide printDeviceInfo)


(define (printDeviceInfo device)
  (printf "  CL_DEVICE_NAME: \t\t\t~a~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_NAME))
  (printf "  CL_DEVICE_VENDOR: \t\t\t~a~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_VENDOR))
  (printf "  CL_DRIVER_VERSION: \t\t\t~a~n"
          (clGetDeviceInfo:generic device 'CL_DRIVER_VERSION))
  (printf "  CL_DEVICE_TYPE: \t\t\t~a~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_TYPE))
  (printf "  CL_DEVICE_MAX_COMPUTE_UNITS: \t\t~a~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_MAX_COMPUTE_UNITS))
  (printf "  CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS: \t~a~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS))
  (let ([sizes (clGetDeviceInfo:generic device 'CL_DEVICE_MAX_WORK_ITEM_SIZES)])
     (printf "  CL_DEVICE_MAX_WORK_ITEM_SIZES: \t~a / ~a / ~a~n"
          (cvector-ref sizes 0)
          (cvector-ref sizes 0)
          (cvector-ref sizes 0)))
  (printf "  CL_DEVICE_MAX_WORK_GROUP_SIZE: \t~a~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_MAX_WORK_GROUP_SIZE))
  (printf "  CL_DEVICE_MAX_CLOCK_FREQUENCY: \t~a MHz~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_MAX_CLOCK_FREQUENCY))
  (printf "  CL_DEVICE_ADDRESS_BITS: \t\t~a~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_ADDRESS_BITS))
  (printf "  CL_DEVICE_MAX_MEM_ALLOC_SIZE: \t~a MByte~n"
          (/ (clGetDeviceInfo:generic device 'CL_DEVICE_MAX_MEM_ALLOC_SIZE) (* 1024 1024)))
  (printf "  CL_DEVICE_GLOBAL_MEM_SIZE: \t\t~a MByte~n"
          (/ (clGetDeviceInfo:generic device 'CL_DEVICE_GLOBAL_MEM_SIZE) (* 1024 1024)))
  (printf "  CL_DEVICE_ERROR_CORRECTION_SUPPORT: \t~a~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_ERROR_CORRECTION_SUPPORT))
  (printf "  CL_DEVICE_LOCAL_MEM_TYPE: \t\t~a~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_LOCAL_MEM_TYPE))
  (printf "  CL_DEVICE_LOCAL_MEM_SIZE: \t\t~a KByte~n"
          (/ (clGetDeviceInfo:generic device 'CL_DEVICE_LOCAL_MEM_SIZE) 1024))
  (printf "  CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE: \t~a KByte~n"
          (/ (clGetDeviceInfo:generic device 'CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE) 1024))
  (printf "  CL_DEVICE_QUEUE_PROPERTIES: \t\t~a~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_QUEUE_PROPERTIES))
  (printf "  CL_DEVICE_IMAGE_SUPPORT: \t\t~a~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_IMAGE_SUPPORT))
  (printf "  CL_DEVICE_MAX_READ_IMAGE_ARGS: \t~a~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_MAX_READ_IMAGE_ARGS))
  (printf "  CL_DEVICE_MAX_WRITE_IMAGE_ARGS: \t~a~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_MAX_WRITE_IMAGE_ARGS))
  (printf "  CL_DEVICE_SINGLE_FP_CONFIG: \t\t~a~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_SINGLE_FP_CONFIG))
  (printf "~n  CL_DEVICE_IMAGE <dim>")
  (printf "\t\t\t2D_MAX_WIDTH\t ~a~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_IMAGE2D_MAX_WIDTH))
  (printf "\t\t\t\t\t2D_MAX_HEIGHT\t ~a~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_IMAGE2D_MAX_HEIGHT))
  (printf "\t\t\t\t\t3D_MAX_WIDTH\t ~a~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_IMAGE3D_MAX_WIDTH))
  (printf "\t\t\t\t\t3D_MAX_HEIGHT\t ~a~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_IMAGE3D_MAX_HEIGHT))
  (printf "\t\t\t\t\t3D_MAX_DEPTH\t ~a~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_IMAGE3D_MAX_DEPTH))
  (printf "~n  CL_DEVICE_EXTENSIONS: \t\t~a~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_EXTENSIONS))
  (printf "~n  CL_DEVICE_PREFERRED_VECTOR_WIDTH_<t>\t")
  (printf "CHAR ~a, SHORT ~a, INT ~a, LONG ~a, FLOAT ~a, DOUBLE ~a~n~n~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR)
          (clGetDeviceInfo:generic device 'CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT)
          (clGetDeviceInfo:generic device 'CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT)
          (clGetDeviceInfo:generic device 'CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG)
          (clGetDeviceInfo:generic device 'CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT)
          (clGetDeviceInfo:generic device 'CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE)))