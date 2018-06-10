#include <stdio.h>

long check_tab (int * tab, int n, int* max);

int main(){
	int max;
	int tab [] = {1,2,2,3,4,6,8,6, 2, 2,2,8,3,11,2};
	int n = 14;

	printf("%ld\n", check_tab(tab, n, &max));
	printf("%d\n", max);
}