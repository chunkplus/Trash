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
	//��ʼ������1000*1000�ľ���
	int (*a)[1000], (*b)[1000];
	a = new int[1000][1000];
	b = new int[1000][1000];

	for (i = 0; i < 1000; i++) {
		for (j = 0; j < 1000; j++) {
			a[i][j] = i % (j + 1);
			b[i][j] = i / (j + 1);
		}
	}
	//���A*B�Ľ��
	int (*c)[1000], (*d)[1000];
	c = new int[1000][1000];
	d = new int[1000][1000];

	//��ʼ��Ϊ0
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

	//�����޸ĵĲ���  ��ʼ
	//======================================================

//	// ����A:���Q
//	for (k = 0; k < 1000; k++) {
//		for (i = 0; i < 1000; i++) {
//			for (j = 0; j < 1000; j++) {
//				d[i][j] += a[i][k] * b[k][j];
//			}
//
//		}
//	}

	// ����B�����Q
	for (i = 0; i < 1000; i++) {
		for (k = 0; k < 1000; k++) {
			for (j = 0; j < 1000; j++) {
				d[i][j] += a[i][k] * b[k][j];
			}

		}
	}

//	// ����C��block
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

//	// ����D��buffer
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

	//�����޸ĵĲ���   ����
	//======================================================
	finish1 = clock();

	//�Ա����εĽ��
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
