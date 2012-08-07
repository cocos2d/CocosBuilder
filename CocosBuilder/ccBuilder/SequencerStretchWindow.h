//
//  SequencerStretchWindow.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBModalSheetController.h"

@interface SequencerStretchWindow : CCBModalSheetController
{
    float factor;
}

@property (nonatomic,assign) float factor;

@end
