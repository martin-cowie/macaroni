//
//  EtherManufacturer.m
//  SSDP Browser
//
//  Created by Martin Cowie on 09/02/2016.
//  Copyright © 2016 ACME. All rights reserved.
//

#import "MCEtherManufacturer.h"

static NSMutableDictionary<NSData*, MCEtherManufacturer*> *manufacturerTable = nil;

@implementation MCEtherManufacturer {
    NSData *_macBytes;
    unsigned int _macMask;
    NSString *_manuName;
    NSString *_manuDescription;
}

+(void) initialize {
#   define MANUF(BYTES, BYTES_LEN, MASK, NAME, DESCRIPTION) \
        [[MCEtherManufacturer alloc] initWithBytes:[NSData dataWithBytes:(BYTES) length:(BYTES_LEN)] mask:(MASK) manufacturer:(NAME) description:(DESCRIPTION)]
    NSArray *manufacturerList = [[NSArray alloc] initWithObjects:
#       include "manuf.m"
        nil];


    manufacturerTable = [[NSMutableDictionary alloc] init];

    // TODO: build tables for each mask size

    for(MCEtherManufacturer *manufacturer in manufacturerList) {
        if(manufacturer.macMask == 24) {
            manufacturerTable[manufacturer.macBytes] = manufacturer;
        }
    }
    NSLog(@"Indexed %d entries", (int)manufacturerTable.count);
}


+(MCEtherManufacturer*) findManufacturer:(NSData *)macAddress {

    // Keeping things simple - take bytes [0..2] and look them up in the table
    NSData *key = [macAddress subdataWithRange:NSMakeRange(0, 3)];
    return [manufacturerTable objectForKey:key];
}

-(id)initWithBytes:(NSData*)macBytes mask:(unsigned int)macMask manufacturer:(NSString*)name description:(NSString*)description {
    if( self = [super init]) {
        _macBytes = macBytes;
        _macMask = macMask;
        _manuName = name;
        _manuDescription = description;
    }
    return self;
}

-(NSString *) description {
    return [NSString stringWithFormat:@"<%@, bytes=%@, name=\"%@\", description=\"%@\">",
            self.class.description, _macBytes, _manuName, _manuDescription];
}

@end
