#lang racket
(require "../../c.rkt")
(require "../utils/utils.rkt")
(require ffi/cvector)
(require ffi/unsafe/cvector)

(printf "oclDeviceQuery Starting...~n~n")
(printf "OpenCL SW Info:~n")

(define firstPlatform (cvector-ref (clGetPlatformIDs:vector) 0))
(printf " CL_PLATFORM_NAME:\t~a~n" (clGetPlatformInfo:generic firstPlatform 'CL_PLATFORM_NAME))
(printf " CL_PLATFORM_VERSION\t~a~n" (clGetPlatformInfo:generic firstPlatform 'CL_PLATFORM_VERSION))

(printf "~nOpenCL Device Info:~n")

(printf "~a devices found supporting OpenCL~n~n" 
        (clGetDeviceIDs:count firstPlatform 'CL_DEVICE_TYPE_ALL))

(define devices (clGetDeviceIDs:vector firstPlatform 'CL_DEVICE_TYPE_ALL))

(for ([device (in-list (cvector->list devices))])
  (printf "--------------------------~n~a~n"
          (clGetDeviceInfo:generic device 'CL_DEVICE_NAME))
  (printf "--------------------------~n")
  (printDeviceInfo device)
  (display "\n\n"))