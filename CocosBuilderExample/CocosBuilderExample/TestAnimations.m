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
    NSLog(@"pressedIdle self: %@", self);
    
    [ccbActionManager runActionsForSequenceNamed:@"Idle" tweenDuration:0.5f];
    
    [self stopAllActions];
    [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:2] two:[CCCallFunc actionWithTarget:self selector:@selector(testing)]]];
    [self runAction:[CCRotateBy actionWithDuration:2 angle:360]];
}

- (void) pressedWave:(id)sender
{
    [ccbActionManager runActionsForSequenceNamed:@"Wave" tweenDuration:0.5f];
}

- (void) pressedJump:(id)sender
{
    [ccbActionManager runActionsForSequenceNamed:@"Jump" tweenDuration:0.5f];
}

- (void) dealloc
{
    self.ccbActionManager = NULL;
    [super dealloc];
}

- (void) testing
{
    NSLog(@"Testing testing!");
}

@end
