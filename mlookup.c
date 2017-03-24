/* 
 * mlookup.c 
 *
 * Look up the manufacturer of a given MAC address
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "macaroni.h"

static int parseMAC(const char *macStr, unsigned char result[6]) {
	int values[6];
	if (6 != sscanf(macStr, "%x:%x:%x:%x:%x:%x",
		&values[0], &values[1], &values[2],
		&values[3], &values[4], &values[5])) {
		return -1;
	}
	for (int i = 0; i < 6; ++i ) {
		result[i] = (unsigned char) values[i];
	}
	return 0;
}

int main(int argc, char *argv[]) {
	if(argc < 2) {
		fprintf(stderr, "wrong # args, try %s <mac-address> [<mac-address> n]\n", argv[0]);
		exit(1);
	}

	for(int i=1; i< argc; i++) {
		unsigned char buff[6] = {0};
		const int n = parseMAC(argv[i], buff);
		if (n<0) {
			fprintf(stderr, "Cannot parse MAC '%s'\n", argv[i]);
			continue;
		}
		const char *manufacturer = macsearch(buff, n);
		if (manufacturer == NULL) {
			fprintf(stderr, "Cannot resolve manufacturer from MAC '%s'\n", argv[i]);
			continue;
		}

		printf("%s => %s\n", argv[i], manufacturer);
	}
}