#ifndef BIGINTEGER_H
#define BIGINTEGER_H

#include <string>
#include <vector>

enum OperationType {
	ADD,
	SUBSTRACT,
	MULTIPLY,
	DIVIDE,
	TODO
};

OperationType identifyOperationType(const char*);

class BigInteger {

private:
	std::vector<char> number;

public:
	BigInteger(std::string number);

	__device__ void add(const BigInteger& other);
	__device__ void substract(const BigInteger& other);
	__device__ void multiply(const BigInteger& other);
	__device__ void divide(const BigInteger& other);
	__device__ void factoriel(const BigInteger& other);
	__device__ void whateverpgcdisinenglish(const BigInteger& other);
};

#endif
