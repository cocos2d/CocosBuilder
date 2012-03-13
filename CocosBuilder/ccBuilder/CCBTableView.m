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
