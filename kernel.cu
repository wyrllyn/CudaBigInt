#include "kernel.h"

#include <iostream>

#include "utility.h"

using namespace std;

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

/*__global__*/ void kernel_add(char* newB, char* first, char* second, int size_biggest, int diff, int * size_newB) {
	int tmp = 0;
	int carry = 0;
	(*size_newB) = size_biggest + 1;
	init(*size_newB, newB);
	int index = *size_newB - 1;

/*
	// know 
	if (size_first > size_second) {
		size_biggest = size_second;
		diff = size_first - size_second;
	}
	else {
		size_biggest = size_first;
		diff = size_second - size_first;
	}

*/

	for (int i = size_biggest - 1; i >= 0; i--) {
		if (i - diff >= 0) {
			tmp = second[i - diff] + first[i] + carry;
			cout << "__ " << (int) first[i] << " + " << (int) second[i - diff] << " + " << carry << " = " << tmp << endl;
		} else {
			tmp = first[i] + carry;
			cout << "__ " << (int) first[i] << " + " << carry << " = " << tmp << endl;
		}

		if (tmp >= 10) {
			carry = 1;
			tmp = tmp % 10;
		}
		else {
			carry = 0;
		}
		newB[index] = tmp;
		cout << index << "___ " << (int) newB[index] << endl;
		index--;
	}

	/*for (int i = diff - 1; i >= 0; i--) {
		tmp = first[i] + carry;
cout << "~~ " << (int) first[i] << " + " << carry << " = " << tmp << endl;
		if (tmp >= 10) {
			carry = 1;
			tmp = tmp % 10;
		}
		else {
			carry = 0;
		}
		newB[index] = tmp;
cout << index << "~~~ " << (int) newB[index] << endl;
		index--;
	}*/
	if (carry != 0) {
		newB[index] = carry;
		cout << index << "### " << (int) newB[index] << endl;
	}

	cout << "cheking final result" << endl;
	for (int i = 0; i < *size_newB; i++) {
		cout << (int) newB[i];
	}
	cout << endl;

}

/**
 * first is divided by second.
 * Note: since we are working with integers, the quotient can't be bigger than the dividend.
 * Also, if the divisor is bigger than the dividend, then the result is zero.
 */
void kernel_div(char* newB, const char* first, const char* second, int size_first, int size_second, int * size_newB) {
	if (size_first > size_second
		|| (size_first == size_second && isFirstBiggerThanSecond(first, second, size_first))
	) {
		*size_newB = size_first;
	} else {
		*size_newB = 1;
		init(*size_newB, newB);
		return;
	}


	char* temp = NULL;
	init(size_second + 1, temp);
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
		init(size_second, sub_res);
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
	}
}

/*__global__*/ void kernel_sub(char* newB, char* first, char* second, int size_biggest, int diff, int * size_newB) {

	int tmp = 0;
	int carry = 0;
	(*size_newB) = size_biggest;
	init(*size_newB, newB);
	int index = *size_newB - 1;

	for (int i = size_biggest - 1; i >= 0; i--) {
		if (i - diff >= 0) {
			tmp = first[i] - second[i-diff] - carry;
			//cout << "__ " << (int) first[i] << " - " << (int) second[i - diff] << " - " << carry << " = " << tmp << endl;
		} else {
			tmp = first[i] - carry;
			//cout << "__ " << (int) first[i] << " - " << carry << " = " << tmp << endl;
		}

		if (tmp < 0) {
			// warning 10 - tmp ?
			carry = 1;
			tmp += 10 ;
		}
		else {
			carry = 0;
		}
		newB[index] = tmp;
		cout << "index : " << index << "___ " << (int) newB[index] << endl;
		index--;
	}

	*size_newB = update(newB, *size_newB);
	

	cout << "cheking final result" << endl;
	for (int i = 0; i < *size_newB; i++) {
		cout << (int) newB[i];
	}
	cout << endl;
}

// first is the bigInt with de biggest size
/*__global__*/ void kernel_mul(char* newB,  char* first, char* second, int size_first, int size_second, int * size_newB) {
	(*size_newB) = size_first + size_second;
	init(*size_newB, newB);
	int index = 0;
	int tmp = 0;
	int tmp_second = 0;
	int carry = 0;
	int carry_second = 0;

	for (int i = size_second - 1; i >= 0; i--) {
		index = (*size_newB) - size_second + i ;
		for (int j = size_first - 1; j >= 0 ; j--) {
			//cout << "i = " << i << " j= " << j << " index = " << index << endl;
			tmp = first[j] * second[i] + carry;
			//cout << "1 tmp = " << tmp << endl;
			carry = 0;
			while (tmp >= 10) {
				tmp -= 10;
				carry++;
			}
		//	cout << "2 tmp = " << tmp << endl;
		//	cout << "carry = " << carry << endl;

			tmp_second = newB[index] + tmp + carry_second;
			if (tmp_second >= 10) {
		//		cout << " test second " << endl;
				tmp_second = tmp_second % 10;
				carry_second = 1;
			}
			newB[index] = tmp_second;
			index --;
			if (carry > 0 && j == 0) {
		//		cout << "test" << endl;
				newB[index] = carry;
			}
		}


		// add values : how ??
	}
}


