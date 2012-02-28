//
//  CCBXCocos2diPhoneWriter.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kCCBXTempBufferSize 8
#define kCCBXVersion 1

enum {
    kCCBXFloat0 = 0,
    kCCBXFloat1,
    kCCBXFloatMinus1,
    kCCBXFloat05,
    kCCBXFloatInteger,
    kCCBXFloatFull
};

@interface CCBXCocos2diPhoneWriter : NSObject
{
    NSMutableData* data;
    
    NSMutableArray* propTypes;
    NSMutableDictionary* stringCacheLookup;
    NSMutableArray* stringCache;
    
    char temp[kCCBXTempBufferSize];
    int tempBit;
    int tempByte;
}

@property (nonatomic,readonly) NSMutableData* data;

- (void) writeDocument:(NSDictionary*)doc;

@end
