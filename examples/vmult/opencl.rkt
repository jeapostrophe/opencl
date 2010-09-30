#lang racket
(require (planet jaymccarthy/opencl/c)
         (planet jaymccarthy/opencl/racket)
         ffi/unsafe)

(define HOW-MANY (read)) 
(define input-v (malloc _float HOW-MANY 'raw))
(define output-v (malloc _float HOW-MANY 'raw))
(define how-much-mem (* HOW-MANY (ctype-sizeof _float)))

(for ([i (in-range HOW-MANY)])
  (ptr-set! input-v _float i (read)))

(define ds (platform-devices #f 'CL_DEVICE_TYPE_GPU))
(define d (cvector-ref ds 0))

(define ctxt (clCreateContext (vector d)))

(define kernel-source
  (string->bytes/utf-8
   #<<END
__kernel square(                                                       
   __global float* input,                                              
   __global float* output,                                             
   const unsigned int count)                                           
{                                                                      
   int i = get_global_id(0);                                           
   if(i < count)                                                       
       output[i] = input[i] * input[i];                                 
}                                                                      
END
   ))

(define program (clCreateProgramWithSource ctxt (vector kernel-source)))            
(define cq (clCreateCommandQueue ctxt d empty))

(clBuildProgram program (vector d) #"")

(define kernel (clCreateKernel program #"square"))
(define input (clCreateBuffer ctxt 'CL_MEM_READ_ONLY how-much-mem #f))
(define output (clCreateBuffer ctxt 'CL_MEM_WRITE_ONLY how-much-mem #f))
(define input-evt
  (clEnqueueWriteBuffer cq input 'CL_FALSE 0 how-much-mem input-v (vector)))

(clFinish cq)

(clSetKernelArg:_cl_mem kernel 0 input)
(clSetKernelArg:_cl_mem kernel 1 output)
(clSetKernelArg:_cl_uint kernel 2 HOW-MANY)

(define work-group-size (kernel-work-group-info kernel d 'CL_KERNEL_WORK_GROUP_SIZE))

(define kernel-evt
  (clEnqueueNDRangeKernel cq kernel 1 
                          (vector HOW-MANY)
                          (vector work-group-size)
                          (vector input-evt)))

(time (clFinish cq))

(define output-evt
  (clEnqueueReadBuffer cq output 'CL_FALSE 0 how-much-mem output-v (vector kernel-evt)))        

(clFinish cq)

(clReleaseMemObject input)
(clReleaseMemObject output)
(clReleaseKernel kernel)

(clReleaseProgram program)
(clReleaseCommandQueue cq)
(clReleaseContext ctxt)

(free input-v)
(free output-v)