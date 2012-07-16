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

- (void) loadImages
{
    imgExpand = [NSImage imageNamed:@"seq-btn-expand.png"];
    [imgExpand setFlipped:YES];
    [imgExpand retain];
    
    imgCollapse = [NSImage imageNamed:@"seq-btn-collapse.png"];
    [imgCollapse setFlipped:YES];
    [imgCollapse retain];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self loadImages];
    return self;
}

- (id) initImageCell:(NSImage *)image
{
    self = [super initImageCell:image];
    [self loadImages];
    return self;
}

- (id) initTextCell:(NSString *)aString
{
    self = [super initTextCell:aString];
    [self loadImages];
    return self;
}

- (id) init
{
    self = [super init];
    [self loadImages];
    return self;
}

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
    /*
    if (!imgExpand)
    {
        imgExpand = [NSImage imageNamed:@"seq-btn-expand.png"];
        [imgExpand setFlipped:YES];
        [imgExpand retain];
    }
    if (!imgCollapse)
    {
        imgCollapse = [NSImage imageNamed:@"seq-btn-collapse.png"];
        [imgCollapse setFlipped:YES];
        [imgCollapse retain];
    }
    */
    
    if (isExpanded)
    {
        [imgCollapse drawAtPoint:cellFrame.origin fromRect:NSMakeRect(0, 0, 16, 16) operation:NSCompositeSourceOver fraction:1];
    }
    else
    {
        [imgExpand drawAtPoint:cellFrame.origin fromRect:NSMakeRect(0, 0, 16, 16) operation:NSCompositeSourceOver fraction:1];
    }
}

- (void) dealloc
{
#warning Why do I get the -[NSImage release]: message sent to deallocated instance ??
    //[imgExpand release];
    //[imgCollapse release];
    [super dealloc];
}

@end
