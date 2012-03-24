#lang scribble/doc
@(require scribble/manual
          scribble/basic
          scribble/extract
          planet/scribble
          (for-label (except-in ffi/unsafe ->)
                     racket
                     "../../c/types.rkt"))

@title[#:tag "Types"]{Types}

@defmodule/this-package[c/types]
@include-extracted[(file "../../c/types.rkt")]
