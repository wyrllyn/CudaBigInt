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
