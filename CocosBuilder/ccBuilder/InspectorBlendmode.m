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

#import "InspectorBlendmode.h"

@implementation InspectorBlendmode

- (void) setBlendSrc:(int)blendSrc
{
    ccBlendFunc blend;
    NSValue* blendValue = [self propertyForSelection];
    [blendValue getValue:&blend];
    
    blend.src = blendSrc;
    
    blendValue = [NSValue value:&blend withObjCType:@encode(ccBlendFunc)];
    [self setPropertyForSelection:blendValue];
}

- (int) blendSrc
{
    ccBlendFunc blend;
    NSValue* blendValue = [self propertyForSelection];
    [blendValue getValue:&blend];
    
    return blend.src;
}

- (void) setBlendDst:(int)blendDst
{
    ccBlendFunc blend;
    NSValue* blendValue = [self propertyForSelection];
    [blendValue getValue:&blend];
    
    blend.dst = blendDst;
    
    blendValue = [NSValue value:&blend withObjCType:@encode(ccBlendFunc)];
    [self setPropertyForSelection:blendValue];
}

- (int) blendDst
{
    ccBlendFunc blend;
    NSValue* blendValue = [self propertyForSelection];
    [blendValue getValue:&blend];
    
    return blend.dst;
}

- (IBAction)blendNormal:(id)sender
{
    self.blendSrc = GL_ONE;
    self.blendDst = GL_ONE_MINUS_SRC_ALPHA;
}

- (IBAction)blendAdditive:(id)sender
{
    self.blendSrc = GL_ONE;
    self.blendDst = GL_ONE;
}

- (void) refresh
{
    [self willChangeValueForKey:@"blendSrc"];
    [self didChangeValueForKey:@"blendSrc"];
    
    [self willChangeValueForKey:@"blendDst"];
    [self didChangeValueForKey:@"blendDst"];
}

@end
