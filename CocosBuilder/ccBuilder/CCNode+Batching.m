//
//  CCNode+Batching.m
//  CocosBuilder
//
//  Created by Nick Verigakis on 28/01/2013.
//
//

#import "CCNode+Batching.h"
#import "cocos2d.h"

@implementation CCNode (Batching)

- (BOOL)isChildOfSpriteBatchNode
{
    return [self isNodeChildOfSpriteBatchNode:self];
}

- (BOOL)isNodeChildOfSpriteBatchNode:(CCNode *)node
{
    if (node.parent) {
        if ([node.parent isKindOfClass:[CCSpriteBatchNode class]])
            return YES;
        else
            [self isNodeChildOfSpriteBatchNode:node.parent];
    }
    
    return NO;
}

@end
