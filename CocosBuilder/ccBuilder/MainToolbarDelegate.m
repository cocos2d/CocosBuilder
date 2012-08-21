//
//  MainToolbarDelegate.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 8/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainToolbarDelegate.h"

@implementation MainToolbarDelegate

- (NSToolbarItem *) toolbar:(NSToolbar *)toolbar
      itemForItemIdentifier:(NSString *)itemIdentifier
  willBeInsertedIntoToolbar:(BOOL)flag
{
    NSLog(@"toolbar itemForIdentifier: %@ willBeInserted: %d", itemIdentifier, flag);
    
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
    
    // Setup toolbar item
    NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
    
    toolbarItem.label = itemIdentifier;
    toolbarItem.paletteLabel = itemIdentifier;
    
    // Create custom segmented control view
    NSSegmentedControl* segmControl = [[[NSSegmentedControl alloc] initWithFrame:NSMakeRect(0, 0, 80, 32)] autorelease];
    NSSegmentedCell* segmCell = [segmControl cell];
    segmCell.trackingMode = NSSegmentSwitchTrackingMomentary;
    
    [segmControl setSegmentCount:plugIns.count];
    for (int i = 0; i < plugIns.count; i++)
    {
        //[segmControl setLabel:[plugIns objectAtIndex:i] forSegment:i];
        [segmControl setWidth:34 forSegment:i];
        [segmCell setToolTip:[plugIns objectAtIndex:i] forSegment:i];
        
    }
    
    segmControl.segmentStyle = NSSegmentStyleTexturedRounded;
    [segmControl sizeToFit];
    
    [toolbarItem setView:segmControl];
    
    return toolbarItem;
}

- (void) addPlugInItemsToToolbar:(NSToolbar*) toolbar
{
    // Load configuration file
    NSString* path = [[NSBundle mainBundle] pathForResource:@"NodePlugInsList" ofType:@"plist"];
    plugInSettings = [[NSDictionary dictionaryWithContentsOfFile:path] retain];
    
    NSArray* plugInGroups = [plugInSettings objectForKey:@"plugInGroups"];
    
    for (NSDictionary* plugInGroup in plugInGroups)
    {
        NSString* groupName = [plugInGroup objectForKey:@"groupName"];
        
        [toolbar insertItemWithItemIdentifier:groupName atIndex:[[toolbar items] count]];
    }
}

- (void) dealloc
{
    [plugInSettings release];
    [super dealloc];
}

@end
