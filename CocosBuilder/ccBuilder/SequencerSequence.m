//
//  SequencerSequence.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SequencerSequence.h"
#import "SequencerHandler.h"

@implementation SequencerSequence

@synthesize timelineScale;
@synthesize timelineOffset;
@synthesize timelineLength;
@synthesize timelinePosition;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    timelineScale = kCCBDefaultTimelineScale;
    timelineOffset = 0;
    timelineResolution = 30;
    timelineLength = 10;
    
    return self;
}

- (void) setTimelinePosition:(float)tp
{
    timelinePosition = tp;
    [[SequencerHandler sharedHandler] redrawTimeline];
}

- (void) setTimelineScale:(float)ts
{
    if (timelineScale != ts)
    {
        timelineScale = ts;
        [[SequencerHandler sharedHandler] redrawTimeline];
    }
}

- (void) setTimelineOffset:(float)to
{
    if (timelineOffset != to)
    {
        if (to < 0)
        {
            to = 0;
        }
        
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
    return max(roundf(rawTime * timelineResolution)/timelineResolution, 0);
}

- (NSString*) currentDisplayTime
{
    int mins = floorf(timelinePosition / 60);
    int secs = ((int)timelinePosition) % 60;
    int frames = roundf((timelinePosition - floorf(timelinePosition)) * timelineResolution);
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", mins,secs,frames];
}

@end
