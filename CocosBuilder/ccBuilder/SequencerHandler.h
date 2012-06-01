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

@class CocosBuilderAppDelegate;

@interface SequencerHandler : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate>
{
    NSOutlineView* outlineHierarchy;
    BOOL dragAndDropEnabled;
    
    CocosBuilderAppDelegate* appDelegate;
    
    float timelineScale;
    float timelineOffset;
}

@property (nonatomic,assign) BOOL dragAndDropEnabled;

@property (nonatomic,assign) float timelineScale;
@property (nonatomic,assign) float timelineOffset;

// Retain the shared instance
+ (SequencerHandler*) sharedHandler;

- (id) initWithOutlineView:(NSOutlineView*)view;
- (void) updateOutlineViewSelection;
- (void) updateExpandedForNode:(CCNode*)node;
- (void) toggleSeqExpanderForRow:(int)row;

@end
