//
//  TexturePropertySetter.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TexturePropertySetter.h"
#import "CocosBuilderAppDelegate.h"
#import "CCBGlobals.h"
#import "CCBWriter.h"

@implementation TexturePropertySetter

+ (void) setTextureForNode:(CCNode*)node andProperty:(NSString*) prop withFile:(NSString*)spriteFile andSheetFile:(NSString*)spriteSheetFile
{
    CocosBuilderAppDelegate* ad = [[CCBGlobals globals] appDelegate];
    CCSpriteFrame* spriteFrame = NULL;
    
    if (spriteSheetFile && ![spriteSheetFile isEqualToString:@""] && ![spriteSheetFile isEqualToString:kCCBUseRegularFile]
        && spriteFile && ![spriteFile isEqualToString:@""])
    {
        // Load the sprite sheet and get the frame
        @try
        {
            // Convert to absolute path
            spriteSheetFile = [NSString stringWithFormat:@"%@%@", ad.assetsPath, spriteSheetFile];
            
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:spriteSheetFile];
            
            spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFile];
        }
        @catch (NSException *exception) {
            spriteFrame = NULL;
        }
    }
    else if (spriteFile && ![spriteFile isEqualToString:@""])
    {
        // Create a sprite frame for the single image file
        NSString* fileName = [NSString stringWithFormat:@"%@%@", ad.assetsPath, spriteFile];
        CCTexture2D* texture = [[CCTextureCache sharedTextureCache] addImage:fileName];
        
        if (texture)
        {
            CGRect bounds = CGRectMake(0, 0, texture.contentSize.width, texture.contentSize.height);
        
            spriteFrame = [CCSpriteFrame frameWithTexture:texture rect:bounds];
        }
    }
    
    if (!spriteFrame)
    {
        // Texture is missing
        CCTexture2D* texture = [[CCTextureCache sharedTextureCache] addImage:@"missing-texture.png"];
        CGRect bounds = CGRectMake(0, 0, texture.contentSize.width, texture.contentSize.height);
        
        spriteFrame = [CCSpriteFrame frameWithTexture:texture rect:bounds] ;
    }

    // Actually set the sprite frame
    [node setValue:spriteFrame forKey:prop];
}

@end
