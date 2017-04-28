#ifndef _MACARONI_H
#define _MACARONI_H 1



typedef void (*row_func_t)(const char *manufacturer, unsigned char *mac, unsigned char macLen);
extern int macwalk(row_func_t node_func);

extern const char *macsearch(const unsigned char *macBytes, const unsigned char macBytesLen);

#endif
