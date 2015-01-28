#ifndef BIGINTEGER_H
#define BIGINTEGER_H

#include <vector>
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
	void print() const;
	char* copyNumberToDevice() const;
	void copyNumberFromDevice(char* d_number);
	/// reinitialize number array
	void reset();
	void shiftRight(int offset = 1);
	/// aligns this BigInteger on the left & store its size
	void alignLeft(int* size);
	void stuffVector(std::vector<char> vect);
	void shrink(int nuSize);

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
