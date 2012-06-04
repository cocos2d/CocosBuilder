//
//  SequencerScrubberSelectionView.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum
{
    kCCBSeqMouseStateNone = 0,
    kCCBSeqMouseStateScrubbing,
    kCCBSeqMouseStateSelecting,
};

@interface SequencerScrubberSelectionView : NSView
{
    NSImage* imgScrubHandle;
    NSImage* imgScrubLine;
    
    int mouseState;
    
    // Current selection
    float xStartSelectTime;
    float xEndSelectTime;
    int yStartSelectRow;
    int yEndSelectRow;
}

@end
