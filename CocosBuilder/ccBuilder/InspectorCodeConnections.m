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

#import "InspectorCodeConnections.h"
#import "CocosScene.h"
#import "CCBGlobals.h"

@implementation InspectorCodeConnections

- (void) setCustomClass:(NSString *)customClass
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    if (!customClass) customClass = @"";
    [cs setExtraProp:customClass forKey:@"customClass" andNode:selection];
}

- (NSString*) customClass
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [cs extraPropForKey:@"customClass" andNode:selection];
}

- (void) setMemberVarAssignmentName:(NSString *)memberVarAssignmentName
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    if (!memberVarAssignmentName) memberVarAssignmentName = @"";
    [cs setExtraProp:memberVarAssignmentName forKey:@"memberVarAssignmentName" andNode:selection];
}

- (NSString*) memberVarAssignmentName
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [cs extraPropForKey:@"memberVarAssignmentName" andNode:selection];
}

- (void) setMemberVarAssignmentType:(int)memberVarAssignmentType
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:[NSNumber numberWithInt: memberVarAssignmentType] forKey:@"memberVarAssignmentType" andNode:selection];
}

- (int) memberVarAssignmentType
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [[cs extraPropForKey:@"memberVarAssignmentType" andNode:selection] intValue];
}

@end
