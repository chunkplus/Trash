/*
 * clock.cu
 *
 *  Created on: Sep 3, 2014
 *      Author: chunk
 */

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include <cuda_runtime.h>
#include <helper_cuda.h>
#include <helper_functions.h>

#define NUM_BLOCKS 64
#define NUM_THREADS 256
#define mmin(a,b) ((a)<(b) ? (a) : (b))

__global__ void timeReduction(int *A, clock_t* timer) {
	extern __shared__ int shared[];
	int tid = threadIdx.x;
	int bid = blockIdx.x;
	if (tid == 0)
		timer[bid] = clock();
	shared[tid] = A[tid];
	shared[tid + blockDim.x] = A[tid + blockDim.x];

	for (unsigned int d = blockDim.x * 2; d > 0; d >> 1) {
		__syncthreads();
		if (tid < d)
			shared[tid] = mmin(shared[tid],shared[tid + d]);
	}
	__syncthreads();
	if (tid == 0)
		timer[bid + blockDim.x] = clock();
}

int main(int argc, char **argv) {
	int devID = findCudaDevice(argc, (const char**) argv);
	assert(devID >= 0);

	int n = NUM_THREADS * 2;
	int nbyte = n * sizeof(int);

	int *h_A, *d_A;
	clock_t *h_timer, *d_timer;

	cudaMallocHost(&h_A, nbyte);
	cudaMallocHost(&h_timer, NUM_BLOCKS * 2 * sizeof(clock_t));
	cudaMalloc(&d_A, nbyte);
	cudaMalloc(&d_timer, NUM_BLOCKS * 2 * sizeof(clock_t));
	srand(time(0));
	for (int i = 0; i < n; i++) {
		h_A[i] = (int) (NUM_THREADS * rand() / (RAND_MAX + 1.0));
	}
	cudaMemset((void *) d_timer, 0, NUM_BLOCKS * 2 * sizeof(clock_t));
	cudaMemcpy(d_A, h_A, nbyte, cudaMemcpyHostToDevice);
	timeReduction<<<NUM_BLOCKS, NUM_THREADS, nbyte>>>(d_A, d_timer);
}

