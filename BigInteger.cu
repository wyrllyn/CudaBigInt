#include "BigInteger.h"

#include <iostream>
#include <string>

using namespace std;

OperationType identifyOperationType(const char* op) {
	if (op == "+") {
		return ADD;
	} else if (op == "-") {
		return SUBSTRACT;
	} else if (op == "*") {
		return MULTIPLY;
	} else if (op == "/") {
		return DIVIDE;
	} else if (op == "!") {
		return FACTORIAL;
	} else if (op == "pgcd") {
		return GCD;
	} else {
		return ERROR;
	}
}

BigInteger::BigInteger() : number(0), size(1) {}

/*BigInteger::BigInteger(const char* number, int size) : size(size) {

}*/


void BigInteger::setNumber(const char* nuNumber, int nuSize) {
	size = nuSize;
	delete number;
	number = new char[size];
	for (int i = 0; i < size; i++) {
		number[i] = nuNumber[i];
	}
}

void BigInteger::zero() {
	for (int i = 0; i < size; i++) {
		number[i] -= '0';
	}
}

void BigInteger::add(const BigInteger& other) {
	
}

void BigInteger::substract(const BigInteger& other) {

}

void BigInteger::multiply(const BigInteger& other) {

}

void BigInteger::divide(const BigInteger& other) {

}

void BigInteger::factorial(const BigInteger& other) {

}

void BigInteger::greatestCommonDivisor(const BigInteger& other) {

}


///
/// Utility functions
///

bool isNeg(char* bi) {
	if (bi[0] == '-') {
		return true;
	}
	else
		return false;
}

void bump(char* number, int size) {
	for (int i = 0; i < size; i++) {
		number[i] += '0';
	}
}

__device__ void add_minus(char* bi, int size) {
	for (int i = size; i > 0 ; i--) {
		bi[i] = bi[i - 1];
	}
	bi[0] = '-';
}
__device__ void remove_minus(char* bi, int size) {
	for (int i = 0; i < size ; i++) {
		bi[i] = bi[i+1];
	}
}




//init 
// size = size_biggest + diff +1 (addition case)
__device__ void init(int size, char* toFill) {
	for (int i = 0; i < size; i++) {
		toFill[i] = 0;
	}
}

//return size, update char*
__device__ int update(char* toUpdate, int value) {
	int dec = 0;
	for (int i = 0; i < value; i++) {
		if (toUpdate[i] == 0) {
			dec++;
		}
		else {
			break;
		}
	}

	int toReturn = value-dec;

	for (int i = 0; i < toReturn; i++) {
		toUpdate[i] = toUpdate[i+dec];
	}

	if (toReturn == 0) {
		toReturn++;
		toUpdate[0] = 0;
	}


	return toReturn;
}

/**
 * Returns true if first is bigger or equal to second.
 * Note: assumes that both numbers have the same size.
 */
int isFirstBiggerThanSecond(const char* first, const char* second, int size) {
	for (int i = 0; i < size; i++) {
		if (first[i] > second[i]) return 1;
		else if (first[i] < second[i]) return 0;
		else continue;
	}
	return 1;
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

int main(int argc, char** argv) {

	BigInteger left, right;
	OperationType opType;
	if (argc >= 2) {
		opType = identifyOperationType(argv[1]);
		left.setNumber(argv[2], string(argv[2]).size());
		left.zero();
		switch (opType) {
		case ADD:
		case SUBSTRACT:
		case MULTIPLY:
		case DIVIDE:
			right.setNumber(argv[3], string(argv[3]).size());
			right.zero();
			break;
		case ERROR:
			cout << "Unrecognised operation type: " << argv[1] << endl;
		}
	} else {
		cout << "Insufficient number of arguments" << endl;
	}

	switch (opType) {
	case ADD:
		left.add(right);
		break;
	case SUBSTRACT:
		left.substract(right);
		break;
	case MULTIPLY:
		left.multiply(right);
		break;
	case DIVIDE:
		left.divide(right);
		break;
	case FACTORIAL:
		left.factorial(right);
		break;
	case GCD:
		left.greatestCommonDivisor(right);
		break;
	}
	///
	/// Testing block
	///
	#define SIZE_FIRST 2
	#define SIZE_SECOND 2
	#define NU_SIZE 4
	char* nu = new char[NU_SIZE], * g_nu;
	char* first = new char[SIZE_FIRST];
	first[0] = 3; first[1] = 5;
	char* second = new char[SIZE_SECOND];
	second[0] = 2; second[1] = 0; // second[2] = 2;
	int nuSize = NU_SIZE;
	/*
	char* g_first, *g_second;
	cudaMalloc( (void**) &g_first, sizeof(char) * 2 );
	cudaMalloc( (void**) &g_second, sizeof(char) * 2 );
	cudaMalloc( (void**) &g_nu, sizeof(char) * 2 );
	cudaMemcpy(g_first, first, sizeof(char) * 2, cudaMemcpyHostToDevice);
	cudaMemcpy(g_second, second, sizeof(char) * 2, cudaMemcpyHostToDevice);
	kernel_add<<<grid, block>>>(g_nu, g_first, g_second, 2, 2, &nuSize);
	cudaMemcpy(nu, g_nu, sizeof(char) * 2, cudaMemcpyDeviceToHost);
	*/
	//kernel_add(nu, first, second, SIZE_FIRST, SIZE_FIRST - SIZE_SECOND, &nuSize);
	//kernel_div(nu, first, second, SIZE_FIRST, SIZE_FIRST - SIZE_SECOND, &nuSize);
	kernel_mul(nu, first, second, SIZE_FIRST, /*SIZE_FIRST -*/ SIZE_SECOND, &nuSize);
	for (int i = 0; i < SIZE_FIRST; i++) {
		cout << (int) first[i];
	}
	cout << " * ";
	for (int i = 0; i < SIZE_SECOND; i++) {
		cout << (int) second[i];
	}
	cout << " = ";
	for (int i = 0; i < nuSize; i++) {
		cout << (int) nu[i];
	}
	cout << endl;
	///
	/// End of testing block
	///
	switch (opType) {
	case ADD:

		break;
	case SUBSTRACT:

		break;
	case MULTIPLY:

		break;
	case DIVIDE:

		break;
	case FACTORIAL:

		break;

	case GCD:

		break;
	default:
		cout << "Reaching default case." << endl;
		break;
	}

}

///
/// Reminder: Don't put functions or methods below the main
///
