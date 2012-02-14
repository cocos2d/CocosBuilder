//
//  InspectorTexture.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorTexture.h"
#import "NodeInfo.h"
#import "CCBGlobals.h"
#import "CocosScene.h"
#import "CocosBuilderAppDelegate.h"

@implementation InspectorTexture

- (void) setSpriteFile:(NSString *)spriteFile
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    CocosBuilderAppDelegate* ad = [[CCBGlobals globals] appDelegate];
    
    [cs setExtraProp:spriteFile forKey:@"spriteFile" andNode:selection];
    
    NSString* fileName = [NSString stringWithFormat:@"%@%@", ad.assetsPath, spriteFile];
    CCTexture2D* texture = [[CCTextureCache sharedTextureCache] addImage:fileName];
    
    CGRect bounds = CGRectMake(0, 0, texture.contentSize.width, texture.contentSize.height);
    
    [self setPropertyForSelection:[CCSpriteFrame frameWithTexture:texture rect:bounds]];
}

- (NSString*) spriteFile
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [cs extraPropForKey:@"spriteFile" andNode:selection];
}

@end
