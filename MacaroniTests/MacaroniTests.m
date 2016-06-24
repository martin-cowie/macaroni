//
//  MacaroniTests.m
//  MacaroniTests
//
//  Created by Martin Cowie on 14/03/2016.
//  Copyright © 2016 ACME. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Macaroni.h"

@interface MacaroniTests : XCTestCase
@end

//TODO: test each mask size

@implementation MacaroniTests

- (void)testSimple3BytePrefix {
    NSData *someMac = [[NSData alloc] initWithBytes:(unsigned char[]){0x00, 0x00, 0x0F, 1,2,3} length:6];

    MCEtherManufacturer *manuf = [MCEtherManufacturer findManufacturer:someMac];
    XCTAssertNotNil(manuf);
    XCTAssertEqualObjects(manuf.manuName, @"Next");
    XCTAssertEqualObjects(manuf.manuDescription, @"NEXT, INC.");

}

@end
