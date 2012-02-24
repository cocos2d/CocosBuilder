//
//  CCBPMenu.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBPMenu.h"

@implementation CCBPMenu

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    self.isMouseEnabled = NO;
    
    return self;
}

@end
