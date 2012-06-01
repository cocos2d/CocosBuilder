//
//  SequencerStructureCell.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBTextFieldCell.h"

@interface SequencerStructureCell : CCBTextFieldCell
{
    BOOL isExpanded;
}

@property (nonatomic,assign) BOOL isExapanded;

@end
