#lang racket
(require "../../c.ss")
(require ffi/cvector)
(require ffi/unsafe/cvector)

(printf "oclDeviceQuery Starting...~n~n")
(printf "OpenCL SW Info:~n~n")

(define firstPlatform (cvector-ref (clGetPlatformIDs:vector) 0))
(clGetPlatformInfo:generic firstPlatform 'CL_PLATFORM_NAME)
(clGetPlatformInfo:generic firstPlatform 'CL_PLATFORM_VERSION)

(printf "OpenCL Device Info:~n~n")

(printf "~a devices found supporting OpenCL~n" 
        (clGetDeviceIDs:count firstPlatform 'CL_DEVICE_TYPE_ALL))

(define cpuDevice (cvector-ref (clGetDeviceIDs:vector firstPlatform 'CL_DEVICE_TYPE_CPU) 0))
(define gpuDevice (cvector-ref (clGetDeviceIDs:vector firstPlatform 'CL_DEVICE_TYPE_GPU) 0))
(clGetDeviceInfo:generic cpuDevice 'CL_DEVICE_NAME)
(clGetDeviceInfo:generic gpuDevice 'CL_DEVICE_NAME)