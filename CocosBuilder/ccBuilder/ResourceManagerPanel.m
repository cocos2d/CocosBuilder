//
//  ResourceManagerPanel.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ResourceManagerPanel.h"
#import "ResourceManager.h"
#import "ResourceManagerUtil.h"

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
}

- (void) reload
{
    [resourceList reloadData];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    // Handle base nodes
    if (item == NULL)
    {
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
    else if ([item isKindOfClass:[RMSpriteFrame class]])
    {
        RMSpriteFrame* sf = item;
        return sf.spriteFrameName;
    }
    return @"";
}

- (BOOL) outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard
{
    NSString* spriteFile = NULL;
    NSString* spriteSheetFile = NULL;
    
    for (id item in items)
    {
        if ([item isKindOfClass:[RMResource class]])
        {
            RMResource* res = item;
            if (res.type == kCCBResTypeImage)
            {
                spriteFile = [ResourceManagerUtil relativePathFromAbsolutePath: res.filePath];
            }
        }
        else if ([item isKindOfClass:[RMSpriteFrame class]])
        {
            RMSpriteFrame* frame = item;
            spriteFile = frame.spriteFrameName;
            spriteSheetFile = [ResourceManagerUtil relativePathFromAbsolutePath: frame.spriteSheetFile];
            if (!spriteSheetFile) spriteFile = NULL;
        }
    }
    
    
    if (spriteFile)
    {
        NSMutableDictionary* clipDict = [NSMutableDictionary dictionary];
        [clipDict setObject:spriteFile forKey:@"spriteFile"];
        if (spriteSheetFile)
        {
            [clipDict setObject:spriteSheetFile forKey:@"spriteSheetFile"];
        }
        
        NSData* clipData = [NSKeyedArchiver archivedDataWithRootObject:clipDict];
        [pasteboard declareTypes:[NSArray arrayWithObject:@"com.cocosbuilder.texture"] owner:NULL];
        [pasteboard setData:clipData forType:@"com.cocosbuilder.texture"];
        
        return YES;
    }
    
    
    return NO;
    
    /*
    int idx = [itemIndexes firstIndex];
    AssetsItem* item = [assetsItems objectAtIndex:idx];
    
    NSMutableDictionary* clipDict = [NSMutableDictionary dictionary];
    [clipDict setObject:[item.spriteFile lastPathComponent] forKey:@"spriteFile"];
    if (item.spriteSheetFile)
    {
        [clipDict setObject:[item.spriteSheetFile lastPathComponent] forKey:@"spriteSheetFile"];
    }
    
    NSData* clipData = [NSKeyedArchiver archivedDataWithRootObject:clipDict];
    [pasteboard declareTypes:[NSArray arrayWithObject:@"com.cocosbuilder.texture"] owner:NULL];
    [pasteboard setData:clipData forType:@"com.cocosbuilder.texture"];
    
    return 1;*/
}

- (void) resourceListUpdated
{
    [resourceList reloadData];
}

@end
