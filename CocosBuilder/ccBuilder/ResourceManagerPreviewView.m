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

#import "ResourceManagerPreviewView.h"
#import "ResourceManager.h"
#import "CCBImageView.h"
#import "CocosBuilderAppDelegate.h"

@implementation ResourceManagerPreviewView

@synthesize previewMain;
@synthesize previewPhone;
@synthesize previewPhonehd;
@synthesize previewTablet;
@synthesize previewTablethd;

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    // Disable focus rings
    [previewMain setFocusRingType:NSFocusRingTypeNone];
    [previewPhone setFocusRingType:NSFocusRingTypeNone];
    [previewPhonehd setFocusRingType:NSFocusRingTypeNone];
    [previewTablet setFocusRingType:NSFocusRingTypeNone];
    [previewTablethd setFocusRingType:NSFocusRingTypeNone];
}

- (void) setPreviewFile:(id) selection
{
    NSImage* preview = NULL;
    if ([selection respondsToSelector:@selector(preview)])
    {
        preview = [selection preview];
    }
    
    [previewMain setImage:preview];
    
    
    //if (preview) [lblNoPreview setHidden:YES];
    //else [lblNoPreview setHidden:NO];
}

- (IBAction)droppedFile:(id)sender
{
    if (![CocosBuilderAppDelegate appDelegate].projectSettings)
    {
        [self setPreviewFile:NULL];
        return;
    }
    
    CCBImageView* imgView = sender;
    
    NSLog(@"dropped file: %@", imgView.imagePath);
}

- (CocosBuilderAppDelegate*) appDelegate
{
    return [CocosBuilderAppDelegate appDelegate];
}

- (CGFloat) splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    if (proposedMinimumPosition < 140) return 140;
    else return proposedMinimumPosition;
}

- (CGFloat) splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    float max = splitView.frame.size.height - 100;
    if (proposedMaximumPosition > max) return max;
    else return proposedMaximumPosition;
}

@end
