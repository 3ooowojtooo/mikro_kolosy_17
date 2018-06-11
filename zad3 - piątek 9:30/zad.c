#include <stdio.h>

char* encode (char* buf, unsigned int mask, int operation, int character);

int main(){

	char buf[] = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '3',0}; // jak cos to 0 na koncu to NULL - znak konca stringu
	printf("%s\n", encode(buf, 1023, 2, 'b'));
	return 0;
}