#include "cuda_runtime.h"
#include "cutil_inline.h"

#include <stdio.h>
#include <math.h>

static void HandleError( cudaError_t err,const char *file,int line ) 
{

  if (err != cudaSuccess)

  {

    printf( "%s in %s at line %d\n", cudaGetErrorString( err ),
      file, line );
    exit( EXIT_FAILURE );
  }
}
#define HANDLE_ERROR( err ) (HandleError( err, __FILE__, __LINE__ ))
#define N (1024*1024)
#define FULL_DATA_SIZE N*20

__global__ void kernel(int* a, int *b, int*c)
{
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  int offset = gridDim.x * blockDim.x;

  if (idx < N)
  {
    int idx1 = (idx + 1) % 256;
    int idx2 = (idx + 2) % 256;
    float as = (a[idx] + a[idx1] + a[idx2]) / 3;
    float bs = (b[idx] + b[idx1] + b[idx2]) / 3;
    c[idx] = (as + bs) / 2;
  }
}

int main()
{
  cudaDeviceProp prop;
  int devID;

  HANDLE_ERROR(cudaGetDevice(&devID));
  HANDLE_ERROR(cudaGetDeviceProperties(&prop, devID));

  if (!prop.deviceOverlap)
  {
    printf("No device will handle overlaps. so no speed up from stream.\n");
    return 0;
  }

  cudaEvent_t start, stop;
  float elapsedTime;
  HANDLE_ERROR(cudaEventCreate(&start));
  HANDLE_ERROR(cudaEventCreate(&stop));
  HANDLE_ERROR(cudaEventRecord(start, 0));

  cudaStream_t stream0;
  cudaStream_t stream1;
  HANDLE_ERROR(cudaStreamCreate(&stream0));
  HANDLE_ERROR(cudaStreamCreate(&stream1));

  int *host_a, *host_b, *host_c;
  int *dev_a0, *dev_b0, *dev_c0;
  int *dev_a1, *dev_b1, *dev_c1;

  HANDLE_ERROR(cudaMalloc((void**)&dev_a0, N*sizeof(int)));
  HANDLE_ERROR(cudaMalloc((void**)&dev_b0, N*sizeof(int)));
  HANDLE_ERROR(cudaMalloc((void**)&dev_c0, N*sizeof(int)));

  HANDLE_ERROR(cudaMalloc((void**)&dev_a1, N*sizeof(int)));
  HANDLE_ERROR(cudaMalloc((void**)&dev_b1, N*sizeof(int)));
  HANDLE_ERROR(cudaMalloc((void**)&dev_c1, N*sizeof(int)));

  HANDLE_ERROR(cudaHostAlloc((void**)&host_a, FULL_DATA_SIZE*sizeof(int), cudaHostAllocDefault));
  HANDLE_ERROR(cudaHostAlloc((void**)&host_b, FULL_DATA_SIZE*sizeof(int), cudaHostAllocDefault));
  HANDLE_ERROR(cudaHostAlloc((void**)&host_c, FULL_DATA_SIZE*sizeof(int), cudaHostAllocDefault));


  for (int i=0; i<FULL_DATA_SIZE; i++)
  {
    host_a[i] = rand();
    host_b[i] = rand();
  }


  // tasks are put into stack for gpu execution
  for (int i=0; i<FULL_DATA_SIZE; i+=2*N)
  {
    HANDLE_ERROR(cudaMemcpyAsync(dev_a0, host_a+i, N*sizeof(int), cudaMemcpyHostToDevice, stream0));
    HANDLE_ERROR(cudaMemcpyAsync(dev_a1, host_a+i+N, N*sizeof(int), cudaMemcpyHostToDevice, stream1));

    HANDLE_ERROR(cudaMemcpyAsync(dev_b0, host_b+i, N*sizeof(int), cudaMemcpyHostToDevice, stream0));
    HANDLE_ERROR(cudaMemcpyAsync(dev_b1, host_a+i+N, N*sizeof(int), cudaMemcpyHostToDevice, stream1));

    kernel<<<N/256, 256, 0, stream0>>>(dev_a0, dev_b0, dev_c0);
    kernel<<<N/256, 256, 0, stream1>>>(dev_a1, dev_b1, dev_c1);

    HANDLE_ERROR(cudaMemcpyAsync(host_c+i, dev_c0, N*sizeof(int), cudaMemcpyDeviceToHost, stream0));
    HANDLE_ERROR(cudaMemcpyAsync(host_c+i+N, dev_c1, N*sizeof(int), cudaMemcpyDeviceToHost, stream1));

// 		HANDLE_ERROR(cudaMemcpyAsync(dev_a0, host_a+i, N*sizeof(int), cudaMemcpyHostToDevice, stream0));
// 		HANDLE_ERROR(cudaMemcpyAsync(dev_b0, host_b+i, N*sizeof(int), cudaMemcpyHostToDevice, stream0));
// 		kernel<<<N/256, 256, 0, stream0>>>(dev_a0, dev_b0, dev_c0);
// 		HANDLE_ERROR(cudaMemcpyAsync(host_c+i, dev_c0, N*sizeof(int), cudaMemcpyDeviceToHost, stream0));
// 
// 		HANDLE_ERROR(cudaMemcpyAsync(dev_a1, host_a+i+N, N*sizeof(int), cudaMemcpyHostToDevice, stream1));
// 		HANDLE_ERROR(cudaMemcpyAsync(dev_a1, host_a+i+N, N*sizeof(int), cudaMemcpyHostToDevice, stream1));
// 		kernel<<<N/256, 256, 0, stream1>>>(dev_a1, dev_b1, dev_c1);
// 		HANDLE_ERROR(cudaMemcpyAsync(host_c+i+N, dev_c1, N*sizeof(int), cudaMemcpyDeviceToHost, stream1));
  }

  // wait until gpu execution finish
  HANDLE_ERROR(cudaStreamSynchronize(stream0));
  HANDLE_ERROR(cudaStreamSynchronize(stream1));

  HANDLE_ERROR(cudaEventRecord(stop, 0));
  HANDLE_ERROR(cudaEventSynchronize(stop));
  HANDLE_ERROR(cudaEventElapsedTime(&elapsedTime, start, stop));

  printf("Time taken: %3.1f ms\n", elapsedTime);

  // free stream and mem
  HANDLE_ERROR(cudaFreeHost(host_a));
  HANDLE_ERROR(cudaFreeHost(host_b));
  HANDLE_ERROR(cudaFreeHost(host_c));
  HANDLE_ERROR(cudaFree(dev_a0));
  HANDLE_ERROR(cudaFree(dev_b0));
  HANDLE_ERROR(cudaFree(dev_c0));
  HANDLE_ERROR(cudaFree(dev_a1));
  HANDLE_ERROR(cudaFree(dev_b1));
  HANDLE_ERROR(cudaFree(dev_c1));
  HANDLE_ERROR(cudaStreamDestroy(stream0));
  HANDLE_ERROR(cudaStreamDestroy(stream1));
  return 0;
}
