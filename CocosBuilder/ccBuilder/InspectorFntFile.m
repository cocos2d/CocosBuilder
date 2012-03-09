//
//  InspectorFntFile.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorFntFile.h"
#import "TexturePropertySetter.h"
#import "CCBGlobals.h"
#import "ResourceManager.h"
#import "ResourceManagerUtil.h"
#import "CocosBuilderAppDelegate.h"

@implementation InspectorFntFile

- (void) willBeAdded
{
    // Setup menu
    NSString* fnt = [TexturePropertySetter fontForNode:selection andProperty:propertyName];
    [ResourceManagerUtil populateResourcePopup:popup resType:kCCBResTypeBMFont allowSpriteFrames:NO selectedFile:fnt selectedSheet:NULL target:self];
}

- (void) selectedResource:(id)sender
{
    [[[CCBGlobals globals] appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    id item = [sender representedObject];
    
    // Fetch info about the sprite name
    NSString* fntFile = NULL;
    
    if ([item isKindOfClass:[RMResource class]])
    {
        RMResource* res = item;
        
        if (res.type == kCCBResTypeBMFont)
        {
            fntFile = [ResourceManagerUtil relativePathFromAbsolutePath:res.filePath];
            [ResourceManagerUtil setTitle:fntFile forPopup:popup];
        }
    }
    
    // Set the properties and sprite frames
    if (fntFile)
    {
        [TexturePropertySetter setFontForNode:selection andProperty:propertyName withFile:fntFile];
    }
    
    [self updateAffectedProperties];
}

@end
