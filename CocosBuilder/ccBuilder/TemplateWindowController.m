//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import "TemplateWindowController.h"
#import "AssetsItem.h"
#import "CCBReader.h"
#import "EditTemplateWindowController.h"
#import "CCBGlobals.h"
#import "CocosBuilderAppDelegate.h"

@implementation TemplateWindowController

@synthesize templateFiles;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    self.templateFiles = NULL;
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
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
    
    //browserGroups = [[NSMutableArray array] retain];
    
    //[self clearContents];
    
    [imageBrowser reloadData];
}

//- (void) clearContents
//{
//}

- (NSUInteger) numberOfItemsInImageBrowser:(IKImageBrowserView *)aBrowser
{
    if (!templateFiles) return 0;
    return [templateFiles count];
}

- (id) imageBrowser:(IKImageBrowserView *)aBrowser itemAtIndex:(NSUInteger)index
{
    CCBTemplate* t = [templateFiles objectAtIndex:index];
    NSString* sprtFile = [NSString stringWithFormat:@"%@%@", t.assetsPath, t.previewImage];
    
    if (!t.previewImage || [t.previewImage isEqualToString:@""] || ![[NSFileManager defaultManager] fileExistsAtPath:sprtFile])
    {
        sprtFile = [CCFileUtils fullPathFromRelativePath:@"missing-texture.png"];
    }
    
    AssetsItem* item = [[[AssetsItem alloc] initWithSpriteFile:sprtFile] autorelease];
    [item setImageVersion:imagesVersion];
    [item setTitle:t.fileName];
    
    return item;
}

- (NSUInteger) imageBrowser:(IKImageBrowserView *)aBrowser writeItemsAtIndexes:(NSIndexSet *)itemIndexes toPasteboard:(NSPasteboard *)pasteboard
{
    int idx = [itemIndexes firstIndex];
    
    CCBTemplate* t = [templateFiles objectAtIndex:idx];
    NSMutableDictionary* clipDict = [NSMutableDictionary dictionary];
    [clipDict setObject:t.fileName forKey:@"templateFile"];
    
    NSData* clipData = [NSKeyedArchiver archivedDataWithRootObject:clipDict];
    [pasteboard declareTypes:[NSArray arrayWithObject:@"com.cocosbuilder.template"] owner:NULL];
    [pasteboard setData:clipData forType:@"com.cocosbuilder.template"];
    
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

- (IBAction) pressedEdit:(id)sender
{
    NSUInteger selectedIdx = [[imageBrowser selectionIndexes] firstIndex];
    if (selectedIdx == NSNotFound) return;
    
    CCBTemplate* t = [templateFiles objectAtIndex:selectedIdx];
    
    EditTemplateWindowController* wc = [[[EditTemplateWindowController alloc] initWithWindowNibName:@"EditTemplateWindow"] autorelease];
    // Populate edit template window
    [wc popuplateWithTemplate:t];
    
    [[NSApplication sharedApplication] runModalForWindow:[wc window]];
    
    //[self reloadData];
    
    [[[[CCBGlobals globals] appDelegate] window] becomeMainWindow];
    //[[[CCBGlobals globals] appDelegate] menuReloadAssets:self];
}

- (IBAction) pressedNewTemplate:(id)sender
{
    NSSavePanel* saveDlg = [NSSavePanel savePanel];
    [saveDlg setAllowedFileTypes:[NSArray arrayWithObject:@"ccbt"]];
    [saveDlg setTitle:@"Create Template"];
    if ([saveDlg runModal] == NSFileHandlingPanelOKButton)
    {
        NSString* filePath = [[saveDlg URL] path];
        CCBTemplate* t = [[[CCBTemplate alloc] initWithNonExistingPath:filePath] autorelease];
        
        EditTemplateWindowController* wc = [[[EditTemplateWindowController alloc] initWithWindowNibName:@"EditTemplateWindow"] autorelease];
        // Populate edit template window
        [wc popuplateWithTemplate:t];
        
        [[NSApplication sharedApplication] runModalForWindow:[wc window]];
        
        //[self reloadData];
        
        [[[[CCBGlobals globals] appDelegate] window] becomeMainWindow];
        
        [[[CCBGlobals globals] appDelegate] performSelector:@selector(menuReloadAssets:) withObject:NULL afterDelay:0.5f];
        //[[[CCBGlobals globals] appDelegate] menuReloadAssets:self];
    }
    
    //[openPanel 
}

@end
