################################################################################
#
# simple Makefile for mpi-cuda
# by Chunk,Sep 2014
#
################################################################################
#flags
CC = mpic++
NVCC = nvcc

CFLAGS+= -O3
CUDA_HOME= /usr/local/cuda
INCFLAGS= -I$(CUDA_HOME)/include -I$(CUDA_HOME)/include/inc
LDFLAGS= -L$(CUDA_HOME)/lib64
LDFLAGS+= -lcudart
NVCCFLAGS= -gencode arch=compute_20,code=sm_20

#targets
all:build
build:cuMPI
cuMPI:simpleMPI.o simpleMPI_cuda.o
	$(CC) $(LDFLAGS) -o $@ $^

%.o:%.cu
	$(NVCC) $(INCFLAGS) $(NVCCFLAGS) $(CFLAGS) -o $@ -c $^ 

%.o:%.cpp
	$(CC) $(INCFLAGS) $(CFLAGS) -o $@ -c $^

clean:
	$(RM) *.o *.s *.i target

run:cuMPI
	mpirun -np 4 ./cuMPI