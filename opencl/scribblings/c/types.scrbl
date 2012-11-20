#lang scribble/doc
@(require scribble/manual
          scribble/basic
          scribble/extract
          (for-label (except-in ffi/unsafe ->)
                     racket
                     "../../c/types.rkt"))

@title[#:tag "Types"]{Types}

@defmodule[opencl/c/types]
@include-extracted["../../c/types.rkt"]
