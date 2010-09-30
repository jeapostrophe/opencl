#lang scribble/doc
@(require scribble/manual
          scribble/basic
          scribble/extract
          unstable/planet
          unstable/scribble
          (for-label ffi/unsafe
                     "../../c.rkt"
                     "../../racket.rkt")
          (for-label ffi/unsafe
                     "../../c/types.rkt"))

@title[#:tag "Types"]{Types}

@defmodule/this-package[c/types #:use-sources () ("../../c/types.rkt")]
@include-extracted[(file "../../c/types.rkt")]
