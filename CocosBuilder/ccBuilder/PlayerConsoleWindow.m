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

#import "PlayerConsoleWindow.h"
#import "PlayerConsolePairingWindow.h"
#import "MGSFragaria.h"
#import "SMLTextView.h"
#import "CocosBuilderAppDelegate.h"

@interface PlayerConsoleWindow ()

@end

@implementation PlayerConsoleWindow

@synthesize playerConnection;

#pragma mark Init & Setup

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (!self) return NULL;
    
    // Setup delegate
    playerConnection = [PlayerConnection sharedPlayerConnection];
    playerConnection.delegate = self;
    
    return self;
}

- (void) setupDeviceMenu
{
    NSDictionary* connectedServers = [PlayerConnection sharedPlayerConnection].connectedServers;
    
    [deviceMenu removeAllItems];
    
    if (connectedServers.count > 0)
    {
        NSMenuItem* selectedItem = NULL;
        
        // Add list of available devices
        for (NSString* serverIdentifier in connectedServers)
        {
            NSString* serverName = [connectedServers objectForKey:serverIdentifier];
        
            NSMenuItem* item = [[[NSMenuItem alloc] initWithTitle:serverName action:@selector(selectedServer:) keyEquivalent:@""] autorelease];
            item.target = self;
            item.representedObject = serverIdentifier;
            
            [deviceMenu addItem:item];
            
            if ([serverIdentifier isEqualToString:playerConnection.selectedServer])
            {
                selectedItem = item;
            }
        }
        
        [devicePopup setEnabled:YES];
        [devicePopup selectItem:selectedItem];
    }
    else
    {
        // No available devices
        NSMenuItem* disabledItem = [[[NSMenuItem alloc] initWithTitle:@"No Player Connected" action:NULL keyEquivalent:@""] autorelease];
        [disabledItem setEnabled:NO];
        [deviceMenu addItem:disabledItem];
        
        [devicePopup setEnabled:NO];
    }
}

- (void)selectedServer:(id)sender
{
    NSMenuItem* item = sender;
    
    playerConnection.selectedServer = item.representedObject;
}

- (void) setupFragaria
{
    fragaria = [[MGSFragaria alloc] init];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:MGSPrefsAutocompleteSuggestAutomatically];	
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:MGSPrefsLineWrapNewDocuments];
    
    [fragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOIsSyntaxColoured];
    [fragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOShowLineNumberGutter];
    
    [fragaria setObject:self forKey:MGSFODelegate];
    
    // define our syntax definition
    [fragaria setObject:@"JavaScript" forKey:MGSFOSyntaxDefinitionName];
    [fragaria embedInView:jsView];
    
    // access the NSTextView
    fragariaTextView = [fragaria objectForKey:ro_MGSFOTextView];
}

- (void) updatePairingButton
{
    NSString* pairing = [[NSUserDefaults standardUserDefaults] objectForKey:@"pairing"];
    
    if (pairing)
    {
        [btnPairing setTitle:pairing];
    }
    else
    {
        [btnPairing setTitle:@"Auto"];
    }
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self setupFragaria];
    
    [self setupDeviceMenu];
    [self updatePairingButton];
    
    [self writeToConsole:@"CocosPlayer JavaScript Console\n" bold:NO];
    
    self.window.delegate = self;
}

#pragma mark Play/Stop buttons

- (IBAction)pressedPlay:(id)sender
{
    [[CocosBuilderAppDelegate appDelegate] menuPublishProjectAndRun:self];
}

- (IBAction)pressedStop:(id)sender
{
    [playerConnection sendStopCommand];
}

- (IBAction)pressedSendJSCode:(id)sender
{
    NSString* script = [fragariaTextView string];
    
    [playerConnection sendJavaScript:script];
}

- (IBAction)pressedPairing:(id)sender
{
    PlayerConsolePairingWindow* wc = [[[PlayerConsolePairingWindow alloc] initWithWindowNibName:@"PlayerConsolePairingWindow"] autorelease];
    
    int pairing = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pairing"] intValue];
    wc.pairing = pairing;
    
    int success = [wc runModalSheetForWindow:self.window];
    if (success)
    {
        NSLog(@"Setting pairing! %d", wc.pairing);
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",wc.pairing] forKey:@"pairing"];
    }
    else
    {
        NSLog(@"Removing pairing!");
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"pairing"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updatePairingButton];
    [playerConnection updatePairing];
}

#pragma mark PlayerConnection delegate

- (void) playerConnection: (PlayerConnection*)playerConn updatedPlayerList:(NSDictionary*)playerList
{
    [self setupDeviceMenu];
}

- (void) playerConnection:(PlayerConnection *)playerConn receivedResult:(NSString *)result
{
    [self writeToConsole:result bold:YES];
}

#pragma mark Output console

- (BOOL) isScrolledToBottom
{
    BOOL scrollToEnd = YES;
    
    id scrollView = (NSScrollView *)textView.superview.superview;
    if ([scrollView isKindOfClass:[NSScrollView class]]) {
        if ([scrollView hasVerticalScroller]) {
            if (textView.frame.size.height > [scrollView frame].size.height) {
                if (1.0f != [scrollView verticalScroller].floatValue)
                    scrollToEnd = NO;
            }
        }
    }
    return scrollToEnd;
}

- (void) scrollToBottom
{
    NSRange range = NSMakeRange ([[textView string] length], 0);
    [textView scrollRangeToVisible: range];
}

- (void) writeToConsole:(NSString*) str bold:(BOOL)bold
{
    // Check if we are scrolled to the bottom
    BOOL scrollToEnd = [self isScrolledToBottom];
    
    // Append the string
    NSFont* font = NULL;
    if (bold) font = [NSFont fontWithName:@"Menlo-Bold" size:11];
    else font = [NSFont fontWithName:@"Menlo" size:11];
    
    NSMutableDictionary *attribs = [NSMutableDictionary dictionary];
    [attribs setObject:font forKey:NSFontAttributeName];
    
    NSAttributedString *stringToAppend = [[NSAttributedString alloc] initWithString:str attributes:attribs];
    [[textView textStorage] appendAttributedString:stringToAppend];
    [stringToAppend release];
    
    // Scroll to the end
    if (scrollToEnd)
    {
        [self scrollToBottom];
    }
}

- (void) cleanConsole
{
    [textView setString:@""];
    [self scrollToBottom];
}

- (void) windowWillStartLiveResize:(NSNotification *)notification
{
    scrolledToBottomWhenResizing = [self isScrolledToBottom];
}

- (void) windowDidResize:(NSNotification *)notification
{
    if (scrolledToBottomWhenResizing)
    {
        [self scrollToBottom];
    }
}

@end
