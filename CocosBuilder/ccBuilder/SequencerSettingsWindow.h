//
//  SequencerSettingsWindow.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CCBModalSheetController.h"

@interface SequencerSettingsWindow : CCBModalSheetController
{
    NSMutableArray* sequences;
}
@property (nonatomic,retain) NSMutableArray* sequences;

- (void) copySequences:(NSMutableArray *)res;

- (void) disableAutoPlayForAllItems;
@end
