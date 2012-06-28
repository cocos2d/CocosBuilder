//
//  SequencerStructureCell.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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
    // Only draw property names if cell is expanded
    if ([node seqExpanded])
    {
        SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
        
        // Color
        NSColor* textColor = [[self textColor] colorWithAlphaComponent:0.6];
        
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
        
        // Draw property names
        SequencerNodeProperty* seqNodeProp = [node sequenceNodeProperty:@"visible" sequenceId:seq.sequenceId];
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
        
        NSArray* props = node.plugIn.animatableProperties;
        
        for (NSString* prop in props)
        {
            seqNodeProp = [node sequenceNodeProperty:prop sequenceId:seq.sequenceId];
            BOOL hasKeyframes = ([seqNodeProp.keyframes count] > 0);
            
            if (hasKeyframes)
            {
                [attrib setObject:[NSFont boldSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]] forKey:NSFontAttributeName];
            }
            else
            {
                [attrib setObject:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]] forKey:NSFontAttributeName];
            }
            
            NSString* displayName = [[node.plugIn.nodePropertiesDict objectForKey:prop] objectForKey:@"displayName"];
            
            propNameRect.origin.y += kCCBSeqDefaultRowHeight;
            [displayName drawInRect:propNameRect withAttributes:attrib];
        }
    
        // Leave space for property name when drawing name in super method
        cellFrame.size.width = cellFrame.size.width - 55;
    }
    
    [super drawWithFrame:cellFrame inView:controlView];
}

- (void) dealloc
{
    //self.node = NULL;
    [super dealloc];
}

@end
