//
//  AnimationPropertySetter.m
//  CocosBuilder
//
//  Created by Joel Petersen on 2/13/12.
//  Copyright (c) 2012 Zynga. All rights reserved.
//

#import "AnimationPropertySetter.h"
#import "CocosBuilderAppDelegate.h"
#import "CCBGlobals.h"
#import "CCBWriterInternal.h"
#import "ResourceManager.h"

@implementation AnimationPropertySetter

+ (void) setAnimationForNode:(CCNode *)node andProperty:(NSString *)prop withName:(NSString *)animation andFile:(NSString *)animationFile
{
	// hacky.
	// TODO:(JP) Pull
    CCAnimation* pAnimation = NULL;
    
    if (animationFile && ![animationFile isEqualToString:@""] && ![animationFile isEqualToString:kCCBUseRegularFile]
        && animation && ![animation isEqualToString:@""])
    {
        // Load the sprite sheet and get the frame
        @try
        {
            // Convert to absolute path
            animationFile = [[ResourceManager sharedManager] toAbsolutePath:animationFile];
            CCAnimationCache* animationCache = [CCAnimationCache sharedAnimationCache];
            [animationCache addAnimationsWithFile:animationFile];
            
            pAnimation = [animationCache animationByName:animation];
        }
        @catch (NSException *exception) {
            pAnimation = NULL;
        }
    }

    // Actually set the sprite frame
    [node setValue:pAnimation forKey:prop];
}

@end
