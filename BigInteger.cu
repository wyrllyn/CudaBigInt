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


BigInteger::~BigInteger() {
	//delete [] number;
}


BigInteger::BigInteger(int size) : size(size) {
	number = new char[size];
	init(size, number);
	number[0] = '+';
}


void BigInteger::setNumber(const char* nuNumber, int nuSize) {
	size = nuSize;
	delete [] number;
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
	cout.flush();
	for (int i = 1; i < size; i++) {
		cout << "`"  << (int) number[i] ;
	}
	cout << endl;
}

void BigInteger::reset() {
	init(size, number);
	number[0] = '+';
}

void BigInteger::shiftRight(int offset) {
	for (int i = size - 1; i > offset; i--) {
		number[i] = number[i - offset];
	}
	for (int i = 1; i <= offset; i++) {
		number[i] = 0;
	}
}

///
/// Utility methods
///

void BigInteger::alignLeft(int* nuSize) {
	for (int i = 1; i < size; i++) {
		if (number[i] != 0) {
			//cout << "align: " << i << endl;
			//cout << "nuSize: " << (size - i) << endl;
			*nuSize = size - i;
			break;
		}
	}
	int i = 1;
	for (int j = size - *nuSize; j < size; j++) {
		//cout << "i=" << i << ";j=" << j << endl;
		//cout << "    =" << (int)number[j] << endl;
		number[i] = number[j];
		i++;
	}
	for (int i = *nuSize + 1; i < size; i++) {
		number[i] = 0;
		//cout << "i=" << i << endl;
		//cout << " =" << (int)number[i] << endl;
	}
}

void BigInteger::stuffVector(vector<char> vect) {
	for (int i = size - 1; i > 0; i--) {
		number[i] = vect.back();
		vect.pop_back();
	}
}

void BigInteger::shrink(int nuSize) {
	size = nuSize + 1;
	char* nuNumber = new char[size];
	for (int i = 0; i < size; i++) {
		nuNumber[i] = number[i];
	}
	delete number;
	number = nuNumber;
}

void BigInteger::resize() {
	int dec = 0;
	for (int i = 1; i < size; i++) {
		if (number[i] == 0) {
			dec++;
		}
		else {
			break;
		}
	}
	if (size - dec <= 1) {
		number[0] = '+';
		number[1] = 0;
		size = 2;
	}
	else if (dec != 0) {
		for (int i = 1; i < size - dec; i++) {
			number[i] = number[i + dec];
		}
		size -= dec;
	}
}

///
/// cudaMemcpy wrapper methods
///

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
	for (int i = size - 1; i >= 1; i--) {
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

BigInteger BigInteger::applyMulCarry(int size_result, int size_first, int size_second) {
	int inc = 1;
	int i, n;
	char * tmp_result;
	BigInteger result(size_result);
	
	tmp_result = new char[size_result];

	for(i=1; i<size_result; i++)
		tmp_result[i] = 0;
	
	
	// i pour result, et n pour number
	for (i = size_result - 1, n = size_first*size_second-1; n > size_first; i--, n--) {
		if (n % size_first != 0) {
			tmp_result[i] += number[n];
			while (tmp_result[i]>9){
				tmp_result[i] -= 10;
				tmp_result[i-1]++;
			}
		}
		if(n % size_first == 0){
			i = size_result - inc;
			inc ++;
		}
	}
	// Signe du résultat
	tmp_result[0] = number[0];
	
	result.setNumber(tmp_result, size_result);

	delete [] tmp_result;
	return result;
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
		else {
			result.number[0] = '+';
		}
	}
	else {
		// check where minus is
		if(other.number[0] == '-') {
			// check size of the number with minus
			if (isFirstBiggerThanSecond_2(number, other.number, size, other.size)) {
				kernel_sub<<<grid, block>>>(d_newB, d_number, d_other_number, size, size - other.size, &size_b);
				result.copyNumberFromDevice(d_newB);
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
				kernel_sub<<<grid, block>>>(d_newB, d_number, d_other_number, size, size - other.size, &size_b);
				result.copyNumberFromDevice(d_newB);
				result.applySubCarry();
				result.number[0] = '-';
			}
			else {
				kernel_sub<<<grid, block>>>(d_newB, d_other_number, d_number, other.size, other.size - size, &size_b);
				result.copyNumberFromDevice(d_newB);
				result.applySubCarry();
			}
		}
	}

	result.resize();
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
	
	dim3 grid(1), block(size_b + 1);

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
		else
				result.number[0] = '+';
	}
	else {
		if(isFirstBiggerThanSecond_2(number, other.number, size, other.size)) {
			kernel_sub<<<grid, block>>>(d_newB, d_number, d_other_number, size, size - other.size, &size_b);
			result.copyNumberFromDevice(d_newB);
			result.applySubCarry();
			if (number[0] == '-') {
				result.number[0] = '-';
			}
			else
				result.number[0] = '+';
		}
		else {
			kernel_sub<<<grid, block>>>(d_newB, d_other_number, d_number, other.size, other.size - size, &size_b);
			result.copyNumberFromDevice(d_newB);
			result.applySubCarry();
			if (number[0] == '+') {
				result.number[0] = '-';
			}
			else
				result.number[0] = '+';
		}
	}
	result.resize();
	return result;
}

BigInteger BigInteger::multiply(const BigInteger& other) {
	char* d_number = copyNumberToDevice();
	char* d_other_number = other.copyNumberToDevice();
	int size_newBbegin = size * other.size;
	
	BigInteger resultbegin(size_newBbegin);
	
	char* d_newB = resultbegin.copyNumberToDevice();
	
	dim3 grid(1), block(size, other.size);

	kernel_mul<<<grid, block>>>(d_newB, d_number, d_other_number, size, other.size, &size_newBbegin);

	resultbegin.copyNumberFromDevice(d_newB);

	cudaFree(d_number);
	cudaFree(d_other_number);
	cudaFree(d_newB);

	int size_newB = size + other.size -1;
	BigInteger result(size_newB);
	result = resultbegin.applyMulCarry(size_newB, size, other.size);
	result.resize();
	return result;
}

BigInteger BigInteger::divide(const BigInteger& other) {
	if (other.size > size) {
		return BigInteger(0);
	}

	BigInteger result(size);
	if(number[0]=='-' || other.number[0]=='-')
		result.number[0]='-';
	else
		result.number[0]='+';

	int dividend_index = 1;
	vector<char> result_vector;
	BigInteger temp(other.size + 1);
	int rest_size = 0;
	int it_count = 0;
	do {
		it_count++;
		cout << "___Iteration #" << it_count << endl;
		cout << "beginning phase 1" << endl;
		int temp_index = rest_size + 1;
		for (int i = dividend_index; i < size; i++) {
			temp.number[temp_index] = number[i];
			temp_index++;
			dividend_index++;
			if (temp_index < other.size) {
				//still not big enough for the divisor
				continue;
			} else if (temp_index == other.size) {
				if (isFirstBiggerThanSecond(other.number, temp.number, other.size)) {
					// still too small, get one extra
					//TODO: handle potential "overflow"
					temp.number[temp_index] = number[i + 1];
					temp_index++;
					dividend_index++;
					break;
				} else {
					// temp is bigger than the divisor, go to next phase
					//cout << "shift right before"; temp.print();
					temp.shiftRight();
					//cout << "shift right after"; temp.print();
					break;
				}
			}
		}
		cout << "end of phase 1, with temp: ";temp.print();
		cout << "dividend_index is at " << dividend_index << "(=" << (int)number[dividend_index] << ")" << endl;
		cout << "temp_index is at " << temp_index << endl;
		cout << "beginning phase 2" << endl;
		BigInteger sub_res(other.size);
		char res = 0;
		do {
			sub_res = temp.substract(other);
			if (sub_res.number[0] == '+') {
				temp = sub_res;
				res++;
			}
		} while (sub_res.number[0] == '+');
		cout << "end of phase 2, with res=" << (int)res << " and temp:"; temp.print();
		cout << "beginning of phase 3" << endl;
		result_vector.push_back(res);
		temp.alignLeft(&rest_size);
		temp.shrink(rest_size + 1);
		cout << "end of phase 3, with rest_size=" << rest_size << " and temp:"; temp.print();
		cout << "loop condition: " << dividend_index << " < " << size  << " : " << (dividend_index <= size) << endl;
		cout << "___end of iteration #" << it_count << endl;
	} while (dividend_index < size);

	// stuff vector into result
	cout << "result_vector contents: ";
	for (int c = 0; c < result_vector.size(); c++) cout << (int) result_vector[c] << " ";
	cout << endl;
	result.stuffVector(result_vector);
	cout << "Final result:"; result.print();
	return result;
}

BigInteger BigInteger::factorial(const BigInteger& other) {
	return BigInteger(0);
}

BigInteger BigInteger::greatestCommonDivisor(const BigInteger& other) {
	return BigInteger(0);
}



