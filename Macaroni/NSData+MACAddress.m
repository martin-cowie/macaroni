//
//  NSData+MACAddresses.m
//  Pods
//
//  Created by Martin Cowie on 14/02/2016.
//
//

#import "NSData+MACAddress.h"

@implementation NSData(MACAddress)

-(NSString*) formatAsMacAddress {
    const unsigned char *bytes = (unsigned char *)self.bytes;
    if (bytes==nil) {
        return nil;
    }
    return [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5]];
}

@end

