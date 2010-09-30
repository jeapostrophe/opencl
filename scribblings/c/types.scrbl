#lang scribble/doc
@(require scribble/manual
          scribble/basic
          scribble/extract
          unstable/planet
          unstable/scribble
          unstable/require
          (for-label racket/foreign
                     (this-package-in c)
                     (this-package-in racket))
          (for-label racket/foreign
                     "../../c/types.rkt"))

@title[#:tag "Types"]{Types}

@defmodule/this-package[c/types #:use-sources () ("../../c/types.rkt")]
@include-extracted[(file "../../c/types.rkt")]
