//
//  CCBXCocos2diPhone.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBXCocos2diPhone.h"

@implementation CCBXCocos2diPhone

- (NSString*) extension
{
    NSLog(@"GETTING EXT: ccbios");
    return @"ccbios";
}

- (NSData*) exportDocument:(NSDictionary *)doc
{
    return [NSData data];
}

@end
