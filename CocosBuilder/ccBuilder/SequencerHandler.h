//
//  SequencerHandler.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class CocosBuilderAppDelegate;

@interface SequencerHandler : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate>
{
    NSOutlineView* outlineHierarchy;
    CocosBuilderAppDelegate* appDelegate;
}

- (id) initWithOutlineView:(NSOutlineView*)view;
- (void) updateOutlineViewSelection;
- (void) updateExpandedForNode:(CCNode*)node;

@end
