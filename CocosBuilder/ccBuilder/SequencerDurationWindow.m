//
//  SequencerDurationWindow.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SequencerDurationWindow.h"

@implementation SequencerDurationWindow


@synthesize mins;
@synthesize secs;
@synthesize frames;

- (void) setDuration:(float)d
{
    self.mins = floorf(d / 60);
    self.secs = ((int)d) % 60;
    self.frames = roundf((d - floorf(d)) * 30);
}

- (float) duration
{
    return self.mins * 60 + self.secs + self.frames/30;
}

@end
