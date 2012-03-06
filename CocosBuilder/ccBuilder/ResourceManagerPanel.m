//
//  ResourceManagerPanel.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ResourceManagerPanel.h"
#import "ResourceManager.h"

@implementation ResourceManagerPanel

@synthesize resManager;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (!self) return NULL;
    
    resManager = [ResourceManager sharedManager];
    [resManager addResourceObserver:self];
    resType = kCCBResTypeImage;
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [resourceList setDataSource:self];
    //[resourceList setDelegate:self];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void) reload
{
    NSLog(@"reload!");
    [resourceList reloadData];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    NSLog(@"outlineView: numberOfChildrenOfItem:");
    
    // Handle base nodes
    if (item == NULL)
    {
        NSLog(@" returning: %d", (int)[resManager.activeDirectories count]);
        
        return [resManager.activeDirectories count];
    }
    
    // Fetch the data object of directory resources and use it as the item object
    if ([item isKindOfClass:[RMResource class]])
    {
        RMResource* res = item;
        if (res.type == kCCBResTypeDirectory)
        {
            item = res.data;
        }
    }
    
    // Handle different nodes
    if ([item isKindOfClass:[RMDirectory class]])
    {
        RMDirectory* dir = item;
        NSArray* children = [dir resourcesForType:resType];
        return [children count];
    }
    else if ([item isKindOfClass:[RMResource class]])
    {
        RMResource* res = item;
        if (res.type == kCCBResTypeSpriteSheet)
        {
            NSArray* frames = res.data;
            return [frames count];
        }
    }
    
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    // Return base nodes
    if (item == NULL)
    {
        return [resManager.activeDirectories objectAtIndex:index];
    }
    
    // Fetch the data object of directory resources and use it as the item object
    if ([item isKindOfClass:[RMResource class]])
    {
        RMResource* res = item;
        if (res.type == kCCBResTypeDirectory)
        {
            item = res.data;
        }
    }
    
    // Return children for different nodes
    if ([item isKindOfClass:[RMDirectory class]])
    {
        RMDirectory* dir = item;
        NSArray* children = [dir resourcesForType:resType];
        return [children objectAtIndex:index];
    }
    else if ([item isKindOfClass:[RMResource class]])
    {
        RMResource* res = item;
        if (res.type == kCCBResTypeSpriteSheet)
        {
            NSArray* frames = res.data;
            return [frames objectAtIndex:index];
        }
    }
    
    return NULL;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if ([item isKindOfClass:[RMDirectory class]])
    {
        return YES;
    }
    else if ([item isKindOfClass:[RMResource class]])
    {
        RMResource* res = item;
        if (res.type == kCCBResTypeSpriteSheet) return YES;
        else if (res.type == kCCBResTypeDirectory) return YES;
    }
    
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    if ([item isKindOfClass:[RMDirectory class]])
    {
        RMDirectory* dir = item;
        return [dir.dirPath lastPathComponent];
    }
    else if ([item isKindOfClass:[RMResource class]])
    {
        RMResource* res = item;
        return [res.filePath lastPathComponent];
    }
    else if ([item isKindOfClass:[NSString class]])
    {
        return item;
    }
    return @"";
}

- (void) resourceListUpdated
{
    NSLog(@"resourceListUpdated!");
    
    [resourceList reloadData];
}

@end
