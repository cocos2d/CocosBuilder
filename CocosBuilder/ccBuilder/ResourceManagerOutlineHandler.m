//
//  ResourceManagerOutlineHandler.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ResourceManagerOutlineHandler.h"
#import "ImageAndTextCell.h"
#import "ResourceManager.h"
#import "ResourceManagerUtil.h"
#import "CocosBuilderAppDelegate.h"
#import "CCBGlobals.h"

@implementation ResourceManagerOutlineHandler

@synthesize resType;

- (void) reload
{
    [resourceList reloadData];
}

- (id) initWithOutlineView:(NSOutlineView *)outlineView resType:(int)rt
{
    return [self initWithOutlineView:outlineView resType:rt imagePreview:NULL lblNoPreview:NULL];
}

- (id) initWithOutlineView:(NSOutlineView*)outlineView resType:(int)rt imagePreview:(NSImageView*)preview lblNoPreview:(NSTextField*)lbl
{
    self = [super init];
    if (!self) return NULL;
    
    resManager = [ResourceManager sharedManager];
    [resManager addResourceObserver:self];
    
    resourceList = [outlineView retain];
    imagePreview = [preview retain];
    lblNoPreview = [lbl retain];
    resType = rt;
    
    [[resourceList outlineTableColumn] setDataCell:[[[ImageAndTextCell alloc] init] autorelease]];
    
    [resourceList setDataSource:self];
    [resourceList setDelegate:self];
    [resourceList setTarget:self];
    [resourceList setDoubleAction:@selector(doubleClicked:)];
    
    return self;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    // Do not display directories if only one directory is used
    if (item == NULL && [resManager.activeDirectories count] == 1)
    {
        item = [resManager.activeDirectories objectAtIndex:0];
    }
    
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
        else if (res.type == kCCBResTypeAnimation)
        {
            NSArray* anims = res.data;
            return [anims count];
        }
    }
    
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    // Do not display directories if only one directory is used
    if (item == NULL && [resManager.activeDirectories count] == 1)
    {
        item = [resManager.activeDirectories objectAtIndex:0];
    }
    
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
        else if (res.type == kCCBResTypeAnimation)
        {
            NSArray* anims = res.data;
            return [anims objectAtIndex:index];
        }
    }
    
    return NULL;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    // Do not display directories if only one directory is used
    if (item == NULL && [resManager.activeDirectories count] == 1)
    {
        item = [resManager.activeDirectories objectAtIndex:0];
    }
    
    if ([item isKindOfClass:[RMDirectory class]])
    {
        return YES;
    }
    else if ([item isKindOfClass:[RMResource class]])
    {
        RMResource* res = item;
        if (res.type == kCCBResTypeSpriteSheet) return YES;
        else if (res.type == kCCBResTypeAnimation) return YES;
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
    else if ([item isKindOfClass:[RMAnimation class]])
    {
        RMAnimation* anim = item;
        return anim.animationName;
    }
    return @"";
}


- (NSImage*) smallIconForFile:(NSString*)file
{
    NSImage* icon = [[NSWorkspace sharedWorkspace] iconForFile:file];
    [icon setScalesWhenResized:YES];
    icon.size = NSMakeSize(16, 16);
    return icon;
}

- (NSImage*) smallIconForFileType:(NSString*)type
{
    NSImage* icon = [[NSWorkspace sharedWorkspace] iconForFileType:type];
    [icon setScalesWhenResized:YES];
    icon.size = NSMakeSize(16, 16);
    return icon;
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    NSImage* icon = NULL;
    
    if ([item isKindOfClass:[RMResource class]])
    {
        RMResource* res = item;
        icon = [self smallIconForFile:res.filePath];
    }
    else if ([item isKindOfClass:[RMSpriteFrame class]])
    {
        icon = [self smallIconForFileType:@"png"];
    }
    else if ([item isKindOfClass:[RMAnimation class]])
    {
        icon = [self smallIconForFileType:@"p12"];
    }
    [cell setImage:icon];
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
}

- (void) outlineViewSelectionDidChange:(NSNotification *)notification
{
    id selection = [resourceList itemAtRow:[resourceList selectedRow]];
    
    NSImage* preview = NULL;
    if ([selection respondsToSelector:@selector(preview)])
    {
        preview = [selection preview];
    }
    
    [imagePreview setImage:preview];
    
    
    
    if (preview) [lblNoPreview setHidden:YES];
    else [lblNoPreview setHidden:NO];
}

- (void) doubleClicked:(id)sender
{
    id item = [resourceList itemAtRow:[resourceList clickedRow]];
    
    if ([item isKindOfClass:[RMResource class]])
    {
        RMResource* res = (RMResource*) item;
        if (res.type == kCCBResTypeCCBFile)
        {
            [[[CCBGlobals globals] appDelegate] openFile: res.filePath];
        }
    }
    
}

- (void) resourceListUpdated
{
    [resourceList reloadData];
}

- (void) setResType:(int)rt
{
    resType = rt;
    [resourceList reloadData];
}

- (void) dealloc
{
    [resourceList release];
    [imagePreview release];
    [lblNoPreview release];
    [super dealloc];
}

@end
