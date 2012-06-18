//
//  SequencerNodeProperty.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@class SequencerKeyframe;

@interface SequencerNodeProperty : NSObject
{
    NSMutableArray* keyframes;
    NSString* propName;
    int type;
}

@property (nonatomic,readonly) NSMutableArray* keyframes;
@property (nonatomic,readonly) int type;

- (id) initWithProperty:(NSString*) name node:(CCNode*)n;
- (void) setKeyframe:(SequencerKeyframe*)keyframe;
- (SequencerKeyframe*) keyframeBetweenMinTime:(float)minTime maxTime:(float)maxTime;
- (NSArray*) keyframesBetweenMinTime:(float)minTime maxTime:(float)maxTime;
- (void) sortKeyframes;
- (id) valueAtTime:(float)time;
- (BOOL) hasKeyframeAtTime:(float)time;
- (SequencerKeyframe*) keyframeAtTime:(float)time;
- (void) updateNode:(CCNode*)node toTime:(float)time;
@end
