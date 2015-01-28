#include "BigInteger.h"

#include <iostream>
#include <string>

#include "utility.h"

using namespace std;

OperationType identifyOperationType(const char* op) {
	if (op[0] == '+') {
		return ADD;
	} else if (op[0] == '-') {
		return SUBSTRACT;
	} else if (op[0] == '*') {
		return MULTIPLY;
	} else if (op[0] == '/') {
		return DIVIDE;
	} else if (op[0] == '!') {
		return FACTORIAL;
	} else if (op == "pgcd") {
		return GCD;
	} else {
		return ERROR;
	}
}

BigInteger::BigInteger() : number(0), size(1) {}


BigInteger::BigInteger(int size) : size(size) {
	number = new char[size];
	init(size, number);
}


void BigInteger::setNumber(const char* nuNumber, int nuSize) {
	size = nuSize;
	delete number;
	if (nuNumber[0] != '-' && nuNumber[0] != '+')
		size++;

	number = new char[size];
	if (nuNumber[0] == '-')
		number[0] = '-';
	else
		number[0] = '+';

	for (int i = 1; i < size; i++) {
		if (nuNumber[0] != '-' && nuNumber[0] != '+')
			number[i] = nuNumber[i - 1];
		else
			number[i] = nuNumber[i];
	}
}

void BigInteger::zero() {
	for (int i = 0; i < size; i++) {
		if (number[i] == '-' || number[i] == '+') continue;
		number[i] -= '0';
	}
}

void BigInteger::print() const {
	cout << number[0];
	for (int i = 1; i < size; i++) {
		cout << (int) number[i] << "`";
	}
	cout << endl;
}

/**
 * Allocate and copy this BigInteger's number to device.
 */
char* BigInteger::copyNumberToDevice() const {
	char* d_number;
	cudaMalloc( (void**) &d_number, sizeof(char) * size);
	cudaMemcpy(d_number, number, sizeof(char) * size, cudaMemcpyHostToDevice);
	return d_number;
}


void BigInteger::copyNumberFromDevice(char* d_number) {
	cudaMemcpy(number, d_number, sizeof(char) * size, cudaMemcpyDeviceToHost);
}

///
/// Carry the things
///

void BigInteger::applyAddCarry() {
	for (int i = size - 1; i >= 0; i--) {
		if (number[i] > 9) {
			number[i] -= 10;
			number[i - 1]++;
		}
	}
}

void BigInteger::applySubCarry() {
	for (int i = size - 1; i >= 0; i--) {
		if (number[i] < 0) {
			number[i] += 10;
			number[i - 1]--;
		}
	}
}

void BigInteger::applyMulCarry() {
	/*for (int i = size - 1; i >= 0; i--) {
		if (number[i] > 9) {
			number[i] -= 10;
			number[i - 1]++;
		}
	}*/
}

///
/// Operations
///

BigInteger BigInteger::add(const BigInteger& other) {

	char* d_number = copyNumberToDevice();
	char* d_other_number = other.copyNumberToDevice();

	int size_b = size;
	if (other.size > size)
		size_b = other.size;
	
	BigInteger result(size_b + 1);
	char* d_newB = result.copyNumberToDevice();
	
	dim3 grid(1), block(size_b + 1);

	if (number[0] == other.number[0]) {	
		if (other.size > size) {
			kernel_add<<<grid, block>>>(d_newB, d_other_number, d_number, other.size, other.size - size, &size_b);
		} else {
			kernel_add<<<grid, block>>>(d_newB, d_number, d_other_number, size, size - other.size, &size_b);
		}
		result.copyNumberFromDevice(d_newB);
		result.applyAddCarry();
		if (number[0] == '-') {
			result.number[0] = '-';
		}
	}
	else {
		// check where minus is
		if(other.number[0] == '-') {
			// check size of the number with minus
			if (isFirstBiggerThanSecond_2(number, other.number, size, other.size)) {
				cout << "test" << endl;
				// HERE
				kernel_sub<<<grid, block>>>(d_newB, d_number, d_other_number, size, size - other.size, &size_b);
				//(d_newB, d_number, d_other_number, size, size - other.size, &size_b
				result.copyNumberFromDevice(d_newB);
				result.print();
				result.applySubCarry();
			}
			else {
				kernel_sub<<<grid, block>>>(d_newB, d_other_number, d_number, other.size, other.size - size, &size_b);
				result.copyNumberFromDevice(d_newB);
				result.applySubCarry();
				result.number[0] = '-';
			}

		}
		else {
			// check size of the number with minus
			if (isFirstBiggerThanSecond_2(number, other.number, size, other.size)) {
				cout << "hey add" << endl;
				kernel_sub<<<grid, block>>>(d_newB, d_number, d_other_number, size, size - other.size, &size_b);
				result.copyNumberFromDevice(d_newB);
				result.applySubCarry();
				result.number[0] = '-';
			}
			else {
				// HERE
				kernel_sub<<<grid, block>>>(d_newB, d_other_number, d_number, other.size, other.size - size, &size_b);
				result.copyNumberFromDevice(d_newB);
				result.applySubCarry();
			}
		}
	}

	
	return result;
}

BigInteger BigInteger::substract(const BigInteger& other) {
	char* d_number = copyNumberToDevice();
	char* d_other_number = other.copyNumberToDevice();

	int size_b = size;
	if (other.size > size)
		size_b = other.size;
	
	BigInteger result(size_b + 1);
	char* d_newB = result.copyNumberToDevice();
	
	dim3 grid(1), block(size_b + 10);

	if (number[0] != other.number[0]) {
		if (isFirstBiggerThanSecond_2(number, other.number, size, other.size))
			kernel_add<<<grid, block>>>(d_newB, d_number, d_other_number, size, size - other.size, &size_b);
		else
			kernel_add<<<grid, block>>>(d_newB, d_other_number, d_number, other.size, other.size - size, &size_b);
		result.copyNumberFromDevice(d_newB);
		result.applyAddCarry();
		if (number[0] == '-') {
			result.number[0] = '-';
		}
	}
	else {
		if(isFirstBiggerThanSecond_2(number, other.number, size, other.size)) {
			cout << "hey" << endl;
		//	kernel_sub<<<grid, block>>>(d_newB, d_number, d_other_number, size, size - other.size, &size_b);
			kernel_sub<<<grid, block>>>(d_newB, d_number, d_other_number, size, size - other.size, &size_b);
			result.copyNumberFromDevice(d_newB);
			print();
			other.print();
			result.print();
			result.applySubCarry();
			if (number[0] == '-') {
				result.number[0] = '-';
			}
		}
		else {
			kernel_sub<<<grid, block>>>(d_newB, d_other_number, d_number, other.size, other.size - size, &size_b);
			result.copyNumberFromDevice(d_newB);
			result.applySubCarry();
			if (number[0] == '+') {
				result.number[0] = '-';
		}
		}
	}

	

	
	return result;
}

BigInteger BigInteger::multiply(const BigInteger& other) {
	char* d_number = copyNumberToDevice();
	char* d_other_number = other.copyNumberToDevice();
	int size_newB = size + other.size;

	BigInteger result(size_newB);
	char* d_newB = result.copyNumberToDevice();
	
	dim3 grid(1), block(size, other.size);

	kernel_mul<<<grid, block>>>(d_newB, d_number, d_other_number, size, other.size, &size_newB);

	result.copyNumberFromDevice(d_newB);
	//result.applyMulCarry();
	return result;
}

BigInteger BigInteger::divide(const BigInteger& other) {

}

BigInteger BigInteger::factorial(const BigInteger& other) {

}

BigInteger BigInteger::greatestCommonDivisor(const BigInteger& other) {

}



