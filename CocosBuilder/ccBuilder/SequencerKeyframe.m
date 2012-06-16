//
//  SequencerKeyframe.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SequencerKeyframe.h"
#import "SequencerNodeProperty.h"

@implementation SequencerKeyframe

@synthesize value;
@synthesize type;
@synthesize name;

@synthesize time;
@synthesize timeAtDragStart;
@synthesize selected;

@synthesize parent;


+ (int) keyframeTypeFromPropertyType:(NSString*)type
{
    if ([type isEqualToString:@"Degrees"])
    {
        return kCCBKeyframeTypeDegrees;
    }
    else
    {
        return kCCBKeyframeTypeUndefined;
    }
}

- (NSComparisonResult) compareTime:(id)cmp
{
    SequencerKeyframe* keyframe = cmp;
    
    if (keyframe.time > self.time) return NSOrderedAscending;
    else if (keyframe.time < self.time) return NSOrderedDescending;
    else return NSOrderedSame;
}

- (void) setTime:(float)t
{
    time = t;
    [parent sortKeyframes];
}

@end
