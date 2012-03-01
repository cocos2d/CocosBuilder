//
//  CCRotatingSprite.h
//  CCRotatingSprite
//
//  Created by Viktor Lidholt on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface CCRotatingSprite : CCSprite
{
    float secondsPerRotation;
}

@property (nonatomic,assign) float secondsPerRotation;

@end
