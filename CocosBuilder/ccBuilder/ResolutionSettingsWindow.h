//
//  ResolutionSettingsWindow.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBModalSheetController.h"

@interface ResolutionSettingsWindow : CCBModalSheetController
{
    NSMutableArray* resolutions;
}

@property (nonatomic,retain) NSMutableArray* resolutions;
- (void) copyResolutions:(NSMutableArray *)res;

@end
