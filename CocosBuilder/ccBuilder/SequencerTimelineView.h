//
//  SequencerTimelineView.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SequencerTimelineView : NSView
{
    NSImage* imgBg;
    NSImage* imgMarkMajor;
    NSImage* imgMarkMinor;
    NSImage* imgNumbers;
    NSRect numberRects[10];
}
@end
