//
//  EtherManufacturer.h
//  SSDP Browser
//
//  Created by Martin Cowie on 09/02/2016.
//  Copyright © 2016 ACME. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCEtherManufacturer : NSObject

+(MCEtherManufacturer*) findManufacturer:(NSData*)macAddress;

@property(readonly) NSString *manuDescription;
@property(readonly) NSString *manuName;

@end
