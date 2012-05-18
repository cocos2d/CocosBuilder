//
//  CCBPFileUtils.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBPFileUtils.h"

@implementation CCBPFileUtils

@synthesize ccbDirectoryPath;

- (NSString*) pathForResource:(NSString*)resource ofType:(NSString *)ext inDirectory:(NSString *)subpath
{
    // Check for file in Documents directory
    NSString* resDir = NULL;
    if (subpath && ![subpath isEqualToString:@""])
    {
        resDir = [ccbDirectoryPath stringByAppendingPathComponent:subpath];
    }
    else
    {
        resDir = ccbDirectoryPath;
    }
    
    NSString* fileName = NULL;
    if (ext && ![ext isEqualToString:@""])
    {
        fileName = [resource stringByAppendingPathExtension:ext];
    }
    else
    {
        fileName = resource;
    }
    
    NSString* filePath = [resDir stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSLog(@"RETURNING: %@", filePath);
        return filePath;
    }
    
    // Use default lookup
    return [bundle_ pathForResource:resource ofType:ext inDirectory:subpath];
}

- (void) dealloc
{
    self.ccbDirectoryPath = NULL;
    [super dealloc];
}

@end
