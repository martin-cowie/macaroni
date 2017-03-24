//
//  EtherManufacturer.m
//  SSDP Browser
//
//  Created by Martin Cowie on 09/02/2016.
//  Copyright © 2016 ACME. All rights reserved.
//

#import "MCEtherManufacturer.h"
#define MAX_MASK_SIZE 48

@implementation MCEtherManufacturer {
    NSData *_macBytes;
    unsigned int _macMask;
    NSString *_manuName;
    NSString *_manuDescription;
}

static NSMutableArray<NSMutableDictionary<NSData*, MCEtherManufacturer*>*> *tablesByMaskSize;

+(void) initialize {
    //TODO: swap for an array?

    NSDate *start = [NSDate date];
/*
    NSArray *manufacturerList = [[NSArray alloc] initWithObjects:
#   define MANUF(BYTES, BYTES_LEN, MASK, NAME, DESCRIPTION) \
        [[MCEtherManufacturer alloc] initWithBytes:[NSData dataWithBytes:(BYTES) length:(BYTES_LEN)] mask:(MASK) manufacturer:(NAME) description:(DESCRIPTION)],
#       include "manuf.m"
        nil];
*/
    NSMutableArray *manufacturerList = [[NSMutableArray alloc] init];
#   define MANUF(BYTES, BYTES_LEN, MASK, NAME, DESCRIPTION) \
        [manufacturerList addObject:[[MCEtherManufacturer alloc] initWithBytes:[NSData dataWithBytes:(BYTES) length:(BYTES_LEN)] mask:(MASK) manufacturer:(NAME) description:(DESCRIPTION)]];
#   include "manuf.m"


    NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    NSLog(@"Loaded %lu ether records in %f seconds", manufacturerList.count, timeInterval);

    //Build tables for each mask size
    int discreteMaskSizes = 0;
    NSMutableDictionary<NSData*, MCEtherManufacturer*> *tables[1+MAX_MASK_SIZE] = {NULL};
    for(MCEtherManufacturer *manufacturer in manufacturerList) {
        const int maskSize = manufacturer.macMask;
        NSMutableDictionary<NSData*, MCEtherManufacturer*> const *table = tables[maskSize];
        if(table == NULL) {
            table = tables[maskSize] = [[NSMutableDictionary alloc] init];
            discreteMaskSizes++;
        }
        table[manufacturer.macBytes] = manufacturer;
    }

    // Collapse tables into sorted array, largest mask first;
    tablesByMaskSize = [[NSMutableArray alloc] init];
    for(int i = MAX_MASK_SIZE; i >= 0; i--) {
        if(NULL != tables[i]) {
            NSLog(@"Indexing table with mask size %d", i);
            [tablesByMaskSize addObject:tables[i]];
        }
    }

    NSLog(@"Indexed %d discrete tables", (int)tablesByMaskSize.count);
}


+(MCEtherManufacturer*) findManufacturer:(NSData *)macAddress {

    for(NSMutableDictionary<NSData*, MCEtherManufacturer*> *dict in tablesByMaskSize) {
        const int maskSize = dict.allValues[0].macMask;
        NSData* const key = [macAddress subdataWithRange:NSMakeRange(0, maskSize/8)]; //TODO: doesn't handle nybbles
        MCEtherManufacturer* const result = dict[key];
        if(result != nil) {
            return result;
        }
    }
    return nil;
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
    return [NSString stringWithFormat:@"<%@, bytes=%@, maskSize=%d, name=\"%@\", description=\"%@\">",
            self.class.description, _macBytes, _macMask, _manuName, _manuDescription];
}

@end
