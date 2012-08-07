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

#import "InspectorColor3.h"
#import "CCBWriterInternal.h"

@implementation InspectorColor3

- (void) setColor:(NSColor *)color
{
    CGFloat r, g, b, a;
    
    color = [color colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
    
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    ccColor3B c = ccc3(r*255, g*255, b*255);
    
    NSValue* colorValue = [NSValue value:&c withObjCType:@encode(ccColor3B)];
    [self setPropertyForSelection:colorValue];
    
    [self updateAnimateablePropertyValue: [CCBWriterInternal serializeColor3:c]];
    
}

- (NSColor*) color
{
    NSValue* colorValue = [self propertyForSelection];
    ccColor3B c;
    [colorValue getValue:&c];
    
    return [NSColor colorWithCalibratedRed:c.r/255.0 green:c.g/255.0 blue:c.b/255.0 alpha:1];
}

@end
