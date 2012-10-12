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

#import "InspectorCodeConnectionsJS.h"
#import "CocosScene.h"
#import "CCBGlobals.h"
#import "CCNode+NodeInfo.h"
#import "CocosBuilderAppDelegate.h"

@implementation InspectorCodeConnectionsJS

- (void) setCustomClass:(NSString *)customClass
{
    NSString* previousCustomClass = [selection extraPropForKey:@"customClass"];
    id disclosureForPreviousCustomClass = [selection extraPropForKey:previousCustomClass];
    
    if (disclosureForPreviousCustomClass) {
        [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:previousCustomClass];
        [selection removeExtraPropForKey:previousCustomClass];
    }
    
    if (customClass) {
        [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:customClass];
        [selection setExtraProp:[NSNumber numberWithInt:NSOnState] forKey:customClass];
    }
    
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:@"customClass"];
    
    if (!customClass) customClass = @"";
    [selection setExtraProp:customClass forKey:@"customClass"];
    
    
    // Reload the inspector
    [[CocosBuilderAppDelegate appDelegate] performSelectorOnMainThread:@selector(updateInspectorFromSelection) withObject:NULL waitUntilDone:NO];
}

- (NSString*) customClass
{
    return [selection extraPropForKey:@"customClass"];
}

- (void) setJsController:(NSString *)jsController
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:@"jsController"];
    
    if (!jsController) jsController = @"";
    [selection setExtraProp:jsController forKey:@"jsController"];
}

- (NSString*) jsController
{
    NSString* jsc = [selection extraPropForKey:@"jsController"];
    if (!jsc) jsc = @"";
    return jsc;
}

- (void) setMemberVarAssignmentName:(NSString *)memberVarAssignmentName
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:@"memberVarAssignmentName"];
    
    if (!memberVarAssignmentName) memberVarAssignmentName = @"";
    [selection setExtraProp:memberVarAssignmentName forKey:@"memberVarAssignmentName"];
}

- (NSString*) memberVarAssignmentName
{
    return [selection extraPropForKey:@"memberVarAssignmentName"];
}

- (void) setMemberVarAssignmentType:(int)memberVarAssignmentType
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:@"memberVarAssignmentType"];
    
    [selection setExtraProp:[NSNumber numberWithInt: memberVarAssignmentType] forKey:@"memberVarAssignmentType"];
}

- (int) memberVarAssignmentType
{
    return [[selection extraPropForKey:@"memberVarAssignmentType"] intValue];
}

@end
