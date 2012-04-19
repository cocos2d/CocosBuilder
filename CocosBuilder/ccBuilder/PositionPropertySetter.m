//
//  PositionPropertySetter.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PositionPropertySetter.h"
#import "CCBGlobals.h"

@implementation PositionPropertySetter

+ (void) setPosition:(NSPoint)pos type:(int)type forNode:(CCNode*) node prop:(NSString*)prop
{
    CGSize parentSize = node.parent.contentSize;
    CGPoint absPos = ccp(0,0);
    
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
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:[NSValue valueWithPoint:pos] forKey:prop andNode:node];
    [cs setExtraProp:[NSNumber numberWithInt:type] forKey:[NSString stringWithFormat:@"%@Type", prop] andNode:node];
    
    NSLog(@"setPosition: (%f,%f) type: %d",pos.x, pos.y, type);
}

+ (void) setPosition:(CGPoint)pos forNode:(CCNode *)node prop:(NSString *)prop
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

@end
