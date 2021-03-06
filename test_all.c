#include <stdio.h>
#include <string.h>

#include "macaroni.h"
#include "macaroni_internal.h"

static int leafCount = 0, failCount = 0;


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

	printf("leaf\tMAC=%s, description=%s\n", 
		macStr,
		stringTable[leaf->description]);
}

static void test_leaf(const char *manufacturer, unsigned char *mac, unsigned char macLen) {
	//Search for the MAC given, and match the results agains the given leaf

	char macStr[macLen*3];
	renderMac(mac, macLen, macStr, 40);

	const char *quary = macsearch(mac, macLen);

	if(quary != NULL && strcmp(quary, manufacturer) == 0) {
		printf("%s, \"%s\" - PASS\n", macStr, quary);
	} else {
		printf("%s returns %p, FAIL\n", macStr, quary);
		failCount++;
	}
}

static int test_partial_match() {
	/* The MAC of a raspberry Pi */
	const unsigned char mac[6] = {0xb8, 0x27, 0xeb, 0x9a, 0x47, 0x11};

	//1. Should find it 
	const char *result = NULL;
	if(NULL == (result = macsearch(mac, 6))) {
		return 1;
	}
	printf("Found non NULL value: %s\n", result);

	//2. Should NOT find it, 2 bytes is a partial match
	if(NULL != (result = macsearch(mac, 2))) {
		printf("Found non NULL value: %s\n", result);
		return 1;
	}
	printf("Found nothing as expected\n");

	return 0;
}

static int test_bits_maps() {
	// Build a tree containing a bits-map section and ensure everything can be found
	const type_node_t node0 = {
		.node_type=leaf, .value={
			.leaf_node={0}
		}
	};
	const type_node_t node1 = {
		.node_type=leaf, .value={
			.leaf_node={1}
		}
	};
	const type_node_t node2 = {
		.node_type=leaf, .value={
			.leaf_node={2}
		}
	};
	const type_node_t node3 = {
		.node_type=leaf, .value={
			.leaf_node={3}
		}
	};

	const bitsmap_elem_t table[] = {
		{.bits = 0x40, .bitslen = 4, .value=&node0},
		{.bits = 0x50, .bitslen = 4, .value=&node1},
		{.bits = 0x60, .bitslen = 4, .value=&node2},
		{.bits = 0x70, .bitslen = 4, .value=&node3}
	};
	const bitsmap_node_t bitsmap_node = {.last_index = 4, .table = table};
	const type_node_t type_node = {.node_type = bits_map, .value={.bitsmap_node=bitsmap_node}};

	const unsigned char path0[] = {0x41, 1, 2};
	const leaf_node_t *leafNode = _macsearch(&type_node, path0, 3);
	if(leafNode == NULL) {
		return 1;
	}

	const unsigned char path1[] = {0x51, 5, 6};
	leafNode = _macsearch(&type_node, path1, 3);
	if(leafNode == NULL) {
		return 1;
	}

	const unsigned char path2[] = {0x61};
	leafNode = _macsearch(&type_node, path2, 1);
	if(leafNode == NULL) {
		return 1;
	}

	const unsigned char path3[] = {0x71};
	leafNode = _macsearch(&type_node, path3, 1);
	if(leafNode == NULL) {
		return 1;
	}

	return 0;
}

int main(int argc, char **argv) {

	fprintf(stderr, "leaf=%ld\n", sizeof(leaf));

	if(argc < 2) {
		fprintf(stderr, "wrong # args, try %s test-name\n", argv[0]);
		return 1;
	}

	const char *testName = argv[1];
	if(strcmp(testName,"test_all_entries") == 0) {
		// Walk every leaf on the tree, and test that searching for it's MAC finds the same leaf
		const int leafCount = macwalk(test_leaf);
		printf("leaves=%d, failures=%d\n", leafCount, failCount);

		return failCount;
	}

	if(strcmp(testName,"test_bits_maps") == 0) {
		return test_bits_maps();
	}

	if(strcmp(testName, "test_partial_match") == 0) {
		return test_partial_match();
	}

	fprintf(stderr, "Unknown test \"%s\"\n", testName);
	return 1;
}
