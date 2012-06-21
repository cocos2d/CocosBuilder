//
//  SequencerSequence.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SequencerSequence.h"
#import "SequencerHandler.h"
#import "CocosBuilderAppDelegate.h"
#import "CCBDocument.h"

@implementation SequencerSequence

@synthesize timelineScale;
@synthesize timelineOffset;
@synthesize timelineLength;
@synthesize timelinePosition;
@synthesize timelineResolution;
@synthesize name;
@synthesize sequenceId;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    timelineScale = kCCBDefaultTimelineScale;
    timelineOffset = 0;
    timelineResolution = 30;
    timelineLength = 10;
    self.name = @"Untitled Timeline";
    sequenceId = -1;
    
    return self;
}

- (void) setTimelinePosition:(float)tp
{
    if (tp < 0) tp = 0;
    if (tp > timelineLength) tp = timelineLength;
    
    if (tp != timelinePosition)
    {
        SequencerHandler* sh = [SequencerHandler sharedHandler];
        
        timelinePosition = tp;
        
        if (sh.currentSequence == self)
        {
            [sh redrawTimeline];
            [sh updatePropertiesToTimelinePosition];
            [[CocosBuilderAppDelegate appDelegate] updateInspectorFromSelection];
        }
    }
}

- (void) setTimelineScale:(float)ts
{
    if (timelineScale != ts)
    {
        timelineScale = ts;
        
        // Make sure scroll is within bounds
        self.timelineOffset = timelineOffset;
        [[SequencerHandler sharedHandler] redrawTimeline];
    }
}

- (void) setTimelineOffset:(float)to
{
    // Check min value
    if (to < 0) to = 0;
    
    // Check max value
    float maxOffset = [[SequencerHandler sharedHandler] maxTimelineOffset];
    if (to > maxOffset) to = maxOffset;
    
    // Update offset
    if (timelineOffset != to)
    {
        timelineOffset = to;
        [[SequencerHandler sharedHandler] redrawTimeline];
    }
}

- (float) timeToPosition:(float)time
{
    return roundf((time - timelineOffset)*timelineScale);
}

- (float) positionToTime:(float)pos
{
    float rawTime = (pos/timelineScale)+timelineOffset;
    float capped = max(roundf(rawTime * timelineResolution)/timelineResolution, 0);
    return min(capped, timelineLength);
}

- (NSString*) formatTime:(float)time
{
    int mins = floorf(time / 60);
    int secs = ((int)time) % 60;
    int frames = roundf((time - floorf(time)) * timelineResolution);
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", mins,secs,frames];
}

- (NSString*) currentDisplayTime
{
    return [self formatTime:timelinePosition];
}

- (NSString*) lengthDisplayTime
{
    return [self formatTime:timelineLength];
}

- (void) dealloc
{
    self.name = NULL;
    [super dealloc];
}

- (id) copyWithZone:(NSZone*)zone
{
    SequencerSequence* copy = [[SequencerSequence alloc] init];
    
    copy.timelineScale = timelineScale;
    copy.timelineOffset = timelineOffset;
    copy.timelineLength = timelineLength;
    copy.timelinePosition = timelinePosition;
    copy.timelineResolution = timelineResolution;
    copy.name = name;
    copy.sequenceId = sequenceId;
    
    return copy;
}

@end
