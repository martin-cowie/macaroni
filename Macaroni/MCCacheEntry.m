//
//  MCCacheEntry.m
//  Pods
//
//  Created by Martin Cowie on 13/02/2016.
//
//

#import <Foundation/Foundation.h>
#import "MCCacheEntry.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/ip.h>

#import "NSData+MACAddress.h"

@implementation MCCacheEntry {
    NSString* _internetAddress;
    NSData *_macAddress;
}

-(id)initWith:(NSString*)internetAddress macAddress:(NSData*)macAddress {
    if (nil != (self = [super init])) {
        _internetAddress= internetAddress;
        _macAddress = macAddress;
    }

    return self;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<%@, internetAddress=%@, macAddress=%@>", self.class.description, _internetAddress, _macAddress.formatAsMacAddress];
}

@end
