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

#import <Foundation/Foundation.h>

@class SequencerNodeProperty;
@class SequencerKeyframeEasing;

enum
{
    // Node properties
    kCCBKeyframeTypeUndefined,
    kCCBKeyframeTypeToggle,
    kCCBKeyframeTypeDegrees,
    kCCBKeyframeTypePosition,
    kCCBKeyframeTypeScaleLock,
    kCCBKeyframeTypeByte,
    kCCBKeyframeTypeColor3,
    kCCBKeyframeTypeSpriteFrame,
    kCCBKeyframeTypeFloatXY,
    
    // Channels
    kCCBKeyframeTypeSoundEffects,
    kCCBKeyframeTypeCallbacks,
};

@interface SequencerKeyframe : NSObject
{
    id value;
    int type;
    NSString* name;
    
    float time;
    float timeAtDragStart;
    BOOL selected;
    
    SequencerNodeProperty* parent;
    SequencerKeyframeEasing* easing;
}

@property (nonatomic,retain) id value;
@property (nonatomic,assign) int type;
@property (nonatomic,retain) NSString* name;

@property (nonatomic,assign) float time;
@property (nonatomic,assign) float timeAtDragStart;
@property (nonatomic,assign) BOOL selected;

@property (nonatomic,assign) SequencerNodeProperty* parent;
@property (nonatomic,retain) SequencerKeyframeEasing* easing;

- (id) initWithSerialization:(id)ser;
- (id) serialization;

+ (int) keyframeTypeFromPropertyType:(NSString*)type;

- (BOOL) valueIsEqualTo:(SequencerKeyframe*)keyframe;
- (BOOL) supportsFiniteTimeInterpolations;

@end
