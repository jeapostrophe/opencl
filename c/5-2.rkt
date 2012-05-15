#lang at-exp racket/base
(require ffi/unsafe
         (except-in racket/contract ->)
         (prefix-in c: racket/contract)
         scribble/srcdoc  
         "include/cl.rkt"
         "lib.rkt"
         "syntax.rkt"
         "types.rkt")
(require/doc racket/base
             scribble/manual
             (for-label "types.rkt"))

;;;;
(define-opencl clCreateBuffer
  (_fun [context : _cl_context]
        [flags : _cl_mem_flags]
        [size : _size_t]
        [host_ptr : _void*/null]
        [errcode_ret : (_ptr o _cl_int)]
        -> [buffer : _cl_mem/null]
        -> (cond
             [(= errcode_ret CL_SUCCESS)
              buffer]
             [(= errcode_ret CL_INVALID_CONTEXT)
              (error 'clCreateBuffer "~e is not a valid context"
                     context)]
             [(= errcode_ret CL_INVALID_VALUE)
              (error 'clCreateBuffer "values specified in ~e are not valid"
                     flags)]
             [(= errcode_ret CL_INVALID_BUFFER_SIZE)
              (error 'clCreateBuffer "~e is 0 or is greater than CL_DEVICE_MAX_MEM_ALLOC_SIZE value specified in table 4.3 for all devices in ~e"
                     size context)]
             [(= errcode_ret CL_INVALID_HOST_PTR)
              (error 'clCreateBuffer "~e is NULL and CL_MEM_USE_HOST_PTR or CL_MEM_COPY_HOST_PTR are set in ~e or if ~e is not NULL but CL_MEM_COPY_HOST_PTR or CL_MEM_USE_HOST_PTR are not set in ~e"
                     host_ptr flags host_ptr flags)]
             [(= errcode_ret CL_MEM_OBJECT_ALLOCATION_FAILURE)
              (error 'clCreateBuffer "there is a failure to allocate memory for buffer object")]
             [(= errcode_ret CL_OUT_OF_HOST_MEMORY)
              (error 'clCreateBuffer "there is a failure to allocate resources required by the OpenCL implmentation on the host")]
             [else
              (error 'clCreateBuffer "Invalid error code: ~e"
                     errcode_ret)])))
(provide/doc
 [proc-doc/names clCreateBuffer
                 (c:-> _cl_context/c  _cl_mem_flags/c _size_t/c _void*/null/c _cl_mem/c)
                 (ctxt mem-flags size host-ptr)
                 @{}])

;;;;
(define-syntax-rule (define-clEnqueueReadBuffer-like clEnqueueReadBuffer)
  (begin
    (define-opencl clEnqueueReadBuffer
      (_fun [command_queue : _cl_command_queue]
            [buffer : _cl_mem]
            [blocking_read : _cl_bool]
            [offset : _size_t]
            [cb : _size_t]
            [ptr : _void*]
            [num_events_in_wait_list : _cl_uint = (vector-length event_wait_list)]
            [event_wait_list : (_vector i _cl_event)]
            [event : (_ptr o _cl_event/null)]
            -> [status : _cl_int]
            ->
            (cond
              [(= status CL_SUCCESS)
               event]
              [(= status CL_INVALID_COMMAND_QUEUE)
               (error 'clEnqueueReadBuffer "command_queue is not a valid command-queue")]
              [(= status CL_INVALID_CONTEXT)
               (error 'clEnqueueReadBuffer "the context associated with command_queue and buffer are not the same or the context associated with command_queue and events in event_wait_list are not the same")]
              [(= status CL_INVALID_MEM_OBJECT)
               (error 'clEnqueueReadBuffer "buffer is not a valid buffer object")]
              [(= status CL_INVALID_VALUE)
               (error 'clEnqueueReadBuffer "the region being read or written specified by (offest, cb) is out of bounds or if ptr is a NULL value")]
              [(= status CL_INVALID_EVENT_WAIT_LIST)
               (error 'clEnqueueReadBuffer "event_wait_list is NULL and num_events_in_wait_list > 0 or event_wait_list is not NULL and num_events_in_wait_list is 0, or if event objects in event_wait_list are not valid events")]
              [(= status CL_MEM_OBJECT_ALLOCATION_FAILURE)
               (error 'clEnqueueReadBuffer "there is a failure to allocate memory for data store associated with buffer")]
              [(= status CL_OUT_OF_HOST_MEMORY)
               (error 'clEnqueueReadBuffer "there is a failure to allocate resources required by the OpenCL implementation on the host")]
              [else
               (error 'clEnqueueReadBuffer "Invalid error code: ~e"
                      status)])))
    (provide/doc
     [proc-doc/names
      clEnqueueReadBuffer
      (c:-> _cl_command_queue/c _cl_mem/c _cl_bool/c _size_t/c _size_t/c _void*/c (vectorof _cl_event/c) _cl_event/c)
      (cq buffer blocking? offset cb ptr wait-list)
      @{}])))

(define-clEnqueueReadBuffer-like clEnqueueReadBuffer)
(define-clEnqueueReadBuffer-like clEnqueueWriteBuffer)

;;;;

(define-opencl clEnqueueCopyBuffer
  (_fun [command_queue : _cl_command_queue]
        [src_buffer : _cl_mem]
        [dst_buffer : _cl_mem]
        [src_offset : _size_t]
        [dst_offset : _size_t]
        [cb : _size_t]
        [num_events_in_wait_list : _cl_uint = (vector-length event_wait_list)]
        [event_wait_list : (_vector i _cl_event)]
        [event : (_ptr o _cl_event/null)]
        -> [status : _cl_int]
        ->
        (cond
          [(= status CL_SUCCESS)
           event]
          [(= status CL_INVALID_COMMAND_QUEUE)
           (error 'clEnqueueCopyBuffer "command_queue is not a valid command-queue")]
          [(= status CL_INVALID_CONTEXT)
           (error 'clEnqueueCopyBuffer "the context associated with command_queue, src_buffer and dst_bufer are not the same or the context associated with command_queue and events in event_wait_list are not the same")]
          [(= status CL_INVALID_MEM_OBJECT)
           (error 'clEnqueueCopyBuffer "src_buffer and dst_buffer are not a valid buffer objects")]
          [(= status CL_INVALID_VALUE)
           (error 'clEnqueueCopyBuffer "src_offset, dst_offset, cb, src_offset + cb or dst_offesrt + cb require accessing elements outside the buffer memory objects")]
          [(= status CL_INVALID_EVENT_WAIT_LIST)
           (error 'clEnqueueCopyBuffer "event_wait_list is NULL and num_events_in_wait_list > 0 or event_wait_list is not NULL and num_events_in_wait_list is 0, or if event objects in event_wait_list are not valid events")]
          [(= status CL_MEM_COPY_OVERLAP)
           (error 'clEnqueueCopyBuffer "src_buffer and dst_buffer are the same buffer object and the source and destination regions overlap")]
          [(= status CL_MEM_OBJECT_ALLOCATION_FAILURE)
           (error 'clEnqueueCopyBuffer "there is a failure to allocate memory for data store associated with src_buffer or dst_buffer")]
          [(= status CL_OUT_OF_HOST_MEMORY)
           (error 'clEnqueueCopyBuffer "there is a failure to allocate resources required by the OpenCL implementation on the host")]
          [else
           (error 'clEnqueueCopyBuffer "Invalid error code: ~e"
                  status)])))
(provide/doc
 [proc-doc/names
  clEnqueueCopyBuffer
  (c:-> _cl_command_queue/c _cl_mem/c _cl_mem/c _size_t/c _size_t/c _size_t/c (vectorof _cl_event/c) _cl_event/c)
  (cq src dst src_offset dst_offset cb wait-list)
  @{}])

;;;;
(define-opencl clRetainMemObject
  (_fun [memobj : _cl_mem]
        -> [status : _cl_int]
        -> (cond [(= status CL_SUCCESS) 
                  (void)]
                 [(= status CL_INVALID_MEM_OBJECT)
                  (error 'clRetainMemObject "memobj is not a valid memory object")]
                 [else
                  (error 'clRetainMemObject "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc/names
  clRetainMemObject
  (c:-> _cl_mem/c void)
  (memobj)
  @{}])

;;;;
(define-opencl clReleaseMemObject
  (_fun [memobj : _cl_mem]
        -> [status : _cl_int]
        -> (cond [(= status CL_SUCCESS) 
                  (void)]
                 [(= status CL_INVALID_MEM_OBJECT)
                  (error 'clReleaseMemObject "memobj is not a valid memory object")]
                 [else
                  (error 'clReleaseMemObject "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc/names
  clReleaseMemObject
  (c:-> _cl_mem/c void)
  (memobj)
  @{}])

;;;;

(define-opencl clCreateImage2D
  (_fun [context : _cl_context]
        [flags : _cl_mem_flags]
        [image_format : _cl_image_format-pointer]
        [image_width : _size_t]
        [image_height : _size_t]
        [image_row_pitch : _size_t]
        [host_ptr : _void*/null]
        [errcode_ret : (_ptr o _cl_int)]
        -> [mem : _cl_mem/null]
        ->
        (cond
          [(= errcode_ret CL_SUCCESS)
           mem]
          [(= errcode_ret CL_INVALID_CONTEXT)
           (error 'clCreateImage2D "context is not a valid context")]
          [(= errcode_ret CL_INVALID_VALUE)
           (error 'clCreateImage2D "values specified in flags are not valid")]
          [(= errcode_ret CL_INVALID_IMAGE_FORMAT_DESCRIPTOR)
           (error 'clCreateImage2D "values specified in image_format are not valid or if image_format is NULL")]
          [(= errcode_ret CL_INVALID_IMAGE_SIZE)
           (error 'clCreateImage2D "image_width or image_height are 0 of if they exceed values specified in CL_DEVICE_IMAGE2D_MAX_WIDTH or CL_DEVICE_IMAGE2D_MAX_HEIGHT respectively for all devices in context or if values specified by image_row_pitch do not follow rules described in the argument description above.")]
          [(= errcode_ret CL_INVALID_HOST_PTR)
           (error 'clCreateImage2D "host_ptr is NULL and CL_MEM_USE_HOST_PTR or CL_MEM_COPY_HOST_PTR are set in flags or if host_ptr is not NULL but CL_MEM_COPY_HOST_PTR or CL_MEM_USE_HOST_PTR are not set in flags")]
          [(= errcode_ret CL_IMAGE_FORMAT_NOT_SUPPORTED)
           (error 'clCreateImage2D "the image_format is not supported")]
          [(= errcode_ret CL_MEM_OBJECT_ALLOCATION_FAILURE)
           (error 'clCreateImage2D "there is a failure to allocate memory for image object")]
          [(= errcode_ret CL_INVALID_OPERATION)
           (error 'clCreateImage2D "there are no devices in context that support images")]
          [(= errcode_ret CL_OUT_OF_HOST_MEMORY)
           (error 'clCreateImage2D "there is a failure to allocate resources required by the OpenCL implementation on the host")]
          [else
           (error 'clCreateImage2D "Invalid error code: ~e" errcode_ret)])))
(provide/doc
 [proc-doc/names
  clCreateImage2D
  (c:-> _cl_context/c _cl_mem_flags/c _cl_image_format/c _size_t/c _size_t/c _size_t/c _void*/c _cl_mem/c)
  (ctxt mem-flags format image-width image-height image-row-pitch host-ptr)
  @{}])

;;;;
(define-opencl clCreateImage3D
  (_fun [context : _cl_context]
        [flags : _cl_mem_flags]
        [image_format : _cl_image_format-pointer]
        [image_width : _size_t]
        [image_height : _size_t]
        [image_depth : _size_t]
        [image_row_pitch : _size_t]
        [image_slice_pitch : _size_t]
        [host_ptr : _void*/null]
        [errcode_ret : (_ptr o _cl_int)]
        -> [mem : _cl_mem/null]
        ->
        (cond
          [(= errcode_ret CL_SUCCESS)
           mem]
          [(= errcode_ret CL_INVALID_CONTEXT)
           (error 'clCreateImage3D "context is not a valid context")]
          [(= errcode_ret CL_INVALID_VALUE)
           (error 'clCreateImage3D "values specified in flags are not valid")]
          [(= errcode_ret CL_INVALID_IMAGE_FORMAT_DESCRIPTOR)
           (error 'clCreateImage3D "values specified in image_format are not valid or if image_format is NULL")]
          [(= errcode_ret CL_INVALID_IMAGE_SIZE)
           (error 'clCreateImage3D "image_width or image_height are 0 or if image_depth <= 1 or if they exceed values specified in CL_DEVICE_IMAGE3D_MAX_WIDTH, CL_DEVICE_IMAGE3D_MAX_HEIGHT, or CL_DEVICE_IMAGE3D_MAX_DEPTH respectively for all devices in context or if values specified by image_row_pitch and image_slice_ptch do not follow rules described in the argument description above.")]
          [(= errcode_ret CL_INVALID_HOST_PTR)
           (error 'clCreateImage3D "host_ptr is NULL and CL_MEM_USE_HOST_PTR or CL_MEM_COPY_HOST_PTR are set in flags or if host_ptr is not NULL but CL_MEM_COPY_HOST_PTR or CL_MEM_USE_HOST_PTR are not set in flags")]
          [(= errcode_ret CL_IMAGE_FORMAT_NOT_SUPPORTED)
           (error 'clCreateImage3D "the image_format is not supported")]
          [(= errcode_ret CL_MEM_OBJECT_ALLOCATION_FAILURE)
           (error 'clCreateImage3D "there is a failure to allocate memory for image object")]
          [(= errcode_ret CL_INVALID_OPERATION)
           (error 'clCreateImage3D "there are no devices in context that support images")]
          [(= errcode_ret CL_OUT_OF_HOST_MEMORY)
           (error 'clCreateImage3D "there is a failure to allocate resources required by the OpenCL implementation on the host")]
          [else
           (error 'clCreateImage3D "Invalid error code: ~e" errcode_ret)])))
(provide/doc
 [proc-doc/names
  clCreateImage3D
  (c:-> _cl_context/c _cl_mem_flags/c _cl_image_format/c _size_t/c _size_t/c _size_t/c _size_t/c _size_t/c _void*/c _cl_mem/c)
  (ctxt mem-flags format image-width image-height image-depth image-row-pitch image-slice-pitch host-ptr)
  @{}])

;;;;
(define-opencl-count
  clGetSupportedImageFormats
  (clGetSupportedImageFormats:count clGetSupportedImageFormats:vector)
  ([context : _cl_context _cl_context/c]
   [flags : _cl_mem_flags _cl_mem_flags/c]
   [image_type : _cl_mem_object_type _cl_mem_object_type/c])
  _cl_image_format _cl_image_format_vector/c
  (error status
         (cond
           [(= status CL_INVALID_CONTEXT)
            (error 'clGetSupportedImageFormats "context is not a valid context")]
           [(= status CL_INVALID_VALUE)
            (error 'clGetSupportedImageFormats "flags or image_type are not valid or if num_entries is 0 and image_foramts is not NULL")]
           [else
            (error 'clGetSupportedImageFormats "Invalid error code: ~e" status)])))
;;;;

(define-syntax-rule (define-clEnqueueReadImage-like clEnqueueReadImage)
  (begin
    (define-opencl clEnqueueReadImage
      (_fun [command_queue : _cl_command_queue]
            [image : _cl_mem]
            [blocking_read : _cl_bool]
            [origin : (_vector i _size_t)] ; len = 3
            [region : (_vector i _size_t)] ; len = 3
            [row_pitch : _size_t]
            [slice_pitch : _size_t]
            [ptr : _void*]
            [num_events_in_wait_list : _cl_uint = (vector-length event_wait_list)]
            [event_wait_list : (_vector i _cl_event)]
            [event : (_ptr o _cl_event/null)]
            -> [status : _cl_int]
            -> 
            (cond [(= status CL_SUCCESS)
                   event]
                  [(= status CL_INVALID_COMMAND_QUEUE)
                   (error 'clEnqueueReadImage "command_queue is not a valid command-queue")]
                  [(= status CL_INVALID_CONTEXT)
                   (error 'clEnqueueReadImage "the context associated with command_queue and image are not the same or if the context associated with command_queue and events in event_wait_list are not the same")]
                  [(= status CL_INVALID_MEM_OBJECT)
                   (error 'clEnqueueReadImage "image is not a valid image object")]
                  [(= status CL_INVALID_VALUE)
                   (error 'clEnqueueReadImage "the region being read or written specified by origin and region is out of bounds or if ptr is a NULL value or if image is a 2D image object and origin[2] is not equal to 0 or region[2] is not eqal to 1 or slice_pitch is not requal to 0")]
                  [(= status CL_INVALID_EVENT_WAIT_LIST)
                   (error 'clEnqueueReadImage "event_wait_list is NULL and num_event_in_wait_list > 0 or event_wait_list is not NULL and num_events_in_wait_list is 0, or event objects in event_wait_list are not valid events")]
                  [(= status CL_MEM_OBJECT_ALLOCATION_FAILURE)
                   (error 'clEnqueueReadImage "there is a failure to allocate memory for data store associated with image")]
                  [(= status CL_INVALID_OPERATION)
                   (error 'clEnqueueReadImage "the device associated with command_queue does not support images")]
                  [(= status CL_OUT_OF_HOST_MEMORY)
                   (error 'clEnqueueReadImage "there is a failure to allocate resources required by the OpenCL implementation on the host")]
                  [else
                   (error 'clEnqueueReadImage "Invalid error code: ~e" status)])))
    (provide/doc
     [proc-doc/names
      clEnqueueReadImage
      (c:-> _cl_command_queue/c _cl_mem/c _cl_bool/c
            (vector/c _size_t/c _size_t/c _size_t/c)
            (vector/c _size_t/c _size_t/c _size_t/c) 
            _size_t/c _size_t/c _void*/c (vectorof _cl_event/c)
            _cl_event/c)
      (cq image blocking? origin region row-pitch slice-ptch ptr wait-list)
      @{}])))

(define-clEnqueueReadImage-like clEnqueueReadImage)
(define-clEnqueueReadImage-like clEnqueueWriteImage)

;;;;
(define-opencl clEnqueueCopyImage
  (_fun [command_queue : _cl_command_queue]
        [src_image : _cl_mem]
        [dst_image : _cl_mem]
        [src_origin : (_vector i _size_t)] ; len = 3
        [dst_origin : (_vector i _size_t)] ; len = 3
        [region : (_vector i _size_t)] ; len = 3
        [num_events_in_wait_list : _cl_uint = (vector-length event_wait_list)]
        [event_wait_list : (_vector i _cl_event)]
        [event : (_ptr o _cl_event/null)]
        -> [status : _cl_int]
        -> 
        (cond [(= status CL_SUCCESS)
               event]
              [(= status CL_INVALID_COMMAND_QUEUE)
               (error 'clEnqueueCopyImage "command_queue is not a valid command-queue")]
              [(= status CL_INVALID_CONTEXT)
               (error 'clEnqueueCopyImage "the context associated with command_queue, src_image and dst_image are not the same or if the context associated with command_queue and events in event_wait_list are not the same")]
              [(= status CL_INVALID_MEM_OBJECT)
               (error 'clEnqueueCopyImage "src_image or dst_image are not valid image objects")]
              [(= status CL_IMAGE_FORMAT_MISMATCH)
               (error 'clEnqueueCopyImage "src_image and dst_image do not use the same image format")]
              [(= status CL_INVALID_VALUE)
               (error 'clEnqueueCopyImage "the 2D or 3D rectangular region specified by src_origin and src_origin + region referes to a region outside src_image or if the 2D or 3D rectangular region specified by dst_origin and dst_origin+region refers to a region outside dst_image or src_image is a 2D image object and src_origin[2] is not equal to 0 or region[2] is not requal to 1 or dst_image is a 2d image object and dst_origin[2] is not equal to 0 or region[2] is not equal to 1")]
              [(= status CL_INVALID_EVENT_WAIT_LIST)
               (error 'clEnqueueCopyImage "event_wait_list is NULL and num_event_in_wait_list > 0 or event_wait_list is not NULL and num_events_in_wait_list is 0, or event objects in event_wait_list are not valid events")]
              [(= status CL_MEM_OBJECT_ALLOCATION_FAILURE)
               (error 'clEnqueueCopyImage "there is a failure to allocate memory for data store associated with src_image or dst_image")]
              [(= status CL_INVALID_OPERATION)
               (error 'clEnqueueCopyImage "the device associated with command_queue does not support images")]
              [(= status CL_OUT_OF_HOST_MEMORY)
               (error 'clEnqueueCopyImage "there is a failure to allocate resources required by the OpenCL implementation on the host")]
              [(= status CL_MEM_COPY_OVERLAP)
               (error 'clEnqueueCopyImage "src_image and dst_image are the same image object and the source and destination regions overlap")]
              [else
               (error 'clEnqueueCopyImage "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc/names
  clEnqueueCopyImage
  (c:-> _cl_command_queue/c _cl_mem/c _cl_mem/c
        (vector/c _size_t/c _size_t/c _size_t/c)
        (vector/c _size_t/c _size_t/c _size_t/c)
        (vector/c _size_t/c _size_t/c _size_t/c)
        (vectorof _cl_event/c) 
        _cl_event/c)
  (cq src dst src-origin dst-origin region wait-list)
  @{}])

;;;;
(define-opencl clEnqueueCopyImageToBuffer
  (_fun [command_queue : _cl_command_queue]
        [src_image : _cl_mem]
        [dst_buffer : _cl_mem]
        [src_origin : (_vector i _size_t)] ; len = 3
        [region : (_vector i _size_t)] ; len = 3
        [dst_offset : _size_t]
        [num_events_in_wait_list : _cl_uint = (vector-length event_wait_list)]
        [event_wait_list : (_vector i _cl_event)]
        [event : (_ptr o _cl_event/null)]
        -> [status : _cl_int]
        -> 
        (cond [(= status CL_SUCCESS)
               event]
              [(= status CL_INVALID_COMMAND_QUEUE)
               (error 'clEnqueueCopyImageToBuffer "command_queue is not a valid command-queue")]
              [(= status CL_INVALID_CONTEXT)
               (error 'clEnqueueCopyImageToBuffer "the context associated with command_queue, src_image and dst_buffer are not the same or if the context associated with command_queue and events in event_wait_list are not the same")]
              [(= status CL_INVALID_MEM_OBJECT)
               (error 'clEnqueueCopyImageToBuffer "src_image is not a valid image object or dst_buffer is not a valid buffer object")]
              [(= status CL_INVALID_VALUE)
               (error 'clEnqueueCopyImageToBuffer "the 2D or 3D rectangular region specified by src_origin and src_origin + region referes to a region outside src_image or if the region specified by dst_offset and dst_offset + dst_cb to a region outside dst_buffer or src_image is a 2D image object and src_origin[2] is not equal to 0 or region[2] is not equal to 1")]
              [(= status CL_INVALID_EVENT_WAIT_LIST)
               (error 'clEnqueueCopyImageToBuffer "event_wait_list is NULL and num_event_in_wait_list > 0 or event_wait_list is not NULL and num_events_in_wait_list is 0, or event objects in event_wait_list are not valid events")]
              [(= status CL_MEM_OBJECT_ALLOCATION_FAILURE)
               (error 'clEnqueueCopyImageToBuffer "there is a failure to allocate memory for data store associated with src_image or dst_buffer")]
              [(= status CL_INVALID_OPERATION)
               (error 'clEnqueueCopyImageToBuffer "the device associated with command_queue does not support images")]
              [(= status CL_OUT_OF_HOST_MEMORY)
               (error 'clEnqueueCopyImageToBuffer "there is a failure to allocate resources required by the OpenCL implementation on the host")]
              [else
               (error 'clEnqueueCopyImageToBuffer "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc/names
  clEnqueueCopyImageToBuffer
  (c:-> _cl_command_queue/c _cl_mem/c _cl_mem/c 
        (vector/c _size_t/c _size_t/c _size_t/c)
        (vector/c _size_t/c _size_t/c _size_t/c) 
        _size_t/c 
        (vectorof _cl_event/c)
        _cl_event/c)
  (cq src-image dst-buffer src-origin region dst-offset wait-list)
  @{}])
;;;;
(define-opencl clEnqueueCopyBufferToImage
  (_fun [command_queue : _cl_command_queue]
        [src_buffer : _cl_mem]
        [dst_image : _cl_mem]
        [src_offset : _size_t]
        [dst_origin : (_vector i _size_t)] ; len = 3
        [region : (_vector i _size_t)] ; len = 3
        [num_events_in_wait_list : _cl_uint = (vector-length event_wait_list)]
        [event_wait_list : (_vector i _cl_event)]
        [event : (_ptr o _cl_event/null)]
        -> [status : _cl_int]
        -> 
        (cond [(= status CL_SUCCESS)
               event]
              [(= status CL_INVALID_COMMAND_QUEUE)
               (error 'clEnqueueCopyBufferToImage "command_queue is not a valid command-queue")]
              [(= status CL_INVALID_CONTEXT)
               (error 'clEnqueueCopyBufferToImage "the context associated with command_queue, src_buffer and dst_image are not the same or if the context associated with command_queue and events in event_wait_list are not the same")]
              [(= status CL_INVALID_MEM_OBJECT)
               (error 'clEnqueueCopyBufferToImage "src_buffer is not a valid buffer object or dst_image is not a valid image object")]
              [(= status CL_INVALID_VALUE)
               (error 'clEnqueueCopyBufferToImage "the 2D or 3D rectangular region specified by dst_origin and dst_origin + region referes to a region outside dst_image or if the region specified by src_offset and src_offset + src_cb to a region outside src_buffer or dst_image is a 2D image object and dst_origin[2] is not equal to 0 or region[2] is not equal to 1")]
              [(= status CL_INVALID_EVENT_WAIT_LIST)
               (error 'clEnqueueCopyBufferToImage "event_wait_list is NULL and num_event_in_wait_list > 0 or event_wait_list is not NULL and num_events_in_wait_list is 0, or event objects in event_wait_list are not valid events")]
              [(= status CL_MEM_OBJECT_ALLOCATION_FAILURE)
               (error 'clEnqueueCopyBufferToImage "there is a failure to allocate memory for data store associated with src_buffer or dst_image")]
              [(= status CL_INVALID_OPERATION)
               (error 'clEnqueueCopyBufferToImage "the device associated with command_queue does not support images")]
              [(= status CL_OUT_OF_HOST_MEMORY)
               (error 'clEnqueueCopyBufferToImage "there is a failure to allocate resources required by the OpenCL implementation on the host")]
              [else
               (error 'clEnqueueCopyBufferToImage "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc/names
  clEnqueueCopyBufferToImage
  (c:-> _cl_command_queue/c _cl_mem/c _cl_mem/c _size_t/c
        (vector/c _size_t/c _size_t/c _size_t/c)
        (vector/c _size_t/c _size_t/c _size_t/c)
        (vectorof _cl_event/c)
        _cl_event/c)
  (cq src-buffer dst-image src-offset dst-origin region wait-list)
  @{}])
;;;;
(define-opencl clEnqueueMapBuffer
  (_fun [command_queue : _cl_command_queue]
        [buffer : _cl_mem]
        [blocking_map : _cl_bool]
        [map_flags : _cl_map_flags]
        [offset : _size_t]
        [cb : _size_t]
        [num_events_in_wait_list : _cl_uint = (vector-length event_wait_list)]
        [event_wait_list : (_vector i _cl_event)]
        [event : (_ptr o _cl_event/null)]
        [errcode_ret : (_ptr o _cl_int)]
        -> [region : _void*]
        ->
        (cond
          [(= errcode_ret CL_SUCCESS)
           (values event region)]
          [(= errcode_ret CL_INVALID_COMMAND_QUEUE)
           (error 'clEnqueueMapBuffer "command_queue is not a valid command-queue")]
          [(= errcode_ret CL_INVALID_CONTEXT)
           (error 'clEnqueueMapBuffer "context associated with command_queue and buffer are not the same or if the context associated with command_queue and events in event_wait_list are not the same")]
          [(= errcode_ret CL_INVALID_MEM_OBJECT)
           (error 'clEnqueueMapBuffer "buffer is not a valid buffer object")]
          [(= errcode_ret CL_INVALID_VALUE)
           (error 'clEnqueueMapBuffer "region being mapped given by (offset, cb) is out of bounds or if values specified in map_flags are not valid")]
          [(= errcode_ret CL_INVALID_EVENT_WAIT_LIST)
           (error 'clEnqueueMapBuffer "event_wait_list is NULL and num_events_in_wait_list > 0 or event_wait_list is not NULL and num_events_in_wait_list is 0 or if event_objects in event_wait_list are not valid events")]
          [(= errcode_ret CL_MAP_FAILURE)
           (error 'clEnqueueMapBuffer "there is a failure to map the requested region into the host address space. This error cannot occur for buffer objects created with CL_MEM_USE_HOST_PTR or CL_MEM_ALLOC_HOST_PTR")]
          [(= errcode_ret CL_MEM_OBJECT_ALLOCATION_FAILURE)
           (error 'clEnqueueMapBuffer "there is a failure to allocate memory for data store associated with buffer")]
          [(= errcode_ret CL_OUT_OF_HOST_MEMORY)
           (error 'clEnqueueMapBuffer "there is a failure to allocate resources required by the OpenCL implementation on the host")]
          [else
           (error 'clEnqueueMapBuffer "Invalid error code: ~e" errcode_ret)])))
(provide/doc
 [proc-doc/names
  clEnqueueMapBuffer
  (c:-> _cl_command_queue/c _cl_mem/c _cl_bool/c _cl_map_flags/c _size_t/c _size_t/c (vectorof _cl_event/c)
        (values _cl_event/c _void*/c))
  (cq buffer blocking? map-flags offset cb wait-list)
  @{}])
;;;;
(define-opencl clEnqueueMapImage
  (_fun [command_queue : _cl_command_queue]
        [image : _cl_mem]
        [blocking_map : _cl_bool]
        [map_flags : _cl_map_flags]
        [origin : (_vector i _size_t)] ; len = 3
        [region : (_vector i _size_t)] ; len = 3
        [image_row_pitch : (_ptr o _size_t)]
        [image_slice_pitch : (_ptr o _size_t)]
        [num_events_in_wait_list : _cl_uint = (vector-length event_wait_list)]
        [event_wait_list : (_vector i _cl_event)]
        [event : (_ptr o _cl_event/null)]
        [errcode_ret : (_ptr o _cl_int)]
        -> [region-ptr : _void*]
        ->
        (cond
          [(= errcode_ret CL_SUCCESS)
           (values image_row_pitch image_slice_pitch event region-ptr)]
          [(= errcode_ret CL_INVALID_COMMAND_QUEUE)
           (error 'clEnqueueMapImage "command_queue is not a valid command-queue")]
          [(= errcode_ret CL_INVALID_CONTEXT)
           (error 'clEnqueueMapImage "context associated with command_queue and image are not the same or if the context associated with command_queue and events in event_wait_list are not the same")]
          [(= errcode_ret CL_INVALID_MEM_OBJECT)
           (error 'clEnqueueMapImage "image is not a valid image object")]
          [(= errcode_ret CL_INVALID_VALUE)
           (error 'clEnqueueMapImage "region being mapped given by (origin, origin+region) is out of bounds or if values specified in map_flags are not valid or if image is a 2D image object and origin[2] is not equal to 0 or region[2] is not equal to 1 or image_row_pitch is NULL or image is a 3D image object and image_slice_pitch is NULL")]
          [(= errcode_ret CL_INVALID_EVENT_WAIT_LIST)
           (error 'clEnqueueMapImage "event_wait_list is NULL and num_events_in_wait_list > 0 or event_wait_list is not NULL and num_events_in_wait_list is 0 or if event_objects in event_wait_list are not valid events")]
          [(= errcode_ret CL_MAP_FAILURE)
           (error 'clEnqueueMapImage "there is a failure to map the requested region into the host address space. This error cannot occur for image objects created with CL_MEM_USE_HOST_PTR or CL_MEM_ALLOC_HOST_PTR")]
          [(= errcode_ret CL_MEM_OBJECT_ALLOCATION_FAILURE)
           (error 'clEnqueueMapImage "there is a failure to allocate memory for data store associated with image")]
          [(= errcode_ret CL_INVALID_OPERATION)
           (error 'clEnqueueMapImage "the device associated with command_queue does not support images")]
          [(= errcode_ret CL_OUT_OF_HOST_MEMORY)
           (error 'clEnqueueMapImage "there is a failure to allocate resources required by the OpenCL implementation on the host")]
          [else
           (error 'clEnqueueMapImage "Invalid error code: ~e" errcode_ret)])))
(provide/doc
 [proc-doc/names
  clEnqueueMapImage
  (c:-> _cl_command_queue/c _cl_mem/c _cl_bool/c _cl_map_flags/c
        (vector/c _size_t/c _size_t/c _size_t/c)
        (vector/c _size_t/c _size_t/c _size_t/c)
        (vectorof _cl_event/c)
        (values _size_t/c _size_t/c _cl_event/c _void*/c))
  (cq image blocking? map-flags origin region wait-list)
  @{}])

;;;;
(define-opencl clEnqueueUnmapMemObject
  (_fun [command_queue : _cl_command_queue]
        [memobj : _cl_mem]
        [mapped_ptr : _void*]
        [num_events_in_wait_list : _cl_uint = (vector-length event_wait_list)]
        [event_wait_list : (_vector i _cl_event)]
        [event : (_ptr o _cl_event/null)]
        -> [status : _cl_int]
        ->
        (cond
          [(= status CL_SUCCESS)
           event]
          [(= status CL_INVALID_COMMAND_QUEUE)
           (error 'clEnqueueUnmapMemObject "command_queue is not a valid command-queue")]
          [(= status CL_INVALID_MEM_OBJECT)
           (error 'clEnqueueUnmapMemObject "memobj is not a valid memory object")]
          [(= status CL_INVALID_VALUE)
           (error 'clEnqueueUnmapMemObject "mapped_ptr is not a valid pointer returned by clEnqueueMapBuffer or clEnqueueMapImage for memobj")]
          [(= status CL_INVALID_EVENT_WAIT_LIST)
           (error 'clEnqueueUnmapMemObject "event_wait_list is NULL and num_events_in_wait_list > 0 or if event_wait_list is not NULL and num_events_in_wait_list is 0 or if event objects in event_wait_list are not valid event")]
          [(= status CL_OUT_OF_HOST_MEMORY)
           (error 'clEnqueueUnmapMemObject "there is a failure to allocate resources required by the OpenCL implementation on the host")]
          [(= status CL_INVALID_CONTEXT)
           (error 'clEnqueueUnmapMemObject "context associated with command_queue and memobj are not the same or if the context associated with command_queue and events in event_wait_list are not the same")]
          [else
           (error 'clEnqueueUnmapMemObject "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc/names
  clEnqueueUnmapMemObject
  (c:-> _cl_command_queue/c _cl_mem/c _void*/c (vectorof _cl_event/c) _cl_event/c)
  (cq memobj mapped-ptr wait-list)
  @{}])

;;;;
(define-opencl-info clGetMemObjectInfo
  (clGetMemObjectInfo:length clGetMemObjectInfo:generic)
  _cl_mem_info _cl_mem_info/c
  (args [memobj : _cl_mem _cl_mem/c])
  (error status 
         (cond [(= status CL_INVALID_VALUE)
                (error 'clGetMemObjectInfo "param_name is not valid or if size in bytes specified by param_value_size is < size of return type and param_value is not NULL")]
               [(= status CL_INVALID_MEM_OBJECT)
                (error 'clGetMemObjectInfo "memobj is not a valid memory object")]
               [else
                (error 'clGetMemObjectInfo "Invalid error code: ~e" status)]))
  (variable param_value_size)
  (fixed [_cl_mem_object_type _cl_mem_object_type/c CL_MEM_TYPE]
         [_cl_mem_flags _cl_mem_flags/c CL_MEM_FLAGS]
         [_size_t _size_t/c CL_MEM_SIZE]
         [_void* _void*/c CL_MEM_HOST_PTR]
         [_cl_uint _cl_uint/c CL_MEM_MAP_COUNT CL_MEM_REFERENCE_COUNT]
         [_cl_context _cl_context/c CL_MEM_CONTEXT]))

;;;;
(define-opencl-info clGetImageInfo
  (clGetImageInfo:length clGetImageInfo:generic)
  _cl_image_info _cl_image_info/c
  (args [memobj : _cl_mem _cl_mem/c])
  (error status 
         (cond [(= status CL_INVALID_VALUE)
                (error 'clGetImageInfo "param_name is not valid or if size in bytes specified by param_value_size is < size of return type and param_value is not NULL")]
               [(= status CL_INVALID_MEM_OBJECT)
                (error 'clGetImageInfo "memobj is not a valid image object")]
               [else
                (error 'clGetImageInfo "Invalid error code: ~e" status)]))
  (variable param_value_size)
  (fixed [_cl_image_format _cl_image_format/c CL_IMAGE_FORMAT]
         [_size_t _size_t/c CL_IMAGE_ELEMENT_SIZE CL_IMAGE_ROW_PITCH CL_IMAGE_SLICE_PITCH CL_IMAGE_WIDTH CL_IMAGE_HEIGHT CL_IMAGE_DEPTH]))
