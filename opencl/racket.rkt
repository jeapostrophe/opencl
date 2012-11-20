#lang at-exp racket
(require scribble/srcdoc
         "c.rkt")
(require/doc racket/base
             scribble/manual
             (for-label "c.rkt"))

; XXX Add auto-release on objects w/ refcounts
; XXX Add synchronization to events
; XXX Turn *-infos into hash table

(define-syntax-rule (opencl-rename [new old] ...)
  (begin (define new old)
         ...
         (provide/doc
          [thing-doc new any/c
                     @{@racket[old] from the C API.}]
          ...)))

;;;;;;;;;;

(opencl-rename
 [valid-bools _cl_bool-values]
 [valid-platform-infos _cl_platform_info-values]
 [valid-device-types _cl_device_type-values]
 [valid-device-infos _cl_device_info-values]
 [valid-device-fp-config _cl_device_fp_config-values]
 [valid-device-mem-cache-types _cl_device_mem_cache_type-values]
 [valid-device-local-mem-types _cl_device_local_mem_type-values]
 [valid-device-exec-capabilities _cl_device_exec_capabilities-values]
 [valid-command-queue-properties _cl_command_queue_properties-values]
 [valid-mem-flags _cl_mem_flags-values]
 [valid-channel-orders _cl_channel_order-values]
 [valid-mem-object-types _cl_mem_object_type-values]
 [valid-addressing-modes _cl_addressing_mode-values]
 [valid-filter-modes _cl_filter_mode-values]
 [valid-context-infos _cl_context_info-values]
 [valid-command-queue-infos _cl_command_queue_info-values]
 [valid-mem-infos _cl_mem_info-values]
 [valid-image-infos _cl_image_info-values]
 [valid-sampler-infos _cl_sampler_info-values]
 [valid-program-infos _cl_program_info-values]
 [valid-program-build-infos _cl_program_build_info-values]
 [valid-build-statuses _cl_build_status-values]
 [valid-kernel-infos _cl_kernel_info-values]
 [valid-kernel-work-group-infos _cl_kernel_work_group_info-values]
 [valid-event-infos _cl_event_info-values]
 [valid-command-types _cl_command_type-values]
 [valid-command-execution-statuses _command_execution_status-values]
 [valid-profiling-infos _cl_profiling_info-values]
 
 [platform-info clGetPlatformInfo:generic]
[system-platforms clGetPlatformIDs:vector]
(platform-devices clGetDeviceIDs:vector)
(device-info clGetDeviceInfo:generic)
(context-info clGetContextInfo:generic)
(command-queue-info clGetCommandQueueInfo:generic)
(context-supported-image-formats clGetSupportedImageFormats:vector)
(memobj-info clGetMemObjectInfo:generic)
(image-info clGetImageInfo:generic)
(sampler-info clGetSamplerInfo:generic)
(program-info clGetProgramInfo:generic)
(program-build-info clGetProgramBuildInfo:generic)
(program-kernels clCreateKernelsInProgram:vector)
(kernel-info clGetKernelInfo:generic)
(kernel-work-group-info clGetKernelWorkGroupInfo:generic)
(event-info clGetEventInfo:generic)
(event-profiling-info clGetEventProfilingInfo:generic)

 [make-image-format make-cl_image_format]
 [devices->context clCreateContext]
 [device-type->context clCreateContextFromType]
 [context-retain! clRetainContext]
 [context-release! clReleaseContext]
 [make-command-queue clCreateCommandQueue]
 [command-queue-retain! clRetainCommandQueue]
 [command-queue-release! clReleaseCommandQueue]
 [set-command-queue-property! clSetCommandQueueProperty]
 [make-buffer clCreateBuffer]
 [enqueue-read-buffer! clEnqueueReadBuffer]
 [enqueue-write-buffer! clEnqueueWriteBuffer]
 [enqueue-copy-buffer! clEnqueueCopyBuffer]
 [memobj-retain! clRetainMemObject]
 [memobj-release! clReleaseMemObject]
 [make-2d-image clCreateImage2D]
 [make-3d-image clCreateImage3D]
 [enqueue-read-image! clEnqueueReadImage]
 [enqueue-write-image! clEnqueueWriteImage]
 [enqueue-copy-image! clEnqueueCopyImage]
 [enqueue-copy-image-to-buffer! clEnqueueCopyImageToBuffer]
 [enqueue-copy-buffer-to-image! clEnqueueCopyBufferToImage]
 [enqueue-map-buffer! clEnqueueMapBuffer]
 [enqueue-map-image! clEnqueueMapImage]
 [enqueue-unmap-buffer! clEnqueueUnmapMemObject]
 [enqueue-unmap-image! clEnqueueUnmapMemObject]
 [make-sampler clCreateSampler]
 [sampler-retain! clRetainSampler]
 [sampler-release! clReleaseSampler]
 [make-program/source clCreateProgramWithSource]
 [make-program/binary clCreateProgramWithBinary]
 [program-retain! clRetainProgram]
 [program-release! clReleaseProgram]
 [program-build! clBuildProgram]
 [unload-compiler-hint! clUnloadCompiler]
 [program-kernel clCreateKernel]
 [kernel-retain! clRetainKernel]
 [kernel-release! clReleaseKernel]
 [set-kernel-arg:_cl_mem! clSetKernelArg:_cl_mem]
 [set-kernel-arg:_cl_uint! clSetKernelArg:_cl_uint]
 [set-kernel-arg:_cl_int! clSetKernelArg:_cl_int]
 [set-kernel-arg:local! clSetKernelArg:local]
 [enqueue-nd-range-kernel! clEnqueueNDRangeKernel]
 [enqueue-kernel! clEnqueueTask]
 [events-wait! clWaitForEvents]
 [event-retain! clRetainEvent]
 [event-release! clReleaseEvent]
 [enqueue-marker! clEnqueueMarker]
 [enqueue-events-wait! clEnqueueWaitForEvents]
 [enqueue-barrier! clEnqueueBarrier]
 [command-queue-flush! clFlush]
 [command-queue-finish! clFinish]
 )
