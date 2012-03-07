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

//@synthesize assetsImgList;

- (void) populateImgList:(NSString*)ssf
{
    //CocosBuilderAppDelegate* ad = [[CCBGlobals globals] appDelegate];
    
    /*
    if (!ssf || [ssf isEqualToString:kCCBUseRegularFile])
    {
        self.assetsImgList = resourceManager.assetsImgListFiles;
    }
    else
    {
        self.assetsImgList = [CCBSpriteSheetParser listFramesInSheet:ssf assetsPath:ad.assetsPath];
    }*/
}

- (id) initWithSelection:(CCNode *)s andPropertyName:(NSString *)pn andDisplayName:(NSString *)dn andExtra:(NSString *)e
{
    self = [super initWithSelection:s andPropertyName:pn andDisplayName:dn andExtra:e];
    if (!self) return NULL;
    
    //NSString* sf = self.spriteFile;
    //NSString* ssf = self.spriteSheetFile;
    
    //self.assetsImgList = [NSMutableArray array];
    //[self populateImgList:ssf];
    
    //self.spriteSheetFile = ssf;
    //self.spriteFile = sf;
    
    return self;
}

- (void) willBeAdded
{
    // Setup menu
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
    NSString* sf = [cs extraPropForKey:propertyName andNode:selection];
    NSString* ssf = [cs extraPropForKey:[NSString stringWithFormat:@"%@Sheet", propertyName] andNode:selection];
    
    if ([ssf isEqualToString:kCCBUseRegularFile] || [ssf isEqualToString:@""]) ssf = NULL;
    
    [ResourceManagerUtil populateTexturePopup:popup allowSpriteFrames:YES selectedFile:sf selectedSheet:ssf target:self];
}

- (void) selectedTexture:(id)sender
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

/*
- (void) setSpriteFile:(NSString *)spriteFile
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];

    [cs setExtraProp:spriteFile forKey:propertyName andNode:selection];
    
    [TexturePropertySetter setSpriteFrameForNode:selection andProperty:propertyName withFile:spriteFile andSheetFile:self.spriteSheetFile];
    
    [self updateAffectedProperties];
}

- (NSString*) spriteFile
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [cs extraPropForKey:propertyName andNode:selection];
}

- (void) setSpriteSheetFile:(NSString *)spriteSheetFile
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
    NSString* oldSpriteSheetFile = self.spriteSheetFile;
    
    [self populateImgList:spriteSheetFile];
    
    NSString* propValue = spriteSheetFile;
    
    if (!propValue) propValue = [cs setExtraProp:spriteFile forKey:propertyName andNode:selection];
    
    if (isSetSpriteSheet && ![propValue isEqualToString:oldSpriteSheetFile])
    {
        self.spriteFile = @"";
    }
    
    [cs setExtraProp:propValue forKey:[NSString stringWithFormat:@"%@Sheet", propertyName] andNode:selection];
    
    isSetSpriteSheet = YES;
}

- (NSString*) spriteSheetFile
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [cs extraPropForKey:[NSString stringWithFormat:@"%@Sheet", propertyName] andNode:selection];
}

- (void) dealloc
{
    self.assetsImgList = NULL;
    [super dealloc];
}*/

@end
