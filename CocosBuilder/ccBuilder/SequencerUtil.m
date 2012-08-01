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

#import "SequencerUtil.h"
#import "CocosBuilderAppDelegate.h"
#import "ResourceManager.h"
#import "CCNode+NodeInfo.h"
#import "PlugInNode.h"

@implementation SequencerUtil

+ (NSArray*) selectedResources
{
    NSMutableArray* selRes = [NSMutableArray array];
    
    NSOutlineView* outlineView = [CocosBuilderAppDelegate appDelegate].outlineProject;
    NSIndexSet* idxSet = [outlineView selectedRowIndexes];
    
    NSUInteger idx = [idxSet firstIndex];
    while (idx != NSNotFound)
    {
        [selRes addObject:[outlineView itemAtRow:idx]];
        idx = [idxSet indexGreaterThanIndex:idx];
    }
    
    return selRes;
}

+ (BOOL) canCreateFramesFromSelectedResources
{
    // Check that all selected resources are images
    NSArray* selRes = [SequencerUtil selectedResources];
    
    for (id selectedObj in selRes)
    {
        if ([selectedObj isKindOfClass:[RMResource class]])
        {
            RMResource* res = selectedObj;
            if (res.type != kCCBResTypeImage)
            {
                return NO;
            }
        }
        else
        {
            return NO;
        }
    }
    
    // Check that the selected object is a sprite
    CCNode* selectedNode = [[CocosBuilderAppDelegate appDelegate] selectedNode];
    if (!selectedNode) return NO;
    
    if (![selectedNode.plugIn.nodeClassName isEqualToString:@"CCSprite"])
    {
        return NO;
    }
    
    return YES;
}

+ (void) createFramesFromSelectedResources
{
    BOOL canCreate = [SequencerUtil canCreateFramesFromSelectedResources];
    
    NSLog(@"canCreate: %d", canCreate);
}

@end
