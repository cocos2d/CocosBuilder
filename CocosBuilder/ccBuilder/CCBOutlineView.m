/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2011 Viktor Lidholt
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

#import "CCBOutlineView.h"


@implementation CCBOutlineView

+ (void) gradientFillRect:(NSRect)rect
{
    if (NSEqualRects(rect, NSZeroRect)) return;
    
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
#warning The clipping rect is a problem since the gradient spans more than one row, the hackish solution is to call setNeedsDisplay after selection has changed
    NSIndexSet *selectedRowIndexes = [self selectedRowIndexes];
    
    NSRect currentRect = NSZeroRect;
    NSUInteger lastSelectedRow = -2;
    
    NSUInteger selectedRow = [selectedRowIndexes firstIndex];
    while (selectedRow != NSNotFound)
    {
        // Skipping invisible rows causes multiple selections to look weird
        
        //if (selectedRow == -1 || !NSLocationInRange(selectedRow, visibleRows)) 
        //{
        //    selectedRow = [selectedRowIndexes indexGreaterThanIndex:selectedRow];
        //    continue;
        //}
        
        if (selectedRow == lastSelectedRow + 1)
        {
            // Add to current rect
            currentRect = NSUnionRect(currentRect, [self rectOfRow:selectedRow]);
        }
        else
        {
            // Draw the last current rect
            [CCBOutlineView gradientFillRect:currentRect];
            
            // Remeber the current rect
            currentRect = [self rectOfRow:selectedRow];
        }
        
        lastSelectedRow = selectedRow;
        selectedRow = [selectedRowIndexes indexGreaterThanIndex:selectedRow];
    }
    
    // Draw the final rect
    [CCBOutlineView gradientFillRect:currentRect];
}

- (NSFocusRingType) focusRingType
{
    return NSFocusRingTypeNone;
}


@end
