//
//  RulersLayer.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCScale9Sprite.h"

@interface RulersLayer : CCLayer
{
    CCScale9Sprite* bgHorizontal;
    CCScale9Sprite* bgVertical;
    
    CCNode* marksVertical;
    CCNode* marksHorizontal;
    
    CGSize winSize;
    CGPoint stageOrigin;
    float zoom;
}

- (void) updateWithSize:(CGSize)winSize stageOrigin:(CGPoint)stageOrigin zoom:(float)zoom;

@end
