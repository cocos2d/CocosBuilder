//
//  PositionPropertySetter.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PositionPropertySetter.h"
#import "CCBGlobals.h"
#import "NodeInfo.h"
#import "PlugInNode.h"

@implementation PositionPropertySetter

+ (void) refreshPositionsForChildren:(CCNode*)node
{
    NodeInfo* info = node.userObject;
    PlugInNode* plugIn = info.plugIn;
    if (!plugIn.canHaveChildren) return;
    
    CCArray* children = [node children];
    for (int i = 0; i < [children count]; i++)
    {
        CCNode* child = [children objectAtIndex:i];
        NodeInfo* info = child.userObject;
        PlugInNode* plugIn = info.plugIn;
        
        NSArray* positionProps = [plugIn readablePropertiesForType:@"Position"];
        for (NSString* prop in positionProps)
        {
            NSPoint oldPos = [PositionPropertySetter positionForNode:child prop:prop];
            [PositionPropertySetter setPosition:oldPos forNode:child prop:prop];
        }
        
        NSArray* sizeProps = [plugIn readablePropertiesForType:@"Size"];
        for (NSString* prop in sizeProps)
        {
            NSSize oldSize = [PositionPropertySetter sizeForNode:child prop:prop];
            [PositionPropertySetter setSize:oldSize forNode:child prop:prop];
        }
    }
}

+ (void) setPosition:(NSPoint)pos type:(int)type forNode:(CCNode*) node prop:(NSString*)prop
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
    // Get parent size
    CGSize parentSize;
    if (cs.rootNode == node)
    {
        parentSize = cs.stageSize;
    }
    else
    {
        parentSize = node.parent.contentSize;
    }
    
    // Calculate absolute position
    NSPoint absPos = ccp(0,0);
    
    if (type == kCCBPositionTypePercent)
    {
        NSPoint relativePos = ccpMult(pos, 0.01f);
        absPos.x = relativePos.x * parentSize.width;
        absPos.y = relativePos.y * parentSize.height;
    }
    else if (type == kCCBPositionTypeRelativeBottomLeft)
    {
        absPos = pos;
    }
    else if (type == kCCBPositionTypeRelativeTopLeft)
    {
        absPos.x = pos.x;
        absPos.y = parentSize.height - pos.y;
    }
    else if (type == kCCBPositionTypeRelativeTopRight)
    {
        absPos.x = parentSize.width - pos.x;
        absPos.y = parentSize.height - pos.y;
    }
    else if (type == kCCBPositionTypeRelativeBottomRight)
    {
        absPos.x = parentSize.width - pos.x;
        absPos.y = pos.y;
    }
    
    // Set the position value
    [node setValue:[NSValue valueWithPoint:absPos] forKey:prop];
    
    // Set the extra properties
    [cs setExtraProp:[NSValue valueWithPoint:pos] forKey:prop andNode:node];
    [cs setExtraProp:[NSNumber numberWithInt:type] forKey:[NSString stringWithFormat:@"%@Type", prop] andNode:node];
}

+ (void) setPosition:(NSPoint)pos forNode:(CCNode *)node prop:(NSString *)prop
{
    int type = [PositionPropertySetter positionTypeForNode:node prop:prop];
    [PositionPropertySetter setPosition:pos type:type forNode:node prop:prop];
}

+ (NSPoint) positionForNode:(CCNode*)node prop:(NSString*)prop
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [[cs extraPropForKey:prop andNode:node] pointValue];
}

+ (int) positionTypeForNode:(CCNode*)node prop:(NSString*)prop
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [[cs extraPropForKey:[NSString stringWithFormat:@"%@Type", prop] andNode:node] intValue];
}

+ (void) setSize:(NSSize)size type:(int)type forNode:(CCNode*)node prop:(NSString*)prop
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
    // Get parent size
    CGSize parentSize;
    if (cs.rootNode == node)
    {
        parentSize = cs.stageSize;
    }
    else
    {
        parentSize = node.parent.contentSize;
    }
    
    // Calculate absolute size
    NSSize absSize = NSMakeSize(0, 0);
    
    if (type == kCCBSizeTypeAbsolute)
    {
        absSize = size;
    }
    else if (type == kCCBSizeTypePercent)
    {
        absSize.width = size.width * 0.01 * parentSize.width;
        absSize.height = size.height * 0.01 * parentSize.height;
    }
    else if (type == kCCBSizeTypeRelativeContainer)
    {
        absSize.width = parentSize.width - size.width;
        absSize.height = parentSize.height - size.height;
    }
    
    // Set the size value
    [node setValue:[NSValue valueWithSize:absSize] forKey:prop];
    
    // Set the extra properties
    [cs setExtraProp:[NSValue valueWithSize:size] forKey:prop andNode:node];
    [cs setExtraProp:[NSNumber numberWithInt:type] forKey:[NSString stringWithFormat:@"%@Type", prop] andNode:node];
    
    [PositionPropertySetter refreshPositionsForChildren:node];
}

+ (void) setSize:(NSSize)size forNode:(CCNode *)node prop:(NSString *)prop
{
    int type = [PositionPropertySetter sizeTypeForNode:node prop:prop];
    [PositionPropertySetter setSize:size type:type forNode:node prop:prop];
}

+ (NSSize) sizeForNode:(CCNode*)node prop:(NSString*)prop
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [[cs extraPropForKey:prop andNode:node] sizeValue];
}

+ (int) sizeTypeForNode:(CCNode*)node prop:(NSString*)prop
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [[cs extraPropForKey:[NSString stringWithFormat:@"%@Type", prop] andNode:node] intValue];
}

@end
