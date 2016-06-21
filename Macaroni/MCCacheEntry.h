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

@interface MCCacheEntry : NSObject

-(id)initWith:(NSString*)internetAddress macAddress:(NSData*)macAddress;


@property(readonly) NSString* internetAddress;
@property(readonly) NSData* macAddress;

@end
