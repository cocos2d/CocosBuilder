//
//  PlayerConsoleWindow.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PlayerConnection.h"

@class MGSFragaria;
@class SMLTextView;

@interface PlayerConsoleWindow : NSWindowController <PlayerConnectionDelegate,NSWindowDelegate>
{
    PlayerConnection* playerConnection;
    
    IBOutlet NSPopUpButton* devicePopup;
    IBOutlet NSMenu* deviceMenu;
    
    IBOutlet NSTextView* textView;
    BOOL scrolledToBottomWhenResizing;
    
    // Javascript editor
    IBOutlet NSView* jsView;
    
    MGSFragaria* fragaria;
    SMLTextView* fragariaTextView;
}

@property (nonatomic,readonly) PlayerConnection* playerConnection;

- (void) writeToConsole:(NSString*) str bold:(BOOL)bold;

- (IBAction)pressedPlay:(id)sender;
- (IBAction)pressedStop:(id)sender;
- (IBAction)pressedSendJSCode:(id)sender;

@end
