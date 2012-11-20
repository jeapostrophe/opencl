#lang scribble/doc
@(require scribble/manual
          scribble/basic
          scribble/extract
          (for-label (except-in ffi/unsafe ->)
                     "../../c/5.rkt"
                     "../../c/5-1.rkt"
                     "../../c/5-2.rkt"
                     "../../c/5-3.rkt"
                     "../../c/5-4.rkt"
                     "../../c/5-5.rkt"
                     "../../c/5-6.rkt"
                     "../../c/5-7.rkt"
                     "../../c/5-8.rkt"
                     "../../c/5-9.rkt"
                     "../../c/5-10.rkt"))

@title[#:tag "5" #:style 'toc]{The OpenCL Runtime}

@defmodule[opencl/c/5]

@local-table-of-contents[]

@section[#:tag "5.1"]{Command Queues}
@defmodule[opencl/c/5-1]
@include-extracted["../../c/5-1.rkt"]

@section[#:tag "5.2"]{Memory Objects}
@defmodule[opencl/c/5-2]
@include-extracted["../../c/5-2.rkt"]

@section[#:tag "5.3"]{Sampler Objects}
@defmodule[opencl/c/5-3]
@include-extracted["../../c/5-3.rkt"]

@section[#:tag "5.4"]{Program Objects}
@defmodule[opencl/c/5-4]
@include-extracted["../../c/5-4.rkt"]

@section[#:tag "5.5"]{Kernel Objects}
@defmodule[opencl/c/5-5]
@include-extracted["../../c/5-5.rkt"]

@section[#:tag "5.6"]{Executing Kernels}
@defmodule[opencl/c/5-6]
@include-extracted["../../c/5-6.rkt"]

@section[#:tag "5.7"]{Event Objects}
@defmodule[opencl/c/5-7]
@include-extracted["../../c/5-7.rkt"]

@section[#:tag "5.8"]{Out-of-order Execution of Kernels and Memory Object Commands}
@defmodule[opencl/c/5-8]
@include-extracted["../../c/5-8.rkt"]

@section[#:tag "5.9"]{Profiling Operations on Memory Objects and Kernels}
@defmodule[opencl/c/5-9]
@include-extracted["../../c/5-9.rkt"]

@section[#:tag "5.10"]{Flush and Finish}
@defmodule[opencl/c/5-10]
@include-extracted["../../c/5-10.rkt"]
