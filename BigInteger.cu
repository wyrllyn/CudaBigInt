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

void bump(char* number, int size) {
	for (int i = 0; i < size; i++) {
		number[i] += '0';
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


	return toReturn;
}

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

	BigInteger* g_left, *g_right;
	cudaMalloc( (void**) &g_left, sizeof(BigInteger));
	cudaMalloc( (void**) &g_right, sizeof(BigInteger));

	cudaMemcpy(g_left, &left, sizeof(BigInteger), cudaMemcpyHostToDevice);
	cudaMemcpy(g_right, &right, sizeof(BigInteger), cudaMemcpyHostToDevice);

	dim3 block(1), grid(1);
	///
	/// Testing block
	///
	#define SIZE_FIRST 2
	#define SIZE_SECOND 1
	#define NU_SIZE 3
	char* nu = new char[NU_SIZE], * g_nu;
	char* first = new char[SIZE_FIRST];
	first[0] = 9; first[1] = 5;
	char* second = new char[SIZE_SECOND];
	second[0] = 7;
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
	kernel_add(nu, first, second, SIZE_FIRST, SIZE_FIRST - SIZE_SECOND, &nuSize);
	for (int i = 0; i < SIZE_FIRST; i++) {
		cout << (int) first[i];
	}
	cout << " + ";
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
