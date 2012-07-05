//
//  CCBActionManager.m
//  CocosBuilderExample
//
//  Created by Viktor Lidholt on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBActionManager.h"
#import "CCBSequence.h"
#import "CCBSequenceProperty.h"

@implementation CCBActionManager

@synthesize sequences;
@synthesize autoPlaySequenceId;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    sequences = [[NSMutableArray alloc] init];
    nodeSequences = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (void) addNode:(CCNode*)node andSequences:(NSDictionary*)seq
{
    [node retain];
    
    NSValue* nodePtr = [NSValue valueWithPointer:node];
    [nodeSequences setObject:seq forKey:nodePtr];
}

- (int) sequenceIdForSequenceNamed:(NSString*)name
{
    for (CCBSequence* seq in sequences)
    {
        if ([seq.name isEqualToString:name])
        {
            return seq.sequenceId;
        }
    }
    return -1;
}


- (void) runActionsForNode:(CCNode*)node sequenceProperty:(CCBSequenceProperty*)seqProp tweenDuration:(float)tweenDuration
{
    NSArray* keyframes = [seqProp keyframes];
    
    if (keyframes.count == 0)
    {
        // TODO: Add support for base values (no animation)
    }
    else if (keyframes.count == 1)
    {
        // Use the single keyframe as value (no animation)
    }
    else
    {
        int type = [seqProp type];
        
    }
}

- (void) runActionsForSequenceNamed:(NSString*)name tweenDuration:(float)tweenDuration
{
    int seqId = [self sequenceIdForSequenceNamed:name];
    NSAssert(seqId != -1, @"Sequence named %@ couldn't be found");
    
    for (NSValue* nodePtr in nodeSequences)
    {
        CCNode* node = [nodePtr pointerValue];
        [node stopAllActions];
        
        NSDictionary* seqNodeProps = [nodeSequences objectForKey:[NSNumber numberWithInt:seqId]];
        
        for (NSString* propName in seqNodeProps)
        {
            CCBSequenceProperty* seqProp = [seqNodeProps objectForKey:propName];
            [self runActionsForNode:node sequenceProperty:seqProp tweenDuration:tweenDuration];
        }
    }
}

- (void) runActionsForSequenceNamed:(NSString*)name
{
    [self runActionsForSequenceNamed:name tweenDuration:0];
}

- (void) dealloc
{
    for (NSValue* nodePtr in nodeSequences)
    {
        CCNode* node = [nodePtr pointerValue];
        [node release];
    }
    
    [sequences release];
    [nodeSequences release];
    [super dealloc];
}

@end
