//
//  SequencerKeyframeEasing.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SequencerKeyframeEasing.h"

#ifndef M_PI_X_2
#define M_PI_X_2 (float)M_PI * 2.0f
#endif

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

-(float) bounceTime:(float) t
{
	if (t < 1 / 2.75) {
		return 7.5625f * t * t;
	}
	else if (t < 2 / 2.75) {
		t -= 1.5f / 2.75f;
		return 7.5625f * t * t + 0.75f;
	}
	else if (t < 2.5 / 2.75) {
		t -= 2.25f / 2.75f;
		return 7.5625f * t * t + 0.9375f;
	}
    
	t -= 2.625f / 2.75f;
	return 7.5625f * t * t + 0.984375f;
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
    else if (type == kCCBKeyframeEasingElasticIn)
    {
        float period = [options floatValue];
        float newT = 0;
        if (t == 0 || t == 1)
            newT = t;
        
        else {
            float s = period / 4;
            t = t - 1;
            newT = -powf(2, 10 * t) * sinf( (t-s) * M_PI_X_2 / period);
        }
        return newT;
    }
    else if (type == kCCBKeyframeEasingElasticOut)
    {
        float period = [options floatValue];
        float newT = 0;
        if (t == 0 || t == 1) {
            newT = t;
            
        } else {
            float s = period / 4;
            newT = powf(2, -10 * t) * sinf( (t-s) *M_PI_X_2 / period) + 1;
        }
        return newT;
    }
    else if (type == kCCBKeyframeEasingElasticInOut)
    {
        float period = [options floatValue];
        float newT = 0;
        if( t == 0 || t == 1 )
            newT = t;
        else {
            t = t * 2;
            if(! period )
                period = 0.3f * 1.5f;
            float s = period / 4;
            
            t = t -1;
            if( t < 0 )
                newT = -0.5f * powf(2, 10 * t) * sinf((t - s) * M_PI_X_2 / period);
            else
                newT = powf(2, -10 * t) * sinf((t - s) * M_PI_X_2 / period) * 0.5f + 1;
        }
        return newT;
    }
    else if (type == kCCBKeyframeEasingBounceIn)
    {
        float newT = 1 - [self bounceTime:1-t];
        return newT;
    }
    else if (type == kCCBKeyframeEasingBounceOut)
    {
        float newT = [self bounceTime:t];
        return newT;
    }
    else if (type == kCCBKeyframeEasingBounceInOut)
    {
        float newT = 0;
        if (t < 0.5) {
            t = t * 2;
            newT = (1 - [self bounceTime:1-t] ) * 0.5f;
        } else
            newT = [self bounceTime:t * 2 - 1] * 0.5f + 0.5f;
        return newT;
    }
    else if (type == kCCBKeyframeEasingBackIn)
    {
        float overshoot = 1.70158f;
        return t * t * ((overshoot + 1) * t - overshoot);
    }
    else if (type == kCCBKeyframeEasingBackOut)
    {
        float overshoot = 1.70158f;
        t = t - 1;
        return t * t * ((overshoot + 1) * t + overshoot) + 1;
    }
    else if (type == kCCBKeyframeEasingBackInOut)
    {
        float overshoot = 1.70158f * 1.525f;
        
        t = t * 2;
        if (t < 1)
            return (t * t * ((overshoot + 1) * t - overshoot)) / 2;
        else {
            t = t - 2;
            return (t * t * ((overshoot + 1) * t + overshoot)) / 2 + 1;
        }
    }
    
    NSAssert(NO, @"Invalid easing option");
    return 0;
}

- (BOOL) hasEaseIn
{
    return (type == kCCBKeyframeEasingCubicIn
            || type == kCCBKeyframeEasingCubicInOut
            || type == kCCBKeyframeEasingElasticIn
            || type == kCCBKeyframeEasingElasticInOut
            || type == kCCBKeyframeEasingBounceIn
            || type == kCCBKeyframeEasingBounceInOut
            || type == kCCBKeyframeEasingBackIn
            || type == kCCBKeyframeEasingBackInOut);
}

- (BOOL) hasEaseOut
{
    return (type == kCCBKeyframeEasingCubicOut
            || type == kCCBKeyframeEasingCubicInOut
            || type == kCCBKeyframeEasingElasticOut
            || type == kCCBKeyframeEasingElasticInOut
            || type == kCCBKeyframeEasingBounceOut
            || type == kCCBKeyframeEasingBounceInOut
            || type == kCCBKeyframeEasingBackOut
            || type == kCCBKeyframeEasingBackInOut);
}

- (BOOL) hasOptions
{
    return (type == kCCBKeyframeEasingCubicIn
            || type == kCCBKeyframeEasingCubicOut
            || type == kCCBKeyframeEasingCubicInOut
            || type == kCCBKeyframeEasingElasticIn
            || type == kCCBKeyframeEasingElasticOut
            || type == kCCBKeyframeEasingElasticInOut);
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
    else if (t == kCCBKeyframeEasingElasticIn
             || t == kCCBKeyframeEasingElasticOut
             || t == kCCBKeyframeEasingElasticInOut)
    {
        self.options = [NSNumber numberWithFloat:0.3f];
    }
    type = t;
}

- (void) dealloc
{
    self.options = NULL;
    [super dealloc];
}

@end
