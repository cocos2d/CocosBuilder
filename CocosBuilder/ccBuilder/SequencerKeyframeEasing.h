//
//  SequencerKeyframeEasing.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum
{
    kCCBKeyframeEasingInstant,
    
    kCCBKeyframeEasingLinear,
    
    kCCBKeyframeEasingCubicIn,
    kCCBKeyframeEasingCubicOut,
    kCCBKeyframeEasingCubicInOut,
    
    kCCBKeyframeEasingElasticIn,
    kCCBKeyframeEasingElasticOut,
    kCCBKeyframeEasingElasticInOut,
    
    kCCBKeyframeEasingBounceIn,
    kCCBKeyframeEasingBounceOut,
    kCCBKeyframeEasingBounceInOut,
    
    kCCBKeyframeEasingBackIn,
    kCCBKeyframeEasingBackOut,
    kCCBKeyframeEasingBackInOut,
};

@interface SequencerKeyframeEasing : NSObject
{
    int type;
    id options;
}

+ (id) easing;

- (id) initWithSerialization:(id) ser;
- (id) serialization;

@property (nonatomic,assign) int type;
@property (nonatomic,retain) id options;
@property (nonatomic,readonly) BOOL hasEaseIn;
@property (nonatomic,readonly) BOOL hasEaseOut;
@property (nonatomic,readonly) BOOL hasOptions;

- (float) easeValue:(float)t;

@end
