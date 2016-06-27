//
//  MacFinder.h
//  SSDP Browser
//
//  Created by Martin Cowie on 06/02/2016.
//  Copyright © 2016 ACME. All rights reserved.
//

#ifndef MacFinder_h
#define MacFinder_h
#import <Foundation/Foundation.h>

@class MCEtherManufacturer, MCCacheEntry;

/**
 * Gathered features to retrieve the IPv4 addresses for a known IP address.
 */
@interface MCMacaroni : NSObject

/**
 * Fetch the MAC address for a known IPv4 address
 * @param ip Dotted quad formatted IP address, e.g. 172.16.1.2
 * @return nil if the IP address is misformatted or is not present in the MAC address cache.
 */
-(NSData*) dottedQuad2macAddress: (NSString*)ip;

/**
 * Fetch the MAC address for a known IPv4 address
 * @param ipAddress base type for internet address
 * @return nil if ipAddress is not present in the MAC address cache.
 */
-(NSData*) ip2macAddress:(in_addr_t) ipAddress;

/**
 * Retrieve the MAC address cache from the OS.
 */
-(NSArray<MCCacheEntry*>*)getCache;

@end



#endif /* MacFinder_h */

