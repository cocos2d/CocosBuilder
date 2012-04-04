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

#import "InspectorScaleLock.h"
#import "CCBGlobals.h"
#import "CocosBuilderAppDelegate.h"

@implementation InspectorScaleLock

- (void) setScaleX:(float)scaleX
{
    [self setPropertyForSelectionX:[NSNumber numberWithFloat:scaleX]];
    if ([self locked])
    {
        [self setPropertyForSelectionY:[NSNumber numberWithFloat:scaleX]];
        [self refresh];
    }
}

- (float) scaleX
{
    return [[self propertyForSelectionX] floatValue];
}

- (void) setScaleY:(float)scaleY
{
    [self setPropertyForSelectionY:[NSNumber numberWithFloat:scaleY]];
    if ([self locked])
    {
        [self setPropertyForSelectionX:[NSNumber numberWithFloat:scaleY]];
        [self refresh];
    }
}

- (float) scaleY
{
    return [[self propertyForSelectionY] floatValue];
}

- (BOOL) locked
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [[cs extraPropForKey:[propertyName stringByAppendingString:@"Lock"] andNode:selection] boolValue];
}

- (void) setLocked:(BOOL)locked
{
    [[[CCBGlobals globals] appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:[NSNumber numberWithBool:locked] forKey:[propertyName stringByAppendingString:@"Lock"] andNode:selection];
    
    if (locked && [self scaleX] != [self scaleY])
    {
        [self setScaleY:[self scaleX]];
    }
    
    [self updateAffectedProperties];
}

- (void) refresh
{
    [self willChangeValueForKey:@"scaleX"];
    [self didChangeValueForKey:@"scaleX"];
    
    [self willChangeValueForKey:@"scaleY"];
    [self didChangeValueForKey:@"scaleY"];
}

@end
