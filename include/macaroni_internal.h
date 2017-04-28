#ifndef _MACARONI_INTERNAL_H
#define _MACARONI_INTERNAL_H 1

#define PACK __attribute__((packed))

struct type_node_t;

/* Contiguous nodes */
typedef struct PACK {
	unsigned char first_index;
	unsigned char last_index;
	const struct type_node_t **values;
} contiguous_node_t;

/* Bytemap nodes */
typedef struct PACK {
	unsigned char byte;
	const struct type_node_t *value;
} bytemap_elem_t;

typedef struct PACK {
	unsigned char last_index; /* table_length -1 */
	const bytemap_elem_t* table;
} bytemap_node_t;

/* Bitsmap nodes */
typedef struct PACK {
	unsigned char bits;
	unsigned char bitslen;
	const struct type_node_t *value;
} bitsmap_elem_t;

typedef struct PACK {
	unsigned char last_index; /* table_length -1 */
	const bitsmap_elem_t* table;
} bitsmap_node_t;

/* Leaf nodes */
typedef struct PACK {
	short unsigned int description;
} leaf_node_t;

/* Type node */
typedef struct PACK type_node_t {
	enum {byte_map, bits_map, contiguous, leaf} node_type;
	union {
		bytemap_node_t bytemap_node;
		bitsmap_node_t bitsmap_node;
		contiguous_node_t contiguous_node;
		leaf_node_t leaf_node;
	} value;
} type_node_t;

/* Exports from mac_tree.c */
extern const type_node_t *root_node;
extern const char * const stringTable[];

/* Exports from macaroni.h */
extern const leaf_node_t* _macsearch(const type_node_t *node, const unsigned char *macBytes, const char macBytesLen);
extern int _macwalk(const type_node_t *node, row_func_t row_func, unsigned char *path, int pathLen);

#endif

