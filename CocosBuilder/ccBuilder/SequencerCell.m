//
//  SequencerCell.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SequencerCell.h"

@implementation SequencerCell

- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    if (!imgSeparator)
    {
        imgSeparator = [NSImage imageNamed:@"seq-vseparator.png"];
        [imgSeparator setFlipped:YES];
    }
    
    [imgSeparator drawAtPoint:cellFrame.origin fromRect:NSMakeRect(0, 0, 1, 16) operation:NSCompositeSourceOver fraction:1];
}

- (NSUInteger)hitTestForEvent:(NSEvent *)event
                       inRect:(NSRect)cellFrame
                       ofView:(NSView *)controlView
{
    return 0;
}

@end
