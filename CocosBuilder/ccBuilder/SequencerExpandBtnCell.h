//
//  SequencerExpandBtnCell.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface SequencerExpandBtnCell : NSCell
{
    NSImage* imgExpand;
    NSImage* imgCollapse;
    
    BOOL isExpanded;
}

@property (nonatomic,assign) BOOL isExpanded;

@end
