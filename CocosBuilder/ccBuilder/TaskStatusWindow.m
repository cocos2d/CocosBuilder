//
//  TaskStatusWindow.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TaskStatusWindow.h"

@implementation TaskStatusWindow

@synthesize status;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) windowDidLoad
{
    [super windowDidLoad];
    [progress startAnimation:self];
    [progress setUsesThreadedAnimation:YES];
}

@end
