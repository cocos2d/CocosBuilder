//
//  InspectorDegrees.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorDegrees.h"

@implementation InspectorDegrees

- (void) setDegrees:(float)degrees
{
    [self setPropertyForSelection:[NSNumber numberWithFloat:degrees]];
}

- (float) degrees
{
    return [[self propertyForSelection] floatValue];
}

- (void) refresh
{
    [self willChangeValueForKey:@"degrees"];
    [self didChangeValueForKey:@"degrees"];
}

@end
