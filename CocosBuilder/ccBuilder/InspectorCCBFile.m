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

#import "InspectorCCBFile.h"
#import "ResourceManager.h"
#import "ResourceManagerUtil.h"
#import "CCBGlobals.h"
#import "CocosBuilderAppDelegate.h"
#import "CCBDocument.h"
#import "CCBReaderInternal.h"
#import "NodeGraphPropertySetter.h"
#import "PositionPropertySetter.h"
#import "CCNode+NodeInfo.h"

@implementation InspectorCCBFile

- (void) willBeAdded
{
    // Setup menu
    NSString* sf = [selection extraPropForKey:propertyName];
    
    [ResourceManagerUtil populateResourcePopup:popup resType:kCCBResTypeCCBFile allowSpriteFrames:NO selectedFile:sf selectedSheet:NULL target:self];
}

- (void) selectedResource:(id)sender
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    id item = [sender representedObject];
    
    // Fetch info about the ccb file name
    NSString* ccbFile = NULL;
    
    if ([item isKindOfClass:[RMResource class]])
    {
        RMResource* res = item;
        
        if (res.type == kCCBResTypeCCBFile)
        {
            ccbFile = [ResourceManagerUtil relativePathFromAbsolutePath:res.filePath];
            [ResourceManagerUtil setTitle:ccbFile forPopup:popup];
        }
    }
    
    // Set the properties and sprite frames
    if (ccbFile)
    {
        [selection setExtraProp:ccbFile forKey:propertyName];
        [NodeGraphPropertySetter setNodeGraphForNode:selection andProperty:propertyName withFile:ccbFile parentSize:[PositionPropertySetter getParentSize:selection]];
    }
    
    [self updateAffectedProperties];
    
    // Reload the inspector
    [[CocosBuilderAppDelegate appDelegate] performSelectorOnMainThread:@selector(updateInspectorFromSelection) withObject:NULL waitUntilDone:NO];
}

@end
