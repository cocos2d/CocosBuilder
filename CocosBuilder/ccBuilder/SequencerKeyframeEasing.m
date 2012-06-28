//
//  SequencerKeyframeEasing.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SequencerKeyframeEasing.h"

@implementation SequencerKeyframeEasing

@synthesize type;
@synthesize options;

+ (id) easing
{
    return [[[SequencerKeyframeEasing alloc] init] autorelease];
}

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    type = kCCBKeyframeEasingLinear;
    
    return self;
}

- (id) initWithSerialization:(id) ser
{
    self = [super init];
    if (!self) return NULL;
    
    type = [[ser objectForKey:@"type"] intValue];
    self.options = [ser objectForKey:@"opt"];
    
    return self;
}

- (id) serialization
{
    NSMutableDictionary* ser = [NSMutableDictionary dictionary];
    [ser setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    if (options) [ser setObject:options forKey:@"opt"];
    return ser;
}

- (float) easeValue:(float)t
{
    if (type == kCCBKeyframeEasingInstant)
    {
        if (t < 1) return 0;
        else return 1;
    }
    else if (type == kCCBKeyframeEasingLinear)
    {
        return t;
    }
    else if (type == kCCBKeyframeEasingCubicIn)
    {
        float rate = [options floatValue];
        return powf(t,rate);
    }
    else if (type == kCCBKeyframeEasingCubicOut)
    {
        float rate = [options floatValue];
        return powf(t,1/rate);
    }
    else if (type == kCCBKeyframeEasingCubicInOut)
    {
        float rate = [options floatValue];
        t *= 2;
        if (t < 1)
        {
            return 0.5f * powf (t, rate);
        }
        else
        {
            return 1.0f - 0.5f * powf(2-t, rate);
        }
    }
    
    NSAssert(NO, @"Invalid easing option");
    return 0;
}

- (BOOL) hasEaseIn
{
    return (type == kCCBKeyframeEasingCubicIn
            || type == kCCBKeyframeEasingCubicInOut);
}

- (BOOL) hasEaseOut
{
    return (type == kCCBKeyframeEasingCubicOut
            || type == kCCBKeyframeEasingCubicInOut);
}

- (BOOL) hasOptions
{
    return (type == kCCBKeyframeEasingCubicIn
            || type == kCCBKeyframeEasingCubicOut
            || type == kCCBKeyframeEasingCubicInOut);
}

- (void) setType:(int)t
{
    if (t == type) return;
    
    if (t == kCCBKeyframeEasingCubicIn
        || t == kCCBKeyframeEasingCubicOut
        || t == kCCBKeyframeEasingCubicInOut)
    {
        self.options = [NSNumber numberWithFloat:2];
    }
    type = t;
}

- (void) dealloc
{
    self.options = NULL;
    [super dealloc];
}

@end
