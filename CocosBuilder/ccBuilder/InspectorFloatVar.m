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
    // TODO: Try/catch is quick fix for particle systems
    @try
    {
        [self setPropertyForSelection:[NSNumber numberWithFloat:f]];
    }
    @catch (NSException *exception)
    {
    }
    
}

- (float) f
{
    @try
    {
        return [[self propertyForSelection] floatValue];
    }
    @catch (NSException *exception)
    {
        return 0;
    }
}

- (void) setFVar:(float)fVar
{
    @try
    {
        [self setPropertyForSelectionVar:[NSNumber numberWithFloat:fVar]];
    }
    @catch (NSException *exception)
    {
    }
}

- (float) fVar
{
    @try
    {
        return [[self propertyForSelectionVar] floatValue];
    }
    @catch (NSException *exception)
    {
        return 0;
    }
}

@end
