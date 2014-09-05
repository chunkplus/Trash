/*
 * asyncAPI.cu
 *
 *  Created on: Sep 3, 2014
 *      Author: chunk
 */

#include <stdio.h>
#include <stdlib.h>

#include <cuda.h>
#include <cuda_runtime.h>
#include <helper_cuda.h>
#include <helper_functions.h>

#include "util.h"

__global__ void vecAdd(int* A, int* B, int* C) {
	int i = threadIdx.x;
	C[i] = A[i] + B[i];
}

void display(int *a, int length) {
	printf("\n");
	for (int i = 0; i < length; i++) {
		printf("%d ", a[i]);
	}
	printf("\n");
}

bool verify(int *a, int *b, int len) {
	for (int i = 0; i < len; i++) {
		if (a[i] != b[i])
			return false;
	}
	return true;
}

int main(int argc, char **argv) {
	int devId;
	cudaDeviceProp devProp;
	devId = findCudaDevice(argc, (const char **) argv);
	cudaGetDeviceProperties(&devProp, devId);

	printf("cuda device info : %d - [%s]\n", devId, devProp.name);

	const int n = 1024;
	const int nbyte = n * sizeof(int);
	int *h_A, *h_B, *h_C, *sum;
	int *d_A, *d_B, *d_C;

	cudaMallocHost(&h_A, nbyte);
	cudaMallocHost(&h_B, nbyte);
	cudaMallocHost(&h_C, nbyte);
//	h_C = (int *) malloc(nbyte);
	cudaMallocHost(&sum, nbyte);
	cudaMalloc(&d_A, nbyte);
	cudaMalloc(&d_B, nbyte);
	cudaMalloc(&d_C, nbyte);
	cudaMemset(&d_A, 0, nbyte);
	cudaMemset(&d_B, 0, nbyte);
	cudaMemset(&d_C, 0, nbyte);

	cudaStream_t stream0, stream1, stream2;
	cudaStreamCreate(&stream0);
	cudaStreamCreate(&stream1);
	cudaStreamCreate(&stream2);

	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);

	StopWatchInterface *timer = NULL;
	mTimer mtimer;
	cuTimer cutmer;
	sdkCreateTimer(&timer);

//	srand(time(0));
	for (int i = 0; i < n; i++) {
		h_A[i] = (int) (1024.0 * rand() / (RAND_MAX + 1.0));
		h_B[i] = (int) (1024.0 * rand() / (RAND_MAX + 1.0));
		sum[i] = h_A[i] + h_B[i];
	}

	sdkStartTimer(&timer);
	mtimer.start();
	cutmer.start();
	/**
	 *
	 * ____
	 * ____|___ ___ ___
	 */
	cudaEventRecord(start, stream0);
	cudaMemcpyAsync(d_A, h_A, nbyte, cudaMemcpyHostToDevice, stream0);
	cudaMemcpyAsync(d_B, h_B, nbyte, cudaMemcpyHostToDevice, stream1);
//	cudaStreamSynchronize(stream0);
//	cudaStreamSynchronize(stream1);
//	vecAdd<<<1, n, 0, stream0>>>(d_A, d_B, d_C);
//	cudaStreamSynchronize(stream0);
	display(h_C, n);
	checkCudaErrors(
			cudaMemcpyAsync(h_C, d_C, nbyte, cudaMemcpyDeviceToHost, stream0));
	cudaStreamSynchronize(stream0);
	cudaEventRecord(stop, stream0);
	display(h_C, n);
	cutmer.end();
	mtimer.end();
	sdkStopTimer(&timer);

	printf("time spent by CPU in CUDA calls: %.2f\n", sdkGetTimerValue(&timer));
	mtimer.showTime();
	cutmer.showTime();
	if (verify(h_C, sum, n))
		printf("Checking OK.\n");
	else
		printf("Checking Eroor!\n");

	cudaEventDestroy(start);
	cudaEventDestroy(stop);
	cudaFreeHost(h_A);
	cudaFreeHost(h_B);
	cudaFreeHost(h_C);
//	free(h_C);
	cudaFreeHost(sum);
	cudaFree(d_A);
	cudaFree(d_B);
	checkCudaErrors(cudaFree((void * )d_C));
	checkCudaErrors(cudaDeviceReset());
}

