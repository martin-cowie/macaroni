//
//  EtherManufacturer.m
//  SSDP Browser
//
//  Created by Martin Cowie on 09/02/2016.
//  Copyright © 2016 ACME. All rights reserved.
//

#import "MCEtherManufacturer.h"
#import "MCCommon.h"

static NSMutableDictionary<NSData*, MCEtherManufacturer*> *manufacturerTable = nil;


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

@implementation MCEtherManufacturer {
    NSData *_bytes;
    NSString *_manuName;
    NSString *_manuDescription;
}

//TODO: make this compile-time, not runtime.
+(void) initialize {
    manufacturerTable = [[NSMutableDictionary alloc] init];

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
        return;
    }

    NSString *pattern = @"^([0-9A-F]{2}):([0-9A-F]{2}):([0-9A-F]{2})\\s+(\\w+)\\s+#\\s+(.*)$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:0
                                                                             error:&error];
    if (regex==nil) {
        NSLog(@"Cannot build regex: %@", error);
        return;
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
    NSLog(@"Loaded %d entries in %@", (int)manufacturerTable.count, fileName);
}


+(MCEtherManufacturer*) findManufacturer:(NSData *)macAddress {

    // Keeping things simple - take bytes [0..2] and look them up in the table
    NSData *key = [macAddress subdataWithRange:NSMakeRange(0, 3)];
    return [manufacturerTable objectForKey:key];
}

-(id)initWithBytes:(NSData*)bytes manufacturer:(NSString*)name description:(NSString*)description {
    if( self = [super init]) {
        _bytes = bytes;
        _manuName = name;
        _manuDescription = description;
    }
    return self;
}

-(NSString *) description {
    return [NSString stringWithFormat:@"<%@, bytes=%@, name=\"%@\", description=\"%@\">",
            self.class.description, _bytes, _manuName, _manuDescription];
}

@end
