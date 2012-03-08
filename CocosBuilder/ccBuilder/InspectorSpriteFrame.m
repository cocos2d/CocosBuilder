//
//  InspectorTexture.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorSpriteFrame.h"
#import "NodeInfo.h"
#import "CCBGlobals.h"
#import "CocosScene.h"
#import "CocosBuilderAppDelegate.h"
#import "TexturePropertySetter.h"
#import "CCBWriterInternal.h"
#import "CCBSpriteSheetParser.h"
#import "ResourceManagerUtil.h"
#import "ResourceManager.h"

@implementation InspectorSpriteFrame

- (void) willBeAdded
{
    // Setup menu
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
    NSString* sf = [cs extraPropForKey:propertyName andNode:selection];
    NSString* ssf = [cs extraPropForKey:[NSString stringWithFormat:@"%@Sheet", propertyName] andNode:selection];
    
    if ([ssf isEqualToString:kCCBUseRegularFile] || [ssf isEqualToString:@""]) ssf = NULL;
    
    [ResourceManagerUtil populateResourcePopup:popup resType:kCCBResTypeImage allowSpriteFrames:YES selectedFile:sf selectedSheet:ssf target:self];
}

- (void) selectedResource:(id)sender
{
    [[[CCBGlobals globals] appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    id item = [sender representedObject];
    
    // Fetch info about the sprite name
    NSString* sf = NULL;
    NSString* ssf = NULL;
    
    if ([item isKindOfClass:[RMResource class]])
    {
        RMResource* res = item;
        
        if (res.type == kCCBResTypeImage)
        {
            sf = [ResourceManagerUtil relativePathFromAbsolutePath:res.filePath];
            ssf = kCCBUseRegularFile;
            [ResourceManagerUtil setTitle:sf forPopup:popup];
        }
    }
    else if ([item isKindOfClass:[RMSpriteFrame class]])
    {
        RMSpriteFrame* frame = item;
        sf = frame.spriteFrameName;
        ssf = [ResourceManagerUtil relativePathFromAbsolutePath:frame.spriteSheetFile];
        [ResourceManagerUtil setTitle:[NSString stringWithFormat:@"%@/%@",ssf,sf] forPopup:popup];
    }
    
    // Set the properties and sprite frames
    if (sf && ssf)
    {
        CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
        [cs setExtraProp:sf forKey:propertyName andNode:selection];
        [cs setExtraProp:ssf forKey:[NSString stringWithFormat:@"%@Sheet", propertyName] andNode:selection];
    
        [TexturePropertySetter setSpriteFrameForNode:selection andProperty:propertyName withFile:sf andSheetFile:ssf];
    }
    
    [self updateAffectedProperties];
}

@end
