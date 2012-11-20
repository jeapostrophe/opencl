#lang scribble/doc
@(require scribble/manual
          scribble/basic
          (for-label "../c.rkt"))

@title[#:tag "C" #:style 'toc]{C API Reference}

@defmodule[opencl/c]

The FFI is mostly a transliteration of the C API. There are some arguments that are automatically computed and some C functions are represented in Racket with multiple types for each of their calling patterns. This documentation gives the exhaustive list of bindings and their contracts. Refer to the specification for the semantics of these functions. This documentation is organized around the specification to make this easier.

@local-table-of-contents[]

@include-section["c/types.scrbl"]
@include-section["c/4.scrbl"]
@include-section["c/5.scrbl"]
