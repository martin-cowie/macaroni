#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "macaroni.h"
#include "macaroni_internal.h"

#define BUILD_MAC(RESULT,PATH,LEN,MACBYTE) \
    unsigned char RESULT[LEN +1]; \
    memcpy(RESULT, PATH, LEN); \
    RESULT[LEN] = MACBYTE;


int _macwalk(const type_node_t *node, row_func_t node_func, unsigned char *path, int pathLen) {
    int result = 0;
    switch(node->node_type) {
        case leaf: {
            const char *description = stringTable[node->value.leaf_node.description];
            node_func(description, path, pathLen);
            return result+1;
        }

        case byte_map:
            for(int i=0; i< node->value.bytemap_node.last_index +1; i++) {
                const bytemap_elem_t *byteMapElem = node->value.bytemap_node.table + i;
                BUILD_MAC(newPath, path, pathLen, byteMapElem->byte);
                result += _macwalk(node->value.bytemap_node.table[i].value, node_func, newPath, 1 + pathLen);
            }
            return result;

        case bits_map:
            for(int i=0; i< node->value.bitsmap_node.last_index +1; i++) {
                const bitsmap_elem_t *bitsMapElem = node->value.bitsmap_node.table + i;
                BUILD_MAC(newPath, path, pathLen, bitsMapElem->bits); //TODO: shave bits - afix the qualifier
                result += _macwalk(node->value.bitsmap_node.table[i].value, node_func, newPath, 1 + pathLen);
            }
            return result;

        case contiguous:
            for(int i=0; i< node->value.contiguous_node.last_index +1; i++) {
                const struct type_node_t *childNode = node->value.contiguous_node.values[i];
                unsigned int indexValue = i + node->value.contiguous_node.first_index;
                BUILD_MAC(newPath, path, pathLen, indexValue);
                result += _macwalk(childNode, node_func, newPath, 1 + pathLen);
            }
            return result;

        default:
            fprintf(stderr, "Unknown node type: %d\n", node->node_type);
            abort();
    }
}

int macwalk(row_func_t node_func) {
    return _macwalk(root_node, node_func, NULL, 0);
}


static const unsigned char bsearchThreshold = 10;

static int compareElems(const void *keyPtr, const void *elemPtr) {
    const unsigned char key = *(const unsigned char *)keyPtr;
    const bytemap_elem_t *bytemap_elem = (const bytemap_elem_t *)elemPtr;

    return key - bytemap_elem->byte;
}

const leaf_node_t*
_macsearch(const type_node_t *node, const unsigned char *macBytes, const signed char macBytesLen) {

    if(0 > macBytesLen) {
        return NULL;
    }

    switch(node->node_type) {
        case leaf:
            return &node->value.leaf_node;

        case byte_map: {
            const unsigned char macByte = macBytes[0];
            const bytemap_node_t *bytesmap_node = &node->value.bytemap_node;

            if(bytesmap_node->last_index > bsearchThreshold) {
                const bytemap_elem_t *bytemap_elem = bsearch((const void *)&macByte,
                                                         (const void *)bytesmap_node->table,
                                                         bytesmap_node->last_index+1,
                                                         sizeof(bytemap_elem_t), compareElems);
                if (NULL == bytemap_elem) {
                    return NULL;
                }
                return _macsearch(bytemap_elem->value, macBytes+1, macBytesLen -1);
            } else {
                for(int i=0; i< bytesmap_node->last_index+1; i++) {
                    const bytemap_elem_t *bytemap_elem = bytesmap_node->table + i;

                    if (bytemap_elem->byte == macByte) {
                        /* step into this branch*/
                        return _macsearch(bytemap_elem->value, macBytes +1, macBytesLen -1);
                    }
                }
                return NULL;
            }
        }

        case bits_map: {
            /* iterate across the map, plain & simple */
            const unsigned char macByte = macBytes[0];
            const bitsmap_node_t *bitsmap_node = &node->value.bitsmap_node;
            for(int i=0; i< bitsmap_node->last_index+1; i++) {
                // Compare masked macByte against the values in the table
                const char bitslen = bitsmap_node->table[i].bitslen;
                const char bits = bitsmap_node->table[i].bits;

                if (bitslen == 8) {
                    /* special non-special case */
                    if (bits == macByte) {
                        return _macsearch(bitsmap_node->table[i].value, macBytes+1, macBytesLen -1);
                    }
                } else {
                    const char mask = ((1 << bitslen) -1) << (8 - bitslen);
                    if (bits == (macByte & mask)) {
                        return _macsearch(bitsmap_node->table[i].value, macBytes+1, macBytesLen -1);
                    }
                }
            }
        }

        case contiguous: {
            const unsigned char macByte = macBytes[0];
            const contiguous_node_t *contiguous_node = &node->value.contiguous_node;
            if (macByte >= contiguous_node->first_index &&
                macByte <= contiguous_node->first_index + contiguous_node->last_index) {
                const type_node_t *type_node = contiguous_node->values[macByte - contiguous_node->first_index];
                return _macsearch(type_node, macBytes +1, macBytesLen -1);
            }
            return NULL;
        }

        default:
            fprintf(stderr, "Unexpected node_type=%02X\n", node->node_type);
            abort();
    }
}

const char *
macsearch(const unsigned char *macBytes, const unsigned char macBytesLen) {
	const leaf_node_t *node = _macsearch(root_node, macBytes, macBytesLen);
    return (node != NULL /*&& node->node_type == leaf */) ? stringTable[node->description] : NULL;
}

