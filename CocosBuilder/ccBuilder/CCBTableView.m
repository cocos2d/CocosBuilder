//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import "CCBTableView.h"


@implementation CCBTableView

- (void) gradientFillRect:(NSRect)rect
{
    NSGradient* gradient = [[[NSGradient alloc]
                             initWithColorsAndLocations:[NSColor colorWithCalibratedRed:0.62 green:0.70 blue:0.80 alpha:1.0], (CGFloat)0.0,
                             [NSColor colorWithCalibratedRed:0.46 green:0.53 blue:0.71 alpha:1.0], (CGFloat)1.0,
                             nil] autorelease];
    
    [gradient drawInRect:rect angle:90];
    
    [[NSColor colorWithCalibratedRed:0.46 green:0.53 blue:0.71 alpha:1.0] set];
    [NSBezierPath setDefaultLineWidth:1];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(rect.origin.x,rect.origin.y+0.5) toPoint:NSMakePoint(rect.origin.x+rect.size.width, rect.origin.y+0.5)];
}


- (void)highlightSelectionInClipRect:(NSRect)clipRect
{
    NSIndexSet *selectedRowIndexes = [self selectedRowIndexes];
    NSRange visibleRows = [self rowsInRect:clipRect];
    
    NSUInteger selectedRow = [selectedRowIndexes firstIndex];
    while (selectedRow != NSNotFound)
    {
        if (selectedRow == -1 || !NSLocationInRange(selectedRow, visibleRows)) 
        {
            selectedRow = [selectedRowIndexes indexGreaterThanIndex:selectedRow];
            continue;
        }   
        
        [[NSColor alternateSelectedControlColor] set];
        [[NSColor redColor] set];
        
        NSRectFill([self rectOfRow:selectedRow]);
        [self gradientFillRect:[self rectOfRow:selectedRow]];
        
        selectedRow = [selectedRowIndexes indexGreaterThanIndex:selectedRow];
    }
}

- (NSFocusRingType) focusRingType
{
    return NSFocusRingTypeNone;
}

@end
