//
//  SequencerStructureCell.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SequencerStructureCell.h"

@implementation SequencerStructureCell

@synthesize isExapanded;

- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    // Only draw property names if cell is expanded
    if (isExapanded)
    {
        // Color
        NSColor* textColor = [[self textColor] colorWithAlphaComponent:0.6];
        
        // Dimensions
        NSRect propNameRect = cellFrame;
        propNameRect.size.width -= 5; // Spacing from right side
    
        // Right alignment
        NSMutableParagraphStyle *style = [[[NSMutableParagraphStyle alloc] init] autorelease];
        [style setAlignment:NSRightTextAlignment];
    
        // Setup attributes
        NSMutableDictionary* attrib = [NSMutableDictionary dictionary];
        [attrib setObject:style forKey:NSParagraphStyleAttributeName];
        [attrib setObject:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]] forKey:NSFontAttributeName];
        [attrib setObject:textColor forKey:NSForegroundColorAttributeName];
    
        // Draw property names
        [@"Position" drawInRect:propNameRect withAttributes:attrib];
    
        cellFrame.size.width = cellFrame.size.width - 55; // Leave space for property name
    }
    
    [super drawWithFrame:cellFrame inView:controlView];
}

@end
