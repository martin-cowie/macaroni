//
//  MCCacheEntry.h
//  Pods
//
//  Created by Martin Cowie on 13/02/2016.
//
//

#import <Foundation/Foundation.h>
#include <netinet/if_ether.h>
#include <netinet/in.h>

/**
 * Representation of a MAC address cache entry
 */
@interface MCCacheEntry : NSObject

/**
 * Initialise an immutable MCCacheEntry
 * @param internetAddress e.g. 127.0.1.2
 * @param macAddress the 6 byte MAC address
 */
-(id)initWith:(NSString*)internetAddress macAddress:(NSData*)macAddress;

/// The initialised internetAddress property
@property(readonly) NSString* internetAddress;

/// The initialised macAddress property
@property(readonly) NSData* macAddress;

@end
