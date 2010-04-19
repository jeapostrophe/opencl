#lang scribble/doc
@(require scribble/manual
          scribble/basic
          scribble/extract
          (planet cce/scheme:4:1/planet)
          (for-label scheme/foreign
                     "../../c/types.ss"
                     "../../c/5.ss"
                     "../../c/5-1.ss"
                     "../../c/5-2.ss"
                     "../../c/5-3.ss"
                     "../../c/5-4.ss"
                     "../../c/5-5.ss"
                     "../../c/5-6.ss"
                     "../../c/5-7.ss"
                     "../../c/5-8.ss"
                     "../../c/5-9.ss"
                     "../../c/5-10.ss"))

@title[#:tag "5" #:style 'toc]{The OpenCL Runtime}

@defmodule/this-package[c/5]

@local-table-of-contents[]

@section[#:tag "5.1"]{Command Queues}
@defmodule/this-package[c/5-1 #:use-sources () ("../../c/5-1.ss")]
@include-extracted[(file "../../c/5-1.ss")]

@section[#:tag "5.2"]{Memory Objects}
@defmodule/this-package[c/5-2 #:use-sources () ("../../c/5-2.ss")]
@include-extracted[(file "../../c/5-2.ss")]

@section[#:tag "5.3"]{Sampler Objects}
@defmodule/this-package[c/5-3 #:use-sources () ("../../c/5-3.ss")]
@include-extracted[(file "../../c/5-3.ss")]

@section[#:tag "5.4"]{Program Objects}
@defmodule/this-package[c/5-4 #:use-sources () ("../../c/5-4.ss")]
@include-extracted[(file "../../c/5-4.ss")]

@section[#:tag "5.5"]{Kernel Objects}
@defmodule/this-package[c/5-5 #:use-sources () ("../../c/5-5.ss")]
@include-extracted[(file "../../c/5-5.ss")]

@section[#:tag "5.6"]{Executing Kernels}
@defmodule/this-package[c/5-6 #:use-sources () ("../../c/5-6.ss")]
@include-extracted[(file "../../c/5-6.ss")]

@section[#:tag "5.7"]{Event Objects}
@defmodule/this-package[c/5-7 #:use-sources () ("../../c/5-7.ss")]
@include-extracted[(file "../../c/5-7.ss")]

@section[#:tag "5.8"]{Out-of-order Execution of Kernels and Memory Object Commands}
@defmodule/this-package[c/5-8 #:use-sources () ("../../c/5-8.ss")]
@include-extracted[(file "../../c/5-8.ss")]

@section[#:tag "5.9"]{Profiling Operations on Memory Objects and Kernels}
@defmodule/this-package[c/5-9 #:use-sources () ("../../c/5-9.ss")]
@include-extracted[(file "../../c/5-9.ss")]

@section[#:tag "5.10"]{Flush and Finish}
@defmodule/this-package[c/5-10 #:use-sources () ("../../c/5-10.ss")]
@include-extracted[(file "../../c/5-10.ss")]
