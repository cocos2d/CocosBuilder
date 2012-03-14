//
//  NodeGraphPropertySetter.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeGraphPropertySetter.h"
#import "CCBGlobals.h"
#import "CocosBuilderAppDelegate.h"
#import "ResourceManager.h"
#import "CCBDocument.h"
#import "CCBReaderInternal.h"

@implementation NodeGraphPropertySetter

+ (void) setNodeGraphForNode:(CCNode*)node andProperty:(NSString*) prop withFile:(NSString*) ccbFileName
{
    CCNode* ccbFile = NULL;
    
    if (ccbFileName && ![ccbFileName isEqualToString:@""])
    {
        CocosBuilderAppDelegate* ad = [[CCBGlobals globals] appDelegate];
    
        // Get absolut file path to ccb file
        ccbFileName = [[ResourceManager sharedManager] toAbsolutePath:ccbFileName];
    
        // Check that it's not the current document (or we get an inifnite loop)
        if (![ad.currentDocument.fileName isEqualToString:ccbFileName])
        {
            // Load document dictionary
            NSMutableDictionary* doc = [NSMutableDictionary dictionaryWithContentsOfFile:ccbFileName];
    
            // Verify doc type and version
            if ([[doc objectForKey:@"fileType"] isEqualToString:@"CocosBuilder"]
                && [[doc objectForKey:@"fileVersion"] intValue] == kCCBFileFormatVersion)
            {
    
                // Parse the node graph
                ccbFile = [CCBReaderInternal nodeGraphFromDictionary:[doc objectForKey:@"nodeGraph"]];
            }
        }
    }
    
    // Set the property
    [node setValue:ccbFile forKey:prop];
}

@end
