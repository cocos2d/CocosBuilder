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
#import "MainToolbarDelegate.h"

#import "PlugInManager.h"
#import "PlugInNode.h"
#import "CocosBuilderAppDelegate.h"
#import <Carbon/Carbon.h>


@implementation MainToolbarDelegate

- (NSToolbarItem *) toolbar:(NSToolbar *)toolbar
      itemForItemIdentifier:(NSString *)itemIdentifier
  willBeInsertedIntoToolbar:(BOOL)flag
{
    // Setup toolbar item
    NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
    
    // User added plug-ins
    if ([itemIdentifier isEqualToString:@"PlugIns"])
    {
        toolbarItem.label = @"PlugIns";
        toolbarItem.paletteLabel = @"PlugIns";
        
        NSSegmentedControl* segmControl = [[[NSSegmentedControl alloc] initWithFrame:NSMakeRect(0, 0, 80, 32)] autorelease];
        NSSegmentedCell* segmCell = [segmControl cell];
        segmCell.trackingMode = NSSegmentSwitchTrackingMomentary;
        
        segmControl.segmentCount = 1;
        [segmControl setWidth:44 forSegment:0];
        
        [segmControl setImage:[NSImage imageNamed:@"TB_plugins.png"] forSegment:0];
        [segmCell setToolTip:@"User PlugIns" forSegment:0];
        
        segmControl.segmentStyle = NSSegmentStyleTexturedRounded;
        [segmControl sizeToFit];
        [toolbarItem setView:segmControl];
        
        
        // Add menu with plugIns
        NSMenu* menu = [[[NSMenu alloc] initWithTitle:@"User PlugIns"] autorelease];
        
        if (userPlugIns.count > 0)
        {
            for (NSString* plugInName in userPlugIns)
            {
                NSMenuItem* item = [[[NSMenuItem alloc] initWithTitle:plugInName action:@selector(selectedItem:) keyEquivalent:@""] autorelease];
                item.target = self;
            
                [menu addItem:item];
            }
        }
        else
        {
            NSMenuItem* item = [[[NSMenuItem alloc] initWithTitle:@"No User PlugIns Installed" action:NULL keyEquivalent:@""] autorelease];
            [item setEnabled:NO];
            
            [menu addItem:item];
        }
        
        [segmControl setMenu:menu forSegment:0];
        
        [toolbarItem bind:@"enabled" toObject:[CocosBuilderAppDelegate appDelegate] withKeyPath:@"hasOpenedDocument" options:NULL];
        
        return toolbarItem;
    }
    
    // Default plug-ins
    NSArray* plugInGroups = [plugInSettings objectForKey:@"plugInGroups"];
    NSArray* plugIns = NULL;
    for (NSDictionary* plugInGroup in plugInGroups)
    {
        NSString* groupName = [plugInGroup objectForKey:@"groupName"];
        if ([groupName isEqualToString:itemIdentifier])
        {
            plugIns = [plugInGroup objectForKey:@"plugIns"];
            break;
        }
    }
    
    if (!plugIns) return NULL;
    
    PlugInManager* pim = [PlugInManager sharedManager];
    
    toolbarItem.label = itemIdentifier;
    toolbarItem.paletteLabel = itemIdentifier;
    
    // Create custom segmented control view
    NSSegmentedControl* segmControl = [[[NSSegmentedControl alloc] initWithFrame:NSMakeRect(0, 0, 80, 32)] autorelease];
    NSSegmentedCell* segmCell = [segmControl cell];
    segmCell.trackingMode = NSSegmentSwitchTrackingMomentary;
    
    [segmControl setSegmentCount:plugIns.count];
    [segmControl setTarget:self];
    [segmControl setAction:@selector(pressedSegment:)];
    for (int i = 0; i < plugIns.count; i++)
    {
        [segmControl setWidth:34 forSegment:i];
        [segmCell setToolTip:[plugIns objectAtIndex:i] forSegment:i];
        
        // Load icon
        PlugInNode* plugIn = [pim plugInNodeNamed:[plugIns objectAtIndex:i]];
        [segmCell setImage:plugIn.icon forSegment:i];
    }
    
    segmControl.segmentStyle = NSSegmentStyleTexturedRounded;
    [segmControl sizeToFit];
    
    [toolbarItem setView:segmControl];
    
    // Bind enabled property
    [toolbarItem bind:@"enabled" toObject:[CocosBuilderAppDelegate appDelegate] withKeyPath:@"hasOpenedDocument" options:NULL];
    
    return toolbarItem;
}

- (void) addPlugInItemsToToolbar:(NSToolbar*) toolbar
{
    // Load configuration file
    NSString* path = [[NSBundle mainBundle] pathForResource:@"NodePlugInsList" ofType:@"plist"];
    plugInSettings = [[NSDictionary dictionaryWithContentsOfFile:path] retain];
    
    NSArray* plugInGroups = [plugInSettings objectForKey:@"plugInGroups"];
    
    NSMutableSet* addedPlugIns = [NSMutableSet set];
    
    // Add default plug-ins
    for (NSDictionary* plugInGroup in plugInGroups)
    {
        // Add to toolbar
        NSString* groupName = [plugInGroup objectForKey:@"groupName"];
        [toolbar insertItemWithItemIdentifier:groupName atIndex:[[toolbar items] count]];
        
        // Remember which plug-ins have been added
        NSArray* plugIns = [plugInGroup objectForKey:@"plugIns"];
        [addedPlugIns addObjectsFromArray:plugIns];
    }
    
    // Figure out which plug-ins hasn't been added (user plug-ins)
    userPlugIns = [[NSMutableArray alloc] init];
    
    PlugInManager* pim = [PlugInManager sharedManager];
    NSArray* nodeNames = pim.plugInsNodeNames;
    for (NSString* nodeName in nodeNames)
    {
        if (![addedPlugIns containsObject:nodeName])
        {
            [userPlugIns addObject:nodeName];
        }
    }
    
    // Add extra plug-ins button
    [toolbar insertItemWithItemIdentifier:@"PlugIns" atIndex:[[toolbar items] count]];
}

- (void) pressedSegment:(id) sender
{
    int selectedSegment = [[sender cell] selectedSegment];
    NSString* objType = [[sender cell] toolTipForSegment:selectedSegment];
    BOOL asChild = ((GetCurrentKeyModifiers() & shiftKey) != 0);
    
    [[CocosBuilderAppDelegate appDelegate] addPlugInNodeNamed:objType asChild:asChild];
}

- (void) selectedItem:(id) sender
{
    NSString* objType = [sender title];
    BOOL asChild = ((GetCurrentKeyModifiers() & shiftKey) != 0);
    
    [[CocosBuilderAppDelegate appDelegate] addPlugInNodeNamed:objType asChild:asChild];
}

- (void) dealloc
{
    [plugInSettings release];
    [super dealloc];
}

@end
