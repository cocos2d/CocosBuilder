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
    
}

- (void) drawPropertyRow:(int) row property:(NSString*)propName withFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    
    SequencerNodeProperty* nodeProp = [node sequenceNodeProperty:propName sequenceId:seq.sequenceId];
    
    if (nodeProp)
    {
        NSRect rect = NSMakeRect(cellFrame.origin.x, cellFrame.origin.y+kCCBSeqDefaultRowHeight*row+2, cellFrame.size.width, 12);
        
        [[NSColor redColor] set];
        NSRectFill(rect);
        
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
    if (!imgKeyframe)
    {
        imgKeyframe = [[NSImage imageNamed:@"seq-keyframe.png"] retain];
    }
    if (!imgKeyframeSel)
    {
        imgKeyframeSel = [[NSImage imageNamed:@"seq-keyframe-sel.png"] retain];
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
