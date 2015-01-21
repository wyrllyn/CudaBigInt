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

/*BigInteger::BigInteger(const char* number, int size) : size(size) {

}*/


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
	for (int i = 1; i < size; i++) {
		cout << (int) number[i];
	}
	cout << endl;
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



