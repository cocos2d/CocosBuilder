//
//  CCBPParticleSystem.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBPParticleSystem.h"

@implementation CCBPParticleSystem

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    self.positionType = kCCPositionTypeGrouped;
    
    return self;
}

@end
