/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "InspectorColor4FVar.h"

@implementation InspectorColor4FVar

- (void) setColor:(NSColor *)color
{
    color = [color colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
    
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
    color = [color colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
    
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
