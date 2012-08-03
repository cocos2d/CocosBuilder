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

#import "InspectorSpriteFrame.h"
#import "NodeInfo.h"
#import "CCBGlobals.h"
#import "CocosScene.h"
#import "CocosBuilderAppDelegate.h"
#import "TexturePropertySetter.h"
#import "CCBWriterInternal.h"
#import "CCBSpriteSheetParser.h"
#import "ResourceManagerUtil.h"
#import "ResourceManager.h"
#import "CCNode+NodeInfo.h"
#import "SequencerHandler.h"
#import "SequencerSequence.h"

@implementation InspectorSpriteFrame

- (void) willBeAdded
{
    // Setup menu
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    id value = [selection valueForProperty:propertyName atTime:seq.timelinePosition sequenceId:seq.sequenceId];
    
    NSString* sf = [value objectAtIndex:0];
    NSString* ssf = [value objectAtIndex:1];
    
    if ([ssf isEqualToString:kCCBUseRegularFile] || [ssf isEqualToString:@""]) ssf = NULL;
    
    [ResourceManagerUtil populateResourcePopup:popup resType:kCCBResTypeImage allowSpriteFrames:YES selectedFile:sf selectedSheet:ssf target:self];
}

- (void) selectedResource:(id)sender
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    id item = [sender representedObject];
    
    // Fetch info about the sprite name
    NSString* sf = NULL;
    NSString* ssf = NULL;
    
    if ([item isKindOfClass:[RMResource class]])
    {
        RMResource* res = item;
        
        if (res.type == kCCBResTypeImage)
        {
            sf = [ResourceManagerUtil relativePathFromAbsolutePath:res.filePath];
            ssf = kCCBUseRegularFile;
            [ResourceManagerUtil setTitle:sf forPopup:popup];
        }
    }
    else if ([item isKindOfClass:[RMSpriteFrame class]])
    {
        RMSpriteFrame* frame = item;
        sf = frame.spriteFrameName;
        ssf = [ResourceManagerUtil relativePathFromAbsolutePath:frame.spriteSheetFile];
        [ResourceManagerUtil setTitle:[NSString stringWithFormat:@"%@/%@",ssf,sf] forPopup:popup];
    }
    
    // Set the properties and sprite frames
    if (sf && ssf)
    {
        [selection setExtraProp:sf forKey:propertyName];
        [selection setExtraProp:ssf forKey:[NSString stringWithFormat:@"%@Sheet", propertyName]];
    
        [TexturePropertySetter setSpriteFrameForNode:selection andProperty:propertyName withFile:sf andSheetFile:ssf];
        
        [self updateAnimateablePropertyValue:[NSArray arrayWithObjects:sf, ssf , nil]];
    }
    
    [self updateAffectedProperties];
}

@end
