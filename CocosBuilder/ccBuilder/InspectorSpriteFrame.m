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

@implementation InspectorSpriteFrame

@synthesize assetsImgList;

- (void) populateImgList:(NSString*)ssf
{
    CocosBuilderAppDelegate* ad = [[CCBGlobals globals] appDelegate];
    
    if (!ssf || [ssf isEqualToString:kCCBUseRegularFile])
    {
        self.assetsImgList = resourceManager.assetsImgListFiles;
    }
    else
    {
        self.assetsImgList = [CCBSpriteSheetParser listFramesInSheet:ssf assetsPath:ad.assetsPath];
    }
}

- (id) initWithSelection:(CCNode *)s andPropertyName:(NSString *)pn andDisplayName:(NSString *)dn andExtra:(NSString *)e
{
    self = [super initWithSelection:s andPropertyName:pn andDisplayName:dn andExtra:e];
    if (!self) return NULL;
    
    //NSString* sf = self.spriteFile;
    NSString* ssf = self.spriteSheetFile;
    
    //self.assetsImgList = [NSMutableArray array];
    [self populateImgList:ssf];
    
    self.spriteSheetFile = ssf;
    //self.spriteFile = sf;
    
    return self;
}

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
    
    if (!propValue) propValue = kCCBUseRegularFile;
    
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
}

@end
