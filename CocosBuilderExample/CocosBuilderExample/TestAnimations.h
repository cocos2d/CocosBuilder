//
//  TestAnimations.h
//  CocosBuilderExample
//
//  Created by Viktor Lidholt on 7/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@class CCBActionManager;

@interface TestAnimations : CCLayer
{
    CCBActionManager* actionManager;
}

@property (nonatomic,retain) CCBActionManager* actionManager;

@end
