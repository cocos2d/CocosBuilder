//
//  CustomPropSettingsWindow.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 8/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomPropSettingsWindow.h"

@interface CustomPropSettingsWindow ()

@end

@implementation CustomPropSettingsWindow

@synthesize settings;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        self.settings = [NSMutableArray array];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void) dealloc
{
    self.settings = NULL;
    [super dealloc];
}

@end
