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
#import "PositionPropertySetter.h"
#import "CCNode+NodeInfo.h"

@implementation InspectorScaleLock

- (void) updateAnimateableX:(float)x Y:(float)y
{
    [self updateAnimateablePropertyValue:
     [NSArray arrayWithObjects:
      [NSNumber numberWithFloat:x],
      [NSNumber numberWithFloat:y],
      nil]];
}

- (void) setScaleX:(float)scaleX
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    int type = [PositionPropertySetter scaledFloatTypeForNode:selection prop:propertyName];
    float scaleY = 0;
    
    if ([self locked])
    {
        scaleY = scaleX;
    }
    else
    {
        scaleY = [PositionPropertySetter scaleYForNode:selection prop:propertyName];
    }
    
    [self updateAnimateableX:scaleX Y:scaleY];
    [PositionPropertySetter setScaledX:scaleX Y:scaleY type:type forNode:selection prop:propertyName];
    
    [self refresh];
    [self updateAffectedProperties];
}

- (float) scaleX
{
    return [PositionPropertySetter scaleXForNode:selection prop:propertyName];
}

- (void) setScaleY:(float)scaleY
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    int type = [PositionPropertySetter scaledFloatTypeForNode:selection prop:propertyName];
    float scaleX = 0;
    
    if ([self locked])
    {
        scaleX = scaleY;
    }
    else
    {
        scaleX = [PositionPropertySetter scaleXForNode:selection prop:propertyName];
    }
    
    [self updateAnimateableX:scaleX Y:scaleY];
    [PositionPropertySetter setScaledX:scaleX Y:scaleY type:type forNode:selection prop:propertyName];
    
    [self refresh];
    [self updateAffectedProperties];
}

- (float) scaleY
{
    return [PositionPropertySetter scaleYForNode:selection prop:propertyName];
}

- (BOOL) locked
{
    return [[selection extraPropForKey:[propertyName stringByAppendingString:@"Lock"]] boolValue];
}

- (void) setLocked:(BOOL)locked
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    [selection setExtraProp:[NSNumber numberWithBool:locked] forKey:[propertyName stringByAppendingString:@"Lock"]];
    
    if (locked && [self scaleX] != [self scaleY])
    {
        [self setScaleY:[self scaleX]];
    }
    
    [self updateAffectedProperties];
}

- (int) type
{
    return [PositionPropertySetter scaledFloatTypeForNode:selection prop:propertyName];
}

- (void) setType:(int)type
{
    float scaleX = [PositionPropertySetter scaleXForNode:selection prop:propertyName];
    float scaleY = [PositionPropertySetter scaleYForNode:selection prop:propertyName];
    [PositionPropertySetter setScaledX:scaleX Y:scaleY type:type forNode:selection prop:propertyName];
}

- (void) refresh
{
    [self willChangeValueForKey:@"scaleX"];
    [self didChangeValueForKey:@"scaleX"];
    
    [self willChangeValueForKey:@"scaleY"];
    [self didChangeValueForKey:@"scaleY"];
}

@end
