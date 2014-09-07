#include <iostream>
#include <vector>
#include <time.h>
#include <stdlib.h>
#include <string.h>
using namespace std;

int main() {
	clock_t start, finish;
	clock_t start1, finish1;

	int i, j, k;
	//初始化两个1000*1000的矩阵
	int (*a)[1000], (*b)[1000];
	a = new int[1000][1000];
	b = new int[1000][1000];

	for (i = 0; i < 1000; i++) {
		for (j = 0; j < 1000; j++) {
			a[i][j] = i % (j + 1);
			b[i][j] = i / (j + 1);
		}
	}
	//存放A*B的结果
	int (*c)[1000], (*d)[1000];
	c = new int[1000][1000];
	d = new int[1000][1000];

	//初始化为0
	memset(c, 0, 1000 * 1000 * sizeof(int));
	memset(d, 0, 1000 * 1000 * sizeof(int));

	start = clock();
	for (i = 0; i < 1000; i++) {
		for (j = 0; j < 1000; j++) {
			for (k = 0; k < 1000; k++) {
				c[i][j] += a[i][k] * b[k][j];
			}

		}
	}
	finish = clock();

	start1 = clock();

	//可以修改的部分  开始
	//======================================================

//	// 方案A:交換
//	for (k = 0; k < 1000; k++) {
//		for (i = 0; i < 1000; i++) {
//			for (j = 0; j < 1000; j++) {
//				d[i][j] += a[i][k] * b[k][j];
//			}
//
//		}
//	}

	// 方案B：交換
	for (i = 0; i < 1000; i++) {
		for (k = 0; k < 1000; k++) {
			for (j = 0; j < 1000; j++) {
				d[i][j] += a[i][k] * b[k][j];
			}

		}
	}

//	// 方案C：block
//	int BFac = 20;
//	for (int jj = 0; jj < 1000; jj = jj + BFac)
//		for (int kk = 0; kk < 1000; kk = kk + BFac)
//			for (i = 0; i < 1000; i++) {
//				for (k = kk; k < min(kk + BFac, 1000); k++) {
//					for (j = jj; j < min(jj + BFac, 1000); j++) {
//						d[i][j] += a[i][k] * b[k][j];
//					}
//
//				}
//			}

//	// 方案D：buffer
//	int (*temp)[1000];
//	temp = new int[1000][1000];
//	memset(temp, 0, 1000 * 1000 * sizeof(int));
//	for (int i = 0; i < 1000; i++) {
//		for (int j = 0; j < 1000; j++) {
//			temp[i][j] = b[j][i];
//		}
//	}
//	for (int i = 0; i < 1000; i++) {
//		for (int j = 0; j < 1000; j++) {
//			for (int k = 0; k < 1000; k++) {
//				d[i][j] += a[i][k] * temp[j][k];
//			}
//		}
//	}

	//可以修改的部分   结束
	//======================================================
	finish1 = clock();

	//对比两次的结果
	for (i = 0; i < 1000; i++) {
		for (j = 0; j < 1000; j++) {
			if (c[i][j] != d[i][j]) {
				cout << "you have got an error in algorithm modification!"
						<< endl;
				exit(1);
			}

		}
	}

	cout << "time spent for original method : " << finish - start << " ms"
			<< endl;
	cout << "time spent for new method : " << finish1 - start1 << " ms" << endl;
	return 0;
}
