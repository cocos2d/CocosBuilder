//
//  InspectorInteger.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorInteger.h"

@implementation InspectorInteger

- (void) setInteger:(int)integer
{
    [self setPropertyForSelection:[NSNumber numberWithInt:integer]];
}

- (int) integer
{
    return [[self propertyForSelection] intValue];
}

@end
