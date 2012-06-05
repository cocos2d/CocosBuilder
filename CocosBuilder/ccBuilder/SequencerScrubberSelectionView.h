//
//  SequencerScrubberSelectionView.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "cocos2d.h"

enum
{
    kCCBSeqMouseStateNone = 0,
    kCCBSeqMouseStateScrubbing,
    kCCBSeqMouseStateSelecting,
};

enum
{
    kCCBSeqAutoScrollHorizontalNone = 0,
    kCCBSeqAutoScrollHorizontalLeft,
    kCCBSeqAutoScrollHorizontalRight,
};

enum
{
    kCCBSeqAutoScrollVerticalNone = 0,
    kCCBSeqAutoScrollVerticalUp,
    kCCBSeqAutoScrollVerticalDown,
};

#define kCCBRowNone -1
#define kCCBRowNoneAbove -2
#define kCCBRowNoneBelow -3

#define kCCBSeqScrubberHeight 16

@interface SequencerScrubberSelectionView : NSView
{
    NSImage* imgScrubHandle;
    NSImage* imgScrubLine;
    
    int mouseState;
    int autoScrollHorizontalDirection;
    int autoScrollVerticalDirection;
    NSPoint lastMousePosition;
    NSEvent* lastDragEvent;
    
    // Current selection
    float xStartSelectTime;
    float xEndSelectTime;
    int yStartSelectRow;
    int yStartSelectSubRow;
    int yEndSelectRow;
    int yEndSelectSubRow;
}

@property (nonatomic,retain) NSEvent* lastDragEvent;

@end
