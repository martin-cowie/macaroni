#include <stdio.h>
#include "macaroni.h"

static int leafCount = 0, failCount = 0;

/* FIXME Exports from mac_tree.c */
extern const type_node_t *root_node;
//TODO: replace with getter function
extern const char * const stringTable[];

const char *renderMac(unsigned char *macBytes, unsigned char macLength, char *buff, unsigned int buffLen) {
	//FIXME: handle buffer underrun
	buff[0] = 0;
    char *ptr = buff;
	for(int i=0; i< macLength; i++) {
		if (i > 0) {
			sprintf(ptr, ":");
			ptr++;
		}
		sprintf(ptr, "%02X", (int)macBytes[i]);
		ptr += 2;
	}
	return buff;
}

void print_leaf(const leaf_node_t *leaf, unsigned char *mac, unsigned char macLen) {
    char macStr[macLen*3];
    renderMac(mac, macLen, macStr, 40);

    printf("leaf\t%d:\tMAC=%s, description=%s\n", 
        leaf->line_number,
        macStr,
        stringTable[leaf->short_description]);
}

static void test_leaf(const leaf_node_t *leaf, unsigned char *mac, unsigned char macLen) {
	//Search for the MAC given, and match the results agains the given leaf

	char macStr[macLen*3];
	renderMac(mac, macLen, macStr, 40);
#   if (DEBUG)
	printf("[testing leaf found with \"%s\"]\n", macStr);
#   endif

	const leaf_node_t *quarry = macsearch(mac, macLen);
	if(quarry == leaf) {
		printf("%s, PASS\n", macStr);
	} else {
		printf("%s returns %p, FAIL\n", macStr, quarry);
        failCount++;
	}
}


int main(int argc, char **argv) {
    // Walk every leaf on the tree, and test that searching for it's MAC finds the same leaf
    const int leafCount = macwalk(root_node, test_leaf, NULL, 0);
    printf("leaves=%d, failures=%d\n", leafCount, failCount);

    return failCount;
}
