//
//  SequencerCell.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SequencerCell.h"
#import "CCNode+NodeInfo.h"
#import "SequencerHandler.h"
#import "PlugInNode.h"
#import "SequencerNodeProperty.h"
#import "SequencerSequence.h"
#import "SequencerKeyframe.h"
#import "SequencerKeyframeEasing.h"

@implementation SequencerCell

@synthesize node;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    return self;
}

- (void) drawPropertyRowVisiblityWithFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    
    // Draw background
    NSRect rowRect = NSMakeRect(cellFrame.origin.x, cellFrame.origin.y -1, cellFrame.size.width, kCCBSeqDefaultRowHeight+1);
    [imgRowBg0 drawInRect:rowRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    
    SequencerNodeProperty* nodeProp = [node sequenceNodeProperty:@"visible" sequenceId:seq.sequenceId];
    
    if (nodeProp)
    {        
        // Draw keyframes
        NSArray* keyframes = nodeProp.keyframes;
        for (SequencerKeyframe* keyframe in keyframes)
        {
            int xPos = [seq timeToPosition:keyframe.time];
            
            NSImage* img = NULL;
            if (keyframe.selected)
            {
                img = imgKeyframeSel;
            }
            else
            {
                img = imgKeyframe;
            }
            
            [img drawAtPoint:NSMakePoint(cellFrame.origin.x + xPos-3, cellFrame.origin.y) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
        }
    }
}

- (void) drawPropertyRow:(int) row property:(NSString*)propName withFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    
    SequencerNodeProperty* nodeProp = [node sequenceNodeProperty:propName sequenceId:seq.sequenceId];
    
    // Draw background
    NSRect rowRect = NSMakeRect(cellFrame.origin.x, cellFrame.origin.y+row*kCCBSeqDefaultRowHeight, cellFrame.size.width, kCCBSeqDefaultRowHeight);
    if (row == 1)
    {
        [imgRowBg1 drawInRect:rowRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
    else
    {
        [imgRowBgN drawInRect:rowRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
    
    if (nodeProp)
    {        
        // Draw keyframes & interpolation lines
        NSArray* keyframes = nodeProp.keyframes;
        for (int i = 0; i < [keyframes count]; i++)
        {
            SequencerKeyframe* keyframe = [keyframes objectAtIndex:i];
            SequencerKeyframe* keyframeNext = NULL;
            if (i + 1 < [keyframes count])
            {
                keyframeNext = [keyframes objectAtIndex:i+1];
            }
            
            int xPos = [seq timeToPosition:keyframe.time];
            
            // Dim interpolation if keyframes are equal
            float fraction = 1;
            if ([keyframe valueIsEqualTo:keyframeNext])
            {
                fraction = 0.5f;
            }
            
            if (keyframeNext && keyframe.easing.type != kCCBKeyframeEasingInstant)
            {
                // Draw interpolation line
                int xPosNext = [seq timeToPosition:keyframeNext.time];
                
                NSRect interpolRect = NSMakeRect(cellFrame.origin.x + xPos, cellFrame.origin.y+kCCBSeqDefaultRowHeight*row+5, xPosNext-xPos, 7);
                
                [imgInterpol drawInRect:interpolRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fraction];
                
                BOOL easeIn = keyframe.easing.hasEaseIn;
                BOOL easeOut = keyframe.easing.hasEaseOut;
                
                if (easeIn || easeOut)
                {
                    // Draw ease in/out
                    NSGraphicsContext* gc = [NSGraphicsContext currentContext];
                    [gc saveGraphicsState];
                    [NSBezierPath clipRect:interpolRect];
                    
                    if (easeIn)
                    {
                        [imgEaseIn drawAtPoint:NSMakePoint(cellFrame.origin.x + xPos + 5, cellFrame.origin.y+kCCBSeqDefaultRowHeight*row+7) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fraction];
                    }
                    
                    if (easeOut)
                    {
                        [imgEaseOut drawAtPoint:NSMakePoint(cellFrame.origin.x + xPosNext - 18, cellFrame.origin.y+kCCBSeqDefaultRowHeight*row+7) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fraction];
                    }
                
                    [gc restoreGraphicsState];
                }
            }
            
            // Draw keyframe
            NSImage* img = NULL;
            if (keyframe.selected)
            {
                img = imgKeyframeSel;
            }
            else
            {
                img = imgKeyframe;
            }
            
            [img drawAtPoint:NSMakePoint(cellFrame.origin.x + xPos-3, cellFrame.origin.y+kCCBSeqDefaultRowHeight*row+2) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
        }
    }
}

- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSGraphicsContext* gc = [NSGraphicsContext currentContext];
    [gc saveGraphicsState];
    
    NSRect clipRect = cellFrame;
    clipRect.origin.y -= 1;
    clipRect.size.height += 1;
    [NSBezierPath clipRect:clipRect];
    
    if (!imagesLoaded)
    {
        imgKeyframe = [[NSImage imageNamed:@"seq-keyframe.png"] retain];
        [imgKeyframe setFlipped:YES];
        
        imgKeyframeSel = [[NSImage imageNamed:@"seq-keyframe-sel.png"] retain];
        [imgKeyframeSel setFlipped:YES];
        
        imgRowBg0 = [[NSImage imageNamed:@"seq-row-0-bg.png"] retain];
        [imgRowBg0 setFlipped:YES];
        
        imgRowBg1 = [[NSImage imageNamed:@"seq-row-1-bg.png"] retain];
        [imgRowBg1 setFlipped:YES];
        
        imgRowBgN = [[NSImage imageNamed:@"seq-row-n-bg.png"] retain];
        [imgRowBgN setFlipped:YES];
        
        imgInterpol = [[NSImage imageNamed:@"seq-keyframe-interpol.png"] retain];
        [imgInterpol setFlipped:YES];
        
        imgEaseIn = [[NSImage imageNamed:@"seq-keyframe-easein.png"] retain];
        [imgEaseIn setFlipped:YES];
        
        imgEaseOut = [[NSImage imageNamed:@"seq-keyframe-easeout.png"] retain];
        [imgEaseOut setFlipped:YES];
    }
    
    [self drawPropertyRowVisiblityWithFrame:cellFrame inView:controlView];
    
    if (node.seqExpanded)
    {
        NSArray* props = node.plugIn.animatableProperties;
        for (int i = 0; i < [props count]; i++)
        {
            [self drawPropertyRow:i+1 property:[props objectAtIndex:i] withFrame:cellFrame inView:controlView];
        }
    }
    
    [gc restoreGraphicsState];
}

- (void) dealloc
{
    [imgKeyframe release];
    [imgKeyframeSel release];
    [imgRowBg0 release];
    [imgRowBg1 release];
    [imgRowBgN release];
    [imgInterpol release];
    [imgEaseIn release];
    [imgEaseOut release];
    [super dealloc];
}

@end
