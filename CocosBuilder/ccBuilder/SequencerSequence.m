/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "SequencerSequence.h"
#import "SequencerHandler.h"
#import "CocosBuilderAppDelegate.h"
#import "CCBDocument.h"
#import "CocosScene.h"
#import "CCNode+NodeInfo.h"
#import "SequencerSettingsWindow.h"

@implementation SequencerSequence

@synthesize timelineScale;
@synthesize timelineOffset;
@synthesize timelineLength;
@synthesize timelinePosition;
@synthesize timelineResolution;
@synthesize name;
@synthesize sequenceId;
@synthesize chainedSequenceId;
@synthesize autoPlay;
@synthesize settingsWindow;

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
    autoPlay = [[ser objectForKey:@"autoPlay"] boolValue];
    
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
    [ser setObject:[NSNumber numberWithBool:autoPlay] forKey:@"autoPlay"];
    
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

- (void) setTimelineLength:(float)tl
{
    if (tl == timelineLength) return;
    
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*timelineLength"];
    
    timelineLength = tl;
    if (timelinePosition > timelineLength) timelinePosition = timelineLength;
    
    [[SequencerHandler sharedHandler] redrawTimeline];
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

- (void) setAutoPlay:(BOOL)ap
{
    if (ap)
    {
        [settingsWindow disableAutoPlayForAllItems];
    }
    
    NSLog(@"setAutoPlay: %d", ap);
    autoPlay = ap;
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
    copy.autoPlay = autoPlay;
    
    return copy;
}

@end
