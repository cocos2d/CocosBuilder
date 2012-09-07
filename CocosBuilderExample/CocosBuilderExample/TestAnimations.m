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

- (void) didLoadFromCCB
{
    self.animationManager = self.userObject;
}

- (void) pressedIdle:(id)sender
{
    [animationManager runAnimationsForSequenceNamed:@"Idle" tweenDuration:0.3f];
}

- (void) pressedWave:(id)sender
{
    [animationManager runAnimationsForSequenceNamed:@"Wave" tweenDuration:0.3f];
}

- (void) pressedJump:(id)sender
{
    [animationManager runAnimationsForSequenceNamed:@"Jump" tweenDuration:0.3f];
}

- (void) pressedFunky:(id)sender
{
    [animationManager runAnimationsForSequenceNamed:@"Funky" tweenDuration:0.3f];
}

- (void) dealloc
{
    self.animationManager = NULL;
    [super dealloc];
}

@end
