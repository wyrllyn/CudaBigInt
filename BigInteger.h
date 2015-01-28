#ifndef BIGINTEGER_H
#define BIGINTEGER_H


#include "kernel.h"

enum OperationType {
	ADD,
	SUBSTRACT,
	MULTIPLY,
	DIVIDE,
	FACTORIAL,
	GCD,
	ERROR
};

OperationType identifyOperationType(const char* op);

class BigInteger {

private:
	char* number;
	int size;

public:
	BigInteger();
	BigInteger(int size);

	void setNumber(const char* nuNumber, int nuSize);
	/// convert '0' to 0
	void zero();
	void print();
	char* copyNumberToDevice() const;
	void copyNumberFromDevice(char* d_number);

	void applyAddCarry();
	void applySubCarry();
	BigInteger applyMulCarry(int, int, int);

	BigInteger add(const BigInteger& other);
	BigInteger substract(const BigInteger& other);
	BigInteger multiply(const BigInteger& other);
	BigInteger divide(const BigInteger& other);
	BigInteger factorial(const BigInteger& other);
	BigInteger greatestCommonDivisor(const BigInteger& other);
};


#endif
