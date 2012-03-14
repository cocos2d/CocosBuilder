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

#import "InspectorBlock.h"
#import "CCBGlobals.h"

@implementation InspectorBlock

- (void) setSelector:(NSString *)selector
{
    if (!selector) selector = @"";
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:selector forKey:propertyName andNode:selection];
}

- (NSString*) selector
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    NSString* sel = [cs extraPropForKey:propertyName andNode:selection];
    if (!sel) sel = @"";
    return sel;
}

- (void) setTarget:(int)target
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:[NSNumber numberWithInt:target] forKey:[NSString stringWithFormat:@"%@Target", propertyName] andNode:selection];
}

- (int) target
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [[cs extraPropForKey:[NSString stringWithFormat:@"%@Target", propertyName] andNode:selection] intValue];
}

@end
