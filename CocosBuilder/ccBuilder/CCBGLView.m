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

#import "CCBGLView.h"
#import "CocosBuilderAppDelegate.h"
#import "CCBGlobals.h"
#import "CocosScene.h"

@implementation CCBGLView

- (void) reshape
{
    [self removeTrackingRect:trackingTag];
    trackingTag = [self addTrackingRect:[self bounds] owner:self userData:NULL assumeInside:NO];
    [[CocosBuilderAppDelegate appDelegate] resizeGUIWindow:[self bounds].size];
    
    [super reshape];
}

- (BOOL) acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    trackingTag = [self addTrackingRect:[self bounds] owner:self userData:NULL assumeInside:NO];
    
    [self registerForDraggedTypes:[NSArray arrayWithObjects: @"com.cocosbuilder.texture", @"com.cocosbuilder.template", @"com.cocosbuilder.ccb", NULL]];
}


-(BOOL) acceptsFirstResponder
{
	return NO;
}

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
    return NSDragOperationGeneric;
}

- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender
{
    NSPoint pt = [self convertPoint:[sender draggingLocation] fromView:NULL];
    pt = NSMakePoint(roundf(pt.x),roundf(pt.y));
    
    NSPasteboard* pb = [sender draggingPasteboard];
    
    NSData* pdData = [pb dataForType:@"com.cocosbuilder.texture"];
    if (pdData)
    {
        NSDictionary* pdDict = [NSKeyedUnarchiver unarchiveObjectWithData:pdData];
        [appDelegate dropAddSpriteNamed:[pdDict objectForKey:@"spriteFile"] inSpriteSheet:[pdDict objectForKey:@"spriteSheetFile"] at:ccp(pt.x,pt.y)];
    }
    
    pdData = [pb dataForType:@"com.cocosbuilder.ccb"];
    if (pdData)
    {
        NSLog(@"Handling ccb drop!");
        NSDictionary* pdDict = [NSKeyedUnarchiver unarchiveObjectWithData:pdData];
        [appDelegate dropAddCCBFileNamed:[pdDict objectForKey:@"ccbFile"] at:ccp(pt.x,pt.y) parent:NULL];
    }

    return YES;
}

- (void) scrollWheel:(NSEvent *)theEvent
{
    [[CocosScene cocosScene] scrollWheel:theEvent];
}

- (void)mouseMoved:(NSEvent *)event
{
    [[CocosScene cocosScene] mouseMoved:event];
}

- (void)mouseEntered:(NSEvent *)event
{
    [[CocosScene cocosScene] mouseEntered:event];
}

- (void)mouseExited:(NSEvent *)event
{
    [[CocosScene cocosScene] mouseExited:event];
}

- (void)cursorUpdate:(NSEvent *)event
{
    [[CocosScene cocosScene] cursorUpdate:event];
}

@end
