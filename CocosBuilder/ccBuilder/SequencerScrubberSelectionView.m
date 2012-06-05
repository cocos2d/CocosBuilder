//
//  SequencerScrubberSelectionView.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SequencerScrubberSelectionView.h"
#import "SequencerHandler.h"
#import "SequencerSequence.h"
#import "CCNode+NodeInfo.h"
#import "PlugInNode.h"

@implementation SequencerScrubberSelectionView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return NULL;
    
    imgScrubHandle = [[NSImage imageNamed:@"seq-scrub-handle.png"] retain];
    imgScrubLine = [[NSImage imageNamed:@"seq-scrub-line.png"] retain];
    
    return self;
}

- (int) yMousePosToRow:(float)y
{
    NSOutlineView* outlineView = [SequencerHandler sharedHandler].outlineHierarchy;
    
    NSPoint convPoint = [outlineView convertPoint:NSMakePoint(0, y) fromView:self];
    
    if (y < 0) return kCCBRowNoneBelow;
    else if (y >= (self.bounds.size.height - 16)) return kCCBRowNoneAbove;
    
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
            return [[lastNode plugIn].animatableProperties count];
        }
        else
        {
            return 0;
        }
    }
    
    NSRect cellFrame = [outlineView frameOfCellAtColumn:0 row:row];
    NSPoint convPoint = [outlineView convertPoint:NSMakePoint(0, y) fromView:self];
    
    float yInCell = convPoint.y - cellFrame.origin.y;
    return yInCell/kCCBSeqDefaultRowHeight;
}

- (void)drawRect:(NSRect)dirtyRect
{
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    
    // Draw selection
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
    
    // Draw scrubber
    float currentPos = [seq timeToPosition:seq.timelinePosition];
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
        
        // Reschedule callback
        [self performSelector:@selector(updateAutoScrollVertical) withObject:NULL afterDelay:0.1f];
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

- (void) mouseDown:(NSEvent *)theEvent
{
    NSPoint mouseLocationInWindow = [theEvent locationInWindow];
    NSPoint mouseLocation = [self convertPoint: mouseLocationInWindow fromView: NULL];
    NSOutlineView* outlineView = [SequencerHandler sharedHandler].outlineHierarchy;
    
    lastMousePosition = mouseLocation;
    
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    
    if (mouseLocation.y > self.bounds.size.height - 16)
    {
        // Scrubbing
        seq.timelinePosition = [seq positionToTime:mouseLocation.x];
        mouseState = kCCBSeqMouseStateScrubbing;
    }
    else
    {
        mouseState = kCCBSeqMouseStateSelecting;
        
        // Position in time
        xStartSelectTime = [seq positionToTime:mouseLocation.x];
        xEndSelectTime = xStartSelectTime;
        
        // Row selection
        yStartSelectRow = [self yMousePosToRow:mouseLocation.y];
        if (yStartSelectRow < 0) yStartSelectRow = [outlineView numberOfRows] - 1;
        yEndSelectRow = yStartSelectRow;
        
        // Selection in row
        yStartSelectSubRow = [self yMousePosToSubRow:mouseLocation.y];
        yEndSelectSubRow = yStartSelectSubRow;
        
        NSLog(@"clickedRow: %d", yStartSelectRow);
    }
}

- (void) mouseDragged:(NSEvent *)theEvent
{
    NSPoint mouseLocationInWindow = [theEvent locationInWindow];
    NSPoint mouseLocation = [self convertPoint: mouseLocationInWindow fromView: NULL];
    NSOutlineView* outlineView = [SequencerHandler sharedHandler].outlineHierarchy;
    
    lastMousePosition = mouseLocation;
    
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    
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
        seq.timelinePosition = [seq positionToTime:mouseLocation.x];
    }
    else if (mouseState == kCCBSeqMouseStateSelecting)
    {
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
            yEndSelectRow = [outlineView rowAtPoint:[outlineView convertPoint:NSMakePoint(0, self.bounds.size.height-16) fromView:self]];
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
}

- (void) mouseUp:(NSEvent *)theEvent
{
    mouseState = kCCBSeqMouseStateNone;
    [self autoScrollHorizontalDirection:kCCBSeqAutoScrollHorizontalNone];
    [self autoScrollVerticalDirection:kCCBSeqAutoScrollVerticalNone];
    [self setNeedsDisplay:YES];
}

- (void) scrollWheel:(NSEvent *)theEvent
{
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    
    seq.timelineOffset -= theEvent.deltaX/seq.timelineScale*2.0f;
    
    [super scrollWheel:theEvent];
}

- (void) dealloc
{
    [imgScrubHandle release];
    [imgScrubLine release];
    [super dealloc];
}

@end
