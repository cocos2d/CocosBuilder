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
    
    imgEndmarker = [[NSImage imageNamed:@"seq-endmarker.png"] retain];
    imgStartmarker = [[NSImage imageNamed:@"seq-startmarker.png"] retain];
    
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
    
    if (tlScale == 0) tlScale = kCCBDefaultTimelineScale;
    
    int divisions = 6;
    if (tlScale <= kCCBTimelineScaleLowBound) divisions = 2;
    
    int secondMarker = tlOffset;
    float xPos = -roundf((tlOffset - secondMarker)*tlScale);
    xPos += TIMELINE_PAD_PIXELS;
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
    
    // Draw end marker
    xPos = roundf([seq timeToPosition: seq.timelineLength]);
    [imgEndmarker drawAtPoint:NSMakePoint(xPos, 0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];

    // draw start marker
    float xStartPos = [seq timeToPosition:0] - TIMELINE_PAD_PIXELS;
    [[NSGraphicsContext currentContext] saveGraphicsState];
    NSRectClip(NSMakeRect(0, 0, TIMELINE_PAD_PIXELS+1, self.bounds.size.height));
    [imgStartmarker drawInRect:NSMakeRect(xStartPos, 0, TIMELINE_PAD_PIXELS+1, self.bounds.size.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    [[NSGraphicsContext currentContext] restoreGraphicsState];

}

- (void) dealloc
{
    [imgBg release];
    [imgEndmarker release];
    [imgStartmarker release];
    [super dealloc];
}

@end
