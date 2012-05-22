//
//  AppDelegate.h
//  Player
//
//  Created by Viktor Lidholt on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "cocos2d.h"

@class JSCocoa;
@class ConsoleWindow;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
{
    IBOutlet NSWindow* window;
    IBOutlet CCGLView* glView;
    
    ConsoleWindow* console;
}


@property (nonatomic,retain) NSWindow *window;
@property (nonatomic,readonly) ConsoleWindow* console;

@end
