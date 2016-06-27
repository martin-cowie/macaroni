//
//  NSData+MACAddresses.h
//  Pods
//
//  Created by Martin Cowie on 14/02/2016.
//
//

#import <Foundation/Foundation.h>

/**
 * Category to format NSData as NSString
 */
@interface NSData(MACAddress)

/**
 * Format this NSData, (presumably holding a 6 byte MAC address) as an NSString.
 * Printis each byte as 2byte hex nybble separated by colons.
 */
-(NSString*) formatAsMacAddress;

@end