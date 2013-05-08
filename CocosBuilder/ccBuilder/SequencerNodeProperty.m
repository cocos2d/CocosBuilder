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

#import "SequencerNodeProperty.h"
#import "SequencerSequence.h"
#import "SequencerKeyframe.h"
#import "SequencerKeyframeEasing.h"
#import "SequencerChannel.h"
#import "CCNode+NodeInfo.h"
#import "PlugInNode.h"

@implementation SequencerNodeProperty

@synthesize keyframes;
@synthesize type;
@synthesize propName;

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

- (id) initWithChannel:(SequencerChannel*)c
{
    self = [super init];
    if (!self) return NULL;
    
    propName = NULL;
    keyframes = [[NSMutableArray alloc] init];
    type = c.keyframeType;
    
    return self;
}

- (id) initWithSerialization: (id) ser
{
    self = [super init];
    if (!self) return NULL;
    
    propName = [[ser objectForKey:@"name"] copy];
    type = [[ser objectForKey:@"type"] intValue];
    
    NSArray* serKeyframes = [ser objectForKey:@"keyframes"];
    keyframes = [[NSMutableArray alloc] initWithCapacity:serKeyframes.count];
    for (id keyframeSer in serKeyframes)
    {
        SequencerKeyframe* keyframe = [[[SequencerKeyframe alloc] initWithSerialization:keyframeSer] autorelease];
        [keyframes addObject:keyframe];
        keyframe.parent = self;
    }
    
    return self;
}

- (id) serialization
{
    NSMutableDictionary* ser = [NSMutableDictionary dictionaryWithCapacity:3];
    
    if (propName)
    {
        [ser setObject:propName forKey:@"name"];
    }
    [ser setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    
    NSMutableArray* serKeyframes = [NSMutableArray arrayWithCapacity:keyframes.count];
    for (SequencerKeyframe* keyframe in keyframes)
    {
        [serKeyframes addObject:[keyframe serialization]];
    }
    
    [ser setObject:serKeyframes forKey:@"keyframes"];
    
    return ser;
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

- (SequencerKeyframe*) keyframeForInterpolationAtTime:(float)time
{
    for (int i = 0; i < [keyframes count]-1; i++)
    {
        SequencerKeyframe* k0 = [keyframes objectAtIndex:i];
        SequencerKeyframe* k1 = [keyframes objectAtIndex:i+1];
        
        if (time > k0.time && time < k1.time) return k0;
    }
    return NULL;
}

- (void) sortKeyframes
{
    // TODO: Optimize sorting (only sort once even if more than one keyframe is moved)
    [keyframes sortUsingSelector:@selector(compareTime:)];
}

- (BOOL) deleteDuplicateKeyframes
{
    BOOL didDelete = NO;
    
    // Remove duplicates
    int i = 0;
    while (i < (keyframes.count - 1))
    {
        SequencerKeyframe* kf0 = [keyframes objectAtIndex:i];
        SequencerKeyframe* kf1 = [keyframes objectAtIndex:i+1];
        
        if (kf0.time == kf1.time)
        {
            if (kf0.selected)
            {
                [keyframes removeObjectAtIndex:i+1];
            }
            else
            {
                [keyframes removeObjectAtIndex:i];
            }
            
            didDelete = YES;
        }
        else
        {
            i++;
        }
    }
    
    return didDelete;
}

- (void) deleteKeyframesAfterTime:(float)time
{
    for (int i = keyframes.count-1; i >= 0; i--)
    {
        SequencerKeyframe* keyframe = [keyframes objectAtIndex:i];
        if (keyframe.time > time)
        {
            [keyframes removeObjectAtIndex:i];
        }
    }
}

- (BOOL) deleteSelectedKeyframes
{
    BOOL deleted = NO;
    for (int i = keyframes.count-1; i >= 0; i--)
    {
        SequencerKeyframe* keyframe = [keyframes objectAtIndex:i];
        if (keyframe.selected)
        {
            [keyframes removeObjectAtIndex:i];
            deleted = YES;
        }
    }
    
    return deleted;
}

- (id) valueAtTime:(float)time
{
    int numKeyframes = [keyframes count];
    
    if (numKeyframes == 0)
    {
        return NULL;
    }
    
    if (numKeyframes == 1 && type == kCCBKeyframeTypeToggle)
    {
        SequencerKeyframe* keyframe = [keyframes objectAtIndex:0];
        return [NSNumber numberWithBool: (time >= keyframe.time)];
    }
    
    if (numKeyframes == 1)
    {
        SequencerKeyframe* keyframe = [keyframes objectAtIndex:0];
        return keyframe.value;
    }
    
    SequencerKeyframe* keyframeFirst = [keyframes objectAtIndex:0];
    SequencerKeyframe* keyframeLast = [keyframes objectAtIndex:numKeyframes-1];
    
    if (type == kCCBKeyframeTypeToggle)
    {
        if (time < keyframeFirst.time)
        {
            return [NSNumber numberWithBool:NO];
        }
        
        BOOL visible = YES;
        for (int i = 1; i < [keyframes count]; i++)
        {
            SequencerKeyframe* kf = [keyframes objectAtIndex:i];
            
            if (time < kf.time)
            {
                return [NSNumber numberWithBool:visible];
            }
            
            visible = !visible;
        }
        return [NSNumber numberWithBool:visible];
    }
    
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
    
    // Skip interpolations for toggle frames (special case)
    if (type == kCCBKeyframeTypeToggle)
    {
        BOOL val = (startFrameNum % 2 == 0);
        return [NSNumber numberWithBool:val];
    }
    
    // Skip interpolation for spriteframes
    if (type == kCCBKeyframeTypeSpriteFrame)
    {
        if (time < keyframeEnd.time) return keyframeStart.value;
        else return keyframeEnd.value;
    }
    
    // interpolVal will be in the range 0.0 - 1.0
    float interpolVal = (time - keyframeStart.time)/(keyframeEnd.time-keyframeStart.time);
    
    // Support for easing
    interpolVal = [keyframeStart.easing easeValue:interpolVal];
    
    // Interpolate according to type
    if (type == kCCBKeyframeTypeDegrees)
    {
        float fStart = [keyframeStart.value floatValue];
        float fEnd = [keyframeEnd.value floatValue];
        
        float span = fEnd - fStart;
        
        return [NSNumber numberWithFloat:fStart+span*interpolVal];
    }
    else if (type == kCCBKeyframeTypePosition
             || type == kCCBKeyframeTypeScaleLock)
    {
        CGPoint pStart = CGPointZero;
        CGPoint pEnd = CGPointZero;
        
        pStart.x = [[keyframeStart.value objectAtIndex:0] floatValue];
        pStart.y = [[keyframeStart.value objectAtIndex:1] floatValue];
        
        pEnd.x = [[keyframeEnd.value objectAtIndex:0] floatValue];
        pEnd.y = [[keyframeEnd.value objectAtIndex:1] floatValue];
        
        CGPoint span = ccpSub(pEnd, pStart);
        
        CGPoint inter = ccpAdd(pStart, ccpMult(span, interpolVal));
        
        return [NSArray arrayWithObjects:
                [NSNumber numberWithFloat:inter.x],
                [NSNumber numberWithFloat:inter.y],
                NULL];
    }
    else if (type == kCCBKeyframeTypeByte)
    {
        float fStart = [keyframeStart.value intValue];
        float fEnd = [keyframeEnd.value intValue];
        
        float span = fEnd - fStart;
        
        return [NSNumber numberWithInt:(int)(roundf(fStart+span*interpolVal))];
    }
    else if (type == kCCBKeyframeTypeColor3)
    {
        float rStart = [[keyframeStart.value objectAtIndex:0] intValue];
        float gStart = [[keyframeStart.value objectAtIndex:1] intValue];
        float bStart = [[keyframeStart.value objectAtIndex:2] intValue];
        
        float rEnd = [[keyframeEnd.value objectAtIndex:0] intValue];
        float gEnd = [[keyframeEnd.value objectAtIndex:1] intValue];
        float bEnd = [[keyframeEnd.value objectAtIndex:2] intValue];
        
        float rSpan = rEnd - rStart;
        float gSpan = gEnd - gStart;
        float bSpan = bEnd - bStart;
        
        int r = (roundf(rStart+rSpan*interpolVal));
        int g = (roundf(gStart+gSpan*interpolVal));
        int b = (roundf(bStart+bSpan*interpolVal));
        
        NSAssert(r >= 0 && r <= 255, @"Color value is out of range");
        NSAssert(g >= 0 && g <= 255, @"Color value is out of range");
        NSAssert(b >= 0 && b <= 255, @"Color value is out of range");
        
        return [NSArray arrayWithObjects:
                [NSNumber numberWithInt:r],
                [NSNumber numberWithInt:g],
                [NSNumber numberWithInt:b],
                nil];
    }
    else if (type == kCCBKeyframeTypeFloatXY)
    {
        float xStart = [[keyframeStart.value objectAtIndex:0] floatValue];
        float yStart = [[keyframeStart.value objectAtIndex:1] floatValue];
        
        float xEnd = [[keyframeEnd.value objectAtIndex:0] floatValue];
        float yEnd = [[keyframeEnd.value objectAtIndex:1] floatValue];
        
        float xSpan = xEnd - xStart;
        float ySpan = yEnd - yStart;
        
        float xVal = xStart+xSpan*interpolVal;
        float yVal = yStart+ySpan*interpolVal;
        
        return [NSArray arrayWithObjects:
                [NSNumber numberWithFloat:xVal],
                [NSNumber numberWithFloat:yVal],
                nil];
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

- (NSArray*) keyframesAtTime:(float)time
{
    NSMutableArray* kfs = [NSMutableArray array];
    
    for (SequencerKeyframe* keyframe in keyframes)
    {
        if (keyframe.time == time) [kfs addObject:keyframe];
    }
    
    return kfs;
}

- (void) deselectKeyframes
{
    for (SequencerKeyframe* keyframe in keyframes)
    {
        keyframe.selected = NO;
    }
}

- (SequencerNodeProperty*) duplicate
{
    id serialization = [self serialization];
    SequencerNodeProperty* duplicate = [[[SequencerNodeProperty alloc] initWithSerialization:serialization] autorelease];
    return duplicate;
}

- (id) copyWithZone:(NSZone*)zone
{
    id serialization = [self serialization];
    SequencerNodeProperty* copy = [[SequencerNodeProperty alloc] initWithSerialization:serialization];
    return copy;
}

/*
- (void) updateNode:(CCNode*)node toTime:(float)time
{
    id value = [self valueAtTime:time];
    NSAssert(value, @"Failed to fetch value!");
    
    if (type == kCCBKeyframeTypeDegrees)
    {
        [node setValue:value forKey:propName];
    }
}*/

@end
