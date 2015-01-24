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

//	printf("\n%d\n", blockDim.x);
	if (tid == 0) {
		timer[bid] = clock();
//		printf("\n%d\n", timer[bid]);
	}
	shared[tid] = A[tid];
	shared[tid + blockDim.x] = A[tid + blockDim.x];

	for (unsigned int d = blockDim.x; d > 0; d /= 2) {
		__syncthreads();
		if (tid < d)
			shared[tid] = mmin(shared[tid],shared[tid + d]);
	}
	__syncthreads();
	A[tid] = shared[tid];

	if (tid == 0) {
//		timer[bid + blockDim.x] = clock();	// HERE : bug eye!
		timer[bid + gridDim.x] = clock();
//		printf("\n%d\n", shared[tid]);
//		printf("\n\t%d\n", timer[bid + blockDim.x]);
	}
}

void display(int *a, int length) {
	printf("\n");
	for (int i = 0; i < length; i++) {
		printf("%d ", a[i]);
	}
	printf("\n");
}
void display(clock_t *a, int length) {
	printf("\n");
	for (int i = 0; i < length; i++) {
		printf("%d ", a[i]);
	}
	printf("\n");
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
		h_A[i] = (int) ((float) NUM_THREADS * rand() / (RAND_MAX + 1.0));
	}
//	display(h_A, n);

	checkCudaErrors(
			cudaMemset((void *) d_timer, 0, NUM_BLOCKS * 2 * sizeof(clock_t)));
	checkCudaErrors(cudaMemcpy(d_A, h_A, nbyte, cudaMemcpyHostToDevice));
	timeReduction<<<NUM_BLOCKS, NUM_THREADS, nbyte>>>(d_A, d_timer);
	checkCudaErrors(cudaPeekAtLastError());
	checkCudaErrors(cudaDeviceSynchronize());
	checkCudaErrors(cudaMemcpy(h_A, d_A, nbyte, cudaMemcpyDeviceToHost));
	checkCudaErrors(
			cudaMemcpy((void *)h_timer, (const void *)d_timer, sizeof(clock_t) * NUM_BLOCKS * 2, cudaMemcpyDeviceToHost));

	display(h_A, n);
	display(h_timer, NUM_BLOCKS * 2);

	clock_t tmin = h_timer[0], tmax = h_timer[NUM_BLOCKS];
	for (int i = 0; i < NUM_BLOCKS; i++) {
		if (h_timer[i] < tmin)
			tmin = h_timer[i];
		if (h_timer[i + NUM_BLOCKS] > tmax)
			tmax = h_timer[i + NUM_BLOCKS];
	}
	printf("\n%d\n", (int) (tmax - tmin));

	checkCudaErrors(cudaFreeHost(h_A));
	checkCudaErrors(cudaFreeHost(h_timer));
	checkCudaErrors(cudaFree(d_A));
	checkCudaErrors(cudaFree(d_timer));
	cudaDeviceReset();
}

