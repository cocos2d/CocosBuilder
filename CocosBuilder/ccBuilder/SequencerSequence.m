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
#import "SequencerCallbackChannel.h"
#import "SequencerSoundChannel.h"
#import "SequencerNodeProperty.h"
#import "SequencerKeyframe.h"
#import "SimpleAudioEngine.h"
#import "ResourceManager.h"

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
@synthesize soundChannel;
@synthesize callbackChannel;

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
    timelinePosition = 0;
    
    callbackChannel = [[SequencerCallbackChannel alloc] init];
    soundChannel = [[SequencerSoundChannel alloc] init];
    
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
    
    id serCallbacks = [ser objectForKey:@"callbackChannel"];
    callbackChannel = [[SequencerCallbackChannel alloc] initWithSerialization: serCallbacks];
    id serSounds = [ser objectForKey:@"soundChannel"];
    soundChannel = [[SequencerSoundChannel alloc] initWithSerialization: serSounds];
    
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
    
    id serCallbacks = [callbackChannel serialize];
    [ser setObject:serCallbacks forKey:@"callbackChannel"];
    id serSounds = [soundChannel serialize];
    [ser setObject:serSounds forKey:@"soundChannel"];
    
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
            [sh redrawTimeline:NO];     // No need to reload Sequencer Outline View (No node has changed)
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
        [[SequencerHandler sharedHandler] redrawTimeline:NO];
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
    return roundf((time - timelineOffset)*timelineScale)+TIMELINE_PAD_PIXELS;
}

- (float) positionToTime:(float)pos
{
    float rawTime = ((pos-TIMELINE_PAD_PIXELS)/timelineScale)+timelineOffset;
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
    // Calculate new time
    float newTime = [self alignTimeToResolution: timelinePosition + numSteps/timelineResolution];
    
    // Handle audio
    NSArray* soundKeyframes = [soundChannel.seqNodeProp keyframesBetweenMinTime:timelinePosition maxTime:newTime - 1.0f/timelineResolution];
    
    for (SequencerKeyframe* keyframe in soundKeyframes)
    {
        NSString* soundFile = [keyframe.value objectAtIndex:0];
        float pitch = [[keyframe.value objectAtIndex:1] floatValue];
        float pan = [[keyframe.value objectAtIndex:2] floatValue];
        float gain = [[keyframe.value objectAtIndex:3] floatValue];
        
        NSString* absFile = [[CocosBuilderAppDelegate appDelegate].resManager toAbsolutePath:soundFile];
        if ([[NSFileManager defaultManager] fileExistsAtPath:absFile])
        {
            [[SimpleAudioEngine sharedEngine] playEffect:absFile pitch:pitch pan:pan gain:gain];
        }
    }
    
    // Update timeline
    self.timelinePosition = newTime;
    [[SequencerHandler sharedHandler] updateScrollerToShowCurrentTime];
}

- (void) stepBack:(int)numSteps
{
    float newTime = [self alignTimeToResolution: timelinePosition - numSteps/timelineResolution];
    self.timelinePosition = newTime;
    [[SequencerHandler sharedHandler] updateScrollerToShowCurrentTime];
}

- (SequencerSequence*) duplicateWithNewId:(int)seqId
{
    SequencerSequence* copy = [self copy];
    copy.name = [copy.name stringByAppendingString:@" copy"];
    copy.sequenceId = seqId;
    
    [[CocosScene cocosScene].rootNode duplicateKeyframesFromSequenceId:sequenceId toSequenceId:seqId];
    
    return [copy autorelease];
}

- (void) dealloc
{
    self.name = NULL;
    [callbackChannel release];
    [soundChannel release];
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
    copy.chainedSequenceId = chainedSequenceId;
    copy.autoPlay = autoPlay;
    
    [copy->callbackChannel release];
    [copy->soundChannel release];
    
    copy->callbackChannel = [callbackChannel copy];
    copy->soundChannel = [soundChannel copy];
    
    return copy;
}

@end
