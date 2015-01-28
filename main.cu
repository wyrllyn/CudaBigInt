#include "BigInteger.h"

#include <iostream>

using namespace std;


int main(int argc, char** argv) {
	cout << "This program assumes that its user enters coherent arguments (op number number), such as + -25 12" << endl;
	cout << "Enter boggus data at your own risks..." << endl;

	BigInteger left, right;
	OperationType opType;
	cout << argv[1] << " " << argv[2] << " " << argv[3] << endl;
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
			break;
		}
	} else {
		cout << "Insufficient number of arguments" << endl;
	}

	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start, 0);

	BigInteger result;
	int r;
	switch (opType) {
	case ADD:
		result = left.add(right);
		break;
	case SUBSTRACT:
		result = left.substract(right);
		break;
	case MULTIPLY:
		result = left.multiply(right);
		break;
	case DIVIDE:
		r = atoi(argv[3]);
		if (r == 0) {
			cout << "Nice try..." << endl;
			return 0;
		} else {
			result = left.divide(right);
		}
		break;
	case FACTORIAL:
		result = left.factorial(right);
		break;
	case GCD:
		result = left.greatestCommonDivisor(right);
		break;
	default:
		cout << "Reaching default case." << endl;
		break;
	}

	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	float elapsed_time;
	cudaEventElapsedTime(&elapsed_time, start, stop);
	cout << "time: " << elapsed_time << " ms" << endl;
	result.print();
}


