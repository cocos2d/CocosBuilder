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
    // TODO: Try/catch is quick fix for particle systems
    @try
    {
        CGPoint pt = [[self propertyForSelection] pointValue];
        pt.x = posX;
        [self setPropertyForSelection:[NSValue valueWithPoint:pt]];
    }
    @catch (NSException *exception)
    {
    }
    
}

- (float) posX
{
    @try
    {
        return [[self propertyForSelection] pointValue].x;
    }
    @catch (NSException *exception)
    {
        return 0;
    }
}

- (void) setPosY:(float)posY
{
    @try
    {
        CGPoint pt = [[self propertyForSelection] pointValue];
        pt.y = posY;
        [self setPropertyForSelection:[NSValue valueWithPoint:pt]];
    }
    @catch (NSException *exception)
    {
    }
}

- (float) posY
{
    @try
    {
        return [[self propertyForSelection] pointValue].y;
    }
    @catch (NSException *exception)
    {
        return 0;
    }
}

@end
