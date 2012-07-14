//
//  PlayerConsoleWindow.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PlayerConnection.h"

@interface PlayerConsoleWindow : NSWindowController <PlayerConnectionDelegate>
{
    IBOutlet NSPopUpButton* devicePopup;
    IBOutlet NSMenu* deviceMenu;
}

@end
