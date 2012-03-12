//
//  CCBXCocos2diPhone.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBXCocos2diPhone.h"
#import "CCBXCocos2diPhoneWriter.h"

@implementation CCBXCocos2diPhone

- (NSString*) extension
{
    return @"ccbi";
}

- (NSData*) exportDocument:(NSDictionary *)doc flattenPaths:(BOOL) flattenPaths
{
    CCBXCocos2diPhoneWriter* writer = [[CCBXCocos2diPhoneWriter alloc] init];
    writer.flattenPaths = flattenPaths;
    [writer writeDocument:doc];
    
    return writer.data;
}

@end
