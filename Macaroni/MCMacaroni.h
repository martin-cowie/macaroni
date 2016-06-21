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

@interface MCMacaroni : NSObject

-(NSData*) dottedQuad2macAddress: (NSString*)ip;

-(NSData*) ip2macAddress:(in_addr_t) ipAddress;

-(NSArray<MCCacheEntry*>*)getCache;

@end



#endif /* MacFinder_h */

