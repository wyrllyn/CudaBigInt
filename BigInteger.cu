#include "BigInteger.h"

#include <iostream>

using namespace std;

OperationType identifyOperationType(const char*) {

}

int main(int argc, char** argv) {

	string left, right;
	OperationType opType;
	if (argc >= 3) {
		opType = identifyOperationType(argv[1]);
		left = string(argv[2]);
		right = string(argv[3]);
	} else {
		cout << "Insufficient number of arguments" << endl;
	}

	/*switch (opType) {
	default:
	}*/

}
