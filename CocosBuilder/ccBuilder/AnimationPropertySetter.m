/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

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
