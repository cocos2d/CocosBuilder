//
//  InspectorScale.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorScaleLock.h"

@implementation InspectorScaleLock

- (void) setScaleX:(float)scaleX
{
    [self setPropertyForSelectionX:[NSNumber numberWithFloat:scaleX]];
}

- (float) scaleX
{
    return [[self propertyForSelectionX] floatValue];
}

- (void) setScaleY:(float)scaleY
{
    [self setPropertyForSelectionY:[NSNumber numberWithFloat:scaleY]];
}

- (float) scaleY
{
    return [[self propertyForSelectionY] floatValue];
}

- (void) refresh
{
    [self willChangeValueForKey:@"scaleX"];
    [self didChangeValueForKey:@"scaleX"];
    
    [self willChangeValueForKey:@"scaleY"];
    [self didChangeValueForKey:@"scaleY"];
}

@end
