#lang scribble/doc
@(require scribble/manual
          scribble/basic
          scribble/extract
          unstable/planet
          unstable/scribble
          unstable/require
          (for-label ffi/unsafe
                     (this-package-in c)
                     (this-package-in racket))
          (for-label ffi/unsafe
                     "../../c/types.rkt"
                     "../../c/4.rkt"
                     "../../c/4-1.rkt"
                     "../../c/4-2.rkt"
                     "../../c/4-3.rkt"))

@title[#:tag "4" #:style 'toc]{The OpenCL Platform Layer}

@defmodule/this-package[c/4]

@local-table-of-contents[]

@section[#:tag "4.1"]{Querying Platform Info}
@defmodule/this-package[c/4-1 #:use-sources () ("../../c/4-1.rkt")]
@include-extracted[(file "../../c/4-1.rkt")]

@section[#:tag "4.2"]{Querying Devices}
@defmodule/this-package[c/4-2 #:use-sources () ("../../c/4-2.rkt")]
@include-extracted[(file "../../c/4-2.rkt")]

@section[#:tag "4.3"]{Contexts}
@defmodule/this-package[c/4-3 #:use-sources () ("../../c/4-3.rkt")]
@include-extracted[(file "../../c/4-3.rkt")]
