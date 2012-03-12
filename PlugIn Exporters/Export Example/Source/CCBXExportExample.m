//
//  CCBXExportExample.m
//  Export Example
//
//  Created by Viktor Lidholt on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBXExportExample.h"

@implementation CCBXExportExample

- (NSString*) extension
{
    return @"ccbExample";
}

- (NSData*) exportDocument:(NSDictionary*)doc flattenPaths:(BOOL)flattenPaths
{
    return [NSPropertyListSerialization dataFromPropertyList:doc format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
}

@end
