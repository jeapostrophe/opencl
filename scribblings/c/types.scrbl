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
                     "../../c/types.rkt"))

@title[#:tag "Types"]{Types}

@defmodule/this-package[c/types #:use-sources () ("../../c/types.rkt")]
@include-extracted[(file "../../c/types.rkt")]
