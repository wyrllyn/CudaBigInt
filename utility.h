#ifndef UTILITY_H
#define UTILITY_H

bool isNeg(char* bi);
__device__ __host__ int update(char* toUpdate, int value);
void init(int size, char* toFill);
__device__ __host__ int isFirstBiggerThanSecond(const char* first, const char* second, int size);

#endif
