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

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define kCCBSeqDefaultRowHeight 16
#define kCCBDefaultTimelineScale 128
#define kCCBTimelineScaleLowBound 64

@class CocosBuilderAppDelegate;
@class SequencerSequence;
@class SequencerScrubberSelectionView;
@class SequencerKeyframe;

@interface SequencerHandler : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate>
{
    NSOutlineView* outlineHierarchy;
    BOOL dragAndDropEnabled;
    
    CocosBuilderAppDelegate* appDelegate;
    
    SequencerSequence* currentSequence;
    //NSMutableArray* sequences;
    SequencerScrubberSelectionView* scrubberSelectionView;
    NSTextField* timeDisplay;
    NSSlider* timeScaleSlider;
    NSScroller* scroller;
    NSScrollView* scrollView;
    
    SequencerKeyframe* contextKeyframe;
}

@property (nonatomic,assign) BOOL dragAndDropEnabled;

@property (nonatomic,retain) SequencerSequence* currentSequence;
@property (nonatomic,retain) SequencerScrubberSelectionView* scrubberSelectionView;
@property (nonatomic,retain) NSTextField* timeDisplay;
@property (nonatomic,retain) NSSlider* timeScaleSlider;
@property (nonatomic,retain) NSScroller* scroller;
@property (nonatomic,retain) NSScrollView* scrollView;
//@property (nonatomic,retain) NSMutableArray* sequences;

@property (nonatomic,readonly) NSOutlineView* outlineHierarchy;

@property (nonatomic,retain) SequencerKeyframe* contextKeyframe;


// Obtain the shared instance
+ (SequencerHandler*) sharedHandler;

- (id) initWithOutlineView:(NSOutlineView*)view;
- (void) updateOutlineViewSelection;
- (void) updateExpandedForNode:(CCNode*)node;
- (void) toggleSeqExpanderForRow:(int)row;

- (void) redrawTimeline:(BOOL) reload;
- (void) redrawTimeline;
- (void) updateScroller;
- (void) updateScrollerToShowCurrentTime;

- (void) updateScaleSlider;

- (float) visibleTimeArea;
- (float) maxTimelineOffset;

- (void) deleteSequenceId:(int)seqId;

- (void) deselectAllKeyframes;
- (NSArray*) selectedKeyframesForCurrentSequence;
- (void) updatePropertiesToTimelinePosition;

- (BOOL) deleteSelectedKeyframesForCurrentSequence;
- (void) deleteDuplicateKeyframesForCurrentSequence;
- (void) deleteKeyframesForCurrentSequenceAfterTime:(float)time;

- (void) setContextKeyframeEasingType:(int) type;

- (void) menuAddKeyframeNamed:(NSString*)keyframeName;
- (BOOL) canInsertKeyframeNamed:(NSString*)prop;
@end
