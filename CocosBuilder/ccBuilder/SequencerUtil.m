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
#import "ResourceManagerUtil.h"
#import "CCNode+NodeInfo.h"
#import "PlugInNode.h"
#import "SequencerHandler.h"
#import "SequencerSequence.h"
#import "SequencerKeyframe.h"
#import "SequencerKeyframeEasing.h"
#import "CCBWriterInternal.h"

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
        else if (![selectedObj isKindOfClass:[RMSpriteFrame class]])
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
    if (!canCreate) return;
    
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    
    CCNode* selectedNode = [[CocosBuilderAppDelegate appDelegate] selectedNode];
    NSArray* selectedImages = [SequencerUtil selectedResources];
    
    float currentTime = seq.timelinePosition;
    
    for (id item in selectedImages)
    {
        // Get spriteFile and spriteSheet
        NSString* spriteFile = NULL;
        NSString* spriteSheetFile = NULL;
        
        if ([item isKindOfClass:[RMResource class]])
        {
            RMResource* res = item;
            spriteFile = [ResourceManagerUtil relativePathFromAbsolutePath: res.filePath];
        }
        else if ([item isKindOfClass:[RMSpriteFrame class]])
        {
            RMSpriteFrame* frame = item;
            spriteFile = frame.spriteFrameName;
            spriteSheetFile = [ResourceManagerUtil relativePathFromAbsolutePath: frame.spriteSheetFile];
            if (!spriteSheetFile) spriteFile = NULL;
        }
        
        if (!spriteFile) spriteFile = @"";
        if (!spriteSheetFile) spriteSheetFile = kCCBUseRegularFile;
        
        // Create keyframe
        SequencerKeyframe* kf = [[[SequencerKeyframe alloc] init] autorelease];
        kf.time = currentTime;
        kf.type = kCCBKeyframeTypeSpriteFrame;
        kf.name = @"displayFrame";
        kf.value = [NSArray arrayWithObjects: spriteFile, spriteSheetFile, nil];
        kf.easing.type = kCCBKeyframeEasingInstant;
        
        // Add the keyframe
        [selectedNode addKeyframe:kf forProperty:@"displayFrame" atTime:currentTime sequenceId:seq.sequenceId];
        
        // Step one keyframe ahead
        currentTime = [seq alignTimeToResolution: currentTime + 1/seq.timelineResolution];
    }
}

+ (BOOL) canAlignKeyframesToMarker
{
    NSArray* keyframes = [[SequencerHandler sharedHandler] selectedKeyframesForCurrentSequence];
    
    if (keyframes.count == 0) return NO;
    
    SequencerSequence* seq = [[SequencerHandler sharedHandler] currentSequence];
    for (SequencerKeyframe* kf in keyframes)
    {
        if (kf.time != seq.timelinePosition) return YES;
    }
    
    return NO;
}

+ (void) alignKeyframesToMarker
{
    BOOL canAlign = [SequencerUtil canAlignKeyframesToMarker];
    if (!canAlign) return;
    
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*alignKeyframesToMarker"];
    
    NSArray* keyframes = [[SequencerHandler sharedHandler] selectedKeyframesForCurrentSequence];
    SequencerSequence* seq = [[SequencerHandler sharedHandler] currentSequence];
    
    for (SequencerKeyframe* kf in keyframes)
    {
        kf.time = seq.timelinePosition;
    }
    
    [[SequencerHandler sharedHandler] redrawTimeline];
    [[SequencerHandler sharedHandler] updatePropertiesToTimelinePosition];
}

@end
