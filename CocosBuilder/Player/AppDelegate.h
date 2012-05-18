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

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet NSWindow* window;
    IBOutlet CCGLView* glView;
    
    JSCocoa* jsController;
}


@property (nonatomic,retain) NSWindow *window;

@end
