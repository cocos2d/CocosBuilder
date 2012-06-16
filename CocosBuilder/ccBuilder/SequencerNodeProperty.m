//
//  SequencerNodeProperty.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SequencerNodeProperty.h"
#import "SequencerSequence.h"
#import "SequencerKeyframe.h"
#import "CCNode+NodeInfo.h"
#import "PlugInNode.h"

@implementation SequencerNodeProperty

@synthesize keyframes;
@synthesize type;

- (id) initWithProperty:(NSString*) name node:(CCNode*)n
{
    self = [super init];
    if (!self) return NULL;
    
    propName = [name copy];
    keyframes = [[NSMutableArray alloc] init];
    
    // Setup type
    NSString* propType = [n.plugIn propertyTypeForProperty:name];
    type = [SequencerKeyframe keyframeTypeFromPropertyType:propType];
    
    NSAssert(type, @"Failed to find valid type for SequencerNodeProperty");
    
    return self;
}

- (void) dealloc
{
    [keyframes release];
    [propName release];
    [super dealloc];
}

- (void) setKeyframe:(SequencerKeyframe*)keyframe
{
    keyframe.parent = self;
    [keyframes addObject:keyframe];
    
    [self sortKeyframes];
}

- (SequencerKeyframe*) keyframeBetweenMinTime:(float)minTime maxTime:(float)maxTime
{
    for (SequencerKeyframe* keyframe in keyframes)
    {
        if (keyframe.time >= minTime && keyframe.time <= maxTime)
        {
            return keyframe;
        }
    }
    return NULL;
}

- (NSArray*) keyframesBetweenMinTime:(float)minTime maxTime:(float)maxTime
{
    NSMutableArray* kfs = [NSMutableArray array];
    for (SequencerKeyframe* keyframe in keyframes)
    {
        if (keyframe.time >= minTime && keyframe.time <= maxTime)
        {
            [kfs addObject:keyframe];
        }
    }
    return kfs;
}

- (void) sortKeyframes
{
    // TODO: Optimize sorting (only sort once even if more than one keyframe is moved)
    [keyframes sortUsingSelector:@selector(compareTime:)];
}

- (id) valueAtTime:(float)time
{
    int numKeyframes = [keyframes count];
    
    NSAssert(numKeyframes, @"SequencerNodeProperty is missing keyframes");
    
    if (numKeyframes == 1)
    {
        SequencerKeyframe* keyframe = [keyframes objectAtIndex:0];
        return  keyframe.value;
    }
    
    SequencerKeyframe* keyframeFirst = [keyframes objectAtIndex:0];
    SequencerKeyframe* keyframeLast = [keyframes objectAtIndex:numKeyframes-1];
    
    if (time <= keyframeFirst.time)
    {
        return keyframeFirst.value;
    }
    
    if (time >= keyframeLast.time)
    {
        return keyframeLast.value;
    }
    
    // Time is between two keyframes, interpolate between them
    int endFrameNum = 1;
    while ([[keyframes objectAtIndex:endFrameNum] time] < time)
    {
        endFrameNum++;
    }
    int startFrameNum = endFrameNum - 1;
    
    SequencerKeyframe* keyframeStart = [keyframes objectAtIndex:startFrameNum];
    SequencerKeyframe* keyframeEnd = [keyframes objectAtIndex:endFrameNum];
    
    // interpolVal will be in the range 0.0 - 1.0
    float interpolVal = (time - keyframeStart.time)/(keyframeEnd.time-keyframeStart.time);
    
    // TODO: Support for tweening etc
    
    // Interpolate according to type
    if (type == kCCBKeyframeTypeDegrees)
    {
        float fStart = [keyframeStart.value floatValue];
        float fEnd = [keyframeEnd.value floatValue];
        
        float span = fEnd - fStart;
        
        return [NSNumber numberWithFloat:fStart+span*interpolVal];
    }
    
    // Unsupported value type
    return NULL;
}

- (BOOL) hasKeyframeAtTime:(float)time
{
    for (SequencerKeyframe* keyframe in keyframes)
    {
        if (keyframe.time == time) return YES;
    }
    return NO;
}

- (SequencerKeyframe*) keyframeAtTime:(float)time
{
    for (SequencerKeyframe* keyframe in keyframes)
    {
        if (keyframe.time == time) return keyframe;
    }
    return NULL;
}

@end
