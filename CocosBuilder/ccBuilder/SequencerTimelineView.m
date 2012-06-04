//
//  SequencerTimelineView.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SequencerTimelineView.h"
#import "SequencerHandler.h"
#import "SequencerSequence.h"

@implementation SequencerTimelineView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return NULL;
    
    // Load graphic assets
    
    // Background
    imgBg = [[NSImage imageNamed:@"seq-tl-bg.png"] retain];
    [imgBg setFlipped:YES];
    
    // Markers
    imgMarkMajor = [[NSImage imageNamed:@"seq-tl-mark-major.png"] retain];
    imgMarkMinor = [[NSImage imageNamed:@"seq-tl-mark-minor.png"] retain];
    
    [imgMarkMajor setFlipped:YES];
    [imgMarkMinor setFlipped:YES];
    
    // Numbers
    imgNumbers = [[NSImage imageNamed:@"ruler-numbers.png"] retain];
    
    // Rects for the individual numbers
    for (int i = 0; i < 10; i++)
    {
        numberRects[i] = NSMakeRect(18+6*i, 0, 6, 8);
    }
    
    return self;
}

- (void) drawNumber:(int)num at:(NSPoint)pt
{
    NSString* str = [NSString stringWithFormat:@"%d",num];
    for (int i = 0; i < [str length]; i++)
    {
        int ch = [str characterAtIndex:i] - '0';
        
        [imgNumbers drawAtPoint:NSMakePoint(pt.x+i*6, pt.y) fromRect:numberRects[ch] operation:NSCompositeSourceOver fraction:1];
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Get current sequence
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    
    // Draw background
    [imgBg drawInRect:[self bounds] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    
    // Retrieve timeline offset/scale
    float tlScale = seq.timelineScale;
    float tlOffset = seq.timelineOffset;
    int divisions = 4;
    
    if (tlScale == 0) tlScale = kCCBDefaultTimelineScale;
    
    int secondMarker = tlOffset;
    float xPos = -roundf((tlOffset - secondMarker)*tlScale);
    float width = [self bounds].size.width;
    float stepSize = tlScale/divisions;
    int step = 0;
    
    NSAssert(stepSize > 0, @"stepSize is <= 0");
    
    while (xPos < width)
    {
        if (step % divisions == 0)
        {
            // Major marker
            [imgMarkMajor drawAtPoint:NSMakePoint(xPos, 0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
            
            [self drawNumber:secondMarker at:NSMakePoint(xPos+3, 1)];
            
            secondMarker++;
        }
        else
        {
            // Minor marker
            [imgMarkMinor drawAtPoint:NSMakePoint(xPos, 0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
        }
        
        step++;
        xPos+=stepSize;
    }
}

- (void) dealloc
{
    [imgBg release];
    [super dealloc];
}

@end
