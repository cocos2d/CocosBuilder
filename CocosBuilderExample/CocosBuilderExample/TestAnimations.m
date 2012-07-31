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

@synthesize ccbActionManager;

- (void) didLoadFromCCB
{
    
}

- (void) pressedIdle:(id)sender
{
    [ccbActionManager runActionsForSequenceNamed:@"Idle" tweenDuration:0.3f];
}

- (void) pressedWave:(id)sender
{
    [ccbActionManager runActionsForSequenceNamed:@"Wave" tweenDuration:0.3f];
}

- (void) pressedJump:(id)sender
{
    [ccbActionManager runActionsForSequenceNamed:@"Jump" tweenDuration:0.3f];
}

- (void) dealloc
{
    self.ccbActionManager = NULL;
    [super dealloc];
}

@end
