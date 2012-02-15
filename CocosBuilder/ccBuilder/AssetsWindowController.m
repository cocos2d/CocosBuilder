//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import "AssetsWindowController.h"
#import "AssetsItem.h"
#import "CCBWriterInternal.h"
#import "CCBSpriteSheetParser.h"

@implementation AssetsWindowController

@synthesize spriteSheetList;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self)
    {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [browserGroups release];
    self.spriteSheetList = NULL;
    [assetsItems release];
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    assetsItems = [[NSMutableArray array] retain];
    
    NSMutableParagraphStyle* paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    [paragraphStyle setAlignment:NSCenterTextAlignment];
    
    NSMutableDictionary* attributes = [[NSMutableDictionary alloc] initWithCapacity:3];	
    [attributes setObject:[NSFont fontWithName:@"Lucida Grande" size:9] forKey:NSFontAttributeName];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];	
    [attributes setObject:[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:1] forKey:NSForegroundColorAttributeName];
    [imageBrowser setValue:attributes forKey:IKImageBrowserCellsTitleAttributesKey];
    
    NSMutableDictionary* attributesHilite = [[[NSMutableDictionary alloc] initWithCapacity:3] autorelease];	
    [attributesHilite setObject:[NSFont fontWithName:@"Lucida Grande" size:9] forKey:NSFontAttributeName];
    [attributesHilite setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];	
    [attributesHilite setObject:[NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:1] forKey:NSForegroundColorAttributeName];
    [imageBrowser setValue:attributesHilite forKey:IKImageBrowserCellsHighlightedTitleAttributesKey];
    [attributes release];
    
    [imageBrowser setCellSize:NSMakeSize(50, 50)];
    [imageBrowser setIntercellSpacing:NSMakeSize(4, 10)];
    
    browserGroups = [[NSMutableArray array] retain];
    
    [self clearContents];
    
    [imageBrowser reloadData];
    
    
}

- (NSUInteger) numberOfItemsInImageBrowser:(IKImageBrowserView *) aBrowse
{
    return [assetsItems count];
}

- (id) imageBrowser:(IKImageBrowserView *) aBrowser itemAtIndex:(NSUInteger)index
{
    return [assetsItems objectAtIndex:index];
}

- (void) clearContents
{
    //NSLog(@"clearContents !!");
    
    [assetsItems removeAllObjects];
    self.spriteSheetList = [NSMutableArray array];
    [spriteSheetList addObject:@"All images"];
    [spriteSheetList addObject:kCCBUseRegularFile];
    [browserGroups removeAllObjects];
}

- (void) addImage:(NSString*) imageFile
{
    AssetsItem* item = [[[AssetsItem alloc] initWithSpriteFile:imageFile] autorelease];
    [item setImageVersion:imagesVersion];
    [assetsItems addObject:item];
}

- (void) addSpriteSheet:(NSString*) spriteSheetFile
{
    if ([browserGroups count] == 0)
    {
        NSMutableDictionary* group = [NSMutableDictionary dictionary];
        [group setObject:[NSValue valueWithRange:NSMakeRange(0, [assetsItems count])] forKey:IKImageBrowserGroupRangeKey];
        [group setObject:@"Regular Files" forKey:IKImageBrowserGroupTitleKey];
        [group setObject:[NSNumber numberWithInt:IKGroupDisclosureStyle] forKey:IKImageBrowserGroupStyleKey];
        [browserGroups addObject:group];
    }
    
    int startPos = [assetsItems count];
    
    [spriteSheetList addObject:[spriteSheetFile lastPathComponent]];
    
    NSArray* arr = [CCBSpriteSheetParser listFramesInSheet:spriteSheetFile assetsPath:@""];
    for (int i = 0; i < [arr count]; i++)
    {
        AssetsItem* item = [[[AssetsItem alloc] initWithSpriteSheet:spriteSheetFile frameName:[arr objectAtIndex:i]] autorelease];
        [item setImageVersion:imagesVersion];
        [assetsItems addObject:item];
    }
    
    NSMutableDictionary* group = [NSMutableDictionary dictionary];
    [group setObject:[NSValue valueWithRange:NSMakeRange(startPos, [arr count])] forKey:IKImageBrowserGroupRangeKey];
    [group setObject:[spriteSheetFile lastPathComponent] forKey:IKImageBrowserGroupTitleKey];
    [group setObject:[NSNumber numberWithInt:IKGroupDisclosureStyle] forKey:IKImageBrowserGroupStyleKey];
    [browserGroups addObject:group];
}

- (NSUInteger) numberOfGroupsInImageBrowser:(IKImageBrowserView *) aBrowser
{
    return [browserGroups count];
}

- (NSDictionary *) imageBrowser:(IKImageBrowserView *) aBrowser groupAtIndex:(NSUInteger) index
{
    return [browserGroups objectAtIndex:index];
}

- (NSUInteger) imageBrowser:(IKImageBrowserView *) aBrowser writeItemsAtIndexes:(NSIndexSet *) itemIndexes toPasteboard:(NSPasteboard *)pasteboard
{
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

    return 1;
}

- (void) invalidateImageCache
{
    imagesVersion++;
}

- (void) reloadData
{
    [self invalidateImageCache];
    [imageBrowser reloadData];
}

@end
