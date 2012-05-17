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

#import "ResourceManagerPanel.h"
#import "ResourceManager.h"
#import "ResourceManagerUtil.h"
#import "ImageAndTextCell.h"
#import "ResourceManagerOutlineHandler.h"

@implementation ResourceManagerPanel

@synthesize resType;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (!self) return NULL;
    
    resType = kCCBResTypeImage;
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    outlineHandler = [[ResourceManagerOutlineHandler alloc] initWithOutlineView:resourceList resType:kCCBResTypeImage imagePreview:imagePreview lblNoPreview:lblNoPreview];
}

- (void) reload
{
    [outlineHandler reload];
}

- (void) setResType:(int)rt
{
    [outlineHandler setResType:rt];
}

- (CGFloat) splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    if (proposedMinimumPosition < 50) return 50;
    else return proposedMinimumPosition;
}

- (CGFloat) splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    float max = splitView.frame.size.height - 100;
    if (proposedMaximumPosition > max) return max;
    else return proposedMaximumPosition;
}

- (void) dealloc
{
    [outlineHandler release];
    [super dealloc];
}

@end
