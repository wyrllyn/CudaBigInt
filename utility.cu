#include "utility.h"

bool isNeg(char* bi) {
	if (bi[0] == '-') {
		return true;
	}
	else
		return false;
}

void bump(char* number, int size) {
	for (int i = 0; i < size; i++) {
		number[i] += '0';
	}
}


//init 
// size = size_biggest + diff +1 (addition case)
void init(int size, char* toFill) {
	for (int i = 0; i < size; i++) {
		toFill[i] = 0;
	}
}

//return size, update char*
__device__ int update(char* toUpdate, int value) {
	int dec = 0;
	for (int i = 0; i < value; i++) {
		if (toUpdate[i] == 0) {
			dec++;
		}
		else {
			break;
		}
	}

	int toReturn = value-dec;

	for (int i = 0; i < toReturn; i++) {
		toUpdate[i] = toUpdate[i+dec];
	}

	if (toReturn == 0) {
		toReturn++;
		toUpdate[0] = 0;
	}


	return toReturn;
}

/**
 * Returns true if first is bigger or equal to second.
 * Note: assumes that both numbers have the same size.
 */
int isFirstBiggerThanSecond(const char* first, const char* second, int size) {
	for (int i = 0; i < size; i++) {
		if (first[i] > second[i]) return 1;
		else if (first[i] < second[i]) return 0;
		else continue;
	}
	return 1;
}


