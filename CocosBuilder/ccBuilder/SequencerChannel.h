//
//  SequencerChannel.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/7/13.
//
//

#import <Foundation/Foundation.h>

@class SequencerNodeProperty;
@class SequencerKeyframe;

@interface SequencerChannel : NSObject

@property (nonatomic, copy) NSString* displayName;
@property (nonatomic, retain) SequencerNodeProperty* seqNodeProp;
@property (nonatomic, readonly) int keyframeType;

- (id) initWithSerialization:(id)ser;
- (id) serialize;

- (SequencerKeyframe*) defaultKeyframe;
- (void) addDefaultKeyframeAtTime:(float)t;
- (NSArray*) keyframesAtTime:(float)t;

@end
