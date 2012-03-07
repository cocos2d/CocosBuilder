//
//  InspectorTexture.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorTexture.h"
#import "CCBGlobals.h"
#import "TexturePropertySetter.h"
#import "ResourceManager.h"
#import "ResourceManagerUtil.h"
#import "CocosBuilderAppDelegate.h"

@implementation InspectorTexture

- (void) willBeAdded
{
    // Setup menu
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
    NSString* sf = [cs extraPropForKey:propertyName andNode:selection];
    
    [ResourceManagerUtil populateTexturePopup:popup allowSpriteFrames:NO selectedFile:sf selectedSheet:NULL target:self];
}


- (void) selectedTexture:(id)sender
{
    [[[CCBGlobals globals] appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    id item = [sender representedObject];
    
    // Fetch info about the sprite name
    NSString* sf = NULL;
    
    if ([item isKindOfClass:[RMResource class]])
    {
        RMResource* res = item;
        
        if (res.type == kCCBResTypeImage)
        {
            sf = [ResourceManagerUtil relativePathFromAbsolutePath:res.filePath];
            [ResourceManagerUtil setTitle:sf forPopup:popup];
        }
    }
    
    // Set the properties and sprite frames
    if (sf)
    {
        CocosScene* cs = [[CCBGlobals globals] cocosScene];
        [cs setExtraProp:sf forKey:propertyName andNode:selection];
        [TexturePropertySetter setTextureForNode:selection andProperty:propertyName withFile:sf];
    }
    
    [self updateAffectedProperties];
}


- (void) setSpriteFile:(NSString *)spriteFile
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
    [cs setExtraProp:spriteFile forKey:propertyName andNode:selection];
    
    [TexturePropertySetter setTextureForNode:selection andProperty:propertyName withFile:spriteFile];
    
    [self updateAffectedProperties];
}

- (NSString*) spriteFile
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [cs extraPropForKey:propertyName andNode:selection];
}

@end
