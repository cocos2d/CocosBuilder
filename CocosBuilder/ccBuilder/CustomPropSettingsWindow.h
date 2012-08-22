//
//  CustomPropSettingsWindow.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 8/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBModalSheetController.h"
#import "cocos2d.h"

@interface CustomPropSettingsWindow : CCBModalSheetController
{
    NSMutableArray* settings;
    CCNode* node;
}

@property (nonatomic,retain) NSMutableArray* settings;

- (void) copySettingsForNode:(CCNode*)n;

@end
