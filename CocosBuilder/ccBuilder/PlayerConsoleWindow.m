//
//  PlayerConsoleWindow.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayerConsoleWindow.h"

@interface PlayerConsoleWindow ()

@end

@implementation PlayerConsoleWindow

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

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self setupDeviceMenu];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)pressedPlay:(id)sender
{
}

- (IBAction)pressedStop:(id)sender
{
}

- (void) playerConnection: (PlayerConnection*)playerConn updatedPlayerList:(NSDictionary*)playerList
{
    [self setupDeviceMenu];
}

@end
