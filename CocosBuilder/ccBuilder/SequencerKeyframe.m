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

- (id) initWithSerialization:(id)ser
{
    self = [super init];
    if (!self) return NULL;
    
    self.value = [ser valueForKey:@"value"];
    self.type = [[ser valueForKey:@"type"] intValue];
    self.name = [ser valueForKey:@"name"];
    self.time = [[ser valueForKey:@"time"] floatValue];
    
    return self;
}

- (id) serialization
{
    NSMutableDictionary* ser = [NSMutableDictionary dictionaryWithCapacity:4];
    
    [ser setValue:value forKey:@"value"];
    [ser setValue:[NSNumber numberWithInt:type] forKey:@"type"];
    [ser setValue:name forKey:@"name"];
    [ser setValue:[NSNumber numberWithFloat:time] forKey:@"time"];
    
    return ser;
}

+ (int) keyframeTypeFromPropertyType:(NSString*)type
{
    if ([type isEqualToString:@"Degrees"])
    {
        return kCCBKeyframeTypeDegrees;
    }
    else if ([type isEqualToString:@"Position"])
    {
        return kCCBKeyframeTypePosition;
    }
    else if ([type isEqualToString:@"ScaleLock"])
    {
        return kCCBKeyframeTypeScaleLock;
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
