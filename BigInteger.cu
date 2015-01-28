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
	number[0] = '+';
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

void BigInteger::print() {
	cout << number[0];
	cout.flush();
	for (int i = 1; i < size; i++) {
		cout << (int) number[i] << "`";
	}
	cout << endl;
}

void BigInteger::reset() {
	init(size, number);
	number[0] = '+';
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

BigInteger BigInteger::applyMulCarry(int size_result, int size_first, int size_second) {
	int inc = 1;
	int i, n;
	char * tmp_result;
	BigInteger result(size_result);
	
	tmp_result = new char(size_result);

	for(i=0; i<size_result; i++)
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
	
	if (other.size > size) {
		kernel_add<<<grid, block>>>(d_newB, d_other_number, d_number, other.size, other.size - size, &size_b);
	} else {
		kernel_add<<<grid, block>>>(d_newB, d_number, d_other_number, size, size - other.size, &size_b);
	}
	cudaFree(d_number);
	cudaFree(d_other_number);

	result.copyNumberFromDevice(d_newB);
	result.applyAddCarry();
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

	kernel_sub<<<grid, block>>>(d_newB, d_number, d_other_number, size, size - other.size, &size_b);

	result.copyNumberFromDevice(d_newB);
	result.applySubCarry();
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
	return result;
}

BigInteger BigInteger::divide(const BigInteger& other) {
	char* d_number = copyNumberToDevice();
	char* d_other_number = other.copyNumberToDevice();
	int size_newB = size;
	if (other.size > size) {
		return BigInteger(0);
	}

	BigInteger result(size_newB);
	if(number[0]=='-' || other.number[0]=='-')
		result.number[0]='-';
	else
		result.number[0]='+';

	dim3 grid(1), block();

	//char* temp = new char[other.size + 1];
	//init(other.size + 1, temp);
	int t = 0; // temp's index
	int n = 0; // newB's index
	for (int i = size - 1; i > 0; i -= t) {
		t = 0;
		BigInteger temp(other.size + 1);
		cout << "loop#" << i << endl;
		for (int j = i - other.size - 1; j <= i; j++) {
			if (j > 0) {
				temp.number[1 + t] = number[j];
				t++;
				if (!isFirstBiggerThanSecond(other.number, temp.number, other.size)) {
					break;
				}
			}
		}
		cout<<"first phase done"<<endl;
		temp.print();
		// verify that we are not attempting to divide something too small
		bool stopDividing = false;
		if (isFirstBiggerThanSecond(other.number, temp.number, other.size)) {
			cout << "expanding our horizons"<<endl;
			for (int j = t + 1; j < other.size; j++) {
				temp.number[1 + t] = number[j];
				t++;
				if (!isFirstBiggerThanSecond(other.number, temp.number, other.size)) {
					break;
				}
			}
			// we went through the entire number & it's still not enough, that means we're done
			if (!isFirstBiggerThanSecond(other.number, temp.number, other.size)) {
				stopDividing = true; // not breaking right here 'cause we've got a print below
			}
		} else {
			// if everything is cool, shift right
			cout<<"shifting right "<<temp.size<<endl;
			for (int k = temp.size - 1; k > 1; k--) {
				cout<<"k="<<k<<endl;
				temp.number[k] = temp.number[k - 1];
			}
			temp.number[1] = 0;
		}
		temp.print();
		if (stopDividing) break;
		// now that we have our thing, let's get to the division itself
		char res = 0;
		//char* sub_res = new char[size_second];
		BigInteger sub_res(other.size);
		//init(size_second, sub_res);
		do {		
			//kernel_sub(sub_res, temp, second, size_second, size_second, &size_res);
			sub_res = temp.substract(other);
			if (sub_res.number[0] == '+') {
				res++;
			}
			temp = sub_res;
		} while (sub_res.number[0] == '+'); //sub_res > 0
		// current division done, save result & move on to the next
		n++;
		result.number[n] = res;
		cout <<"just checkin: i="<<i<<";t="<<t<<";n="<<n<<";res="<<(int)res<<endl;
	}
	// all divisions done, we need to realign our result;
	int diff = other.size - n + 1;
	cout<<"diff="<<diff<<endl;
	cout<<"size-1="<<(size - 1)<<endl;
	result.print();
	for (int i = size - 1; i > 0; i--) {
		if (i > n && (i - diff) > 0) {
			cout<<"##"<<i<<"="<<(int)result.number[i - diff]<<endl;
			result.number[i] = result.number[i - diff];
		} else {
			result.number[i] = 0;
		}
	}

	return result;
}

BigInteger BigInteger::factorial(const BigInteger& other) {
	return BigInteger(0);
}

BigInteger BigInteger::greatestCommonDivisor(const BigInteger& other) {
	return BigInteger(0);
}



