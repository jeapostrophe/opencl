#lang scribble/doc
@(require scribble/manual
          scribble/basic
          scribble/extract
          unstable/scribble
          (for-label (except-in ffi/unsafe ->)
                     racket
                     "../c.rkt"
                     "../racket.rkt"))

@title[#:tag "top"]{OpenCL}
@author[(author+email "Jay McCarthy" "jay@racket-lang.org")]

This package provides a binding for @link["http://en.wikipedia.org/wiki/OpenCL"]{OpenCL} based on the 1.0.48 revision.

This documentation does not describe meaning of API calls; it only describes their Racket calling conventions. For details on API semantics, refer to the specification at the @link["http://www.khronos.org/registry/cl/"]{Khronos OpenCL API Registry}.

If you run @filepath{tests/test.rkt}, it will print out a whole lot of stuff and run some code on all your OpenCL devices. This will show you that it is really doing something on your hardware.

Here are some caveats:

@itemize[

@item{The binding should wrap some objects in finalizers (using @racket[register-finalizer]) that decrement their reference count.}

@item{The binding should wrap @racket[_cl_event] objects in a struct with the @racket[prop:evt] property to support synchronization in a Racket style.}

@item{These functions should provide the properties in a Racket style to look like fields or using the dictionary interface (by wrapping with @racket[prop:dict].)}

@item{@racket[clCreateContext]'s properties argument is hard to fathom. It is defaulted to NULL in the binding.}

@item{No functions allow callbacks. (@racket[clCreateContext] and @racket[clBuildProgram] should.)}

@item{@racket[clCreateProgramWithBinary] doesn't automatically extract the status of each binary.}

@item{@racket[program-info] doesn't support the @racket['CL_PROGRAM_BINARIES] option, because its calling convention doesn't match my macro.}

@item{@racket[clSetKernelArg] is specialized for each argument type (i.e., @racket[clSetKernelArg:_cl_mem]), but I definitely haven't created a binding for each available argument type.}

@item{@racket[clGetKernelWorkGroupInfo] implements @racket['CL_KERNEL_COMPILE_WORK_GROUP_SIZE] a bit wonky.}

@item{@racket[clEnqueueNativeKernel] isn't available.}

]

@include-section["c.scrbl"]

@section[#:tag "Racket"]{Racket-style API Reference}

@defmodule/this-package[racket]

The FFI provides Racket-style names for many of the C API functions.

@include-extracted[(file "../racket.rkt")]
