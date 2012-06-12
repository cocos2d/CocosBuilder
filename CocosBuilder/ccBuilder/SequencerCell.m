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
            
            [img drawAtPoint:NSMakePoint(cellFrame.origin.x + xPos-3, cellFrame.origin.y+kCCBSeqDefaultRowHeight*row+1) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
        }
    }
}

- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    if (!imagesLoaded)
    {
        imgKeyframe = [[NSImage imageNamed:@"seq-keyframe.png"] retain];
        [imgKeyframe setFlipped:YES];
        
        imgKeyframeSel = [[NSImage imageNamed:@"seq-keyframe-sel.png"] retain];
        [imgKeyframeSel setFlipped:YES];
        
        imgRowBg0 = [[NSImage imageNamed:@"seq-row-0-bg"] retain];
        [imgRowBg0 setFlipped:YES];
        
        imgRowBg1 = [[NSImage imageNamed:@"seq-row-1-bg"] retain];
        [imgRowBg1 setFlipped:YES];
        
        imgRowBgN = [[NSImage imageNamed:@"seq-row-n-bg"] retain];
        [imgRowBgN setFlipped:YES];
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
}

- (void) dealloc
{
    [imgKeyframe release];
    [imgKeyframeSel release];
    [super dealloc];
}

@end
