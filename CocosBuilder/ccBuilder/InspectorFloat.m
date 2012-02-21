//
//  InspectorFloat.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorFloat.h"

@implementation InspectorFloat

- (void) setF:(float)f
{
    [self setPropertyForSelection:[NSNumber numberWithFloat:f]];
}

- (float) f
{
    return [[self propertyForSelection] floatValue];
}

@end
