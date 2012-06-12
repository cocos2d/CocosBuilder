//
//  CCNode+NodeInfo.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCNode+NodeInfo.h"
#import "NodeInfo.h"
#import "PlugInNode.h"
#import "SequencerNodeProperty.h"
#import "SequencerKeyframe.h"

@implementation CCNode (NodeInfo)

- (void) setExtraProp:(id)prop forKey:(NSString *)key
{
    NodeInfo* info = self.userObject;
    [info.extraProps setObject:prop forKey:key];
}

- (id) extraPropForKey:(NSString *)key
{
    NodeInfo* info = self.userObject;
    return [info.extraProps objectForKey:key];
}

- (void) setSeqExpanded:(BOOL)seqExpanded
{
    [self setExtraProp:[NSNumber numberWithBool:seqExpanded] forKey:@"seqExpanded"];
}

- (BOOL) seqExpanded
{
    return [[self extraPropForKey:@"seqExpanded"] boolValue];
}

- (PlugInNode*) plugIn
{
    NodeInfo* info = self.userObject;
    return info.plugIn;
}

- (SequencerNodeProperty*) sequenceNodeProperty:(NSString*)name sequenceId:(int)seqId
{
    NodeInfo* info = self.userObject;
    NSDictionary* dict = [info.animatableProperties objectForKey:[NSNumber numberWithInt:seqId]];
    return [dict objectForKey:name];
}

- (void) enableSequenceNodeProperty:(NSString*)name sequenceId:(int)seqId
{
    // Check if animations are already enabled for this node property
    if ([self sequenceNodeProperty:name sequenceId:seqId])
    {
        return;
    }
    
    // Get the right seqence, create one if neccessary
    NodeInfo* info = self.userObject;
    NSMutableDictionary* sequences = [info.animatableProperties objectForKey:[NSNumber numberWithInt:seqId]];
    if (!sequences)
    {
        sequences = [NSMutableDictionary dictionary];
        [info.animatableProperties setObject:sequences forKey:[NSNumber numberWithInt:seqId]];
    }
    
    SequencerNodeProperty* seqNodeProp = [[SequencerNodeProperty alloc] initWithProperty:name node:self];
    
    [sequences setObject:seqNodeProp forKey:name];
}

- (void) addKeyframe:(SequencerKeyframe*)keyframe forProperty:(NSString*)name atTime:(float)time sequenceId:(int)seqId
{
    // Make sure timeline is enabled for this property
    [self enableSequenceNodeProperty:name sequenceId:seqId];
    
    SequencerNodeProperty* seqNodeProp = [self sequenceNodeProperty:name sequenceId:seqId];
    [seqNodeProp setKeyframe:keyframe];
}

- (void) addDefaultKeyframeForProperty:(NSString*)name atTime:(float)time sequenceId:(int)seqId
{
    // Create keyframe
    SequencerKeyframe* keyframe = [[SequencerKeyframe alloc] init];
    keyframe.time = time;
    
    [self addKeyframe:keyframe forProperty:name atTime:time sequenceId:seqId];
}

- (void) deselectAllKeyframes
{
    NodeInfo* info = self.userObject;
    
    NSEnumerator* animPropEnum = [info.animatableProperties objectEnumerator];
    NSDictionary* seq;
    while ((seq = [animPropEnum nextObject]))
    {
        NSEnumerator* seqEnum = [seq objectEnumerator];
        SequencerNodeProperty* prop;
        while ((prop = [seqEnum nextObject]))
        {
            for (SequencerKeyframe* keyframe in prop.keyframes)
            {
                keyframe.selected = NO;
            }
        }
    }
}

@end
