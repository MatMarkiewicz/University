
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <float.h>

#include "helper_cuda.h"

////////////////////////////////////////////////////////////////////////////////
// CPU routines
////////////////////////////////////////////////////////////////////////////////

void reduction_gold(float* odata, float* idata, const unsigned int len)
{
    *odata = 0;
    for (int i = 0; i < len; i++) *odata += idata[i];
}

////////////////////////////////////////////////////////////////////////////////
// GPU routines
////////////////////////////////////////////////////////////////////////////////

__global__ void reduction(float* g_odata, float* g_idata)
{
    // dynamically allocated shared memory

    extern  __shared__  float temp[];

    int tid = threadIdx.x;
    int id = threadIdx.x + blockDim.x * blockIdx.x;

    // first, each thread loads data into shared memory

    temp[id] = g_idata[id];

    // V1 (zad 3 i 4)

    // find previout power of 2
    // int k = 1;
    // int bd = blockDim.x;
    // while (bd >>= 1)
    //     k = k << 1;

    // __syncthreads();
    // if (tid < blockDim.x - k) temp[id] += temp[id + k];

    // next, we perform binary tree reduction

    // for (int d = k >> 1; d > 0; d >>= 1) {
    //     __syncthreads();  // ensure previous step completed 
    //     if (tid < d)  temp[id] += temp[id + d];
    // }

    // finally, first thread puts result into global memory

 
    // if (tid == 0) g_odata[blockIdx.x] = temp[blockDim.x * blockIdx.x];


    // V2 (zad 5)

    int value = temp[id];
    int bd = blockDim.x;
    for (int i = bd/2; i > 0; i = i / 2)
        value += __shfl_down_sync(-1, value, i);
    if (tid == 0) g_odata[blockIdx.x] = value;
}





////////////////////////////////////////////////////////////////////////////////
// Program main
////////////////////////////////////////////////////////////////////////////////

int main(int argc, const char** argv)
{
    int num_elements, num_threads, mem_size, shared_mem_size, num_blocks;

    float* h_data, * reference, sum, gpu_sum;
    float* d_idata, * d_odata;

    // initialise card

    findCudaDevice(argc, argv);

    num_elements = 512;
    num_blocks = 16;
    num_threads = num_elements/num_blocks;
    mem_size = sizeof(float) * num_elements;

    // allocate host memory to store the input data
    // and initialize to integer values between 0 and 1000

    h_data = (float*)malloc(mem_size);

    for (int i = 0; i < num_elements; i++)
        h_data[i] = floorf(1000 * (rand() / (float)RAND_MAX));

    // compute reference solutions

    reference = (float*)malloc(mem_size);
    reduction_gold(&sum, h_data, num_elements);

    // allocate device memory input and output arrays

    checkCudaErrors(cudaMalloc((void**)&d_idata, mem_size));
    checkCudaErrors(cudaMalloc((void**)&d_odata, sizeof(float)* num_blocks));

    // copy host memory to device input array

    checkCudaErrors(cudaMemcpy(d_idata, h_data, mem_size,
        cudaMemcpyHostToDevice));

    // execute the kernel

    shared_mem_size = sizeof(float) * num_elements;
    reduction << <num_blocks, num_threads, shared_mem_size >> > (d_odata, d_idata);
    getLastCudaError("reduction kernel execution failed");

    // copy result from device to host

    checkCudaErrors(cudaMemcpy(h_data, d_odata, sizeof(float)* num_blocks,
        cudaMemcpyDeviceToHost));

    gpu_sum = 0.0;
    for (int k = 0; k < num_blocks; k++) gpu_sum += h_data[k];

    // check results

    printf("reduction error = %f\n", gpu_sum - sum);

    // cleanup memory

    free(h_data);
    free(reference);
    checkCudaErrors(cudaFree(d_idata));
    checkCudaErrors(cudaFree(d_odata));

    // CUDA exit -- needed to flush printf write buffer

    cudaDeviceReset();
}