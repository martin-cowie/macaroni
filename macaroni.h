#ifndef _MACARONI_H
#define _MACARONI_H

/* Leaf nodes */
struct type_node_t;

#define PACK __attribute__((packed))

typedef struct PACK {
	short int line_number;
	short unsigned int short_description;
	short unsigned int long_description;
} leaf_node_t;

/* Contiguous nodes */
typedef struct PACK {
	unsigned char first_index;
	unsigned char last_index; //TODO: need a better name - this is valueCount -1
	const struct type_node_t **values;
} contiguous_node_t;

/* Indexed nodes */
typedef struct PACK {
	unsigned char index;
	const struct type_node_t *value;
} index_elem_t;

typedef struct PACK {
	unsigned char last_index; /* table_length -1 */
	const index_elem_t* table;
} index_node_t;

/* Type node */
typedef struct PACK type_node_t {
	enum {index, contiguous, leaf} node_type;
	union {
		index_node_t index_node;
		contiguous_node_t contiguous_node;
		leaf_node_t leaf_node;
	} value;
#	if(DEBUG)
	unsigned short id;
#	endif
} type_node_t;


typedef void (*node_func_t)(const leaf_node_t *leaf, unsigned char *mac, unsigned char macLen);

extern int macwalk(const type_node_t *node, node_func_t node_func, unsigned char *path, int pathLen);
extern const leaf_node_t *macsearch(const unsigned char *macBytes, const unsigned char macBytesLen);


#endif