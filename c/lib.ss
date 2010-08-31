#lang scheme/base
(require scheme/foreign)
(unsafe!)

(define opencl-path
  (case (system-type)
    [(macosx)
     (build-path "/System" "Library" "Frameworks" "OpenCL.framework" "OpenCL")]
    [(windows)
     (build-path (getenv "WINDIR") "system32" "OpenCL")]
    [(unix)
     "libOpenCL"]
    [else
     (error 'opencl "This platform is not (yet) supported.")]))

(define opencl-lib (ffi-lib opencl-path))

(define-syntax define-opencl
  (syntax-rules ()
    [(_ id ty)
     (define-opencl id id ty)]
    [(_ id internal-id ty)
     (define id (get-ffi-obj 'internal-id opencl-lib ty))]))

(provide define-opencl)