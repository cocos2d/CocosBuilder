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
    // fix possible broken easing/type combinations
    if (![self supportsFiniteTimeInterpolations]) {
        easing.type = kCCBKeyframeEasingInstant;
    }
    
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
        return kCCBKeyframeTypeToggle;
    }
    else if ([type isEqualToString:@"Byte"])
    {
        return kCCBKeyframeTypeByte;
    }
    else if ([type isEqualToString:@"Color3"])
    {
        return kCCBKeyframeTypeColor3;
    }
    else if ([type isEqualToString:@"SpriteFrame"])
    {
        return kCCBKeyframeTypeSpriteFrame;
    }
    else if ([type isEqualToString:@"FloatXY"])
    {
        return kCCBKeyframeTypeFloatXY;
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
    else if (type == kCCBKeyframeTypeByte)
    {
        return ([value intValue] == [keyframe.value intValue]);
    }
    else if (type == kCCBKeyframeTypeColor3)
    {
        int r0 = [[value objectAtIndex:0] intValue];
        int g0 = [[value objectAtIndex:1] intValue];
        int b0 = [[value objectAtIndex:2] intValue];
        
        int r1 = [[keyframe.value objectAtIndex:0] intValue];
        int g1 = [[keyframe.value objectAtIndex:1] intValue];
        int b1 = [[keyframe.value objectAtIndex:2] intValue];
        
        return (r0 == r1 && g0 == g1 && b0 == b1);
    }
    return NO;
}

- (BOOL) supportsFiniteTimeInterpolations
{
    return (type != kCCBKeyframeTypeToggle && type != kCCBKeyframeTypeUndefined && type != kCCBKeyframeTypeSpriteFrame);
}


- (void) dealloc
{
    [value release];
    [name release];
    [easing release];
    [super dealloc];
}

@end
