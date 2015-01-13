#ifndef BIGINTEGER_H
#define BIGINTEGER_H

#include <string>
#include <vector>

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
	std::string number;

public:
	__device__ __host__ BigInteger(std::string number);

	__device__ __host__ void add(const BigInteger& other);
	__device__ __host__ void substract(const BigInteger& other);
	__device__ __host__ void multiply(const BigInteger& other);
	__device__ __host__ void divide(const BigInteger& other);
	__device__ __host__ void factorial(const BigInteger& other);
	__device__ __host__ void greatestCommonDivisor(const BigInteger& other);
};

#endif
