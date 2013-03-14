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

#import "SequencerStructureCell.h"
#import "SequencerNodeProperty.h"
#import "CCNode+NodeInfo.h"
#import "PlugInNode.h"
#import "SequencerHandler.h"
#import "SequencerSequence.h"

@implementation SequencerStructureCell

@synthesize node;

- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    if (!imagesLoaded)
    {
        imgRowBgChannel = [[NSImage imageNamed:@"seq-row-channel-bg.png"] retain];
        imagesLoaded = YES;
    }
    
    if (!node)
    {
        NSRect rowRect = NSMakeRect(0, /*cellFrame.origin.x,*/ cellFrame.origin.y, cellFrame.size.width+16, kCCBSeqDefaultRowHeight);
        [imgRowBgChannel drawInRect:rowRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
        [super drawWithFrame:cellFrame inView:controlView];
        return;
    }
    
    // Only draw property names if cell is expanded
    if ([node seqExpanded])
    {
        SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
        
        // Color
        NSColor* textColor = [[self textColor] colorWithAlphaComponent:0.6];
        NSColor* textColorDisabled = [[self textColor] colorWithAlphaComponent:0.3];
        
        // Dimensions (spacing from right side)
        NSRect propNameRect = cellFrame;
        propNameRect.size.width -= 5; 
    
        // Right alignment
        NSMutableParagraphStyle *style = [[[NSMutableParagraphStyle alloc] init] autorelease];
        [style setAlignment:NSRightTextAlignment];
    
        // Setup attributes
        NSMutableDictionary* attrib = [NSMutableDictionary dictionary];
        [attrib setObject:style forKey:NSParagraphStyleAttributeName];
        [attrib setObject:textColor forKey:NSForegroundColorAttributeName];
        /*
        // Draw property names
        SequencerNodeProperty* seqNodeProp = [node sequenceNodeProperty:@"visible" sequenceId:seq.sequenceId];
        
        // Check for disabled visible
        if ([node shouldDisableProperty:@"visible"])
        {
            [attrib setObject:textColorDisabled forKey:NSForegroundColorAttributeName];
        }
        
        
        BOOL hasKeyframes = ([seqNodeProp.keyframes count] > 0);
        if (hasKeyframes)
        {
            [attrib setObject:[NSFont boldSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]] forKey:NSFontAttributeName];
        }
        else
        {
            [attrib setObject:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]] forKey:NSFontAttributeName];
        }
        
        [@"Visible" drawInRect:propNameRect withAttributes:attrib];
        */
        NSArray* props = [node.plugIn animatablePropertiesForNode:node];
        int i=0;
        for (NSString* prop in props)
        {
            SequencerNodeProperty* seqNodeProp = [node sequenceNodeProperty:prop sequenceId:seq.sequenceId];
            BOOL hasKeyframes = ([seqNodeProp.keyframes count] > 0);
            
            if ([node shouldDisableProperty:prop])
            {
                [attrib setObject:textColorDisabled forKey:NSForegroundColorAttributeName];
            }
            else
            {
                [attrib setObject:textColor forKey:NSForegroundColorAttributeName];
            }
            
            if (hasKeyframes)
            {
                [attrib setObject:[NSFont boldSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]] forKey:NSFontAttributeName];
            }
            else
            {
                [attrib setObject:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]] forKey:NSFontAttributeName];
            }
            
            NSString* displayName = [[node.plugIn.nodePropertiesDict objectForKey:prop] objectForKey:@"displayName"];
            
            if (i>0)
                propNameRect.origin.y += kCCBSeqDefaultRowHeight;
            else
                i++;
            
            [displayName drawInRect:propNameRect withAttributes:attrib];
            
        }
    
        // Leave space for property name when drawing name in super method
        cellFrame.size.width = cellFrame.size.width - 55;
    }
    
    [super drawWithFrame:cellFrame inView:controlView];
}

- (BOOL) isEditable
{
    NSLog(@"isEditable");
    return YES;
}

- (void) dealloc
{
    //self.node = NULL;
    [imgRowBgChannel release];
    [super dealloc];
}

@end
