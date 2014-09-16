#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>
#include <unistd.h>

using namespace std;

int main() {
	//ms
	int runtime = 1;
	timeval a,b;
	while(1) {
		
		gettimeofday(&a, 0);
		gettimeofday(&b, 0);
		while((b.tv_sec - a.tv_sec)<runtime) {
			gettimeofday(&b, 0);
		};
		//s
		sleep(runtime);
	}
	return 0;
}










