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

@implementation InspectorTexture

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
