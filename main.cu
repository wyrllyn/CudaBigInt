#include "BigInteger.h"

#include <iostream>

using namespace std;


int main(int argc, char** argv) {
	cout << "This program assumes that its user enters coherent arguments (op number number), such as * -25 12" << endl;
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
		result = left.divide(right);
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

	///
	/// Testing block
	///
	/*#define SIZE_FIRST 2
	#define SIZE_SECOND 2
	#define NU_SIZE 4
	char* nu = new char[NU_SIZE], * g_nu;
	char* first = new char[SIZE_FIRST];
	first[0] = 3; first[1] = 5;
	char* second = new char[SIZE_SECOND];
	second[0] = 2; second[1] = 0; // second[2] = 2;
	int nuSize = NU_SIZE;*/
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
	//kernel_mul(nu, first, second, SIZE_FIRST, /*SIZE_FIRST -*/ SIZE_SECOND, &nuSize);
	/*for (int i = 0; i < SIZE_FIRST; i++) {
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
	cout << endl;*/
	///
	/// End of testing block
	///
}


