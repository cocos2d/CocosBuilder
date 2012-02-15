//
//  InspectorPosition.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorPosition.h"

@implementation InspectorPosition

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

- (void) refresh
{
    [self willChangeValueForKey:@"posX"];
    [self didChangeValueForKey:@"posX"];
    
    [self willChangeValueForKey:@"posY"];
    [self didChangeValueForKey:@"posY"];
}

@end
