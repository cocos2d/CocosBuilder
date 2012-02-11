//
//  InspectorColor3.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorColor3.h"

@implementation InspectorColor3

- (void) setColor:(NSColor *)color
{
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    ccColor3B c = ccc3(r*255, g*255, b*255);
    
    NSValue* colorValue = [NSValue value:&c withObjCType:@encode(ccColor3B)];
    [self setPropertyForSelection:colorValue];
    
}

- (NSColor*) color
{
    NSValue* colorValue = [self propertyForSelection];
    ccColor3B c;
    [colorValue getValue:&c];
    
    return [NSColor colorWithCalibratedRed:c.r/255.0 green:c.g/255.0 blue:c.b/255.0 alpha:1];
}

@end
