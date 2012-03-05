//
//  InspectorPointLock.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorPointLock.h"

@implementation InspectorPointLock

- (void) setPosX:(float)posX
{
	NSPoint pt = [[self propertyForSelection] pointValue];
    pt.x = posX;
    [self setPropertyForSelection:[NSValue valueWithPoint:pt]];
}

- (float) posX
{
    return [[self propertyForSelection] pointValue].x;
}

- (void) setPosY:(float)posY
{
	NSPoint pt = [[self propertyForSelection] pointValue];
    pt.y = posY;
    [self setPropertyForSelection:[NSValue valueWithPoint:pt]];
}

- (float) posY
{
    return [[self propertyForSelection] pointValue].y;
}

@end
