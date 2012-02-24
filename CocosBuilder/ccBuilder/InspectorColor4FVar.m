//
//  InspectorColor4Var.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorColor4FVar.h"

@implementation InspectorColor4FVar

- (void) setColor:(NSColor *)color
{
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    ccColor4F c = ccc4f(r, g, b, a);
    
    NSValue* colorValue = [NSValue value:&c withObjCType:@encode(ccColor4F)];
    [self setPropertyForSelection:colorValue];
    
}

- (NSColor*) color
{
    NSValue* colorValue = [self propertyForSelection];
    ccColor4F c;
    [colorValue getValue:&c];
    
    return [NSColor colorWithCalibratedRed:c.r green:c.g blue:c.b alpha:c.a];
}

- (void) setColorVar:(NSColor *)color
{
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    ccColor4F c = ccc4f(r, g, b, a);
    
    NSValue* colorValue = [NSValue value:&c withObjCType:@encode(ccColor4F)];
    
    [self setPropertyForSelectionVar:colorValue];
    
}

- (NSColor*) colorVar
{
    NSValue* colorValue = [self propertyForSelectionVar];
    ccColor4F c;
    [colorValue getValue:&c];
    
    return [NSColor colorWithCalibratedRed:c.r green:c.g blue:c.b alpha:c.a];
}

@end
