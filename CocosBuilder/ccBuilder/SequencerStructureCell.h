//
//  SequencerStructureCell.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBTextFieldCell.h"
#import "cocos2d.h"

@interface SequencerStructureCell : CCBTextFieldCell
{
    CCNode* node;
}

@property (nonatomic,assign) CCNode* node;

@end
