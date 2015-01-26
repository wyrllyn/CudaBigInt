
void cpu_add(char* newB, char* first, char* second, int size_biggest, int diff, int * size_newB) {
	int tmp = 0;
	int carry = 0;
	(*size_newB) = size_biggest + 1;
	init(*size_newB, newB);
	int index = *size_newB - 1;
	int i = BlockIdx.x;

	for (int i = size_biggest - 1; i >= 0; i--) {
		if (i - diff >= 0 && (second[i] != '+' && second[i] != '-')) {
			tmp = second[i - diff] + first[i] + carry;
		} else if (first[i] != '+' && first[i] != '-') {
			tmp = first[i] + carry;
		}

		if (tmp >= 10) {
			carry = 1;
			tmp = tmp % 10;
		}
		else {
			carry = 0;
		}
		newB[index] = tmp;
		index--;
	}

	if (carry != 0) {
		newB[index] = carry;
	}
}


void cpu_sub(char* newB, char* first, char* second, int size_biggest, int diff, int * size_newB) {

	int tmp = 0;
	int carry = 0;
	(*size_newB) = size_biggest;
	init(*size_newB, newB);
	int index = *size_newB - 1;

	for (int i = size_biggest - 1; i >= 0; i--) {
		if (i - diff >= 0) {
			tmp = first[i] - second[i-diff] - carry;
			//cout << "__ " << (int) first[i] << " - " << (int) second[i - diff] << " - " << carry << " = " << tmp << endl;
		} else {
			tmp = first[i] - carry;
			//cout << "__ " << (int) first[i] << " - " << carry << " = " << tmp << endl;
		}

		if (tmp < 0) {
			// warning 10 - tmp ?
			carry = 1;
			tmp += 10 ;
		}
		else {
			carry = 0;
		}
		newB[index] = tmp;
		cout << "index : " << index << "___ " << (int) newB[index] << endl;
		index--;
	}

	*size_newB = update(newB, *size_newB);
	

	cout << "cheking final result" << endl;
	for (int i = 0; i < *size_newB; i++) {
		cout << (int) newB[i];
	}
	cout << endl;
}


