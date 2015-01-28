#include "kernel.h"

#include <iostream>
#include <cstdio>

#include "utility.h"

using namespace std;

__device__ inline void charAtomicAdd(char *address, char value) {
   int oldval, newval, readback;
 
   oldval = *address;
   newval = oldval + value;
   while ((readback=atomicCAS((int *)address, oldval, newval)) != oldval) {
      oldval = readback;
      newval = oldval + value;
   }
}


///
/// Kernel functions
///

/*
How to use this method :
- newB and size newB contains the result
- size_biggest is the biggest size
- diff is the difference between sizes
- first is the biggest char*
- second is the other
- calcul newB avant

*/
__global__ void kernel_add(char* newB, char* first, char* second, int size_biggest, int diff, int * size_newB) {
	int tmp = 0;
	int i = threadIdx.x;
#if __CUDA_ARCH__>=200
	//printf("#threadIdx.x = %d\n", threadIdx.x);
#endif
	if (i == 0) return;

	//for (int i = size_biggest - 1; i >= 0; i--) {
	if (i - 1 - diff >= 0 && (second[i - 1 - diff] != '+' && second[i - 1 - diff] != '-')) {
		tmp = second[i - 1 - diff] + first[i - 1];
	} else if (first[i - 1] != '+' && first[i - 1] != '-') {
		tmp = first[i - 1];
	}

	if (tmp >= 10) {
		//charAtomicAdd(&newB[i], 1);
		newB[i - 1]++;
		tmp = tmp % 10;
	}
	if (i != 0)
		newB[i] += tmp;
	//}
}


__global__ void kernel_sub(char* newB, char* first, char* second, int size_biggest, int diff, int * size_newB) {
	int tmp = 0;
	int i = threadIdx.x;
#if __CUDA_ARCH__>=200
	//printf("#threadIdx.x = %d\n", threadIdx.x);
#endif
	if (i == 0) return;

	//for (int i = size_biggest - 1; i >= 0; i--) {
	if (i - 1 - diff >= 0 && (second[i - 1 - diff] != '+' && second[i - 1 - diff] != '-')) {
		tmp = first[i - 1] - second[i-1-diff];
	} else if (first[i - 1] != '+' && first[i - 1] != '-') {
		tmp = first[i - 1];
	}

	if (tmp < 0) {
		// warning 10 - tmp ?
		newB[i - 1]--;
		tmp += 10;
	}
	if (i != 0)
		newB[i] += tmp;
	//}
}

// first is the bigInt with the biggest size
__global__ void kernel_mul(char* newB,  char* first, char* second, int size_first, int size_second, int * size_newB) {

	int i = threadIdx.x;
	int j = threadIdx.y;

	int tid = j * gridDim.x * blockDim.x + i ;

	if(j!=0 && i!=0){
		newB[tid] = first[i] * second[j];
	}

	if(j==0 && i==0){
		if(first[j] != second[i])
			newB[0]='-';
		else
			newB[0]='+';
	}
}



/// Unused - see BigInteger::divide()
/**
 * first is divided by second.
 * Note: since we are working with integers, the quotient can't be bigger than the dividend.
 * Also, if the divisor is bigger than the dividend, then the result is zero.
 */
__global__ void kernel_div(char* newB, char* first, char* second, int size_first, int size_second, int * size_newB, char* aux) {
	int i = threadIdx.x;
	int j = threadIdx.y;

	if(j==0 && i==0){
		if(first[j]=='-' || second[i]=='-')
			newB[0]='-';
		else
			newB[0]='+';
		return;
	}

#if __CUDA_ARCH__>=200
	printf("#i, j = %d, %d\n", i, j);
#endif
	// adapted from kernel_sub
	int diff = size_first - size_second;
	int tmp = 0;
	if (j - 1 - diff >= 0 && (second[j - 1 - diff] != '+' && second[j - 1 - diff] != '-')) {
		tmp = first[j - 1] - second[j-1-diff];
	} else if (first[j - 1] != '+' && first[j - 1] != '-') {
		tmp = first[j - 1];
	}

	if (tmp < 0) {
		// warning 10 - tmp ?
		aux[i * size_first + j - 1]--;
		tmp += 10;
	}
	if (i != 0)
		aux[i * size_first + j] += tmp;
	// end of kernel_sub

#if __CUDA_ARCH__>=200
	printf("#aux = %d\n", aux[i * size_first + j]);
#endif

/*
	char* temp = NULL;
	//init(size_second + 1, temp);
	int t = 0; // temp's index
	int n = 0; // newB's index
	for (int i = size_first - 1; i >= 0; i -= t) {
		t = 0;
		for (int j = i - size_second; j <= i; j++) {
			if (j >= 0) {
				temp[t] = first[j];
				t++;
			}
		}
		// verify that we are not attempting to divide something too small
		if (isFirstBiggerThanSecond(second, temp, size_second)) {
			t = 0;
			for (int j = i - size_second - 1; j <= i; j++) {
				if (j < 0) {
					// nothing left to divide, exit function
					return;
				} else {
					temp[t] = first[j];
					t++;
				}
			}
		}
		// now that we have our thing, let's get to the division itself
		char res = 0;
		char* sub_res = NULL;
		int size_res = 0;
		//init(size_second, sub_res);
		do {		
			//kernel_sub(sub_res, temp, second, size_second, size_second, &size_res);
			res++;
		} while (0); //sub_res > 0
		// current division done, save result & move on to the next
		newB[n] = res;
		n++;
	}
	// all divisions done, we need to realign our result;
	int diff = size_second - n;
	for (int i = size_second - 1; i > n; i++) {
		newB[i] = newB[i - diff];
	}*/
}




