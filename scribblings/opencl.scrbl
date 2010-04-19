#lang scribble/doc
@(require scribble/manual
          scribble/basic
          scribble/extract
          (planet cce/scheme:4:1/planet)
          (for-label scheme/foreign
                     (this-package-in c)
                     (this-package-in scheme)))

@title[#:tag "top"]{OpenCL}
@author[(author+email "Jay McCarthy" "jay@plt-scheme.org")]

This package provides a binding for @link["http://en.wikipedia.org/wiki/OpenCL"]{OpenCL} based on the 1.0.48 revision.

This documentation does not describe meaning of API calls; it only describes their Scheme calling conventions. For details on API semantics, refer to the specification at the @link["http://www.khronos.org/registry/cl/"]{Khronos OpenCL API Registry}.

If you run @filepath{tests/test.ss}, it will print out a whole lot of stuff and run some code on all your OpenCL devices. This will show you that it is really doing something on your hardware.

Here's what you can do to help:

@itemize[
 @item{Test on other platforms and hardware.}
         
 @item{Write OpenCL programs and see what the API is missing. I suggest porting the programs from @link["https://developer.apple.com/mac/library/navigation/#section=Topics&topic=Performance"]{Apple's examples}.}
 ]

Here are some implementation notes:

@itemize[

@item{It is only tested on Mac OS X Snow Leopard with an Nvidia GeForce 9400M and Windows Vista 32-bit with an NVIDIA MSI N240GT. The binding will fail to load on other systems. I need to find the path to the OpenCL binding on other systems and put it in the definition of @scheme[opencl-path] at the top of @filepath{ffi.ss}. There are also a few C types that probably have sizes specific to version of OS X I'm using. Locating and dealing with these is essential.}

@item{The binding should wrap some objects in finalizers (using @scheme[register-finalizer]) that decrement their reference count.}

@item{The binding should wrap @scheme[_cl_event] objects in a struct with the @scheme[prop:evt] property to support synchronization in a Scheme style.}

@item{These functions should provide the properties in a Scheme style to look like fields or using the dictionary interface (by wrapping with @scheme[prop:dict].)}

@item{@scheme[clCreateContext]'s properties arguments is hard to fathom. It is defaulted to NULL in the binding.}

@item{No functions allow callbacks. (@scheme[clCreateContext] and @scheme[clBuildProgram] should.)}

@item{@scheme[clCreateProgramWithBinary] doesn't automatically extract the status of each binary.}

@item{@scheme[program-info] doesn't support the @scheme['CL_PROGRAM_BINARIES] option, because its calling convention doesn't match my macro.}

@item{@scheme[clSetKernelArg] is specialized for each argument type (i.e., @scheme[clSetKernelArg:_cl_mem]), but I definitely haven't created a binding for each available argument type.}

@item{@scheme[clGetKernelWorkGroupInfo] implements @scheme['CL_KERNEL_COMPILE_WORK_GROUP_SIZE] a bit wonky.}

@item{@scheme[clEnqueueNativeKernel] isn't available.}

]

@include-section["c.scrbl"]

@section[#:tag "Scheme"]{Scheme-style API Reference}

@defmodule/this-package[scheme]

The FFI provides Scheme-style names for many of the C API functions.

@include-extracted[(file "../scheme.ss")]
