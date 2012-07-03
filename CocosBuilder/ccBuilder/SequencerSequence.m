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
#import "CocosScene.h"
#import "CCNode+NodeInfo.h"

@implementation SequencerSequence

@synthesize timelineScale;
@synthesize timelineOffset;
@synthesize timelineLength;
@synthesize timelinePosition;
@synthesize timelineResolution;
@synthesize name;
@synthesize sequenceId;
@synthesize chainedSequenceId;

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
    chainedSequenceId = -1;
    
    return self;
}

- (id) initWithSerialization:(id)ser
{
    self = [super init];
    if (!self) return NULL;
    
    timelineScale = [[ser objectForKey:@"scale"] floatValue];
    timelineOffset = [[ser objectForKey:@"offset"] floatValue];
    timelineLength = [[ser objectForKey:@"length"] floatValue];
    timelinePosition = [[ser objectForKey:@"position"] floatValue];
    timelineResolution = [[ser objectForKey:@"resolution"] floatValue];
    self.name = [ser objectForKey:@"name"];
    sequenceId = [[ser objectForKey:@"sequenceId"] intValue];
    NSNumber* chainedSeqIdNum = [ser objectForKey:@"chainedSequenceId"];
    if (chainedSeqIdNum) chainedSequenceId = [chainedSeqIdNum intValue];
    else chainedSequenceId = -1;
    
    return self;
}

- (id) serialize
{
    NSMutableDictionary* ser = [NSMutableDictionary dictionary];
    
    [ser setObject:[NSNumber numberWithFloat:timelineScale] forKey:@"scale"];
    [ser setObject:[NSNumber numberWithFloat:timelineOffset] forKey:@"offset"];
    [ser setObject:[NSNumber numberWithFloat:timelineLength] forKey:@"length"];
    [ser setObject:[NSNumber numberWithFloat:timelinePosition] forKey:@"position"];
    [ser setObject:[NSNumber numberWithFloat:timelineResolution] forKey:@"resolution"];
    [ser setObject:name forKey:@"name"];
    [ser setObject:[NSNumber numberWithInt:sequenceId] forKey:@"sequenceId"];
    [ser setObject:[NSNumber numberWithInt:chainedSequenceId] forKey:@"chainedSequenceId"];
    
    return ser;
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

- (float) alignTimeToResolution:(float)time
{
    return roundf(time * timelineResolution)/timelineResolution;
}

- (void) stepForward:(int)numSteps
{
    float newTime = [self alignTimeToResolution: timelinePosition + 1/timelineResolution*numSteps];
    self.timelinePosition = newTime;
}

- (void) stepBack:(int)numSteps
{
    float newTime = [self alignTimeToResolution: timelinePosition - 1/timelineResolution*numSteps];
    self.timelinePosition = newTime;
}

- (SequencerSequence*) duplicateWithNewId:(int)seqId
{
    SequencerSequence* copy = [self copy];
    copy.name = [copy.name stringByAppendingString:@" copy"];
    copy.sequenceId = seqId;
    
    [[CocosScene cocosScene].rootNode duplicateKeyframesFromSequenceId:sequenceId toSequenceId:seqId];
    
    return copy;
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
