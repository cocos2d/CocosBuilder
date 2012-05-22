//
//  TaskStatusWindow.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TaskStatusWindow : NSWindowController
{
    NSString* status;
    IBOutlet NSProgressIndicator* progress;
    IBOutlet NSTextField* lblStatus;
}

@property (atomic,copy) NSString* status;

@end
