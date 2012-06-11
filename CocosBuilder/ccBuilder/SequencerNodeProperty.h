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
}

@property (nonatomic,readonly) NSMutableArray* keyframes;

- (id) initWithProperty:(NSString*) name node:(CCNode*)n;
- (void) setKeyframe:(SequencerKeyframe*)keyframe;
@end
