/*
 * Copyright 1993-2009 NVIDIA Corporation.  All rights reserved.
 *
 * NVIDIA Corporation and its licensors retain all intellectual property and 
 * proprietary rights in and to this software and related documentation. 
 * Any use, reproduction, disclosure, or distribution of this software 
 * and related documentation without an express license agreement from
 * NVIDIA Corporation is strictly prohibited.
 * 
 */
 
 __kernel void DotProduct (__global float* a, __global float* b, __global float* c, int iNumElements)
{
    // find position in global arrays
    int iGID = get_global_id(0);

    // bound check (equivalent to the limit on a 'for' loop for standard/serial C code
    if (iGID >= iNumElements)
    {   
        return; 
    }

    // process 
    int iInOffset = iGID << 2;
    c[iGID] = a[iInOffset] * b[iInOffset] 
               + a[iInOffset + 1] * b[iInOffset + 1]
               + a[iInOffset + 2] * b[iInOffset + 2]
               + a[iInOffset + 3] * b[iInOffset + 3];
}
