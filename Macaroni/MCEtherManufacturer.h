//
//  EtherManufacturer.h
//  SSDP Browser
//
//  Created by Martin Cowie on 09/02/2016.
//  Copyright © 2016 ACME. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Immutable record of an Ethernet manufacturer.
 */
@interface MCEtherManufacturer : NSObject

/**
 * Initalise an MCEtherManufacturer.
 * @param
 */
-(id)initWithBytes:(NSData*)bytes mask:(unsigned int)macMask manufacturer:(NSString*)name description:(NSString*)description;

/**
 * Find an Ehternet manufacturer
 * @param macAddress MAC address to search for.
 */
+(MCEtherManufacturer*) findManufacturer:(NSData*)macAddress;

/// Optional desscription of the manufacturer
@property(readonly) NSString *manuDescription;

/// Name of the manufacturer
@property(readonly) NSString *manuName;

/// The MAC prefix
@property(readonly) NSData *macBytes;

/// The size in bits of the MAC address prefix
@property(readonly) unsigned int macMask;

@end
