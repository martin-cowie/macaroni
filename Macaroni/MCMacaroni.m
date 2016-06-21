//
//  MacFinder.m
//  SSDP Browser
//
//  Created by Martin Cowie on 06/02/2016.
//  Copyright © 2016 ACME. All rights reserved.
//


#include <sys/param.h>
#include <sys/file.h>
#include <sys/socket.h>
#include <sys/sysctl.h>

#include <net/if.h>
#include <net/if_dl.h>
#include <net/if_types.h>
#include <net/route.h>

#include <netinet/if_ether.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include <err.h>
#include <errno.h>
#include <netdb.h>

#include <paths.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#import "MCCommon.h"
#import "MCMacaroni.h"
#import "MCCacheEntry.h"
#import "MCEtherManufacturer.h"

#import "NSData+MACAddress.h"

int mib[6] = {CTL_NET, PF_ROUTE, 0, AF_INET, NET_RT_FLAGS, RTF_LLINFO};

@implementation MCMacaroni

typedef struct {
    size_t size;
    void *base;
} blob_t;


#define GET_ARP_CACHE ({\
    blob_t result;\
    if (sysctl(mib, 6, NULL, &result.size, NULL, 0) < 0)\
        err(1, "route-sysctl-estimate");\
    if ((result.base = alloca(result.size)) == NULL)\
        err(1, "alloca");\
    if (sysctl(mib, 6, result.base, &result.size, NULL, 0) < 0)\
        err(1, "actual retrieval of routing table");\
    result;\
})

-(NSData*) ip2macAddress:(in_addr_t) ipAddress {
    const blob_t table = GET_ARP_CACHE;

    // Iterate across the table, looking for a match
    const char *limit = table.base + table.size;
    struct rt_msghdr *rtm;

    for (const char *cursor = table.base; cursor < limit; cursor += rtm->rtm_msglen) {
        rtm = (struct rt_msghdr *)cursor;
        struct sockaddr_inarp *sin = (struct sockaddr_inarp *)(rtm + 1);
        struct sockaddr_dl *sdl = (struct sockaddr_dl *)(sin + 1);

        if (ipAddress == sin->sin_addr.s_addr) {
            const u_char *cp = (const u_char*)LLADDR(sdl);
            return [NSData dataWithBytes:cp length:6];
        }
    }
    return nil;
}

-(NSData*) dottedQuad2macAddress: (NSString*)ipStr {

    in_addr_t ipAddress;
    if (0 > inet_pton(AF_INET, ipStr.UTF8String, &ipAddress)) {
        return nil;
    }

    return [self ip2macAddress:ipAddress];
}

-(NSArray<MCCacheEntry*>*)getCache {
    NSMutableArray *result = [NSMutableArray new];
    const blob_t table = GET_ARP_CACHE;

    // Iterate across the table, looking for a match
    const char *limit = table.base + table.size;
    struct rt_msghdr *rtm;

    for (const char *cursor = table.base; cursor < limit; cursor += rtm->rtm_msglen) {
        rtm = (struct rt_msghdr *)cursor;
        struct sockaddr_inarp *sin = (struct sockaddr_inarp *)(rtm + 1);
        struct sockaddr_dl *sdl = (struct sockaddr_dl *)(sin + 1);

        const char *macAddressBytes = LLADDR(sdl);

        char presBuff[INET_ADDRSTRLEN];
        inet_ntop(AF_INET, &(sin->sin_addr), presBuff, ARRAY_LEN(presBuff) -1);
        NSString *presString = [NSString stringWithCString:presBuff encoding:NSASCIIStringEncoding];

        MCCacheEntry *cacheEntry = [[MCCacheEntry alloc] initWith:presString
                                                       macAddress:[NSData dataWithBytes:macAddressBytes length:6]];
        [result addObject:cacheEntry];
    }
    return result;
}

@end