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

#import "InspectorPosition.h"
#import "PositionPropertySetter.h"
#import "CCBGlobals.h"
#import "CocosBuilderAppDelegate.h"
#import "CCNode+NodeInfo.h"
#import "SequencerKeyframe.h"

@implementation InspectorPosition

- (void) setPosX:(float)posX
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
	NSPoint pt = [PositionPropertySetter positionForNode:selection prop:propertyName];
    pt.x = posX;
    [PositionPropertySetter setPosition:pt type:[PositionPropertySetter positionTypeForNode:selection prop:propertyName] forNode:selection prop:propertyName];
    
    NSArray* animValue = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:pt.x],
                          [NSNumber numberWithFloat:pt.y],
                          NULL];
    [self updateAnimateablePropertyValue:animValue];
    
    [self updateAffectedProperties];
}

- (float) posX
{
    return [PositionPropertySetter positionForNode:selection prop:propertyName].x;
}

- (void) setPosY:(float)posY
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    NSPoint pt = [PositionPropertySetter positionForNode:selection prop:propertyName];
    pt.y = posY;
    [PositionPropertySetter setPosition:pt type:[PositionPropertySetter positionTypeForNode:selection prop:propertyName] forNode:selection prop:propertyName];
    
    NSArray* animValue = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:pt.x],
                          [NSNumber numberWithFloat:pt.y],
                          NULL];
    [self updateAnimateablePropertyValue:animValue];
    
    [self updateAffectedProperties];
}

- (float) posY
{
    return [PositionPropertySetter positionForNode:selection prop:propertyName].y;
}

- (id) convertAnimatableValue:(id)value fromType:(int)fromType toType:(int)toType
{
    NSPoint relPos = NSZeroPoint;
    relPos.x = [[value objectAtIndex:0] floatValue];
    relPos.y = [[value objectAtIndex:1] floatValue];
    
    relPos = [PositionPropertySetter convertPosition:relPos fromType:fromType toType:toType forNode:selection];
    
    return [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:relPos.x],
                              [NSNumber numberWithFloat:relPos.y],
                              NULL];
}

- (void) setPositionType:(int)positionType
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    int oldPositionType = [PositionPropertySetter positionTypeForNode:selection prop:propertyName];
    
    // Update keyframes
    NSArray* keyframes = [selection keyframesForProperty:propertyName];
    for (SequencerKeyframe* keyframe in keyframes)
    {
        keyframe.value = [self convertAnimatableValue:keyframe.value fromType:oldPositionType toType:positionType];
    }
    
    // Update base value
    id baseValue = [selection baseValueForProperty:propertyName];
    if (baseValue)
    {
        baseValue = [self convertAnimatableValue:baseValue fromType:oldPositionType toType:positionType];
        [selection setBaseValue:baseValue forProperty:propertyName];
    }
    
    [PositionPropertySetter setPositionType:positionType forNode:selection prop:propertyName];
    [self refresh];
    
    [self updateAffectedProperties];
}

- (int) positionType
{
    return [PositionPropertySetter positionTypeForNode:selection prop:propertyName];
}

- (void) refresh
{
    [self willChangeValueForKey:@"posX"];
    [self didChangeValueForKey:@"posX"];
    
    [self willChangeValueForKey:@"posY"];
    [self didChangeValueForKey:@"posY"];
    
    [self willChangeValueForKey:@"positionType"];
    [self didChangeValueForKey:@"positionType"];
}

@end
