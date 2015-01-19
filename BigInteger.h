#ifndef BIGINTEGER_H
#define BIGINTEGER_H

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
	__device__ __host__ BigInteger();
	//__device__ __host__ BigInteger(const char* number, int size);

	__device__ __host__ void setNumber(const char* nuNumber, int nuSize);
	/// convert '0' to 0
	void zero();

	__device__ __host__ void add(const BigInteger& other);
	__device__ __host__ void substract(const BigInteger& other);
	__device__ __host__ void multiply(const BigInteger& other);
	__device__ __host__ void divide(const BigInteger& other);
	__device__ __host__ void factorial(const BigInteger& other);
	__device__ __host__ void greatestCommonDivisor(const BigInteger& other);
};

__device__ __host__ int update(char* toUpdate, int value);
__device__ __host__ void init(int size, char* toFill);
__device__ __host__ int isFirstBiggerThanSeond(const char* first, const char* second, int size);

/*__global__*/ void kernel_add(char* newB, char* first, char* second, int size_first, int size_second, int * size_newB);
/*__global__*/ void kernel_sub(char* newB, const char* first, const char* second, int size_first, int size_second, int * size_newB);
__global__ void kernel_mul(char* newB, const char* first, const char* second, int size_first, int size_second, int * size_newB);
/*__global__*/ void kernel_div(char* newB, const char* first, const char* second, int size_first, int size_second, int * size_newB);

__global__ void kernel_fact(char* newB, const char* first, int size_first, int * size_newB);
__global__ void kernel_GCD(char* newB, const char* first, int size_first, int * size_newB);

#endif
