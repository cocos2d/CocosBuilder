//
//  CCBPCCBFile.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBPCCBFile.h"
#import "ResourceManager.h"
#import "CCBReaderInternal.h"
#import "CCBGlobals.h"
#import "CCBDocument.h"
#import "CocosBuilderAppDelegate.h"

@implementation CCBPCCBFile

@synthesize ccbFile;

- (void) setCcbFile:(NSString *)cf
{
    [ccbFile release];
    ccbFile = [cf retain];
    
    CCBGlobals* g = [CCBGlobals globals];
    CocosBuilderAppDelegate* ad = [g appDelegate];
    
    [self removeAllChildrenWithCleanup:YES];
    
    // Get absolut file path to ccb file
    NSString* filePath = [[ResourceManager sharedManager] toAbsolutePath:cf];
    
    // Check that it's not the current document (or we get an inifnite loop)
    if ([ad.currentDocument.fileName isEqualToString:filePath]) return;
    
    // Load document dictionary
    NSMutableDictionary* doc = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    
    // Verify doc type and version
    if (![[doc objectForKey:@"fileType"] isEqualToString:@"CocosBuilder"]) return;
    if ([[doc objectForKey:@"fileVersion"] intValue] != kCCBFileFormatVersion) return;
    
    // Parse the node graph
    CCNode* nodeGraph = [CCBReaderInternal nodeGraphFromDictionary:[doc objectForKey:@"nodeGraph"]];
    
    // Add the node graph as a child
    [self addChild:nodeGraph];
}

@end
