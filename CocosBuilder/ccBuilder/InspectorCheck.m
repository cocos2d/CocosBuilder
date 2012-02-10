//
//  InspectorCheck.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorCheck.h"

@implementation InspectorCheck

- (void) setBoolean:(BOOL)boolean
{
    [self setPropertyForSelection:[NSNumber numberWithBool:boolean]];
}

- (BOOL) boolean
{
    return [[self propertyForSelection] boolValue];
}

@end
