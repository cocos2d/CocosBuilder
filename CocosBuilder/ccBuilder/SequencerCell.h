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
    
    NSImage* imgKeyframe;
    NSImage* imgKeyframeSel;
}

@property (nonatomic,assign) CCNode* node;

@end
