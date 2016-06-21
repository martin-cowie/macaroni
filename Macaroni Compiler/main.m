//
//  main.m
//  Macaroni Compiler
//
//  Created by Martin Cowie on 21/06/2016.
//  Copyright © 2016 ACME. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCEtherManufacturer.h"
#import "MCCommon.h"

@interface NSTextCheckingResult(harvestGroups)
-(NSArray<NSString*>*) harvestGroupsFrom:(NSString*)origin;
@end

@implementation NSTextCheckingResult(harvestGroups)
-(NSArray<NSString*>*) harvestGroupsFrom:(NSString*)origin {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (int i=1; i< self.numberOfRanges; i++) {
        NSRange range = [self rangeAtIndex:i];

        [result addObject:[origin substringWithRange:range]];
    }
    return result;
}
@end

@implementation NSString(hexString)
-(int)fromHex {
    unsigned int result;
    NSScanner *scanner = [NSScanner scannerWithString:self];
    return [scanner scanHexInt:&result] ? result : -1;
}
@end


NSDictionary const *compile() {
    NSMutableDictionary const *manufacturerTable = [[NSMutableDictionary alloc] init];

    //Load and parse the Wireshark file
    NSString *fileName = [[NSBundle mainBundle]
                          pathForResource:@"manuf" ofType:@"txt"];

    NSLog(@"Found %@", fileName);

    NSError *error;
    NSString *fileContent = [NSString stringWithContentsOfFile:fileName
                                                      encoding:NSUTF8StringEncoding
                                                         error:&error];
    if (fileContent==nil) {
        NSLog(@"Cannot load %@: %@", fileName, error);
        return nil; //TODO: throw exception
    }

    NSString *pattern = @"^([0-9A-F]{2}):([0-9A-F]{2}):([0-9A-F]{2})\\s+(\\w+)\\s+#\\s+(.*)$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:0
                                                                             error:&error];
    if (regex==nil) {
        NSLog(@"Cannot build regex: %@", error);
        return nil; //TODO: throw exception
    }

    // Tokenise the content, and break out the regex machinery
    NSArray<NSString*> *lines = [fileContent componentsSeparatedByString:@"\n"];
    for(NSString *line in lines) {
        if ([line hasPrefix:@"#"] || line.length == 0) {
            continue;
        }

        const NSRange allOfLine = NSMakeRange(0, line.length);
        // Does it match?
        NSTextCheckingResult *matchingResult;
        if( nil == ( matchingResult = [regex firstMatchInString:line options:0 range:allOfLine] ) ) {

            //            NSLog(@"Cannot parse: %@", line);
            continue;
        }

        // Get the groups
        NSArray<NSString*> *groups = [matchingResult harvestGroupsFrom:line];
        unsigned char rawBytes[] = {
            groups[0].fromHex,
            groups[1].fromHex,
            groups[2].fromHex};
        NSData *key = [NSData dataWithBytes:rawBytes length:ARRAY_LEN(rawBytes)];
        NSString *manuName = groups[3];
        NSString *manuDescription = groups[4];

        MCEtherManufacturer *manuf = [[MCEtherManufacturer alloc] initWithBytes:key
                                                                   manufacturer:manuName
                                                                    description:manuDescription];

        manufacturerTable[key] = manuf;
    }
    NSLog(@"Loaded %d entries from %@", (int)manufacturerTable.count, fileName);
    return manufacturerTable;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        compile();
    }
    return 0;
}
