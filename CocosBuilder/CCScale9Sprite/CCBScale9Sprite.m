//
//  CCBScale9Sprite.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/4/13.
//
//

#import "CCBScale9Sprite.h"
#import "CocosBuilderAppDelegate.h"
#import "CCBDocument.h"
#import "ResolutionSetting.h"

@implementation CCBScale9Sprite

- (float) resolutionScale
{
    CCBDocument* currentDocument = [CocosBuilderAppDelegate appDelegate].currentDocument;
    
    ResolutionSetting* resolution = [currentDocument.resolutions objectAtIndex:currentDocument.currentResolution];
    
    return resolution.scale;
}

- (void) setInsetBottom:(float)insetBottom
{
    [super setInsetBottom:insetBottom * [self resolutionScale]];
    iBot = insetBottom;
}

- (float) insetBottom
{
    return iBot;
}

- (void) setInsetTop:(float)insetTop
{
    [super setInsetTop:insetTop * [self resolutionScale]];
    iTop = insetTop;
}

- (float) insetTop
{
    return iTop;
}

- (void) setInsetLeft:(float)insetLeft
{
    [super setInsetLeft:insetLeft * [self resolutionScale]];
    iLeft = insetLeft;
}

- (float) insetLeft
{
    return iLeft;
}

- (void) setInsetRight:(float)insetRight
{
    [super setInsetRight:insetRight * [self resolutionScale]];
    iRight = insetRight;
}

- (float) insetRight
{
    return iRight;
}

@end
