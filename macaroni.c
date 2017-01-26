#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "macaroni.h"

#define BUILD_MAC(RESULT,PATH,LEN,MACBYTE) \
    unsigned char RESULT[LEN +1]; \
    memcpy(RESULT, PATH, LEN); \
    RESULT[LEN] = MACBYTE;

/* Exports from mac_tree.c */
extern const type_node_t *root_node;
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

int macwalk(const type_node_t *node, node_func_t node_func, unsigned char *path, int pathLen) {

    int result = 0;
    switch(node->node_type) {
        case leaf:
            node_func(&node->value.leaf_node, path, pathLen);
            return result+1;

        case index_map:
            for(int i=0; i< node->value.index_node.last_index +1; i++) {
                const index_elem_t *indexElem = node->value.index_node.table + i;
                BUILD_MAC(newPath, path, pathLen, indexElem->index);
                result += macwalk(node->value.index_node.table[i].value, node_func, newPath, 1 + pathLen);
            }
            return result;

        case contiguous:
            for(int i=0; i< node->value.contiguous_node.last_index +1; i++) {
                const struct type_node_t *childNode = node->value.contiguous_node.values[i];
                unsigned int indexValue = i + node->value.contiguous_node.first_index;
                BUILD_MAC(newPath, path, pathLen, indexValue);
                result += macwalk(childNode, node_func, newPath, 1 + pathLen);
            }
            return result;

        default:
            fprintf(stderr, "Unknown node type: %d\n", node->node_type);
            abort();
    }
}

static const unsigned char bsearchThreshold = 10;

static int compareElems(const void *keyPtr, const void *elemPtr) {
    const unsigned char key = *(const unsigned char *)keyPtr;
    const index_elem_t *index_elem = (const index_elem_t *)elemPtr;

#   if (DEBUG)
    fprintf(stderr, "Comparing key %02X with element %02X\n", key, index_elem->index);
#   endif
    return key - index_elem->index;
}

static const leaf_node_t*
_macsearch(const type_node_t *node, const unsigned char *macBytes, const unsigned char macBytesLen) {

    switch(node->node_type) {
        case leaf:
            if (macBytesLen != 0) {
                fprintf(stderr, "Found a leaf, with non zero path remaining\n");
                abort();
            }
            return &node->value.leaf_node;

        case index_map: {
            const unsigned char macByte = macBytes[0];
            const index_node_t *index_node = &node->value.index_node;

#           if (DEBUG)
            fprintf(stderr, "Searching index node %d for macByte %02X\n", node->id, macByte);
#           endif

            if(index_node->last_index > bsearchThreshold) {
#               if (DEBUG)
                fprintf(stderr, "Seeking key %02X in table of %d elements\n", macByte, index_node->last_index+1);
#               endif
                const index_elem_t *index_elem = bsearch((const void *)&macByte,
                                                         (const void *)index_node->table,
                                                         index_node->last_index+1,
                                                         sizeof(index_elem_t), compareElems);
                if (NULL == index_elem) {
                    return NULL;
                }
                return _macsearch(index_elem->value, macBytes+1, macBytesLen -1);
            } else {
                for(int i=0; i< index_node->last_index+1; i++) {
                    const index_elem_t *index_elem = index_node->table + i;

                    if (index_elem->index == macByte) {
                        /* step into this branch*/
                        return _macsearch(index_elem->value, macBytes +1, macBytesLen -1);
                    }
                }
                return NULL;
            }

        }

        case contiguous: {
            const unsigned char macByte = macBytes[0];
            const contiguous_node_t *contiguous_node = &node->value.contiguous_node;
#           if (DEBUG)
            fprintf(stderr, "Searching contiguous node %d for macByte %02X\n", node->id, macByte);
#           endif
            if (macByte >= contiguous_node->first_index &&
                macByte <= contiguous_node->first_index + contiguous_node->last_index) {
                const type_node_t *type_node = contiguous_node->values[macByte - contiguous_node->first_index];
                return _macsearch(type_node, macBytes +1, macBytesLen -1);
            }
            return NULL;
        }

        default:
            //FIXME: something better
            fprintf(stderr, "Unexpected node_type=%02X\n", node->node_type);
            abort();
    }
}

const leaf_node_t *
macsearch(const unsigned char *macBytes, const unsigned char macBytesLen) {
	return _macsearch(root_node, macBytes, macBytesLen);
}

