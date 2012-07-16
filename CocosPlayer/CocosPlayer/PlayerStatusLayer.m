//
//  PlayerStatusLayer.m
//  CocosPlayer
//
//  Created by Viktor Lidholt on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayerStatusLayer.h"

static PlayerStatusLayer* sharedPlayerStatusLayer = NULL;

@implementation PlayerStatusLayer

+ (PlayerStatusLayer*) sharedInstance
{
    return sharedPlayerStatusLayer;
}

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    sharedPlayerStatusLayer = self;
    
    return self;
}

- (void) setStatus:(NSString*)status
{
    [lblStatus setString:status];
}

- (void) pressedRun:(id)sender
{
}

- (void) pressedReset:(id)sender
{
}

- (void) pressedPair:(id)sender
{
}

@end
