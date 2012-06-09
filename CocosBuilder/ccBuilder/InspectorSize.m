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

#import "InspectorSize.h"
#import "PositionPropertySetter.h"
#import "CCBGlobals.h"
#import "CocosBuilderAppDelegate.h"

@implementation InspectorSize

- (void) setWidth:(float)width
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    NSSize size = [PositionPropertySetter sizeForNode:selection prop:propertyName];
    size.width = width;
    [PositionPropertySetter setSize:size forNode:selection prop:propertyName];
    
    [self updateAffectedProperties];
}

- (float) width
{
    return [PositionPropertySetter sizeForNode:selection prop:propertyName].width;
}

- (void) setHeight:(float)height
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
	NSSize size = [PositionPropertySetter sizeForNode:selection prop:propertyName];
    size.height = height;
    [PositionPropertySetter setSize:size forNode:selection prop:propertyName];
    
    [self updateAffectedProperties];
}

- (float) height
{
    return [PositionPropertySetter sizeForNode:selection prop:propertyName].height;
}

- (void) setType:(int)type
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    //NSSize size = [PositionPropertySetter sizeForNode:selection prop:propertyName];
    //[PositionPropertySetter setSize:size type:type forNode:selection prop:propertyName];
    [PositionPropertySetter setSizeType:type forNode:selection prop:propertyName];
    
    [self willChangeValueForKey:@"width"];
    [self didChangeValueForKey:@"width"];
    
    [self willChangeValueForKey:@"height"];
    [self didChangeValueForKey:@"height"];
    
    [self updateAffectedProperties];
}

- (int) type
{
    return [PositionPropertySetter sizeTypeForNode:selection prop:propertyName];
}

- (void) refresh
{
    [PositionPropertySetter refreshSizeForNode:selection prop:propertyName];
    
    [self willChangeValueForKey:@"width"];
    [self didChangeValueForKey:@"width"];
    
    [self willChangeValueForKey:@"height"];
    [self didChangeValueForKey:@"height"];
    
    [self willChangeValueForKey:@"type"];
    [self didChangeValueForKey:@"type"];
}

@end
