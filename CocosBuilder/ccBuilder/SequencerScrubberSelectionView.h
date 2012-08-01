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

#import <Cocoa/Cocoa.h>
#import "cocos2d.h"

@class SequencerKeyframe;

enum
{
    kCCBSeqMouseStateNone = 0,
    kCCBSeqMouseStateScrubbing,
    kCCBSeqMouseStateSelecting,
    kCCBSeqMouseStateKeyframe,
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
    
    SequencerKeyframe* mouseDownKeyframe;
    NSPoint mouseDownPosition;
    int mouseDownRelPositionX;
    BOOL didAutoScroll;
}

@property (nonatomic,retain) NSEvent* lastDragEvent;

@end
