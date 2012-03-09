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
#import "CCBWriterInternal.h"
#import "ResourceManager.h"

@implementation TexturePropertySetter

+ (void) setSpriteFrameForNode:(CCNode*)node andProperty:(NSString*) prop withFile:(NSString*)spriteFile andSheetFile:(NSString*)spriteSheetFile
{
    NSString* assetsPath = [[ResourceManager sharedManager] assetsPath];
    CCSpriteFrame* spriteFrame = NULL;
    
    if (spriteSheetFile && ![spriteSheetFile isEqualToString:@""] && ![spriteSheetFile isEqualToString:kCCBUseRegularFile]
        && spriteFile && ![spriteFile isEqualToString:@""])
    {
        // Load the sprite sheet and get the frame
        @try
        {
            // Convert to absolute path
            spriteSheetFile = [NSString stringWithFormat:@"%@/%@", assetsPath, spriteSheetFile];
            
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
        NSString* fileName = [NSString stringWithFormat:@"%@/%@", assetsPath, spriteFile];
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

+ (void) setTextureForNode:(CCNode*)node andProperty:(NSString*) prop withFile:(NSString*) spriteFile
{
    
    NSString* assetsPath = [[ResourceManager sharedManager] assetsPath];
    CCTexture2D* texture = NULL;
    
    if (spriteFile && ![spriteFile isEqualToString:@""])
    {
        @try
        {
            NSString* fileName = [NSString stringWithFormat:@"%@/%@", assetsPath, spriteFile];
            texture = [[CCTextureCache sharedTextureCache] addImage:fileName];
        }
        @catch (NSException *exception)
        {
            texture = NULL;
        }
    }
    
    if (!texture) texture = [[CCTextureCache sharedTextureCache] addImage:@"missing-texture.png"];
    
    [node setValue:texture forKey:prop];
}

+ (void) setFontForNode:(CCNode*)node andProperty:(NSString*) prop withFile:(NSString*) fontFile
{
    // TODO: Add error check!
    NSString* assetsPath = [[ResourceManager sharedManager] assetsPath];
    
    NSString* absPath = NULL;
    
    if (!fontFile || [fontFile isEqualToString:@""])
    {
        absPath = @"missing-font.fnt";
    }
    else
    {
        absPath = [NSString stringWithFormat:@"%@/%@", assetsPath, fontFile];
    }
    
    [node setValue:absPath forKey:prop];
}

+ (NSString*) fontForNode:(CCNode*)node andProperty:(NSString*) prop
{
    NSString* fntFile = [node valueForKey:prop];
    if ([fntFile isEqualToString:@"missing-font.fnt"]) return NULL;
    return [fntFile lastPathComponent];
}

@end
