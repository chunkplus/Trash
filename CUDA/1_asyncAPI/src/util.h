/*
 * util.h
 *
 *  Created on: Sep 3, 2014
 *      Author: chunk
 */

#ifndef UTIL_H_
#define UTIL_H_

#include <stdio.h>
#include <stdlib.h>

#include <cuda.h>
#include <cuda_runtime.h>
#include <helper_cuda.h>
#include <helper_functions.h>

#include <sys/time.h>
/**
 * timer utils
 */

class mTimer {
	struct timeval _tstart, _tend;
	struct timezone tz;
public:
	void start() {
		gettimeofday(&_tstart, &tz);
	}
	void end() {
		gettimeofday(&_tend, &tz);
	}
	double getTime() {
		double t1, t2;
		t1 = (double) _tstart.tv_sec + (double) _tstart.tv_usec / (1000 * 1000);
		t2 = (double) _tend.tv_sec + (double) _tend.tv_usec / (1000 * 1000);
		return t2 - t1;
	}
	void showTime() {
		printf("time in sec:\t%.12f s\n", getTime());
	}
};

class cuTimer {
	StopWatchInterface *timer;
public:
	cuTimer() {
		sdkCreateTimer(&timer);
	}
	~cuTimer() {
		sdkDeleteTimer(&timer);
	}
	void start() {
		sdkStartTimer(&timer);
	}
	void end() {
		sdkStopTimer(&timer);
	}
	double getTime() {
		return sdkGetTimerValue(&timer);
	}
	//Time in msec
	void showTime() {
		printf("time in msec:\t%.12f ms\n", getTime());
	}
};

#endif /* UTIL_H_ */
