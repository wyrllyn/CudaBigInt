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

BigInteger::BigInteger() : number("0"), size(1) {}

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


int main(int argc, char** argv) {

	BigInteger left, right;
	OperationType opType;
	if (argc >= 2) {
		opType = identifyOperationType(argv[1]);
		left.setNumber(argv[2], string(argv[2]).size());
		switch (opType) {
		case ADD:
		case SUBSTRACT:
		case MULTIPLY:
		case DIVIDE:
			right.setNumber(argv[3], string(argv[3]).size());
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

	dim3 block, grid;
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



//init 
// size = vali + hjvo +1 (addition case)
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
- vali is the biggest size
- hjvo is the difference between sizes
- first is the biggest char*
- second is the other
- calcul newB avant

*/

__global__ void kernel_add(char* newB, char* first, char* second, int vali, int hjvo, int * size_newB) {
	int tmp = 0;
	int carry = 0;
	(*size_newB) = vali + hjvo +1;
	init(*size_newB, newB);
	int index = *size_newB;

/*
	// know 
	if (size_first > size_second) {
		vali = size_second;
		hjvo = size_first - size_second;
	}
	else {
		vali = size_first;
		hjvo = size_second - size_first;
	}

*/

	for (int i = vali - 1; i >= 0; i--) {
		tmp = second[i] + first[i] + carry;
		if (tmp >= 10) {
			carry = 1;
			tmp = tmp % 10;
		}
		else {
			carry = 0;
		}
		newB[index] = tmp;
		index--;
	}

	for (int i = hjvo - 1; i >= 0; i--) {
		tmp = first[i] + carry;
		if (tmp >= 10) {
			carry = 1;
			tmp = tmp % 10;
		}
		else {
			carry = 0;
		}
		newB[index] = tmp;
		index--;
	}
	if (carry != 0) {
		newB[index] = carry;
	}

}
