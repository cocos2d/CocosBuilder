//
//  SequencerOutlineView.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SequencerOutlineView.h"
#import "SequencerHandler.h"

@implementation SequencerOutlineView

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self setGridStyleMask:NSTableViewSolidHorizontalGridLineMask];
    [self setGridColor:[NSColor colorWithDeviceRed:0.85 green:0.85 blue:0.85 alpha:1]];
}

// Disable draggging of rows for expander and sequencer column
- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint mouseLocationInWindow = [theEvent locationInWindow];
    
    // Translate the mouse co-ordinates so they are relative to the tableview's...
    NSPoint mouseLocationInTable = [self convertPoint:
                                    mouseLocationInWindow fromView: NULL];
    
    SequencerHandler* sh = (SequencerHandler*) [self dataSource];
    
    NSInteger column = [self columnAtPoint:mouseLocationInTable];
    
    if (column == [self columnWithIdentifier:@"sequencer"])
    {
        // Events in the sequencer are handled by the SequencerOutlineView which
        // is placed on top of the outline view
        return;
    }
    else if (column == [self columnWithIdentifier:@"expander"])
    {
        sh.dragAndDropEnabled = NO;
        [sh toggleSeqExpanderForRow:(int)[self rowAtPoint:mouseLocationInTable]];
        return;
    }
    else
    {
        sh.dragAndDropEnabled = YES;
    }
    
    [super mouseDown: theEvent];
}

- (void)drawGridInClipRect:(NSRect)clipRect
{
    NSRect lastRowRect = [self rectOfRow:[self numberOfRows]-1];
    NSRect myClipRect = NSMakeRect(0, 0, lastRowRect.size.width, NSMaxY(lastRowRect));
    NSRect finalClipRect = NSIntersectionRect(clipRect, myClipRect);
    [super drawGridInClipRect:finalClipRect];
}

@end
