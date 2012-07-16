//
//  PlayerConsoleWindow.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayerConsoleWindow.h"
#import "MGSFragaria.h"
#import "SMLTextView.h"
#import "CocosBuilderAppDelegate.h"

@interface PlayerConsoleWindow ()

@end

@implementation PlayerConsoleWindow

#pragma mark Init & Setup

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    // Setup delegate
    [PlayerConnection sharedPlayerConnection].delegate = self;
    
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
            
            if ([serverIdentifier isEqualToString:[PlayerConnection sharedPlayerConnection].selectedServer])
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
    
    [PlayerConnection sharedPlayerConnection].selectedServer = item.representedObject;
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

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self setupFragaria];
    
    [self setupDeviceMenu];
    
    [self writeToConsole:@"CocosPlayer JavaScript Console\n" bold:NO];
    
    self.window.delegate = self;
}

#pragma mark Play/Stop buttons

- (IBAction)pressedPlay:(id)sender
{
    [[CocosBuilderAppDelegate appDelegate] runProject:self];
}

- (IBAction)pressedStop:(id)sender
{
}

- (IBAction)pressedSendJSCode:(id)sender
{
    NSString* script = [fragariaTextView string];
    
    [[PlayerConnection sharedPlayerConnection] sendJavaScript:script];
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
