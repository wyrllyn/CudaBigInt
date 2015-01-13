#include "BigInteger.h"

#include <iostream>

using namespace std;

OperationType identifyOperationType(const char* op) {
	if (op == "+") {
		return ADD;
	} else if (op == "-") {
		return SUBSTRACT;
	} else if (op == "*") {
		return MULTIPLY;
	} else if (op == "/") {
		return DIVIDE;
	} else if (op == "!") {
		return FACTORIAL;
	} else if (op == "pgcd") {
		return GCD;
	} else {
		return ERROR;
	}
}

int main(int argc, char** argv) {

	string left, right;
	OperationType opType;
	if (argc >= 3) {
		opType = identifyOperationType(argv[1]);
		left = string(argv[2]);
		switch (opType) {
		case ADD:
		case SUBSTRACT:
		case MULTIPLY:
		case DIVIDE:
			right = string(argv[3]);
			break;
		}
	} else {
		cout << "Insufficient number of arguments" << endl;
	}

	/*switch (opType) {
	default:
	}*/

}
