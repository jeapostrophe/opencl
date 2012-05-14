#lang at-exp racket/base
(require ffi/unsafe
         (except-in racket/contract ->)
         (prefix-in c: racket/contract)
         scribble/srcdoc  
         (file "include/cl.rkt")
         (file "lib.rkt")
         (file "syntax.rkt")
         (file "types.rkt"))
(require/doc racket/base
             scribble/manual
             (for-label (file "types.rkt")))

;;;;
(define-opencl clEnqueueNDRangeKernel
  (_fun [command_queue : _cl_command_queue]
        [kernel : _cl_kernel]
        [work_dim : _cl_uint]
        ; XXX Must be NULL right now
        [global_work_offset : _pointer = #f]
        [global_work_size : (_vector i _size_t)] ; len = work_dim
        [local_work_size : (_vector i _size_t)]
        [num_events_in_wait_list : _cl_uint = (vector-length event_wait_list)]
        [event_wait_list : (_vector i _cl_event)]
        [event : (_ptr o _cl_event/null)]
        -> [status : _cl_int]
        ->
        (cond 
          [(= status CL_SUCCESS)
           event]
          [(= status CL_INVALID_PROGRAM_EXECUTABLE)
           (error 'clEnqueueNDRangeKernel "there is no successfully built program executable available for device associated with command_queue.")]
          [(= status CL_INVALID_COMMAND_QUEUE)
           (error 'clEnqueueNDRangeKernel "command_queue is not a valid command-queue")]
          [(= status CL_INVALID_KERNEL)
           (error 'clEnqueueNDRangeKernel "kernel is not a valid kernel object")]
          [(= status CL_INVALID_CONTEXT)
           (error 'clEnqueueNDRangeKernel "context associated with command_queue and kernel is not the same or if the context associated with command_queue and events in event_wait_list are not the same.")]
          [(= status CL_INVALID_KERNEL_ARGS)
           (error 'clEnqueueNDRangeKernel "the kernel argument values have not been specified")]
          [(= status CL_INVALID_WORK_DIMENSION)
           (error 'clEnqueueNDRangeKernel "work_dim is not a valid value")]
          [(= status CL_INVALID_GLOBAL_WORK_SIZE)
           (error 'clEnqueueNDRangeKernel "global_work_size is NULL, or if any of the values specified in global_work_size[0], ... global_work_size[work_dim – 1] are 0 or exceed the range given by the sizeof(size_t) for the device on which the kernel execution will be enqueued.")]
          [(= status CL_INVALID_WORK_GROUP_SIZE)
           (error 'clEnqueueNDRangeKernel "local_work_size is specified and number of work- items specified by global_work_size is not evenly divisible by size of work-group given by local_work_size or does not match the work-group size specified for kernel using the __attribute__((reqd_work_group_size(X, Y, Z))) qualifier in program source. OR local_work_size is specified and the total number of work-items in the work-group computed as local_work_size[0] * ... local_work_size[work_dim – 1] is greater than the value specified by CL_DEVICE_MAX_WORK_GROUP_SIZE in table 4.3. OR local_work_size is NULL and the __attribute__((reqd_work_group_size(X, Y, Z))) qualifier is used to declare the work-group size for kernel in the program source.")]
          [(= status CL_INVALID_WORK_ITEM_SIZE)
           (error 'clEnqueueNDRangeKernel "the number of work-items specified in any of local_work_size[0], ... local_work_size[work_dim – 1] is greater than the corresponding values specified by CL_DEVICE_MAX_WORK_ITEM_SIZES[0], .... CL_DEVICE_MAX_WORK_ITEM_SIZES[work_dim – 1].")]
          [(= status CL_INVALID_GLOBAL_OFFSET)
           (error 'clEnqueueNDRangeKernel "global_work_offset is not NULL")]
          [(= status CL_OUT_OF_RESOURCES)
           (error 'clEnqueueNDRangeKernel "there is a failure to queue the execution instance of kernel on the command-queue because of insufficient resources needed to execute the kernel")]
          [(= status CL_MEM_OBJECT_ALLOCATION_FAILURE)
           (error 'clEnqueueNDRangeKernel "there is a failure to allocate memory for data store associated with image or buffer objects specified as arguments to kernel")]
          [(= status CL_INVALID_EVENT_WAIT_LIST)
           (error 'clEnqueueNDRangeKernel "event_wait_list is NULL and num_events_in_wait_list > 0 or event_wait_list is not NULL and num_events_in_wait_list is 0 or if event objects in event_wait_list are not valid events")]
          [(= status CL_OUT_OF_HOST_MEMORY)
           (error 'clEnqueueNDRangeKernel "there is a failure to allocate resources required by the OpenCL implementation on the host")]
          [else
           (error 'clEnqueueNDRangeKernel "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc/names
  clEnqueueNDRangeKernel
  (c:-> _cl_command_queue/c _cl_kernel/c
        (and/c _cl_uint/c (between/c 1 3))
        (vectorof _size_t/c)
        (vectorof _size_t/c)
        (vectorof _cl_event/c)
        _cl_event/c)
  (cq kernel dim global-size local-size wait-list)
  @{}])

;;;; clEnqueueTask
(define-opencl clEnqueueTask
  (_fun [command_queue : _cl_command_queue]
        [kernel : _cl_kernel]
        [num_events_in_wait_list : _cl_uint = (vector-length event_wait_list)]
        [event_wait_list : (_vector i _cl_event)]
        [event : (_ptr o _cl_event/null)]
        -> [status : _cl_int]
        ->
        (cond 
          [(= status CL_SUCCESS)
           event]
          [(= status CL_INVALID_PROGRAM_EXECUTABLE)
           (error 'clEnqueueTask "there is no successfully built program executable available for device associated with command_queue.")]
          [(= status CL_INVALID_COMMAND_QUEUE)
           (error 'clEnqueueTask "command_queue is not a valid command-queue")]
          [(= status CL_INVALID_KERNEL)
           (error 'clEnqueueTask "kernel is not a valid kernel object")]
          [(= status CL_INVALID_CONTEXT)
           (error 'clEnqueueTask "context associated with command_queue and kernel is not the same or if the context associated with command_queue and events in event_wait_list are not the same.")]
          [(= status CL_INVALID_KERNEL_ARGS)
           (error 'clEnqueueTask "the kernel argument values have not been specified")]
          [(= status CL_INVALID_WORK_GROUP_SIZE)
           (error 'clEnqueueTask "work-group size is specified for kernel using ... qualifier in program source and is not (1, 1, 1)")]
          [(= status CL_OUT_OF_RESOURCES)
           (error 'clEnqueueTask "there is a failure to queue the execution instance of kernel on the command-queue because of insufficient resources needed to execute the kernel")]
          [(= status CL_MEM_OBJECT_ALLOCATION_FAILURE)
           (error 'clEnqueueTask "there is a failure to allocate memory for data store associated with image or buffer objects specified as arguments to kernel")]
          [(= status CL_INVALID_EVENT_WAIT_LIST)
           (error 'clEnqueueTask "event_wait_list is NULL and num_events_in_wait_list > 0 or event_wait_list is not NULL and num_events_in_wait_list is 0 or if event objects in event_wait_list are not valid events")]
          [(= status CL_OUT_OF_HOST_MEMORY)
           (error 'clEnqueueTask "there is a failure to allocate resources required by the OpenCL implementation on the host")]
          [else
           (error 'clEnqueueTask "Invalid error code: ~e" status)])))
(provide/doc
 [proc-doc/names clEnqueueTask
           (c:-> _cl_command_queue/c _cl_kernel/c (vectorof _cl_event/c)
                 _cl_event/c)
           (cq kernel wait-list)
           @{}])

;;;; XXX clEnqueueNativeKernel
