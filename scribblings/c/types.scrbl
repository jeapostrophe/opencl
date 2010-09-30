#lang scribble/doc
@(require scribble/manual
          scribble/basic
          scribble/extract
          unstable/scribble
          (for-label (except-in ffi/unsafe ->)
                     racket
                     "../../c/types.rkt"))

@title[#:tag "Types"]{Types}

@defmodule/this-package[c/types #:use-sources () ("../../c/types.rkt")]
@include-extracted[(file "../../c/types.rkt")]
