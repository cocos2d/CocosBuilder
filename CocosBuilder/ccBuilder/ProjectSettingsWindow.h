//
//  ProjectSettingsWindow.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBModalSheetController.h"
#import "cocos2d.h"

@class ProjectSettings;

@interface ProjectSettingsWindow : CCBModalSheetController
{
    ProjectSettings* projectSettings;
    IBOutlet NSArrayController* resDirArrayController;
}

@property (nonatomic,retain) ProjectSettings* projectSettings;

@end
