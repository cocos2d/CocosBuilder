//
//  InspectorPoint.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorPoint.h"

@implementation InspectorPoint

- (void) setPosX:(float)posX
{
    CGPoint pt = [[self propertyForSelection] pointValue];
    pt.x = posX;
    [self setPropertyForSelection:[NSValue valueWithPoint:pt]];
}

- (float) posX
{
    return [[self propertyForSelection] pointValue].x;
}

- (void) setPosY:(float)posY
{
    CGPoint pt = [[self propertyForSelection] pointValue];
    pt.y = posY;
    [self setPropertyForSelection:[NSValue valueWithPoint:pt]];
}

- (float) posY
{
    return [[self propertyForSelection] pointValue].y;
}

@end
