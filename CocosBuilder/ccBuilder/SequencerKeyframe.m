//
//  SequencerKeyframe.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SequencerKeyframe.h"
#import "SequencerNodeProperty.h"
#import "SequencerKeyframeEasing.h"

@implementation SequencerKeyframe

@synthesize value;
@synthesize type;
@synthesize name;

@synthesize time;
@synthesize timeAtDragStart;
@synthesize selected;

@synthesize parent;
@synthesize easing;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    self.easing = [SequencerKeyframeEasing easing];
    
    return self;
}

- (id) initWithSerialization:(id)ser
{
    self = [super init];
    if (!self) return NULL;
    
    self.value = [ser valueForKey:@"value"];
    self.type = [[ser valueForKey:@"type"] intValue];
    self.name = [ser valueForKey:@"name"];
    self.time = [[ser valueForKey:@"time"] floatValue];
    self.easing = [[[SequencerKeyframeEasing alloc] initWithSerialization:[ser objectForKey:@"easing"]] autorelease];
    
    return self;
}

- (id) serialization
{
    NSMutableDictionary* ser = [NSMutableDictionary dictionaryWithCapacity:4];
    
    [ser setValue:value forKey:@"value"];
    [ser setValue:[NSNumber numberWithInt:type] forKey:@"type"];
    [ser setValue:name forKey:@"name"];
    [ser setValue:[NSNumber numberWithFloat:time] forKey:@"time"];
    [ser setValue:[easing serialization] forKey:@"easing"];
    
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
    else if ([type isEqualToString:@"Check"])
    {
        return kCCBKeyframeTypeVisible;
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

- (BOOL) valueIsEqualTo:(SequencerKeyframe*)keyframe
{
    if (type != keyframe.type)
    {
        return NO;
    }
    
    if (type == kCCBKeyframeTypeDegrees)
    {
        return ([value floatValue] == [keyframe.value floatValue]);
    }
    else if (type == kCCBKeyframeTypePosition
             || type == kCCBKeyframeTypeScaleLock)
    {
        return ([[value objectAtIndex:0] floatValue] == [[keyframe.value objectAtIndex:0] floatValue]
                && [[value objectAtIndex:1] floatValue] == [[keyframe.value objectAtIndex:1] floatValue]);
    }
    return NO;
}

- (void) dealloc
{
    self.easing = NULL;
    self.parent = NULL;
    [super dealloc];
}

@end
