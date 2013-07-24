/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
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

#import "CCBSplitHorizontalView.h"
#import "MainWindow.h"
#import "CocosBuilderAppDelegate.h"

@interface CCBSplitHorizontalView(Private)

-(void) collapseBottomView;
-(void) uncollapseBottomView;

@end

@implementation CCBSplitHorizontalView

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegate = self;
    }
    return self;
}


- (NSColor*) dividerColor
{
    return [NSColor colorWithDeviceRed:0.42 green:0.42 blue:0.42 alpha:1];
}

-(void) toggleBottomView:(BOOL)show;
{
    if ([self isSubviewCollapsed:bottomView] && show) {
        [self uncollapseBottomView];
    } else if (![self isSubviewCollapsed:bottomView] && !show) {
        [self collapseBottomView];
    }
}

-(void) collapseBottomView
{
    NSRect topFrame = topView.frame;
    NSRect overallFrame = self.frame;
    [bottomView setHidden:YES];
    [topView setFrameSize:NSMakeSize(topFrame.size.width, overallFrame.size.height)];
    [self display];
}

-(void) uncollapseBottomView
{
    [bottomView setHidden:NO];
    CGFloat dividerThickness = [self dividerThickness];
    NSRect topFrame = topView.frame;
    NSRect bottomFrame = bottomView.frame;
    
    topFrame.size.width = topFrame.size.width-bottomFrame.size.width-dividerThickness;
    bottomFrame.origin.y = topFrame.size.height + dividerThickness;
    [topView setFrame:topFrame];
    [bottomView setFrame:bottomFrame];
    [self display];
    [self setNeedsLayout:YES];
    
}

#pragma mark
#pragma mark NSSplitViewDelegate implementation

-(void)splitViewWillResizeSubviews:(NSNotification *)notification
{
    MainWindow *win = (MainWindow*)self.window;
    [win disableUpdatesUntilFlush];
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
    
    return (subview == bottomView);
}

- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex
{
    return YES;
}



- (CGFloat) splitView:(NSSplitView *)sv constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    
    if (bottomView.isHidden) {
        return proposedMaximumPosition;
    }
    
    float max = sv.frame.size.height - 62;
    if (proposedMaximumPosition > max) return max;
    else return proposedMaximumPosition;
}

- (void)splitViewDidResizeSubviews:(NSNotification *)aNotification
{
    if ([self isSubviewCollapsed:bottomView]) {
        [[CocosBuilderAppDelegate appDelegate].panelVisibilityControl setSelected:NO forSegment:1];
    } else {
        [[CocosBuilderAppDelegate appDelegate].panelVisibilityControl setSelected:YES forSegment:1];
    }
}

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
    
    static float minCocosSize = 50.0f;
    
    
    
    if (bottomView.isHidden) {
        [topView setFrameSize:[sender frame].size];
        return;
    }
    
    // keep timeline view intact
    NSSize newSize = sender.frame.size;
    float timeLineHeight = bottomView.frame.size.height;
    float cocosViewHeight = newSize.height-timeLineHeight-[sender dividerThickness];
    if (cocosViewHeight<minCocosSize) {
        cocosViewHeight = minCocosSize;
        timeLineHeight = newSize.height-cocosViewHeight-[sender dividerThickness];
    }
    
    [bottomView setFrameOrigin:NSMakePoint(bottomView.frame.origin.x, newSize.height-timeLineHeight)];
    [bottomView setFrameSize:NSMakeSize(newSize.width, timeLineHeight)];
    [topView setFrameSize:NSMakeSize(newSize.width, cocosViewHeight)];
    
    [bottomView setNeedsDisplay:YES];
    [topView setNeedsDisplay:YES];
    
}
 
@end
