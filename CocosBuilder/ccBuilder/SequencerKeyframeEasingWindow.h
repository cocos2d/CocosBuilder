//
//  SequencerKeyframeEasingWindow.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBModalSheetController.h"

@interface SequencerKeyframeEasingWindow : CCBModalSheetController
{
    float option;
    NSString* optionName;
}

@property (nonatomic,assign) float option;
@property (nonatomic,copy) NSString* optionName;

@end
