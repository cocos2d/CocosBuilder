//
//  SequencerDurationWindow.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBModalSheetController.h"

@interface SequencerDurationWindow : CCBModalSheetController
{
    int mins;
    int secs;
    int frames;
}

@property (nonatomic,assign) float duration;
@property (nonatomic,assign) int mins;
@property (nonatomic,assign) int secs;
@property (nonatomic,assign) int frames;

@end
