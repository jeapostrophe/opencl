#lang scribble/doc
@(require scribble/manual
          scribble/basic
          unstable/planet
          unstable/scribble
          (for-label ffi/unsafe
                     "../c.rkt"
                     "../racket.rkt"))

@title[#:tag "C" #:style 'toc]{C API Reference}

@defmodule/this-package[ffi #:use-sources () ("../c.rkt")]

The FFI is mostly a transliteration of the C API. There are some arguments that are automatically computed and some C functions are represented in Racket with multiple types for each of their calling patterns. This documentation gives the exhaustive list of bindings and their contracts. Refer to the specification for the semantics of these functions. This documentation is organized around the specification to make this easier.

@local-table-of-contents[]

@include-section["c/types.scrbl"]
@include-section["c/4.scrbl"]
@include-section["c/5.scrbl"]