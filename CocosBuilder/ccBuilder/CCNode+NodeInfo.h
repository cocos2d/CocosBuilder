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

#import "cocos2d.h"

@class PlugInNode;
@class SequencerNodeProperty;
@class SequencerKeyframe;

@interface CCNode (NodeInfo)

@property (nonatomic,assign) BOOL seqExpanded;
@property (nonatomic,readonly) PlugInNode* plugIn;
@property (nonatomic,copy) NSString* displayName;
@property (nonatomic,retain) NSMutableArray* customProperties;
@property (nonatomic,assign) CGPoint transformStartPosition;

- (id) extraPropForKey:(NSString*)key;
- (void) setExtraProp:(id)prop forKey:(NSString*)key;
- (void)removeExtraPropForKey:(NSString*)key;

- (id) baseValueForProperty:(NSString*)name;
- (void) setBaseValue:(id)value forProperty:(NSString*)name;

- (SequencerNodeProperty*) sequenceNodeProperty:(NSString*)name sequenceId:(int)seqId;
- (void) enableSequenceNodeProperty:(NSString*)name sequenceId:(int)seqId;

- (void) addKeyframe:(SequencerKeyframe*)keyframe forProperty:(NSString*)name atTime:(float)time sequenceId:(int)seqId;
- (void) addDefaultKeyframeForProperty:(NSString*)name atTime:(float)time sequenceId:(int)seqId;
- (void) duplicateKeyframesFromSequenceId:(int)fromSeqId toSequenceId:(int)toSeqId;

- (void) deselectAllKeyframes;
- (void) addSelectedKeyframesToArray:(NSMutableArray*)keyframes;

- (id) valueForProperty:(NSString*)name atTime:(float)time sequenceId:(int)seqId;
- (void) updatePropertiesTime:(float)time sequenceId:(int)seqId;

- (void) deleteSequenceId:(int) seqId;

- (BOOL) deleteSelectedKeyframesForSequenceId:(int)seqId;

- (BOOL) deleteDuplicateKeyframesForSequenceId:(int)seqId;
- (void) deleteKeyframesAfterTime:(float)time sequenceId:(int)seqId;

- (NSArray*) keyframesForProperty:(NSString*) prop;
- (BOOL) hasKeyframesForProperty:(NSString*) prop;

- (id) serializeAnimatedProperties;
- (void) loadAnimatedPropertiesFromSerialization:(id)ser;

- (NSString*) customPropertyNamed:(NSString*)name;
- (void) setCustomPropertyNamed:(NSString*)name value:(NSString*)value;

- (id) serializeCustomProperties;
- (void) loadCustomPropertiesFromSerialization:(id)ser;
- (void) loadCustomPropertyValuesFromSerialization:(id)ser;
- (BOOL) shouldDisableProperty:(NSString*) prop;

- (void) setUsesFlashSkew:(BOOL)seqExpanded;
- (BOOL) usesFlashSkew;

@end
