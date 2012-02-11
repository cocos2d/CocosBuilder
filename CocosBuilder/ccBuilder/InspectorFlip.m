//
//  InspectorFlip.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorFlip.h"

@implementation InspectorFlip

- (void) setFlipX:(BOOL)flipX
{
    [self setPropertyForSelectionX:[NSNumber numberWithBool:flipX]];
}

- (BOOL) flipX
{
    return [[self propertyForSelectionX] boolValue];
}

- (void) setFlipY:(BOOL)flipY
{
    [self setPropertyForSelectionY:[NSNumber numberWithBool:flipY]];
}

- (BOOL) flipY
{
    return [[self propertyForSelectionY] boolValue];
}

@end
