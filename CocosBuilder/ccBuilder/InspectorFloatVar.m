//
//  InspectorFloatVar.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorFloatVar.h"

@implementation InspectorFloatVar

- (void) setF:(float)f
{
    [self setPropertyForSelection:[NSNumber numberWithFloat:f]];
}

- (float) f
{
    return [[self propertyForSelection] floatValue];
}

- (void) setFVar:(float)fVar
{
    [self setPropertyForSelectionVar:[NSNumber numberWithFloat:fVar]];
}

- (float) fVar
{
    return [[self propertyForSelectionVar] floatValue];
}

@end
