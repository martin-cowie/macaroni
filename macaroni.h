#ifndef _MACARONI_H
#define _MACARONI_H 1

#define PACK __attribute__((packed))

/* Leaf nodes */
typedef struct PACK {
	short unsigned int description;
} leaf_node_t;

typedef void (*node_func_t)(const leaf_node_t *leaf, unsigned char *mac, unsigned char macLen);
extern int macwalk(node_func_t node_func);

extern const char *macsearch(const unsigned char *macBytes, const unsigned char macBytesLen);

#endif
