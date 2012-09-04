//
//  TestAnimations.m
//  CocosBuilderExample
//
//  Created by Viktor Lidholt on 7/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestAnimations.h"
#import "CCBAnimationManager.h"

@implementation TestAnimations

@synthesize animationManager;

- (void) pressedIdle:(id)sender
{
    [animationManager runActionsForSequenceNamed:@"Idle" tweenDuration:0.3f];
}

- (void) pressedWave:(id)sender
{
    [animationManager runActionsForSequenceNamed:@"Wave" tweenDuration:0.3f];
}

- (void) pressedJump:(id)sender
{
    [animationManager runActionsForSequenceNamed:@"Jump" tweenDuration:0.3f];
}

- (void) pressedFunky:(id)sender
{
    [animationManager runActionsForSequenceNamed:@"Funky" tweenDuration:0.3f];
}

- (void) dealloc
{
    self.animationManager = NULL;
    [super dealloc];
}

@end
