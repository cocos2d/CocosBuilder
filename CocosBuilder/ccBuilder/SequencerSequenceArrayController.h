//
//  SequencerSequenceArrayController.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SequencerSettingsWindow;

@interface SequencerSequenceArrayController : NSArrayController
{
    IBOutlet SequencerSettingsWindow* settingsWindow;
}

@property (nonatomic,assign) SequencerSettingsWindow* settingsWindow;

@end
