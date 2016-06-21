//
//  EtherManufacturer.h
//  SSDP Browser
//
//  Created by Martin Cowie on 09/02/2016.
//  Copyright © 2016 ACME. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCEtherManufacturer : NSObject
-(id)initWithBytes:(NSData*)bytes manufacturer:(NSString*)name description:(NSString*)description;

+(MCEtherManufacturer*) findManufacturer:(NSData*)macAddress;

@property(readonly) NSString *manuDescription;
@property(readonly) NSString *manuName;

@end
