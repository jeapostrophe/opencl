#lang scribble/doc
@(require scribble/manual
          scribble/basic
          scribble/extract
          (planet cce/scheme:4:1/planet)
          (for-label scheme/foreign
                     "../../c/types.ss"
                     "../../c/4.ss"
                     "../../c/4-1.ss"
                     "../../c/4-2.ss"
                     "../../c/4-3.ss"))

@title[#:tag "4" #:style 'toc]{The OpenCL Platform Layer}

@defmodule/this-package[c/4]

@local-table-of-contents[]

@section[#:tag "4.1"]{Querying Platform Info}
@defmodule/this-package[c/4-1 #:use-sources () ("../../c/4-1.ss")]
@include-extracted[(file "../../c/4-1.ss")]

@section[#:tag "4.2"]{Querying Devices}
@defmodule/this-package[c/4-2 #:use-sources () ("../../c/4-2.ss")]
@include-extracted[(file "../../c/4-2.ss")]

@section[#:tag "4.3"]{Contexts}
@defmodule/this-package[c/4-3 #:use-sources () ("../../c/4-3.ss")]
@include-extracted[(file "../../c/4-3.ss")]
