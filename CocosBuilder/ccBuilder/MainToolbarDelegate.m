//
//  MainToolbarDelegate.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 8/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainToolbarDelegate.h"

#import "PlugInManager.h"
#import "PlugInNode.h"
#import "CocosBuilderAppDelegate.h"


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
        NSMenu* menu = [[NSMenu alloc] initWithTitle:@"User PlugIns"];
        
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
    
    // Figure out which plug-ins hasn't been added
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
    
    CCNode* node = [[PlugInManager sharedManager] createDefaultNodeOfType:objType];
    [[CocosBuilderAppDelegate appDelegate] addCCObject:node asChild:NO];
}

- (void) selectedItem:(id) sender
{
    NSString* objType = [sender title];
    
    CCNode* node = [[PlugInManager sharedManager] createDefaultNodeOfType:objType];
    [[CocosBuilderAppDelegate appDelegate] addCCObject:node asChild:NO];
}

- (void) dealloc
{
    [plugInSettings release];
    [super dealloc];
}

@end
