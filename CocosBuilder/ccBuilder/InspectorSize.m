//
//  InspectorSize.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorSize.h"

@implementation InspectorSize

- (void) setWidth:(float)width
{
    CGSize size = [[self propertyForSelection] sizeValue];
    size.width = width;
    [self setPropertyForSelection:[NSValue valueWithSize:size]];
}

- (float) width
{
    return [[self propertyForSelection] sizeValue].width;
}

- (void) setHeight:(float)height
{
    CGSize size = [[self propertyForSelection] sizeValue];
    size.height = height;
    [self setPropertyForSelection:[NSValue valueWithSize:size]];
}

- (float) height
{
    return [[self propertyForSelection] sizeValue].height;
}

@end
