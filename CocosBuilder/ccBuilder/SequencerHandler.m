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

#import "SequencerHandler.h"
#import "CocosBuilderAppDelegate.h"
#import "CCBGlobals.h"
#import "NodeInfo.h"
#import "CCNode+NodeInfo.h"
#import "PlugInNode.h"
#import "CCBWriterInternal.h"
#import "CCBReaderInternal.h"
#import "PositionPropertySetter.h"
#import "SequencerExpandBtnCell.h"
#import "SequencerStructureCell.h"
#import "SequencerCell.h"
#import "SequencerSequence.h"
#import "SequencerScrubberSelectionView.h"
#import "SequencerKeyframe.h"
#import "SequencerKeyframeEasing.h"
#import "CCNode+NodeInfo.h"
#import "CCBDocument.h"
#import "CCBPCCBFile.h"
#import <objc/runtime.h>

static SequencerHandler* sharedSequencerHandler;

@implementation SequencerHandler

@synthesize dragAndDropEnabled;
@synthesize currentSequence;
@synthesize scrubberSelectionView;
@synthesize timeDisplay;
@synthesize outlineHierarchy;
@synthesize timeScaleSlider;
@synthesize scroller;
@synthesize scrollView;
@synthesize contextKeyframe;

#pragma mark Init and singleton object

- (id) initWithOutlineView:(NSOutlineView*)view
{
    self = [super init];
    if (!self) return NULL;
    
    sharedSequencerHandler = self;
    
    appDelegate = [CocosBuilderAppDelegate appDelegate];
    outlineHierarchy = view;
    
    [outlineHierarchy setDataSource:self];
    [outlineHierarchy setDelegate:self];
    [outlineHierarchy reloadData];
    
    [outlineHierarchy registerForDraggedTypes:[NSArray arrayWithObjects: @"com.cocosbuilder.node", @"com.cocosbuilder.texture", @"com.cocosbuilder.template", @"com.cocosbuilder.ccb", NULL]];
    
    [[[outlineHierarchy outlineTableColumn] dataCell] setEditable:YES];
    
    // Set default values for timeline scale & offset
    timelineScales[0] = kCCBTimelineScale0;
    timelineScales[1] = kCCBTimelineScale1;
    timelineScales[2] = kCCBTimelineScale2;
    timelineScales[3] = kCCBTimelineScale3;
    timelineScales[4] = kCCBTimelineScale4;
    
    return self;
}

+ (SequencerHandler*) sharedHandler
{
    return sharedSequencerHandler;
}

#pragma mark Handle Scale slider

- (void) setTimeScaleSlider:(NSSlider *)tss
{
    if (tss != timeScaleSlider)
    {
        [timeScaleSlider release];
        timeScaleSlider = [tss retain];
        
        [timeScaleSlider setTarget:self];
        [timeScaleSlider setAction:@selector(timeScaleSliderUpdated:)];
    }
}

- (void) timeScaleSliderUpdated:(id)sender
{
    int scale = roundf(timeScaleSlider.doubleValue);
    timeScaleSlider.doubleValue = scale;
    
    currentSequence.timelineScale = timelineScales[scale];
}

- (void) updateScaleSlider
{
    if (!currentSequence)
    {
        timeScaleSlider.doubleValue = 2;
        [timeScaleSlider setEnabled:NO];
        return;
    }
    
    [timeScaleSlider setEnabled:YES];
    
    int val = 0;
    for (int i = 0; i < kCCBNumTimlineScales; i++)
    {
        if (currentSequence.timelineScale == timelineScales[i])
        {
            val = i;
            break;
        }
    }
    
    timeScaleSlider.doubleValue = val;
}

#pragma mark Handle scroller

- (float) visibleTimeArea
{
    NSTableColumn* column = [outlineHierarchy tableColumnWithIdentifier:@"sequencer"];
    return column.width/currentSequence.timelineScale;
}

- (float) maxTimelineOffset
{
    float visibleTime = [self visibleTimeArea];
    return max(currentSequence.timelineLength - visibleTime, 0);
}

- (void) updateScroller
{
    float visibleTime = [self visibleTimeArea];
    float maxTimeScroll = currentSequence.timelineLength - visibleTime;
    
    float proportion = visibleTime/currentSequence.timelineLength;
    
    scroller.knobProportion = proportion;
    scroller.doubleValue = currentSequence.timelineOffset / maxTimeScroll;
    
    if (proportion < 1)
    {
        [scroller setEnabled:YES];
    }
    else
    {
        [scroller setEnabled:NO];
    }
}

- (void) setScroller:(NSScroller *)s
{
    if (s != scroller)
    {
        [scroller release];
        scroller = [s retain];
        
        [scroller setTarget:self];
        [scroller setAction:@selector(scrollerUpdated:)];
        
        [self updateScroller];
    }
}

- (void) scrollerUpdated:(id)sender
{
    float newOffset = currentSequence.timelineOffset;
    float visibleTime = [self visibleTimeArea];
    
    switch ([scroller hitPart]) {
        case NSScrollerNoPart:
            break;
        case NSScrollerDecrementPage:
            newOffset -= 300 / currentSequence.timelineScale;
            break;
        case NSScrollerKnob:
            newOffset = scroller.doubleValue * (currentSequence.timelineLength - visibleTime);
            break;
        case NSScrollerIncrementPage:
            newOffset += 300 / currentSequence.timelineScale;
            break;
        case NSScrollerDecrementLine:
            newOffset -= 20 / currentSequence.timelineScale;
            break;
        case NSScrollerIncrementLine:
            newOffset += 20 / currentSequence.timelineScale;
            break;
        case NSScrollerKnobSlot:
            newOffset = scroller.doubleValue * (currentSequence.timelineLength - visibleTime);
            break;
        default:
            break;
    }
    
    
    currentSequence.timelineOffset = newOffset;
}

#pragma mark Outline view

- (void) updateOutlineViewSelection
{
    if (!appDelegate.selectedNodes.count)
    {
        [outlineHierarchy selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
        return;
    }
    CCBGlobals* g = [CCBGlobals globals];
    
    // Expand parents of the selected node
    CCNode* node = [appDelegate.selectedNodes objectAtIndex:0];
    NSMutableArray* nodesToExpand = [NSMutableArray array];
    while (node != g.rootNode && node != NULL)
    {
        [nodesToExpand insertObject:node atIndex:0];
        node = node.parent;
    }
    for (int i = 0; i < [nodesToExpand count]; i++)
    {
        node = [nodesToExpand objectAtIndex:i];
        [outlineHierarchy expandItem:node.parent];
    }
    
    // Update the selection
    NSMutableIndexSet* indexes = [NSMutableIndexSet indexSet];
    
    for (CCNode* selectedNode in appDelegate.selectedNodes)
    {
        int row = (int)[outlineHierarchy rowForItem:selectedNode];
        [indexes addIndex:row];
    }
    [outlineHierarchy selectRowIndexes:indexes byExtendingSelection:NO];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    
    if ([[CCBGlobals globals] rootNode] == NULL) return 0;
    if (item == nil) return 1;
    
    CCNode* node = (CCNode*)item;
    CCArray* arr = [node children];
    
    return [arr count];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if (item == nil) return YES;
    
    CCNode* node = (CCNode*)item;
    CCArray* arr = [node children];
    NodeInfo* info = node.userObject;
    PlugInNode* plugIn = info.plugIn;
    
    if ([arr count] == 0) return NO;
    if (!plugIn.canHaveChildren) return NO;
    
    return YES;
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    CCBGlobals* g= [CCBGlobals globals];
    
    if (item == nil) return g.rootNode;
    
    CCNode* node = (CCNode*)item;
    CCArray* arr = [node children];
    return [arr objectAtIndex:index];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{    
    NSIndexSet* indexes = [outlineHierarchy selectedRowIndexes];
    NSMutableArray* selectedNodes = [NSMutableArray array];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop){
        CCNode* node = [outlineHierarchy itemAtRow:idx];
        [selectedNodes addObject:node];
    }];
    
    appDelegate.selectedNodes = selectedNodes;
    
    [appDelegate updateInspectorFromSelection];
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification
{
    CCNode* node = [[notification userInfo] objectForKey:@"NSObject"];
    [node setExtraProp:[NSNumber numberWithBool:NO] forKey:@"isExpanded"];
}

- (void)outlineViewItemDidExpand:(NSNotification *)notification
{
    CCNode* node = [[notification userInfo] objectForKey:@"NSObject"];
    [node setExtraProp:[NSNumber numberWithBool:YES] forKey:@"isExpanded"];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    if (item == nil) return @"Root";
    
    if ([tableColumn.identifier isEqualToString:@"sequencer"])
    {
        return @"";
    }
    
    CCNode* node = item;
    return node.displayName;
}

- (void) outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    CCNode* node = item;
    
    if (![object isEqualToString:node.displayName])
    {
        [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*nodeDisplayName"];
        node.displayName = object;
    }
}

- (BOOL) outlineView:(NSOutlineView *)outline shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    NSLog(@"should edit?");
    [outline editColumn:0 row:[outline selectedRow] withEvent:[NSApp currentEvent] select:YES];
    return YES;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard
{
    if (!dragAndDropEnabled) return NO;
    
    CCBGlobals* g = [CCBGlobals globals];
    
    CCNode* draggedNode = [items objectAtIndex:0];
    if (draggedNode == g.rootNode) return NO;
    
    NSMutableDictionary* clipDict = [CCBWriterInternal dictionaryFromCCObject:draggedNode];
    
    [clipDict setObject:[NSNumber numberWithLongLong:(long long)draggedNode] forKey:@"srcNode"];
    NSData* clipData = [NSKeyedArchiver archivedDataWithRootObject:clipDict];
    
    [pboard setData:clipData forType:@"com.cocosbuilder.node"];
    
    return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id < NSDraggingInfo >)info proposedItem:(id)item proposedChildIndex:(NSInteger)index
{
    if (item == NULL) return NSDragOperationNone;
    
    CCBGlobals* g = [CCBGlobals globals];
    NSPasteboard* pb = [info draggingPasteboard];
    
    NSData* nodeData = [pb dataForType:@"com.cocosbuilder.node"];
    if (nodeData)
    {
        NSDictionary* clipDict = [NSKeyedUnarchiver unarchiveObjectWithData:nodeData];
        CCNode* draggedNode = (CCNode*)[[clipDict objectForKey:@"srcNode"] longLongValue];
        
        CCNode* node = item;
        CCNode* parent = [node parent];
        while (parent && parent != g.rootNode)
        {
            if (parent == draggedNode) return NSDragOperationNone;
            parent = [parent parent];
        }
        
        return NSDragOperationGeneric;
    }
    
    return NSDragOperationGeneric;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id < NSDraggingInfo >)info item:(id)item childIndex:(NSInteger)index
{
    NSPasteboard* pb = [info draggingPasteboard];
    
    NSData* clipData = [pb dataForType:@"com.cocosbuilder.node"];
    if (clipData)
    {
        NSMutableDictionary* clipDict = [NSKeyedUnarchiver unarchiveObjectWithData:clipData];
        
        CCNode* clipNode= [CCBReaderInternal nodeGraphFromDictionary:clipDict parentSize:CGSizeZero];
        if (![appDelegate addCCObject:clipNode toParent:item atIndex:index]) return NO;
        
        // Remove old node
        CCNode* draggedNode = (CCNode*)[[clipDict objectForKey:@"srcNode"] longLongValue];
        [appDelegate deleteNode:draggedNode];
        
        [appDelegate setSelectedNodes:[NSArray arrayWithObject: clipNode]];
        
        [PositionPropertySetter refreshAllPositions];
        
        return YES;
    }
    clipData = [pb dataForType:@"com.cocosbuilder.texture"];
    if (clipData)
    {
        NSDictionary* clipDict = [NSKeyedUnarchiver unarchiveObjectWithData:clipData];
        
        [appDelegate dropAddSpriteNamed:[clipDict objectForKey:@"spriteFile"] inSpriteSheet:[clipDict objectForKey:@"spriteSheetFile"] at:ccp(0,0) parent:item];
        
        [PositionPropertySetter refreshAllPositions];
        
        return YES;
    }
    clipData = [pb dataForType:@"com.cocosbuilder.ccb"];
    if (clipData)
    {
        NSDictionary* clipDict = [NSKeyedUnarchiver unarchiveObjectWithData:clipData];
        
        [appDelegate dropAddCCBFileNamed:[clipDict objectForKey:@"ccbFile"] at:ccp(0, 0) parent:item];
        
        return YES;
    }
    
    return NO;
}

- (CGFloat) outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
    CCNode* node = item;
    if (node.seqExpanded)
    {
        return kCCBSeqDefaultRowHeight * ([node.plugIn.animatableProperties count] + 1);
    }
    else
    {
        return kCCBSeqDefaultRowHeight;
    }
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayOutlineCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	[cell setImagePosition:NSImageAbove];
}

- (void) outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    CCNode* node = item;
    
    if ([tableColumn.identifier isEqualToString:@"expander"])
    {
        SequencerExpandBtnCell* expCell = cell;
        expCell.isExpanded = node.seqExpanded;
    }
    else if ([tableColumn.identifier isEqualToString:@"structure"])
    {
        SequencerStructureCell* strCell = cell;
        strCell.node = node;
    }
    else if ([tableColumn.identifier isEqualToString:@"sequencer"])
    {
        SequencerCell* seqCell = cell;
        seqCell.node = node;
    }
}

- (void) updateExpandedForNode:(CCNode*)node
{
    if ([self outlineView:outlineHierarchy isItemExpandable:node])
    {
        bool expanded = [[node extraPropForKey:@"isExpanded"] boolValue];
        if (expanded) [outlineHierarchy expandItem:node];
        else [outlineHierarchy collapseItem:node];
        
        CCArray* childs = [node children];
        for (int i = 0; i < [childs count]; i++)
        {
            CCNode* child = [childs objectAtIndex:i];
            [self updateExpandedForNode:child];
        }
    }
}

- (void) toggleSeqExpanderForRow:(int)row
{
    CCNode* node = [outlineHierarchy itemAtRow:row];
    
    node.seqExpanded = !node.seqExpanded;
    
    // Need to reload all data when changing heights of rows
    [outlineHierarchy reloadData];
}


#pragma mark Timeline

- (void) redrawTimeline
{
    [scrubberSelectionView setNeedsDisplay:YES];
    NSString* displayTime = [currentSequence currentDisplayTime];
    if (!displayTime) displayTime = @"00:00:00";
    [timeDisplay setStringValue:displayTime];
    [self updateScroller];
    [outlineHierarchy reloadData];
}

#pragma mark Util

- (void) deleteSequenceId:(int)seqId
{
    // Delete any keyframes for the sequence
    [[CocosScene cocosScene].rootNode deleteSequenceId:seqId];
    
    // Delete any chained sequence references
    for (SequencerSequence* seq in [CocosBuilderAppDelegate appDelegate].currentDocument.sequences)
    {
        if (seq.chainedSequenceId == seqId)
        {
            seq.chainedSequenceId = -1;
        }
    }
    
    [[CocosBuilderAppDelegate appDelegate] updateTimelineMenu];
}

- (void) deselectKeyframesForNode:(CCNode*)node
{
    [node deselectAllKeyframes];
    
    // Also deselect keyframes of children
    CCArray* children = [node children];
    CCNode* child = NULL;
    CCARRAY_FOREACH(children, child)
    {
        [self deselectKeyframesForNode:child];
    }
}

- (void) deselectAllKeyframes
{
    [self deselectKeyframesForNode:[[CocosScene cocosScene] rootNode]];
    [outlineHierarchy reloadData];
}

- (BOOL) deleteSelectedKeyframesForCurrentSequence
{
    BOOL didDelete = [[CocosScene cocosScene].rootNode deleteSelectedKeyframesForSequenceId:currentSequence.sequenceId];
    if (didDelete)
    {
        [self redrawTimeline];
        [self updatePropertiesToTimelinePosition];
        [[CocosBuilderAppDelegate appDelegate] updateInspectorFromSelection];
    }
    return didDelete;
}

- (void) deleteDuplicateKeyframesForCurrentSequence
{
    BOOL didDelete = [[CocosScene cocosScene].rootNode deleteDuplicateKeyframesForSequenceId:currentSequence.sequenceId];
    
    if (didDelete)
    {
        [self redrawTimeline];
        [self updatePropertiesToTimelinePosition];
        [[CocosBuilderAppDelegate appDelegate] updateInspectorFromSelection];
    }
}

- (void) deleteKeyframesForCurrentSequenceAfterTime:(float)time
{
    [[CocosScene cocosScene].rootNode deleteKeyframesAfterTime:time sequenceId:currentSequence.sequenceId];
}

- (void) addSelectedKeyframesForNode:(CCNode*)node toArray:(NSMutableArray*)keyframes
{
    [node addSelectedKeyframesToArray:keyframes];
    
    // Also add selected keyframes of children
    CCArray* children = [node children];
    CCNode* child = NULL;
    CCARRAY_FOREACH(children, child)
    {
        [self addSelectedKeyframesForNode:child toArray:keyframes];
    }
}

- (NSArray*) selectedKeyframesForCurrentSequence
{
    NSMutableArray* keyframes = [NSMutableArray array];
    [self addSelectedKeyframesForNode:[[CocosScene cocosScene] rootNode] toArray:keyframes];
    return keyframes;
}

- (void) updatePropertiesToTimelinePositionForNode:(CCNode*)node sequenceId:(int)seqId
{
    [node updatePropertiesTime:currentSequence.timelinePosition sequenceId:seqId];
    
    // Also deselect keyframes of children
    CCArray* children = [node children];
    CCNode* child = NULL;
    CCARRAY_FOREACH(children, child)
    {
        int childSeqId = seqId;
        
        // Sub ccb files uses different sequence id:s
        NSNumber* childSequence = [child extraPropForKey:@"*sequenceId"];
        if (childSequence) childSeqId = [childSequence intValue];
        
        [self updatePropertiesToTimelinePositionForNode:child sequenceId:childSeqId];
    }
}

- (void) updatePropertiesToTimelinePosition
{
    [self updatePropertiesToTimelinePositionForNode:[[CocosScene cocosScene] rootNode] sequenceId:currentSequence.sequenceId];
}

- (void) setCurrentSequence:(SequencerSequence *)seq
{
    if (seq != currentSequence)
    {
        [currentSequence release];
        currentSequence = [seq retain];
        
        [outlineHierarchy reloadData];
        [[CocosBuilderAppDelegate appDelegate] updateTimelineMenu];
        [self redrawTimeline];
        [self updatePropertiesToTimelinePosition];
        [[CocosBuilderAppDelegate appDelegate] updateInspectorFromSelection];
        [self updateScaleSlider];
    }
}

- (void) menuSetSequence:(id)sender
{
    int seqId = [sender tag];
    
    SequencerSequence* seqSet = NULL;
    for (SequencerSequence* seq in [CocosBuilderAppDelegate appDelegate].currentDocument.sequences)
    {
        if (seq.sequenceId == seqId)
        {
            seqSet = seq;
            break;
        }
    }
    
    self.currentSequence = seqSet;
}

- (void) menuSetChainedSequence:(id)sender
{
    int seqId = [sender tag];
    if (seqId != self.currentSequence.chainedSequenceId)
    {
        [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*chainedseqid"];
        self.currentSequence.chainedSequenceId = [sender tag];
        [[CocosBuilderAppDelegate appDelegate] updateTimelineMenu];
    }
}

#pragma mark Easings

- (void) setContextKeyframeEasingType:(int) type
{
    if (!contextKeyframe) return;
    if (contextKeyframe.easing.type == type) return;
    
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*keyframeeasing"];
    
    contextKeyframe.easing.type = type;
    [self redrawTimeline];
}

#pragma mark Adding keyframes

- (void) menuAddKeyframeNamed:(NSString*)prop
{
    CCNode* node = [CocosBuilderAppDelegate appDelegate].selectedNode;
    if (!node) return;
    
    SequencerSequence* seq = self.currentSequence;
    
    [node addDefaultKeyframeForProperty:prop atTime: seq.timelinePosition sequenceId:seq.sequenceId];
    [self deleteDuplicateKeyframesForCurrentSequence];
    
    node.seqExpanded = YES;
}

- (BOOL) canInsertKeyframeNamed:(NSString*)prop
{
    CCNode* node = [CocosBuilderAppDelegate appDelegate].selectedNode;
    if (!node) return NO;
    if (!prop) return NO;
    
    if ([node shouldDisableProperty:prop]) return NO;
    
    if ([prop isEqualToString:@"visible"]) return YES;
    return [node.plugIn.animatableProperties containsObject:prop];
}

#pragma mark Destructor

- (void) dealloc
{
    self.currentSequence = NULL;
    self.scrubberSelectionView = NULL;
    self.timeDisplay = NULL;
    //self.sequences = NULL;
    
    [super dealloc];
}

@end
