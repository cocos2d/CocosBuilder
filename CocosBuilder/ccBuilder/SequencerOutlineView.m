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

// Disable draggging of rows for expander and sequencer column
- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint mouseLocationInWindow = [theEvent locationInWindow];
    
    // Translate the mouse co-ordinates so they are relative to the tableview's...
    NSPoint mouseLocationInTable = [self convertPoint:
                                    mouseLocationInWindow fromView: NULL];
    
    SequencerHandler* sh = (SequencerHandler*) [self dataSource];
    
    NSInteger column = [self columnAtPoint:mouseLocationInTable];
    
    NSLog(@"mouseDown in col: %d seq-col: %d", (int)column, (int)[self columnWithIdentifier:@"sequencer"]);
    
    if (column == [self columnWithIdentifier:@"sequencer"])
    {
        sh.dragAndDropEnabled = NO;
    }
    else if (column == [self columnWithIdentifier:@"expander"])
    {
        sh.dragAndDropEnabled = NO;
    }
    else
    {
        sh.dragAndDropEnabled = YES;
    }
    
    [super mouseDown: theEvent];
}

@end
