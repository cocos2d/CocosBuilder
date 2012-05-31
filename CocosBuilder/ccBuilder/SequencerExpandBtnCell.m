//
//  SequencerExpandBtnCell.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SequencerExpandBtnCell.h"

@implementation SequencerExpandBtnCell

@synthesize isExpanded;

- (BOOL) trackMouse:(NSEvent *)theEvent
             inRect:(NSRect)cellFrame
             ofView:(NSView *)controlView
       untilMouseUp:(BOOL)untilMouseUp
{
    NSPoint tempCoords = [controlView convertPoint: [theEvent locationInWindow] fromView: [[controlView window] contentView]];
    
    NSPoint mouseCoords = NSMakePoint(tempCoords.x - cellFrame.origin.x,
                                      tempCoords.y  - cellFrame.origin.y);
    
    // Deal with the click however you need to here, for example in a slider cell you can use the mouse x
    // coordinate to set the floatValue.
    NSLog(@"mouseCoords: (%f,%f)", mouseCoords.x, mouseCoords.y);
    
    // Dragging won't work unless you still make the call to the super class...
    return [super trackMouse: theEvent inRect: cellFrame ofView:
            controlView untilMouseUp: untilMouseUp];
}

- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    if (!imgExpand)
    {
        imgExpand = [NSImage imageNamed:@"seq-btn-expand.png"];
    }
    
    [imgExpand setFlipped:!isExpanded];
    [imgExpand drawAtPoint:cellFrame.origin fromRect:NSMakeRect(0, 0, 16, 16) operation:NSCompositeSourceOver fraction:1];
}

@end
