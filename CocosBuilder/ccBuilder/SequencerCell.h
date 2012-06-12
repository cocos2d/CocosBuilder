//
//  SequencerCell.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "cocos2d.h"

@interface SequencerCell : NSCell
{
    CCNode* node;
    
    BOOL imagesLoaded;
    
    NSImage* imgKeyframe;
    NSImage* imgKeyframeSel;
    
    NSImage* imgRowBg0;
    NSImage* imgRowBg1;
    NSImage* imgRowBgN;
}

@property (nonatomic,assign) CCNode* node;

@end
