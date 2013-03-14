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

#import "SequencerScrubberSelectionView.h"
#import "SequencerHandler.h"
#import "SequencerSequence.h"
#import "CCNode+NodeInfo.h"
#import "PlugInNode.h"
#import "SequencerNodeProperty.h"
#import "SequencerKeyframe.h"
#import "SequencerKeyframeEasing.h"
#import "CocosBuilderAppDelegate.h"
#import "SequencerChannel.h"
#import "SequencerCallbackChannel.h"
#import "SequencerSoundChannel.h"
#import "SequencerPopoverHandler.h"

@implementation SequencerScrubberSelectionView

@synthesize lastDragEvent;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return NULL;
    
    imgScrubHandle = [[NSImage imageNamed:@"seq-scrub-handle.png"] retain];
    imgScrubLine = [[NSImage imageNamed:@"seq-scrub-line.png"] retain];
    
    return self;
}

- (float) activeWidth
{
    return [[SequencerHandler sharedHandler].outlineHierarchy tableColumnWithIdentifier:@"sequencer"].width;
}

- (int) yMousePosToRow:(float)y
{
    NSOutlineView* outlineView = [SequencerHandler sharedHandler].outlineHierarchy;
    
    NSPoint convPoint = [outlineView convertPoint:NSMakePoint(0, y) fromView:self];
    
    if (y < 0) return kCCBRowNoneBelow;
    else if (y >= (self.bounds.size.height - kCCBSeqScrubberHeight)) return kCCBRowNoneAbove;
    
    return [outlineView rowAtPoint:convPoint];
}

- (int) yMousePosToSubRow:(float)y
{
    NSOutlineView* outlineView = [SequencerHandler sharedHandler].outlineHierarchy;
    
    int row = [self yMousePosToRow:y];
    if (row == kCCBRowNoneAbove || row == kCCBRowNoneBelow)
    {
        return 0;
    }
    else if (row == kCCBRowNone)
    {
        CCNode* lastNode = [outlineView itemAtRow:[outlineView numberOfRows]-1];
        if (lastNode.seqExpanded)
        {
            return [[[lastNode plugIn] animatablePropertiesForNode:lastNode] count]-1;
        }
        else
        {
            return 0;
        }
    }
    
    NSRect cellFrame = [outlineView frameOfCellAtColumn:0 row:row];
    NSPoint convPoint = [outlineView convertPoint:NSMakePoint(0, y) fromView:self];
    
    float yInCell = convPoint.y - cellFrame.origin.y;
    int subRow = yInCell/kCCBSeqDefaultRowHeight;
    
    // Check bounds
    id item = [outlineView itemAtRow:row];
    
    if ([item isKindOfClass:[SequencerChannel class]])
    {
        return 0;
    }
    CCNode* node = item;
    
    if (node.seqExpanded)
    {
        if (subRow >= [[[node plugIn] animatablePropertiesForNode:node] count])
        {
            subRow = [[[node plugIn] animatablePropertiesForNode:node] count]-1;
        }
    }
    else
    {
        subRow = 0;
    }
    
    return subRow;
}

- (void)drawRect:(NSRect)dirtyRect
{
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    
    // Draw selection
    NSGraphicsContext* gc = [NSGraphicsContext currentContext];
    [gc saveGraphicsState];
    
    [NSBezierPath clipRect:NSMakeRect(0, 0, [self activeWidth], self.bounds.size.height - kCCBSeqScrubberHeight)];
    
    if (mouseState == kCCBSeqMouseStateSelecting
        && xStartSelectTime != xEndSelectTime)
    {
        // Determine min/max values for the selection
        float xMinTime = 0;
        float xMaxTime = 0;
        if (xStartSelectTime < xEndSelectTime)
        {
            xMinTime = xStartSelectTime;
            xMaxTime = xEndSelectTime;
        }
        else
        {
            xMinTime = xEndSelectTime;
            xMaxTime = xStartSelectTime;
        }
        
        // Rows
        int yMinRow = 0;
        int yMaxRow = 0;
        int yMinSubRow = 0;
        int yMaxSubRow = 0;
        
        if (yStartSelectRow < yEndSelectRow)
        {
            yMinRow = yStartSelectRow;
            yMaxRow = yEndSelectRow;
            yMinSubRow = yStartSelectSubRow;
            yMaxSubRow = yEndSelectSubRow;
        }
        else
        {
            yMinRow = yEndSelectRow;
            yMaxRow = yStartSelectRow;
            yMinSubRow = yEndSelectSubRow;
            yMaxSubRow = yStartSelectSubRow;
        }
        
        // Sub rows
        if (yMinRow == yMaxRow)
        {
            if (yStartSelectSubRow < yEndSelectSubRow)
            {
                yMinSubRow = yStartSelectSubRow;
                yMaxSubRow = yEndSelectSubRow;
            }
            else
            {
                yMinSubRow = yEndSelectSubRow;
                yMaxSubRow = yStartSelectSubRow;
            }
        }
        
        // Check bounds
        if (xMinTime < 0) xMinTime = 0;
        if (xMaxTime > seq.timelineLength) xMaxTime = seq.timelineLength;
        
        // Calc x/width
        float x = [seq timeToPosition:xMinTime];
        float w = [seq timeToPosition:xMaxTime] - x;
        
        // Calc y/height
        NSOutlineView* outline = [SequencerHandler sharedHandler].outlineHierarchy;
        
        NSRect minRowRect = [outline rectOfRow:yMinRow];
        minRowRect.size.height = kCCBSeqDefaultRowHeight;
        minRowRect.origin.y += kCCBSeqDefaultRowHeight * yMinSubRow;
        
        NSRect maxRowRect = [outline rectOfRow:yMaxRow];
        maxRowRect.size.height = kCCBSeqDefaultRowHeight;
        maxRowRect.origin.y += kCCBSeqDefaultRowHeight * yMaxSubRow;
        
        NSRect yStartRect = [self convertRect:minRowRect fromView:outline]; 
        NSRect yEndRect = [self convertRect:maxRowRect fromView:outline];
        
        float y = yEndRect.origin.y;
        float h = (yStartRect.origin.y + yStartRect.size.height) - y;
        
        // Draw the selection rectangle
        NSRect rect = NSMakeRect(x, y-1, w+1, h+1);
        
        [[NSColor colorWithDeviceRed:0.83f green:0.88f blue:1.00f alpha:0.50f] set];
        [NSBezierPath fillRect: rect];
        
        [[NSColor colorWithDeviceRed:0.45f green:0.55f blue:0.82f alpha:1.00f] set];
        NSFrameRect(rect);
    }
    
    [gc restoreGraphicsState];
    
    // Draw scrubber
    float currentPos = TIMELINE_PAD_PIXELS;
    if (seq) {
        currentPos = [seq timeToPosition:seq.timelinePosition];
    }
    
    float yPos = self.bounds.size.height - imgScrubHandle.size.height;
    
    // Handle
    [imgScrubHandle drawAtPoint:NSMakePoint(currentPos-3, yPos-1) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    
    // Line
    [imgScrubLine drawInRect:NSMakeRect(currentPos, 0, 2, yPos) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
}

- (void) updateAutoScrollHorizontal
{
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    
    if (autoScrollHorizontalDirection)
    {
        // Perform scroll
        if (autoScrollHorizontalDirection == kCCBSeqAutoScrollHorizontalLeft)
        {
            seq.timelineOffset -= 20 / seq.timelineScale;
        }
        else if (autoScrollHorizontalDirection == kCCBSeqAutoScrollHorizontalRight)
        {
            seq.timelineOffset += 20 / seq.timelineScale;
        }
        
        // Reschedule callback
        [self performSelector:@selector(updateAutoScrollHorizontal) withObject:NULL afterDelay:0.1f];

        if (mouseState == kCCBSeqMouseStateScrubbing)
        {
            // Update time marker
            seq.timelinePosition = [seq positionToTime:lastMousePosition.x];
        }
        else if (mouseState == kCCBSeqMouseStateSelecting)
        {
            xEndSelectTime = [seq positionToTime:lastMousePosition.x];
        }
        
        didAutoScroll = YES;
    }
}

- (void) autoScrollHorizontalDirection:(int)dir
{
    if (dir == autoScrollHorizontalDirection) return;
    
    autoScrollHorizontalDirection = dir;
    
    if (dir != kCCBSeqAutoScrollHorizontalNone)
    {
        // Schedule callback
        [self updateAutoScrollHorizontal];
    }
}

- (void) updateAutoScrollVertical
{
    NSScrollView* scrollView = [SequencerHandler sharedHandler].scrollView;
    NSClipView* contentView = scrollView.contentView;
    
    if (autoScrollVerticalDirection)
    {
        if (autoScrollVerticalDirection == kCCBSeqAutoScrollVerticalUp)
        {
            float yScroll = contentView.bounds.origin.y - 10;
            
            [contentView scrollToPoint: [contentView constrainScrollPoint: NSMakePoint(0,yScroll)]];
            [scrollView reflectScrolledClipView: [scrollView contentView]];
        }
        else if (autoScrollVerticalDirection == kCCBSeqAutoScrollVerticalDown)
        {
            float yScroll = contentView.bounds.origin.y + 10;
            
            [contentView scrollToPoint: [contentView constrainScrollPoint: NSMakePoint(0,yScroll)]];
            [scrollView reflectScrolledClipView: [scrollView contentView]];
        }
        
        // Fake drag event
        [self mouseDragged:lastDragEvent];
        
        // Reschedule callback
        [self performSelector:@selector(updateAutoScrollVertical) withObject:NULL afterDelay:0.1f];
        
        didAutoScroll = YES;
    }
}

- (void) autoScrollVerticalDirection:(int)dir
{
    if (dir == autoScrollVerticalDirection) return;
    
    autoScrollVerticalDirection = dir;
    
    if (dir != kCCBSeqAutoScrollHorizontalNone)
    {
        // Schedule callback
        [self updateAutoScrollVertical];
    }
}

- (NSString*) propNameForNode:(CCNode*) node subRow:(int)sub
{
    NSArray* props = [node.plugIn animatablePropertiesForNode:node];
    
    NSString* prop = NULL;
    prop = [props objectAtIndex:sub];
    
    return prop;
}

- (void) addKeyframeAtRow:(int)row sub:(int)sub time:(float) time
{
    NSOutlineView* outlineView = [SequencerHandler sharedHandler].outlineHierarchy;
    
    // Get the double clicked node
    id item = [outlineView itemAtRow:row];
    
    if ([item isKindOfClass:[SequencerChannel class]])
    {
        SequencerChannel* channel = item;
        [channel addDefaultKeyframeAtTime:time];
        
        return;
    }
    
    CCNode* node = item;
    NSString* prop = [self propNameForNode:node subRow:sub];
    
    [node addDefaultKeyframeForProperty:prop atTime:time sequenceId:[SequencerHandler sharedHandler].currentSequence.sequenceId];
}

- (SequencerKeyframe*) keyframeForRow:(int)row sub:(int)sub minTime:(float)minTime maxTime:(float)maxTime
{
    NSOutlineView* outlineView = [SequencerHandler sharedHandler].outlineHierarchy;
    
    id item = [outlineView itemAtRow:row];
    
    if ([item isKindOfClass:[SequencerChannel class]])
    {
        // Handle audio & callbacks
        SequencerChannel* channel = item;
        return [channel.seqNodeProp keyframeBetweenMinTime:minTime maxTime:maxTime];
    }
    
    CCNode* node = item;
    NSString* prop = [self propNameForNode:node subRow:sub];
    
    SequencerNodeProperty* seqNodeProp = [node sequenceNodeProperty:prop sequenceId:[SequencerHandler sharedHandler].currentSequence.sequenceId];
    
    return [seqNodeProp keyframeBetweenMinTime:minTime maxTime:maxTime];
}

- (SequencerKeyframe*) keyframeForInterpolationInRow:(int)row sub:(int)sub time:(float)time
{
    NSOutlineView* outlineView = [SequencerHandler sharedHandler].outlineHierarchy;
    CCNode* node = [outlineView itemAtRow:row];
    NSString* prop = [self propNameForNode:node subRow:sub];
    
    SequencerNodeProperty* seqNodeProp = [node sequenceNodeProperty:prop sequenceId:[SequencerHandler sharedHandler].currentSequence.sequenceId];
    
    return [seqNodeProp keyframeForInterpolationAtTime:time];
}

- (NSArray*) keyframesInSelectionArea
{
    NSOutlineView* outlineView = [SequencerHandler sharedHandler].outlineHierarchy;
    SequencerSequence* seq = [[SequencerHandler sharedHandler] currentSequence];
    
    NSMutableArray* selectedKeyframes = [NSMutableArray array];
    
    // Determine min/max values for the selection
    float xMinTime = 0;
    float xMaxTime = 0;
    if (xStartSelectTime < xEndSelectTime)
    {
        xMinTime = xStartSelectTime;
        xMaxTime = xEndSelectTime;
    }
    else
    {
        xMinTime = xEndSelectTime;
        xMaxTime = xStartSelectTime;
    }
    
    // Rows
    int yMinRow = 0;
    int yMaxRow = 0;
    int yMinSubRow = 0;
    int yMaxSubRow = 0;
    
    if (yStartSelectRow < yEndSelectRow)
    {
        yMinRow = yStartSelectRow;
        yMaxRow = yEndSelectRow;
        yMinSubRow = yStartSelectSubRow;
        yMaxSubRow = yEndSelectSubRow;
    }
    else
    {
        yMinRow = yEndSelectRow;
        yMaxRow = yStartSelectRow;
        yMinSubRow = yEndSelectSubRow;
        yMaxSubRow = yStartSelectSubRow;
    }
    
    if (yMinRow == yMaxRow)
    {
        // Only selection within a row
        
        if (yStartSelectSubRow < yEndSelectSubRow)
        {
            yMinSubRow = yStartSelectSubRow;
            yMaxSubRow = yEndSelectSubRow;
        }
        else
        {
            yMinSubRow = yEndSelectSubRow;
            yMaxSubRow = yStartSelectSubRow;
        }
        
        id item = [outlineView itemAtRow:yMinRow];
        
        if ([item isKindOfClass:[SequencerChannel class]])
        {
            // Handle audio & callbacks
            SequencerChannel* channel = item;
            [selectedKeyframes addObjectsFromArray:[channel.seqNodeProp keyframesBetweenMinTime:xMinTime maxTime:xMaxTime]];
        }
        else
        {
            CCNode* node = item;
            for (int subRow = yMinSubRow; subRow <= yMaxSubRow; subRow++)
            {
                NSString* propName = [self propNameForNode:node subRow:subRow];
                SequencerNodeProperty* seqNodeProp = [node sequenceNodeProperty:propName sequenceId:seq.sequenceId];
                [selectedKeyframes addObjectsFromArray:[seqNodeProp keyframesBetweenMinTime:xMinTime maxTime:xMaxTime]];
            }
        }
    }
    else
    {
        // Selection spanning multiple rows
        for (int row = yMinRow; row <= yMaxRow; row++)
        {
            id item = [outlineView itemAtRow:row];
            CCNode* node = NULL;
            
            if ([item isKindOfClass:[SequencerChannel class]])
            {
                SequencerChannel* channel = item;
                [selectedKeyframes addObjectsFromArray: [channel.seqNodeProp keyframesBetweenMinTime:xMinTime maxTime:xMaxTime]];
            }
            else
            {
                node = item;
            }
            
            if (node.seqExpanded)
            {
                // This row is expanded
                if (row == yMinRow)
                {
                    for (int subRow = yMinSubRow; subRow < [[node.plugIn animatablePropertiesForNode:node] count]; subRow++)
                    {
                        NSString* propName  = [self propNameForNode:node subRow:subRow];
                        SequencerNodeProperty* seqNodeProp = [node sequenceNodeProperty:propName sequenceId:seq.sequenceId];
                        [selectedKeyframes addObjectsFromArray:[seqNodeProp keyframesBetweenMinTime:xMinTime maxTime:xMaxTime]];
                    }
                }
                else if (row == yMaxRow)
                {
                    for (int subRow = 0; subRow <= yMaxSubRow; subRow++)
                    {
                        NSString* propName  = [self propNameForNode:node subRow:subRow];
                        SequencerNodeProperty* seqNodeProp = [node sequenceNodeProperty:propName sequenceId:seq.sequenceId];
                        [selectedKeyframes addObjectsFromArray:[seqNodeProp keyframesBetweenMinTime:xMinTime maxTime:xMaxTime]];
                    }
                }
                else
                {
                    for (int subRow = 0; subRow < [[node.plugIn animatablePropertiesForNode:node] count]; subRow++)
                    {
                        NSString* propName  = [self propNameForNode:node subRow:subRow];
                        SequencerNodeProperty* seqNodeProp = [node sequenceNodeProperty:propName sequenceId:seq.sequenceId];
                        [selectedKeyframes addObjectsFromArray:[seqNodeProp keyframesBetweenMinTime:xMinTime maxTime:xMaxTime]];
                    }
                }
            }
            else
            {
                // Row is not expaned, only select the first visible property
                NSString* propName  = [self propNameForNode:node subRow:0];
                SequencerNodeProperty* seqNodeProp = [node sequenceNodeProperty:propName sequenceId:seq.sequenceId];
                [selectedKeyframes addObjectsFromArray:[seqNodeProp keyframesBetweenMinTime:xMinTime maxTime:xMaxTime]];
            }
        }
    }
    
    return selectedKeyframes;
}

- (void) mouseDown:(NSEvent *)theEvent
{
    NSPoint mouseLocationInWindow = [theEvent locationInWindow];
    NSPoint mouseLocation = [self convertPoint: mouseLocationInWindow fromView: NULL];
    
    // Pass on events that are not in the active area (eg on the scrollbar)
    if (mouseLocation.x > [self activeWidth])
    {
        [super mouseDown:theEvent];
        return;
    }
    
    NSOutlineView* outlineView = [SequencerHandler sharedHandler].outlineHierarchy;
    
    lastMousePosition = mouseLocation;
    
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    
    // Calculate the clicked time and time span for hit area of keyframes
    float time = [seq positionToTime:mouseLocation.x];
    
    float timeMin = [seq positionToTime:mouseLocation.x - 3];
    float timeMax = [seq positionToTime:mouseLocation.x + 3];
    
    int row = [self yMousePosToRow:mouseLocation.y];
    int subRow = [self yMousePosToSubRow:mouseLocation.y];
    
    CCNode* node = NULL;
    if (row >= 0)
    {
        id item = [outlineView itemAtRow:row];
        
        if ([item isKindOfClass:[CCNode class]])
        {
            node = item;
        }
    }
    
    didAutoScroll = NO;
    mouseDownPosition = mouseLocation;
    mouseDownKeyframe = [self keyframeForRow:row sub:subRow minTime:timeMin maxTime:timeMax];
    mouseDownRelPositionX = (seq.timelineScale*seq.timelineOffset)+mouseLocation.x;
    
    if (mouseLocation.y > self.bounds.size.height - kCCBSeqScrubberHeight)
    {
        // Scrubbing
        seq.timelinePosition = time;
        mouseState = kCCBSeqMouseStateScrubbing;
    }
    else
    {
        if (mouseDownKeyframe)
        {
            if (theEvent.modifierFlags & NSShiftKeyMask)
            {
                mouseDownKeyframe.selected = ! mouseDownKeyframe.selected;
            }
            else
            {
                // Handle selections
                if (!mouseDownKeyframe.selected)
                {
                    [[SequencerHandler sharedHandler] deselectAllKeyframes];
                    mouseDownKeyframe.selected = YES;
                }
                
                // Center on keyframe for double clicks
                if (theEvent.clickCount == 2)
                {
                    seq.timelinePosition = mouseDownKeyframe.time;
                    if (node)
                    {
                        // Center
                        [CocosBuilderAppDelegate appDelegate].selectedNodes = [NSArray arrayWithObject: node];
                        
                        if (subRow != 0)
                        {
                            // Calc bounds of keyframe
                            float xPos = [seq timeToPosition:mouseDownKeyframe.time];
                            NSRect kfBounds = NSMakeRect(xPos-3, mouseLocation.y, 7, 10);
                            
                            // Popover
                            [SequencerPopoverHandler popoverNode:node property:[self propNameForNode:node subRow:subRow] overView:self kfBounds:kfBounds];
                        }
                    }
                    else
                    {
                        // This is a channel keyframe
                        float time = mouseDownKeyframe.time;
                        SequencerChannel* channel = NULL;
                        if (mouseDownKeyframe.type == kCCBKeyframeTypeCallbacks)
                        {
                            channel = seq.callbackChannel;
                        }
                        else if (mouseDownKeyframe.type == kCCBKeyframeTypeSoundEffects)
                        {
                            channel = seq.soundChannel;
                        }
                        
                        NSAssert(channel, @"Keyframe doesn't have valid channel");
                        
                        // Calc bounds of keyframe
                        float xPos = [seq timeToPosition:mouseDownKeyframe.time];
                        NSRect kfBounds = NSMakeRect(xPos-3, mouseLocation.y, 7, 10);
                        
                        // Popover
                        [SequencerPopoverHandler popoverChannelKeyframes:[channel keyframesAtTime:time] kfBounds:kfBounds overView:self];
                    }
                }
                
                // Start dragging keyframe(s)
                for (SequencerKeyframe* keyframe in [[SequencerHandler sharedHandler] selectedKeyframesForCurrentSequence])
                {
                    keyframe.timeAtDragStart = keyframe.time;
                }
                
                mouseState = kCCBSeqMouseStateKeyframe;
            }
            
            [outlineView reloadItem:node];
        }
        else if (theEvent.modifierFlags & NSAlternateKeyMask)
        {
            mouseState = kCCBSeqMouseStateNone;
            
            int clickedRow = row;
            int clickedSubRow = subRow;
            
            if (clickedRow != -1)
            {
                [self addKeyframeAtRow:clickedRow sub:clickedSubRow time:time];
            }
        }
        else
        {
            mouseState = kCCBSeqMouseStateSelecting;
        
            // Position in time
            xStartSelectTime = time;
            xEndSelectTime = xStartSelectTime;
        
            // Row selection
            yStartSelectRow = row;
            if (yStartSelectRow < 0) yStartSelectRow = [outlineView numberOfRows] - 1;
            yEndSelectRow = yStartSelectRow;
        
            // Selection in row
            yStartSelectSubRow = subRow;
            yEndSelectSubRow = yStartSelectSubRow;
        }
    }
}

- (void) mouseDragged:(NSEvent *)theEvent
{
    NSPoint mouseLocationInWindow = [theEvent locationInWindow];
    NSPoint mouseLocation = [self convertPoint: mouseLocationInWindow fromView: NULL];
    
    if (mouseLocation.x > [self activeWidth])
    {
        [super mouseDragged:theEvent];
    }
    
    self.lastDragEvent = theEvent;
    
    NSOutlineView* outlineView = [SequencerHandler sharedHandler].outlineHierarchy;
    
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    
    lastMousePosition = mouseLocation;
    int relMousePosX = (seq.timelineScale*seq.timelineOffset)+mouseLocation.x;
    
    if (mouseLocation.x < 0)
    {
        [self autoScrollHorizontalDirection:kCCBSeqAutoScrollHorizontalLeft];
    }
    else if (mouseLocation.x > self.bounds.size.width)
    {
        [self autoScrollHorizontalDirection:kCCBSeqAutoScrollHorizontalRight];
    }
    else
    {
        [self autoScrollHorizontalDirection:kCCBSeqAutoScrollHorizontalNone];
    }
    
    if (mouseState == kCCBSeqMouseStateScrubbing)
    {
        // Scrubbing in the timeline
        
        seq.timelinePosition = [seq positionToTime:mouseLocation.x];
    }
    else if (mouseState == kCCBSeqMouseStateSelecting)
    {
        // Drawing a selection box
        
        xEndSelectTime = [seq positionToTime:mouseLocation.x];
        yEndSelectRow = [self yMousePosToRow:mouseLocation.y];
        
        int scrollDir = kCCBSeqAutoScrollVerticalNone;
        
        if (yEndSelectRow == kCCBRowNone)
        {
            yEndSelectRow = [outlineView numberOfRows]-1;
        }
        else if (yEndSelectRow == kCCBRowNoneAbove)
        {
            // Get row visible at the top of the sequencer
            yEndSelectRow = [outlineView rowAtPoint:[outlineView convertPoint:NSMakePoint(0, self.bounds.size.height-kCCBSeqScrubberHeight) fromView:self]];
            if (yEndSelectRow == -1) yEndSelectRow = 0;
            
            // Scroll up
            scrollDir = kCCBSeqAutoScrollVerticalUp;
        }
        else if (yEndSelectRow == kCCBRowNoneBelow)
        {
            // Get the row at the visible end of the sequencer
            yEndSelectRow = [outlineView rowAtPoint:[outlineView convertPoint:NSMakePoint(0, 0) fromView:self]];
            if (yEndSelectRow == -1) yEndSelectRow = [outlineView numberOfRows] - 1;
            
            // Scroll down
            scrollDir = kCCBSeqAutoScrollVerticalDown;
        }
        
        [self autoScrollVerticalDirection:scrollDir];
        
        yEndSelectSubRow = [self yMousePosToSubRow:mouseLocation.y];
        
        [self setNeedsDisplay:YES];
    }
    else if (mouseState == kCCBSeqMouseStateKeyframe)
    {
        // Mouse down in a keyframe
        
        int xDelta = relMousePosX - mouseDownRelPositionX;
        
        NSArray* selection = [[SequencerHandler sharedHandler] selectedKeyframesForCurrentSequence];
        
        BOOL moved = NO;
        
        for (SequencerKeyframe* keyframe in selection)
        {
            float oldTime = keyframe.time;
            
            float startPos = [seq timeToPosition:keyframe.timeAtDragStart];
            float newTime = [seq positionToTime:startPos + xDelta];
            
            if (oldTime != newTime)
            {
                [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*keyframe"];
                keyframe.time = newTime;
                moved = YES;
            }
        }
        
        if (moved)
        {
            [[SequencerHandler sharedHandler].outlineHierarchy reloadData];
            [[SequencerHandler sharedHandler] updatePropertiesToTimelinePosition];
        }
    }
}

- (void) mouseUp:(NSEvent *)theEvent
{
    NSPoint mouseLocationInWindow = [theEvent locationInWindow];
    NSPoint mouseLocation = [self convertPoint: mouseLocationInWindow fromView: NULL];
    
    NSOutlineView* outlineView = [SequencerHandler sharedHandler].outlineHierarchy;
    
    // Check for out of bounds
    if (mouseLocation.x > [self activeWidth])
    {
        [super mouseUp:theEvent];
    }
    
    if (mouseState == kCCBSeqMouseStateSelecting)
    {
        if (theEvent.modifierFlags & NSShiftKeyMask)
        {
            NSArray* selectedKeyframes = [self keyframesInSelectionArea];
            for (SequencerKeyframe* keyframe in selectedKeyframes)
            {
                keyframe.selected = YES;
                [outlineView reloadData];
            }
        }
        else
        {
            [[SequencerHandler sharedHandler] deselectAllKeyframes];
            NSArray* selectedKeyframes = [self keyframesInSelectionArea];
            for (SequencerKeyframe* keyframe in selectedKeyframes)
            {
                keyframe.selected = YES;
                [outlineView reloadData];
            }
        }
    }
    else if (mouseState == kCCBSeqMouseStateKeyframe)
    {
        if (NSEqualPoints(mouseLocation, mouseDownPosition) && !didAutoScroll)
        {
            [[SequencerHandler sharedHandler] deselectAllKeyframes];
            mouseDownKeyframe.selected = YES;
        }
        else
        {
            // Moved keyframes, clean up duplicates
            [[SequencerHandler sharedHandler] deleteDuplicateKeyframesForCurrentSequence];
            [outlineView reloadData];
        }
    }
    
    // Clean up
    mouseState = kCCBSeqMouseStateNone;
    [self autoScrollHorizontalDirection:kCCBSeqAutoScrollHorizontalNone];
    [self autoScrollVerticalDirection:kCCBSeqAutoScrollVerticalNone];
    [self setNeedsDisplay:YES];
}

- (void) scrollWheel:(NSEvent *)theEvent
{
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    
    seq.timelineOffset -= theEvent.deltaX/seq.timelineScale*4.0f;
    
    [super scrollWheel:theEvent];
}

- (NSMenu*) menuForEvent:(NSEvent *)theEvent
{
    CocosBuilderAppDelegate* ad = [CocosBuilderAppDelegate appDelegate];
    
    NSPoint mouseLocationInWindow = [theEvent locationInWindow];
    NSPoint mouseLocation = [self convertPoint: mouseLocationInWindow fromView: NULL];
    
    // Check that document is open
    if (!ad.hasOpenedDocument) return NULL;
    
    // Check that user clicked a row
    int row = [self yMousePosToRow:mouseLocation.y];
    if (row < 0) return NULL;
    
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    int subRow = [self yMousePosToSubRow:mouseLocation.y];
    float timeMin = [seq positionToTime:mouseLocation.x - 3];
    float timeMax = [seq positionToTime:mouseLocation.x + 3];
    
    // Check if a keyframe was clicked
    SequencerKeyframe* keyframe = [self keyframeForRow:row sub:subRow minTime:timeMin maxTime:timeMax];
    if (keyframe)
    {
        [SequencerHandler sharedHandler].contextKeyframe = keyframe;
        return [CocosBuilderAppDelegate appDelegate].menuContextKeyframe;
    }
    
    NSOutlineView* outlineView = [SequencerHandler sharedHandler].outlineHierarchy;
    
    id item = [outlineView itemAtRow:row];
    if ([item isKindOfClass:[SequencerChannel class]])
    {
        return NULL;
    }
    
    // Check if an interpolation was clicked
    keyframe = [self keyframeForInterpolationInRow:row sub:subRow time:[seq positionToTime:mouseLocation.x]];
    if (keyframe && [keyframe supportsFiniteTimeInterpolations])
    {
        [SequencerHandler sharedHandler].contextKeyframe = keyframe;
        
        // Highlight selected option in context menu
        NSMenu* menu = [CocosBuilderAppDelegate appDelegate].menuContextKeyframeInterpol;
        
        for (NSMenuItem* item in menu.itemArray)
        {
            [item setState:NSOffState];
        }
        
        NSMenuItem* item = [menu itemWithTag:keyframe.easing.type];
        [item setState:NSOnState];
        
        // Enable or disable options menu item
        NSMenuItem* itemOpt = [menu itemWithTag:-1];
        [itemOpt setEnabled: keyframe.easing.hasOptions];
        
        return menu;
    }
    
    return NULL;
}

- (void) dealloc
{
    [imgScrubHandle release];
    [imgScrubLine release];
    self.lastDragEvent = NULL;
    [super dealloc];
}

@end
