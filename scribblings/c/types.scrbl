#lang scribble/doc
@(require scribble/manual
          scribble/basic
          scribble/extract
          (planet cce/scheme:4:1/planet)
          (for-label scheme/foreign
                     "../../c/types.ss"))

@title[#:tag "Types"]{Types}

@defmodule/this-package[c/types #:use-sources () ("../../c/types.ss")]
@include-extracted[(file "../../c/types.ss")]
