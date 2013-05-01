/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <Cocoa/Cocoa.h>
#import "PlayerConnection.h"

@class DebuggerTextField;

@interface PlayerConsoleWindow : NSWindowController <PlayerConnectionDelegate,NSWindowDelegate>
{
    PlayerConnection* playerConnection;
    
    IBOutlet NSPopUpButton* devicePopup;
    IBOutlet NSMenu* deviceMenu;
    IBOutlet NSButton *btnPairing;
    
    IBOutlet NSTextView* textView;
    BOOL scrolledToBottomWhenResizing;
    
    IBOutlet DebuggerTextField* textInput;
}

@property (nonatomic,readonly) PlayerConnection* playerConnection;

- (void) writeToConsole:(NSString*) str bold:(BOOL)bold;
- (void) writeToConsole:(NSString*) str bold:(BOOL)bold color:(NSColor*) color;
- (void) cleanConsole;

- (IBAction)pressedPlay:(id)sender;
- (IBAction)pressedStop:(id)sender;
- (IBAction)pressedSendJSCode:(id)sender;
- (IBAction)pressedPairing:(id)sender;
- (IBAction)pressedContinue:(id)sender;
- (IBAction)pressedStep:(id)sender;

@end
