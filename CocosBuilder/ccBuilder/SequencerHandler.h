//
//  SequencerHandler.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define kCCBSeqDefaultRowHeight 16
#define kCCBDefaultTimelineScale 128

#define kCCBNumTimlineScales 5

#define kCCBTimelineScale0 32
#define kCCBTimelineScale1 64
#define kCCBTimelineScale2 128
#define kCCBTimelineScale3 256
#define kCCBTimelineScale4 512

@class CocosBuilderAppDelegate;
@class SequencerSequence;
@class SequencerScrubberSelectionView;

@interface SequencerHandler : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate>
{
    NSOutlineView* outlineHierarchy;
    BOOL dragAndDropEnabled;
    
    float timelineScales[kCCBNumTimlineScales];
    
    CocosBuilderAppDelegate* appDelegate;
    
    SequencerSequence* currentSequence;
    //NSMutableArray* sequences;
    SequencerScrubberSelectionView* scrubberSelectionView;
    NSTextField* timeDisplay;
    NSSlider* timeScaleSlider;
    NSScroller* scroller;
    NSScrollView* scrollView;
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


// Obtain the shared instance
+ (SequencerHandler*) sharedHandler;

- (id) initWithOutlineView:(NSOutlineView*)view;
- (void) updateOutlineViewSelection;
- (void) updateExpandedForNode:(CCNode*)node;
- (void) toggleSeqExpanderForRow:(int)row;

- (void) redrawTimeline;
- (void) updateScroller;

- (void) updateScaleSlider;

- (float) visibleTimeArea;
- (float) maxTimelineOffset;

- (void) deselectAllKeyframes;
- (NSArray*) selectedKeyframesForCurrentSequence;
- (void) updatePropertiesToTimelinePosition;

- (BOOL) deleteSelectedKeyframesForCurrentSequence;
- (void) deleteDuplicateKeyframesForCurrentSequence;
- (void) deleteKeyframesForCurrentSequenceAfterTime:(float)time;
@end
