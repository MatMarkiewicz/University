// Zad5:
// (2 * 4B * 100 (pętla) * 960000 (NPATH)) / 1.5ms
// 512GB/s (COLAB - TESLA T4)
// kod prezentowany na pracowni, działa z printem w kernelu, bez printa zwrca nan

////////////////////////////////////////////////////////////////////////
// GPU version of Ax2+bz+c
////////////////////////////////////////////////////////////////////////

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include <cuda.h>
#include <curand.h>


////////////////////////////////////////////////////////////////////////
// CUDA global constants
////////////////////////////////////////////////////////////////////////

__constant__ int a,b,c;

////////////////////////////////////////////////////////////////////////
// kernel routine
////////////////////////////////////////////////////////////////////////

__global__ void average(float *d_rands, float *d_res) {
    int ind = threadIdx.x + blockIdx.x*blockDim.x;
    //printf("ID %d %d %d %d\n", ind, threadIdx.x, blockIdx.x, blockDim.x);
    float sum, z;

    for (int n=0; n<100; n++) {
        z = d_rands[ind];
        sum += a*z*z + b*z + c;
        ind += 32;
    }
    
    d_res[threadIdx.x + blockIdx.x*blockDim.x] = sum / 100.0f;
}

int main(int argc, const char **argv){
    int N=3200;
    int A=5;
    int B=1;
    int C=12;
    float *h_res, *d_res, *d_rands;

    h_res = (float *)malloc(N/100*sizeof(float));
    cudaMalloc((void **)&d_res, N/100*sizeof(float));
    cudaMalloc((void **)&d_rands, N*sizeof(float));

    cudaMemcpyToSymbol(a, &A, sizeof(A));
    cudaMemcpyToSymbol(b, &B, sizeof(B));
    cudaMemcpyToSymbol(c, &C, sizeof(C));

    curandGenerator_t gen;
    curandCreateGenerator(&gen, CURAND_RNG_PSEUDO_DEFAULT);
    curandSetPseudoRandomGeneratorSeed(gen, 1234ULL);
    curandGenerateNormal(gen, d_rands, N, 0.0f, 1.0f);

    average<<<2, 16>>>(d_rands, d_res);
    cudaDeviceSynchronize();
    cudaMemcpy(h_res, d_res, sizeof(float)*N/100, cudaMemcpyDeviceToHost);
    float res;
    for (int i=0;i<N/100;i++){
        printf("h: %f\n", h_res[i]);
        res += h_res[i];
    }
    printf("Result: %f\n", res/(N/100));

    curandDestroyGenerator(gen);
    free(h_res);
    cudaFree(d_res);
    cudaFree(d_rands);

    cudaDeviceReset();
}