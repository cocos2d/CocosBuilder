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

@implementation SequencerNodeProperty

@synthesize keyframes;

- (id) initWithProperty:(NSString*) name node:(CCNode*)n
{
    self = [super init];
    if (!self) return NULL;
    
    propName = [name copy];
    keyframes = [[NSMutableArray alloc] init];
    
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
    [keyframes addObject:keyframe];
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

@end
