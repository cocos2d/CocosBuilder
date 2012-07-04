//
//  SequencerSequenceArrayController.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SequencerSequenceArrayController.h"
#import "SequencerSequence.h"

@implementation SequencerSequenceArrayController

@synthesize settingsWindow;

- (void) addObject:(id)object
{
    SequencerSequence* seq = object;
    seq.settingsWindow = settingsWindow;
    [super addObject:object];
}

@end
