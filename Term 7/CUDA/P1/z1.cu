// zadanie prezentowane na pracowni

//
// include files
//

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

//
// kernel routine
// 

__global__ void my_first_kernel(float *x, float *y, float *z)
{
  int tid = threadIdx.x + blockDim.x*blockIdx.x;
  z[tid] = x[tid] + y[tid];
}


//
// main code
//

int main(int argc, char **argv)
{
  float *h1_x, *h2_x, *h3_x, *d1_x, *d2_x, *d3_x;
  int   nblocks, nthreads, nsize, n; 

  // set number of blocks, and threads per block

  nblocks  = 2;
  nthreads = 8;
  nsize    = nblocks*nthreads ;

  // allocate memory for array

  h1_x = (float *)malloc(nsize*sizeof(float));
  h2_x = (float *)malloc(nsize*sizeof(float));
  h3_x = (float *)malloc(nsize*sizeof(float));
  cudaMalloc((void **)&d1_x, nsize*sizeof(float));
  cudaMalloc((void **)&d2_x, nsize*sizeof(float));
  cudaMalloc((void **)&d3_x, nsize*sizeof(float));
 
  for (int i=0;i<nsize;i++){
      h1_x[i] = 0.11*i;
      h2_x[i] = 0.33*i;
  }

  cudaMemcpy(d1_x,h1_x,nsize*sizeof(float),cudaMemcpyHostToDevice);
  cudaMemcpy(d2_x,h2_x,nsize*sizeof(float),cudaMemcpyHostToDevice);

  // execute kernel

  my_first_kernel<<<nblocks,nthreads>>>(d1_x, d2_x, d3_x);

  // copy back results and print them out

  cudaMemcpy(h3_x,d3_x,nsize*sizeof(float),cudaMemcpyDeviceToHost);

  for (n=0; n<nsize; n++) printf(" n,  x  =  %d  %f \n",n,h3_x[n]);

  // free memory 

  cudaFree(d1_x);
  cudaFree(d2_x);
  cudaFree(d3_x);
  free(h1_x);
  free(h2_x);
  free(h3_x);

  // CUDA exit -- needed to flush printf write buffer

  cudaDeviceReset();

  return 0;
}