//
//  CCRotatingSprite.m
//  CCRotatingSprite
//
//  Created by Viktor Lidholt on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCRotatingSprite.h"

@implementation CCRotatingSprite

@synthesize secondsPerRotation;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    self.secondsPerRotation = 2;
    
    return self;
}

- (void) setSecondsPerRotation:(float)spr
{
    secondsPerRotation = spr;
    
    // Stop rotating
    [self stopAllActions];
    
    // Rotate with the new speed
    [self runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:spr angle:360]]];
}

@end
