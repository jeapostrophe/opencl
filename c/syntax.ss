#lang at-exp scheme/base
(require scheme/foreign
         (except-in scheme/contract ->)
         scheme/local
         (for-syntax scheme/base
                     scheme/function)
         (file "include/cl.ss")
         (file "lib.ss")
         (file "tsyntax.ss")
         (file "types.ss"))
(require scribble/srcdoc)
(require/doc scheme/base
             scribble/manual)

(define-syntax (define-opencl-info stx)
  (syntax-case stx (args : error variable fixed)
    [(_ id 
        (id:length id:selector)
        _param_type _param_type/c
        (args [arg_id : _arg_type _arg_type/c]
              ...)
        (error status error-expr)
        (variable param_value_size
                  [_vtype _vtype_type _vtype-default _vtype/c vparam_name ...]
                  ...)
        (fixed [_ftype _ftype/c fparam_name ...]
               ...))
     (with-syntax
         ([id/c (stxformat "~a/c" #'id)]
          [(id:_ftype ...) (map (curry stxformat "~a:~a" #'id) (syntax->list #'(_ftype ...)))]
          [(id:_vtype ...) (map (curry stxformat "~a:~a" #'id) (syntax->list #'(_vtype ...)))])
       (syntax/loc stx
         (begin
           ; Bind id for documentation
           (define (id . args)
             (error 'id "This function behaves differently for each type. Please use ~a or one of ~a." 'id:selector '(id:_ftype ... id:_vtype ...)))
           (provide/doc
            (thing-doc id procedure?
                       @{A dummy Scheme function that refers callers to the other @scheme[id]-based functions which access the true C function.}))
           ; Return status
           (define (id-return status success)
             (if (= status CL_SUCCESS)
                 (success)
                 error-expr))
           ; Info length
           (define-opencl id:length id
             (_fun [arg_id : _arg_type]
                   ...
                   [param_name : _param_type]
                   [param_value_size : _size_t = 0]
                   [param_value : _pointer = #f]
                   [param_value_size_ret : (_ptr o _size_t)]
                   -> [status : _cl_int]
                   -> (id-return status (lambda () param_value_size_ret))))
           (provide/doc
            (proc-doc id:length
                      (([arg_id _arg_type/c] ...
                        [param_name _param_type/c])
                       ()
                       . ->d .
                       [length _size_t/c])
                      @{Returns the size of @scheme[param_name] field of the argument(s). Calls @scheme[id] with values for @scheme[_param_value_size] and @scheme[_param_value] such that @scheme[param_value_size_ret] is queried.}))
           ; Fixed length
           (define-opencl id:_ftype id
             (_fun [arg_id : _arg_type]
                   ...
                   [param_name : _param_type]
                   [param_value_size : _size_t = (ctype-sizeof _ftype)]
                   [param_value : (_ptr o _ftype)]
                   [param_value_size_ret : _pointer = #f]
                   -> [status : _cl_int]
                   -> (id-return status (lambda () param_value))))
           ...
           (provide/doc
            (proc-doc id:_ftype
                      (([arg_id _arg_type/c] ...
                        [param_name _param_type/c])
                       ()
                       . ->d .
                       [value _ftype/c])
                      @{Returns the value associated with @scheme[param_name] for the argument(s). Implemented by @scheme[id] with @scheme[_param_value_size] set to @scheme[(ctype-sizeof _ftype)] so that the value is queried. Valid @scheme[param_name]s are @scheme['(fparam_name ...)].})
            ...)
           ; Variable length
           (define-opencl id:_vtype id
             (_fun [arg_id : _arg_type]
                   ...
                   [param_name : _param_type]
                   [param_value_size : _size_t]
                   [param_value : _vtype_type]
                   [param_value_size_ret : _pointer = #f]
                   -> [status : _cl_int]
                   -> (id-return status (lambda () param_value))))
           ...
           (provide/doc
            (proc-doc id:_vtype
                      (([arg_id _arg_type/c] ...
                        [param_name _param_type/c]
                        [param_value_size _size_t/c])
                       ()
                       . ->d .
                       [value _vtype/c])
                      @{Returns the value associated with @scheme[param_name] for the argument(s). Implemented by @scheme[id] with @scheme[param_value_size] passed explicitly. Uses @scheme[id:length] to find the maximum value. Valid @scheme[param_name]s are @scheme['(vparam_name ...)].})
            ...)
           ; Dispatcher
           (define id-selector-map (make-hasheq))
           (define (hash-set!* ht v . ks)
             (for ([k (in-list ks)])
               (hash-set! ht k v)))
           (hash-set!* id-selector-map '_vtype 'vparam_name ...)
           ...
           (hash-set!* id-selector-map '_ftype 'fparam_name ...)
           ...
           (define (id:selector _arg_type ... _param_type)
             (case (hash-ref id-selector-map _param_type #f)
               [(_vtype) 
                (local [(define len (id:length _arg_type ... _param_type))]
                  (if (zero? len)
                      _vtype-default
                      (id:_vtype _arg_type ... _param_type len)))]
               ...
               [(_ftype)
                (id:_ftype _arg_type ... _param_type)]
               ...
               [else
                (error 'id:selector "Invalid parameter: ~e" _param_type)]))
           (define id/c (or/c _ftype/c ... _vtype/c ...))
           (provide/doc
            (thing-doc id/c contract?
                       @{A contract for the return values of @scheme[id:selector]. Its definition is: @scheme[(or/c _ftype/c ... _vtype/c ...)].})
            (proc-doc id:selector
                      (([arg_id _arg_type/c] ...
                        [param_name _param_type/c])
                       ()
                       . ->d .
                       [value id/c])
                      @{Returns the value associated with @scheme[param_name] for the argument(s). Selects the appropriate @scheme[id]-based function to extract the appropriate value, automatically providing the right length for variable length functions.})))))]))

(define-syntax define-opencl-count
  (syntax-rules (error :)
    [(_ id
        (id:count id:extract)
        ([arg : _arg_type _arg_type/c]
         ...)
        _return_type _return_type_vector/c
        (error status error-expr))
     (begin
       (define (id:return status success)
         (cond [(= status CL_SUCCESS) (success)]
               [else error-expr]))
       (define-opencl id:count id
         (_fun [arg : _arg_type]
               ...
               [num : _cl_uint = 0]
               [rets : _pointer = #f]
               [num_rets : (_ptr o _cl_uint)]
               -> [status : _cl_int]
               -> (id:return status (lambda () num_rets))))
       (define-opencl id
         (_fun [arg : _arg_type]
               ...
               [num : _cl_uint]
               [rets : (_cvector o _return_type num)]
               [num_rets : (_ptr o _cl_uint)]
               -> [status : _cl_int]
               -> (id:return status (lambda () (values rets num_rets)))))
       (define (id:extract arg ...)
         (define how-many (id:count arg ...))
         (if (zero? how-many)
             (make-cvector _return_type 0)
             (local [(define-values (rs nrs) (id arg ... how-many))]
               rs)))
       (provide/doc
        (proc-doc id:count
                  (([arg _arg_type/c] ...)
                   ()
                   . ->d .
                   [how-many _cl_uint/c])
                  @{Returns how many results @scheme[id] may return for these arguments.})
        (proc-doc id
                  (([arg _arg_type/c] ...
                    [how-many _cl_uint/c])
                   ()
                   . ->d .
                   (values [rets _return_type_vector/c] [how-many-possible _cl_uint/c]))
                  @{Returns the minimum of @scheme[how-many] and @scheme[how-many-possible] values in @scheme[rets].})
        (proc-doc id:extract
                  (([arg _arg_type/c] ...)
                   ()
                   . ->d .
                   [rets _return_type_vector/c])
                  @{Returns all possible results from @scheme[id] using @scheme[id:count] to extract the number available.})))]))

(provide define-opencl-info
         define-opencl-count)