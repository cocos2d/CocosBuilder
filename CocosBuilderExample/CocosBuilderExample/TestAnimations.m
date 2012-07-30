//
//  TestAnimations.m
//  CocosBuilderExample
//
//  Created by Viktor Lidholt on 7/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestAnimations.h"
#import "CCBActionManager.h"

@implementation TestAnimations

@synthesize actionManager;

- (void) pressedIdle:(id)sender
{
    [actionManager runActionsForSequenceNamed:@"Idle" tweenDuration:0.5f];
}

- (void) pressedWave:(id)sender
{
    [actionManager runActionsForSequenceNamed:@"Wave" tweenDuration:0.5f];
}

- (void) pressedJump:(id)sender
{
    [actionManager runActionsForSequenceNamed:@"Jump" tweenDuration:0.5f];
}

- (void) dealloc
{
    self.actionManager = NULL;
    [super dealloc];
}

@end
