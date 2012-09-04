//
//  TestAnimations.h
//  CocosBuilderExample
//
//  Created by Viktor Lidholt on 7/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@class CCBAnimationManager;

@interface TestAnimations : CCLayer
{
    CCBAnimationManager* animationManager;
}

@property (nonatomic,retain) CCBAnimationManager* animationManager;

@end
