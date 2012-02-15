//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import "CocosBuilderAppDelegate.h"
#import "CocosScene.h"
#import "NSFlippedView.h"
#import "CCBGlobals.h"
#import "cocos2d.h"
#import "CCBWriterInternal.h"
#import "CCBReaderInternal.h"
#import "CCBReaderInternalV1.h"
#import "CCBDocument.h"
#import "NewDocWindowController.h"
#import "CCBSpriteSheetParser.h"
#import "CCBUtil.h"
#import "StageSizeWindow.h"
#import "AssetsWindowController.h"
#import "TemplateWindowController.h"
#import "PlugInManager.h"
#import "InspectorPosition.h"
#import "NodeInfo.h"
#import "PlugInNode.h"

#import <ExceptionHandling/NSExceptionHandler.h>

@implementation CocosBuilderAppDelegate

@synthesize window, assestsImgList, assetsImgListFiles, assetsFontList, assetsSpriteSheetList, assetsTemplates, currentDocument, assetsPath, cocosView, canEditContentSize, canEditCustomClass, hasOpenedDocument, defaultCanvasSize, plugInManager;

#pragma mark Setup functions

- (void) setupInspectorPane
{
    inspectorDocumentView = [[NSFlippedView alloc] initWithFrame:NSMakeRect(0, 0, 233, 239+239+121)];
    [inspectorDocumentView setAutoresizesSubviews:YES];
    [inspectorScroll setDocumentView:inspectorDocumentView];
}

- (void) setupCocos2d
{
    // Insert code here to initialize your application
    CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	
	[director setDisplayStats:NO];
	[director setProjection:kCCDirectorProjection2D];
    //[cocosView openGLContext];
    
	[director setView:cocosView];
    
	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	// Use kCCDirectorResize_NoScale if you don't want auto-scaling.
	[director setResizeMode:kCCDirectorResize_NoScale];
	
	// Enable "moving" mouse event. Default no.
	//[window setAcceptsMouseMovedEvents:YES];
	
	[director runWithScene:[CocosScene sceneWithAppDelegate:self]];
}

- (void) setupOutlineView
{
    [outlineHierarchy setDataSource:self];
    [outlineHierarchy setDelegate:self];
    [outlineHierarchy reloadData];
    
    [outlineHierarchy registerForDraggedTypes:[NSArray arrayWithObjects: @"com.cocosbuilder.node", @"com.cocosbuilder.texture", @"com.cocosbuilder.template", NULL]];
}

- (void) updateAssetsView
{
    // Remove objects
    [assetsList removeObjectsAtArrangedObjectIndexes:
     [NSIndexSet indexSetWithIndexesInRange:
      NSMakeRange(0, [[assetsList arrangedObjects] count])]];
    
    [assetsWindowController clearContents];
    
    if (currentDocument && currentDocument.fileName && ![currentDocument.fileName isEqualToString:@""])
    {
        NSString* a = [currentDocument.fileName stringByDeletingLastPathComponent];// @"/Users/viktor/ccbAssets/";
        self.assetsPath = [NSString stringWithFormat:@"%@/",a];
        NSArray* dir = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:assetsPath error:NULL];
    
        //[[assetsList mutableArrayValueForKey:@"filename"] removeAllObjects];
        
        
        self.assestsImgList = [NSMutableArray array];
        self.assetsFontList = [NSMutableArray array];
        self.assetsTemplates = [NSMutableArray array];
        self.assetsSpriteSheetList = [CCBSpriteSheetParser findSpriteSheetsAtPath:assetsPath];
        [self.assetsSpriteSheetList insertObject:kCCBUseRegularFile atIndex:0];
        
        //[self.assestsImgList addObject:@""];
        
        for (int i = 0; i < [dir count]; i++)
        {
            NSString* file = [dir objectAtIndex:i];
            
            NSString* pathExt = [file pathExtension];
            NSString* fileNoExt = [file stringByDeletingPathExtension];
            BOOL isHDFile = [fileNoExt hasSuffix:@"-hd"];
            
            [assetsList addObject: [NSDictionary dictionaryWithObject:file forKey:@"filename"]];
            
            if ([pathExt isEqualToString:@"png"] ||
                [pathExt isEqualToString:@"jpg"])
            {
                if (!isHDFile) [self.assestsImgList addObject:file];
            }
            else if ([pathExt isEqualToString:@"fnt"])
            {
                if (!isHDFile) [self.assetsFontList addObject:file];
            }
            else if ([pathExt isEqualToString:@"ccbt"])
            {
                [self.assetsTemplates addObject:file];
            }
        }
        
        
        // Update assetsWindow!
        for (int i = 0; i < [assestsImgList count]; i++)
        {
            [assetsWindowController addImage:[NSString stringWithFormat:@"%@%@",assetsPath,[assestsImgList objectAtIndex:i]]];
        }
        
        for (int i = 0; i < [assetsSpriteSheetList count]; i++)
        {
            if ([[assetsSpriteSheetList objectAtIndex:i] isEqualToString:kCCBUseRegularFile]) continue;
            
            [assetsWindowController addSpriteSheet:[NSString stringWithFormat:@"%@%@",assetsPath,[assetsSpriteSheetList objectAtIndex:i]]];
        }
    }
    else
    {
        [[assetsWindowController window] setIsVisible:NO];
        
        self.assetsPath = @"";
        self.assestsImgList = [NSMutableArray array];
        self.assetsFontList = [NSMutableArray array];
    }
    
    self.assetsImgListFiles = self.assestsImgList;
    //self.assetsFontList = [CCBFontUtil createFontList];
    
    [assetsWindowController reloadData];
    
    /*
    // Update templates
    [menuTemplates removeAllItems];
    [menuTemplatesAsChild removeAllItems];
    
    NSMutableArray* templates = [NSMutableArray arrayWithCapacity:[assetsTemplates count]];
    
    for (int i = 0; i < [assetsTemplates count]; i++)
    {
        CCBTemplate* t = [[[CCBTemplate alloc] initWithFile:[assetsTemplates objectAtIndex:i] assetsPath:assetsPath] autorelease];
        if (!t) continue;
        
        [templates addObject:t];
        
        NSMenuItem* item = [[[NSMenuItem alloc] initWithTitle:[assetsTemplates objectAtIndex:i] action:@selector(menuAddTemplate:) keyEquivalent:@""] autorelease];
        [item setTarget:self];
        [item setTag:0];
        [menuTemplates addItem:item];
        
        NSMenuItem* itemC = [[[NSMenuItem alloc] initWithTitle:[assetsTemplates objectAtIndex:i] action:@selector(menuAddTemplate:) keyEquivalent:@""] autorelease];
        [itemC setTarget:self];
        [itemC setTag:1];
        [menuTemplatesAsChild addItem:itemC];
    }
    if ([assetsTemplates count] == 0)
    {
        NSMenuItem* item = [[[NSMenuItem alloc] initWithTitle:@"No Templates Found" action:NULL keyEquivalent:@""] autorelease];
        [item setEnabled:NO];
        [menuTemplates addItem:item];
        
        NSMenuItem* itemC = [[[NSMenuItem alloc] initWithTitle:@"No Templates Found" action:NULL keyEquivalent:@""] autorelease];
        [item setEnabled:NO];
        [menuTemplates addItem:itemC];
    }
    
    templateWindowController.templateFiles = templates;
    [templateWindowController reloadData];
     */
}

- (void) setupTabBar
{
    // Create tabView
    tabView = [[NSTabView alloc] initWithFrame:NSMakeRect(0, 0, 500, 30)];
    [tabBar setTabView:tabView];
    [tabView setDelegate:tabBar];
    [tabBar setDelegate:self];
    
    // Settings for tabBar
    [tabBar setShowAddTabButton:NO];
    [tabBar setSizeCellsToFit:YES];
    [tabBar setUseOverflowMenu:YES];
    [tabBar setHideForSingleTab:NO];
    [tabBar setAllowsResizing:YES];
    [tabBar setAlwaysShowActiveTab:YES];
    [tabBar setAllowsScrubbing:YES];
    [tabBar setCanCloseOnlyTab:YES];
    
    [window setShowsToolbarButton:NO];
}

- (void) setupDefaultDocument
{
	currentDocument = [[CCBDocument alloc] init];
}

- (void) setupAssetsWindow
{
    BOOL visible = NO;
    if (assetsWindowController)
    {
        visible = [[assetsWindowController window] isVisible];
        [assetsWindowController close];
        [assetsWindowController release];
    }
    assetsWindowController = [[AssetsWindowController alloc] initWithWindowNibName:@"AssetsWindow"];
        [[assetsWindowController window] setIsVisible:visible];
}

/*
- (void) setupTemplateWindow
{
    templateWindowController = [[TemplateWindowController alloc] initWithWindowNibName:@"TemplateWindow"];
}*/

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[CCBGlobals globals] setAppDelegate:self];
    
    [[NSExceptionHandler defaultExceptionHandler] setExceptionHandlingMask: NSLogUncaughtExceptionMask | NSLogUncaughtSystemExceptionMask | NSLogUncaughtRuntimeErrorMask];
    
    defaultCanvasSizes[kCCBCanvasSizeIPhoneLandscape] = CGSizeMake(480, 320);
    defaultCanvasSizes[kCCBCanvasSizeIPhonePortrait] = CGSizeMake(320, 480);
    defaultCanvasSizes[kCCBCanvasSizeIPadLandscape] = CGSizeMake(1024, 768);
    defaultCanvasSizes[kCCBCanvasSizeIPadPortrait] = CGSizeMake(768, 1024);
    
    [window setDelegate:self];
    
    [self setupTabBar];
    [self setupDefaultDocument];
    [self setupInspectorPane];
    [self setupCocos2d];
    [self setupOutlineView];
    [self updateInspectorFromSelection];
    [self setupAssetsWindow];
    //[self setupTemplateWindow];
    [self updateAssetsView];
    
    [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setStageBorder:0];
    [self updateCanvasBorderMenu];
    
    // Load plug-ins
    plugInManager = [PlugInManager sharedManager];
    [plugInManager loadPlugIns];
    
    // Populate object menus
    [menuAddObject removeAllItems];
    [menuAddObjectAsChild removeAllItems];
    
    NSArray* plugInNames = plugInManager.plugInsNodeNames;
    for (int i = 0; i < [plugInNames count]; i++)
    {
        NSString* plugInName = [plugInNames objectAtIndex:i];
        
        NSMenuItem* item = [[[NSMenuItem alloc] initWithTitle:plugInName action:@selector(menuAddPlugInNode:) keyEquivalent:@""] autorelease];
        [item setTarget:self];
        [item setTag:0];
        [menuAddObject addItem:item];
        
        item = [[[NSMenuItem alloc] initWithTitle:plugInName action:@selector(menuAddPlugInNode:) keyEquivalent:@""] autorelease];
        [item setTarget:self];
        [item setTag:1];
        [menuAddObjectAsChild addItem:item];
    }
}

#pragma mark Notifications to user

- (void) modalDialogTitle: (NSString*)title message:(NSString*)msg
{
    NSAlert* alert = [NSAlert alertWithMessageText:title defaultButton:@"OK" alternateButton:NULL otherButton:NULL informativeTextWithFormat:msg];
    [alert runModal];
}

#pragma mark Handling the tab bar

- (void) addTab:(CCBDocument*)doc
{
    NSTabViewItem *newItem = [[[NSTabViewItem alloc] initWithIdentifier:doc] autorelease];
	[newItem setLabel:[doc formattedName]];
	[tabView addTabViewItem:newItem];
    [tabView selectTabViewItem:newItem]; // this is optional, but expected behavior
}

- (void)tabView:(NSTabView*)tv didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    [self switchToDocument:[tabViewItem identifier]];
}

- (void)tabView:(NSTabView *)aTabView didCloseTabViewItem:(NSTabViewItem *)tabViewItem
{
    if ([[aTabView tabViewItems] count] == 0)
    {
        [self closeLastDocument];
    }
    
    [self updateDirtyMark];
}


- (BOOL)tabView:(NSTabView *)aTabView shouldCloseTabViewItem:(NSTabViewItem *)tabViewItem
{
    CCBDocument* doc = [tabViewItem identifier];
    
    if (doc.isDirty)
    {
        NSAlert* alert = [NSAlert alertWithMessageText:@"Do you want to save the changes you made in the document “Untitled”?" defaultButton:@"Save" alternateButton:@"Cancel" otherButton:@"Don’t Save" informativeTextWithFormat:@"Your changes will be lost if you don’t save them."];
        NSInteger result = [alert runModal];
        
        if (result == NSAlertDefaultReturn)
        {
            [self saveDocument:self];
            return YES;
        }
        else if (result == NSAlertAlternateReturn)
        {
            return NO;
        }
        else if (result == NSAlertOtherReturn)
        {
            return YES;
        }
    }
    return YES;
}

- (BOOL)tabView:(NSTabView *)aTabView shouldDragTabViewItem:(NSTabViewItem *)tabViewItem fromTabBar:(PSMTabBarControl *)tabBarControl
{
    return YES;
}

#pragma mark Handling the outline view

- (void) updateOutlineViewSelection
{
    if (!selectedNode)
    {
        [outlineHierarchy selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
        return;
    }
    CCBGlobals* g = [CCBGlobals globals];
    
    CCNode* node = selectedNode;
    NSMutableArray* nodesToExpand = [NSMutableArray array];
    while (node != g.rootNode && node != NULL)
    {
        [nodesToExpand insertObject:node atIndex:0];
        node = node.parent;
    }
    for (int i = 0; i < [nodesToExpand count]; i++)
    {
        node = [nodesToExpand objectAtIndex:i];
        [outlineHierarchy expandItem:node.parent];
    }
    
    int row = (int)[outlineHierarchy rowForItem:selectedNode];
    [outlineHierarchy selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}

- (void) setSelectedNode:(CCNode*) selection
{
    [CCBUtil endEditingForView:mainView];
    
    selectedNode = selection;
    [self updateOutlineViewSelection];
    
    if (currentDocument) currentDocument.lastOperationType = kCCBOperationTypeUnspecified;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    
    if ([[CCBGlobals globals] rootNode] == NULL) return 0;
    if (item == nil) return 1;
    
    CCNode* node = (CCNode*)item;
    CCArray* arr = [node children];
    
    return [arr count];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if (item == nil) return YES;
    
    CCNode* node = (CCNode*)item;
    CCArray* arr = [node children];
    
    return ([arr count] > 0 &&
            ![item isKindOfClass:[CCMenuItemImage class]] &&
            ![item isKindOfClass:[CCLabelBMFont class]]);
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    CCBGlobals* g= [CCBGlobals globals];
    
    if (item == nil) return g.rootNode;
    
    CCNode* node = (CCNode*)item;
    CCArray* arr = [node children];
    return [arr objectAtIndex:index];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    selectedNode = [outlineHierarchy itemAtRow:[outlineHierarchy selectedRow]];
    [self updateInspectorFromSelection];
    CCBGlobals* g = [CCBGlobals globals];
    [g.cocosScene setSelectedNode:selectedNode];
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification
{
    CCNode* node = [[notification userInfo] objectForKey:@"NSObject"];
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:[NSNumber numberWithBool:NO] forKey:@"isExpanded" andNode:node];
}

- (void)outlineViewItemDidExpand:(NSNotification *)notification
{
    CCNode* node = [[notification userInfo] objectForKey:@"NSObject"];
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:[NSNumber numberWithBool:YES] forKey:@"isExpanded" andNode:node];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
    if (item == nil) return @"Root";
    
    CCNode* node = item;
    NodeInfo* info = node.userData;
    
    // Get class name
    NSString* className = @"";
    NSString* customClass = [cs extraPropForKey:@"customClass" andNode:item];
    if (customClass && ![customClass isEqualToString:@""]) className = customClass;
    else if ([item isKindOfClass:[CCParticleSystem class]]) className = @"CCParticleSystem";
    else className = info.plugIn.nodeClassName;
    
    // Assignment name
    NSString* assignmentName = [cs extraPropForKey:@"memberVarAssignmentName" andNode:item];
    if (assignmentName && ![assignmentName isEqualToString:@""]) return [NSString stringWithFormat:@"%@ (%@)",className,assignmentName];
    
    // Naming after textures
    if ([item isKindOfClass:[CCSprite class]] && ![item isKindOfClass:[CCBTemplateNode class]])
    {
        NSString* textureName = [cs extraPropForKey:@"spriteFile" andNode:item];
        if (textureName && ![textureName isEqualToString:@""])
        {
            return [NSString stringWithFormat:@"CCSprite (%@)", textureName];
        }
    }
    else if ([item isKindOfClass:[CCMenuItemImage class]])
    {
        NSString* textureName = [cs extraPropForKey:@"spriteFileNormal" andNode:item];
        if (textureName && ![textureName isEqualToString:@""])
        {
            return [NSString stringWithFormat:@"CCMenuItemImage (%@)", textureName];
        }
    }
    else if ([item isKindOfClass:[CCBTemplateNode class]])
    {
        CCBTemplateNode* t = (CCBTemplateNode*) item;
        return t.ccbTemplate.customClass;
    }
    
    // Fallback, just use the class name
    return className;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard
{
    CCBGlobals* g = [CCBGlobals globals];
    
    CCNode* draggedNode = [items objectAtIndex:0];
    if (draggedNode == g.rootNode) return NO;
    
    NSMutableDictionary* clipDict = [CCBWriterInternal dictionaryFromCCObject:draggedNode];
    
    [clipDict setObject:[NSNumber numberWithLongLong:(long long)draggedNode] forKey:@"srcNode"];
    NSData* clipData = [NSKeyedArchiver archivedDataWithRootObject:clipDict];
    
    [pboard setData:clipData forType:@"com.cocosbuilder.node"];
    
    return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id < NSDraggingInfo >)info proposedItem:(id)item proposedChildIndex:(NSInteger)index
{
    if (item == NULL) return NSDragOperationNone;
    if (index != -1) return NSDragOperationNone;
    
    CCBGlobals* g = [CCBGlobals globals];
    NSPasteboard* pb = [info draggingPasteboard];
    
    NSData* nodeData = [pb dataForType:@"com.cocosbuilder.node"];
    if (nodeData)
    {
        NSDictionary* clipDict = [NSKeyedUnarchiver unarchiveObjectWithData:nodeData];
        CCNode* draggedNode = (CCNode*)[[clipDict objectForKey:@"srcNode"] longLongValue];
        
        CCNode* node = item;
        CCNode* parent = [node parent];
        while (parent && parent != g.rootNode)
        {
            if (parent == draggedNode) return NSDragOperationNone;
            parent = [parent parent];
        }
        
        return NSDragOperationGeneric;
    }
    
    return NSDragOperationGeneric;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id < NSDraggingInfo >)info item:(id)item childIndex:(NSInteger)index
{
    //CocosScene* cs = [[CCBGlobals globals] cocosScene];
    NSPasteboard* pb = [info draggingPasteboard];
    
    NSData* clipData = [pb dataForType:@"com.cocosbuilder.node"];
    if (clipData)
    {
        NSMutableDictionary* clipDict = [NSKeyedUnarchiver unarchiveObjectWithData:clipData];
        
        //CCNode* clipNode = [CCBReaderInternalV1 ccObjectFromDictionary:clipDict assetsDir:assetsPath owner:NULL];
        CCNode* clipNode= [CCBReaderInternal nodeGraphFromDictionary:clipDict];
        if (![self addCCObject:clipNode toParent:item]) return NO;
        
        // Remove old node
        CCNode* draggedNode = (CCNode*)[[clipDict objectForKey:@"srcNode"] longLongValue];
        [self deleteNode:draggedNode];
        [self setSelectedNode:clipNode];
        
        return YES;
    }
    clipData = [pb dataForType:@"com.cocosbuilder.texture"];
    if (clipData)
    {
        NSDictionary* clipDict = [NSKeyedUnarchiver unarchiveObjectWithData:clipData];
        
        [self dropAddSpriteNamed:[clipDict objectForKey:@"spriteFile"] inSpriteSheet:[clipDict objectForKey:@"spriteSheetFile"] at:ccp(0,0) parent:item];
        
        return YES;
    }
    /*
    clipData = [pb dataForType:@"com.cocosbuilder.template"];
    if (clipData)
    {
        NSDictionary* clipDict = [NSKeyedUnarchiver unarchiveObjectWithData:clipData];
        
        //[self dropAddSpriteName
        [self dropAddTemplateNamed:[clipDict objectForKey:@"templateFile"] at:ccp(0,0) parent:item];
        
        return YES;
    }
     */
    
    return NO;
}

- (void) updateExpandedForNode:(CCNode*)node
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
    if ([self outlineView:outlineHierarchy isItemExpandable:node])
    {
        bool expanded = [[cs extraPropForKey:@"isExpanded" andNode:node] boolValue];
        if (expanded) [outlineHierarchy expandItem:node];
        else [outlineHierarchy collapseItem:node];
        
        CCArray* childs = [node children];
        for (int i = 0; i < [childs count]; i++)
        {
            CCNode* child = [childs objectAtIndex:i];
            [self updateExpandedForNode:child];
        }
    }
}

#pragma mark Window Delegate

- (void) windowDidResignMain:(NSNotification *)notification
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
    if (![[CCDirector sharedDirector] isPaused])
    {
        [[CCDirector sharedDirector] pause];
        [cs pauseSchedulerAndActions];
    }
}

- (void) windowDidBecomeMain:(NSNotification *)notification
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
    if ([[CCDirector sharedDirector] isPaused])
    {
        [[CCDirector sharedDirector] resume];
        [cs resumeSchedulerAndActions];
    }
}

#pragma mark Populate Inspector

/*
- (int) addInspectorPane:(NSView*)pane offset:(int)offset
{
    NSRect frame = [pane frame];
    [pane setFrame:NSMakeRect(0, offset, frame.size.width, frame.size.height)];
    [pane setHidden:NO];
    return offset+frame.size.height;
}*/

/*
- (void) populateProperty:(NSString*) propName
{
    [self willChangeValueForKey:propName];
    [self didChangeValueForKey:propName];
}
 */

- (int) addInspectorPropertyOfType:(NSString*)type name:(NSString*)prop displayName:(NSString*)displayName atOffset:(int)offset
{
    NSString* inspectorNibName = [NSString stringWithFormat:@"Inspector%@",type];
    
    // Create inspector
    InspectorValue* inspectorValue = [InspectorValue inspectorOfType:type withSelection:selectedNode andPropertyName:prop andDisplayName:displayName];
    inspectorValue.resourceManager = self;
    
    // Load it's associated view
    [NSBundle loadNibNamed:inspectorNibName owner:inspectorValue];
    NSView* view = inspectorValue.view;
    
    // Add view to inspector and place it at the bottom
    [inspectorDocumentView addSubview:view];
    [view setAutoresizingMask:NSViewWidthSizable];
    
    NSRect frame = [view frame];
    [view setFrame:NSMakeRect(0, offset, frame.size.width, frame.size.height)];
    offset += frame.size.height;
    
    return offset;
}

- (void) updateInspectorFromSelection
{
    // Remove all old inspector panes
    NSArray* panes = [inspectorDocumentView subviews];
    for (int i = [panes count]-1; i >= 0 ; i--)
    {
        NSView* pane = [panes objectAtIndex:i];
        //[pane setHidden:YES];
        [pane removeFromSuperview];
    }
    
    [inspectorDocumentView setFrameSize:NSMakeSize(233, 1)];
    int paneOffset = 0;
    
    // Add show panes according to selections
    if (!selectedNode) return;
    
    // Always add the code connections pane
    paneOffset = [self addInspectorPropertyOfType:@"CodeConnections" name:@"customClass" displayName:@"" atOffset:paneOffset];
    
    NSLog(@"ADDED CodeConnections offset: %d",paneOffset);
    
    // Add panes for each property
    NodeInfo* info = selectedNode.userData;
    PlugInNode* plugIn = info.plugIn;
    
    if (plugIn)
    {
        NSArray* propInfos = plugIn.nodeProperties;
        for (int i = 0; i < [propInfos count]; i++)
        {
            NSDictionary* propInfo = [propInfos objectAtIndex:i];
            NSString* type = [propInfo objectForKey:@"type"];
            NSString* name = [propInfo objectForKey:@"name"];
            NSString* displayName = [propInfo objectForKey:@"displayName"];
            
            paneOffset = [self addInspectorPropertyOfType:type name:name displayName:displayName atOffset:paneOffset];
        }
    }
    else
    {
        NSLog(@"WARNING info:%@ plugIn:%@", info, plugIn);
    }
    
    [inspectorDocumentView setFrameSize:NSMakeSize(233, paneOffset)];
    
    //[self populateInspectorViews];
}


#pragma mark Properties

- (BOOL) isSelectedNode
{
    if (!selectedNode) return NO;
    if (![selectedNode isKindOfClass:[CCNode class]]) return NO;
    return YES;
}

- (BOOL) isSelectedLayer
{
    if (!selectedNode) return NO;
    if (![selectedNode isKindOfClass:[CCLayer class]]) return NO;
    return YES;
}

- (BOOL) isSelectedLayerColor
{
    if (!selectedNode) return NO;
    if (![selectedNode isKindOfClass:[CCLayerColor class]]) return NO;
    return YES;
}

- (BOOL) isSelectedLayerGradient
{
    if (!selectedNode) return NO;
    if (![selectedNode isKindOfClass:[CCLayerGradient class]]) return NO;
    return YES;
}

- (BOOL) isSelectedSprite
{
    if (!selectedNode) return NO;
    if (![selectedNode isKindOfClass:[CCSprite class]]) return NO;
    if ([selectedNode isKindOfClass:[CCBTemplateNode class]]) return NO;
    return YES;
}

- (BOOL) isSelectedMenu
{
    if (!selectedNode) return NO;
    if (![selectedNode isKindOfClass:[CCMenu class]]) return NO;
    return YES;
}

- (BOOL) isSelectedMenuItem
{
    if (!selectedNode) return NO;
    if (![selectedNode isKindOfClass:[CCMenuItem class]]) return NO;
    return YES;
}

- (BOOL) isSelectedMenuItemImage
{
    if (!selectedNode) return NO;
    if (![selectedNode isKindOfClass:[CCMenuItemImage class]]) return NO;
    return YES;
}

- (BOOL) isSelectedLabelTTF
{
    if (!selectedNode) return NO;
    if (![selectedNode isKindOfClass:[CCLabelTTF class]]) return NO;
    return YES;
}

- (BOOL) isSelectedLabelBMFont
{
    if (!selectedNode) return NO;
    if (![selectedNode isKindOfClass:[CCLabelBMFont class]]) return NO;
    return YES;
}

- (BOOL) isSelectedThreeSlice
{
    if (!selectedNode) return NO;
    if (![selectedNode isKindOfClass:[CCThreeSlice class]]) return NO;
    return YES;
}

- (BOOL) isSelectedParticleSystem
{
    if (!selectedNode) return NO;
    if (![selectedNode isKindOfClass:[CCParticleSystem class]]) return NO;
    return YES;
}

#pragma mark Document handling

- (BOOL) hasDirtyDocument
{
    NSArray* docs = [tabView tabViewItems];
    for (int i = 0; i < [docs count]; i++)
    {
        CCBDocument* doc = [(NSTabViewItem*)[docs objectAtIndex:i] identifier];
        if (doc.isDirty) return YES;
    }
    return NO;
}

- (void) updateDirtyMark
{
    [window setDocumentEdited:[self hasDirtyDocument]];
}

- (NSMutableDictionary*) docDataFromCurrentNodeGraph
{
    CCBGlobals* g= [CCBGlobals globals];
    NSMutableDictionary* doc = [NSMutableDictionary dictionary];
    
    // Add node graph
    NSMutableDictionary* nodeGraph = [CCBWriterInternal dictionaryFromCCObject:g.rootNode];
    [doc setObject:nodeGraph forKey:@"nodeGraph"];
    
    // Add meta data
    [doc setObject:@"CocosBuilder" forKey:@"fileType"];
    [doc setObject:[NSNumber numberWithInt:3] forKey:@"fileVersion"];
    
    [doc setObject:[NSNumber numberWithInt:[g.cocosScene stageSize].width] forKey:@"stageWidth"];
    [doc setObject:[NSNumber numberWithInt:[g.cocosScene stageSize].height] forKey:@"stageHeight"];
    [doc setObject:[NSNumber numberWithBool:[g.cocosScene centeredOrigin]] forKey:@"centeredOrigin"];
    
    return doc;
}

- (void) prepareForDocumentSwitch
{
    [self setSelectedNode:NULL];
    CCBGlobals* g = [CCBGlobals globals];
    CocosScene* cs = [g cocosScene];
    //[g.cocosScene setStageSize:CGSizeMake(0, 0) centeredOrigin:NO];
    
    if (![self hasOpenedDocument]) return;
    currentDocument.docData = [self docDataFromCurrentNodeGraph];
    currentDocument.stageZoom = [cs stageZoom];
    currentDocument.stageScrollOffset = [cs scrollOffset];
}

- (void) replaceDocumentData:(NSMutableDictionary*)doc
{
    // Process contents
    NSMutableDictionary* extraProps = [NSMutableDictionary dictionary];
    
    //CCNode* loadedRoot = [CCBReaderInternalV1 nodeGraphFromDictionary:doc assetsDir:assetsPath owner:NULL];
    CCNode* loadedRoot = [CCBReaderInternal nodeGraphFromDocumentDictionary:doc];
    
    // Replace open document
    CCBGlobals* g = [CCBGlobals globals];
    
    selectedNode = NULL;
    [g.cocosScene replaceRootNodeWith:loadedRoot extraProps:extraProps];
    [outlineHierarchy reloadData];
    [self updateOutlineViewSelection];
    [self updateInspectorFromSelection];
    
    [self updateExpandedForNode:g.rootNode];
    
    // Setup stage
    int stageW = [[doc objectForKey:@"stageWidth"] intValue];
    int stageH = [[doc objectForKey:@"stageHeight"] intValue];
    BOOL centered = [[doc objectForKey:@"centeredOrigin"] boolValue];
    
    [g.cocosScene setStageSize:CGSizeMake(stageW, stageH) centeredOrigin:centered];
}

- (void) switchToDocument:(CCBDocument*) document forceReload:(BOOL)forceReload
{
    if (!forceReload && [document.fileName isEqualToString:currentDocument.fileName]) return;
    
    [self prepareForDocumentSwitch];
    
    self.currentDocument = document;
    
    NSMutableDictionary* doc = document.docData;
    
    [self updateAssetsView];
    
    [self replaceDocumentData:doc];
    
    [self updateCanvasSizeMenu];
    [self updateStateOriginCenteredMenu];
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setStageZoom:document.stageZoom];
    [cs setScrollOffset:document.stageScrollOffset];
}

- (void) switchToDocument:(CCBDocument*) document
{
    [self switchToDocument:document forceReload:NO];
}

- (void) addDocument:(CCBDocument*) doc
{
    [self addTab:doc];
}

- (void) closeLastDocument
{
    CCBGlobals* g = [CCBGlobals globals];
    selectedNode = NULL;
    [g.cocosScene replaceRootNodeWith:NULL extraProps:[NSMutableDictionary dictionary]];
    currentDocument.docData = NULL;
    currentDocument.fileName = NULL;
    [g.cocosScene setStageSize:CGSizeMake(0, 0) centeredOrigin:YES];
    
    [outlineHierarchy reloadData];
    [self updateAssetsView];
    
    [[assetsWindowController window] setIsVisible:NO];
//    [[templateWindowController window] setIsVisible:NO];
    
    self.hasOpenedDocument = NO;
}

- (CCBDocument*) findDocumentFromFile:(NSString*)file
{
    NSArray* items = [tabView tabViewItems];
    for (int i = 0; i < [items count]; i++)
    {
        CCBDocument* doc = [(NSTabViewItem*)[items objectAtIndex:i] identifier];
        if ([doc.fileName isEqualToString:file]) return doc;
    }
    return NULL;
}

- (NSTabViewItem*) tabViewItemFromDoc:(CCBDocument*)docRef
{
    NSArray* items = [tabView tabViewItems];
    for (int i = 0; i < [items count]; i++)
    {
        CCBDocument* doc = [(NSTabViewItem*)[items objectAtIndex:i] identifier];
        if (doc == docRef) return [items objectAtIndex:i];
    }
    return NULL;
}

- (void) openFile:(NSString*) fileName
{
    // Add to recent list of opened documents
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL fileURLWithPath:fileName]];
    
    // Check if file is already open
    CCBDocument* openDoc = [self findDocumentFromFile:fileName];
    if (openDoc)
    {
        [tabView selectTabViewItem:[self tabViewItemFromDoc:openDoc]];
        return;
    }
    
    [self prepareForDocumentSwitch];
    
    NSMutableDictionary* doc = [NSMutableDictionary dictionaryWithContentsOfFile:fileName];
    
    CCBDocument* newDoc = [[[CCBDocument alloc] init] autorelease];
    newDoc.fileName = fileName;
    newDoc.docData = doc;
    
    [self switchToDocument:newDoc];
     
    [self addDocument:newDoc];
    self.hasOpenedDocument = YES;
}

- (void) saveFile:(NSString*) fileName
{
    // Add to recent list of opened documents
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL fileURLWithPath:fileName]];
    
    NSMutableDictionary* doc = [self docDataFromCurrentNodeGraph];
     
    [doc writeToFile:fileName atomically:YES];
    currentDocument.fileName = fileName;
    currentDocument.docData = doc;
    [self updateAssetsView];
    
    currentDocument.isDirty = NO;
    NSTabViewItem* item = [self tabViewItemFromDoc:currentDocument];
    
    if (item)
    {
        [tabBar setIsEdited:NO ForTabViewItem:item];
        [self updateDirtyMark];
    }
        
    [currentDocument.undoManager removeAllActions];
    currentDocument.lastOperationType = kCCBOperationTypeUnspecified;
}

- (void) newFile:(NSString*) fileName type:(NSString*) type template:(int)template stageSize:(CGSize)stageSize origin:(int)origin
{
    // Close old doc if neccessary
    CCBDocument* oldDoc = [self findDocumentFromFile:fileName];
    if (oldDoc)
    {
        NSTabViewItem* item = [self tabViewItemFromDoc:oldDoc];
        if (item) [tabView removeTabViewItem:item];
    }
    
    // Add to recent list of opened documents
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL fileURLWithPath:fileName]];
    
    [self prepareForDocumentSwitch];
    
    CCBGlobals* g = [CCBGlobals globals];
    
    selectedNode = NULL;
    [g.cocosScene setStageSize:stageSize centeredOrigin:origin];
    [g.cocosScene replaceRootNodeWithDefaultObjectOfType:type template:template];
    
    [outlineHierarchy reloadData];
    [self updateOutlineViewSelection];
    [self updateInspectorFromSelection];
    
    self.currentDocument = [[[CCBDocument alloc] init] autorelease];
    
    [self saveFile:fileName];
    
    [self addDocument:currentDocument];
    self.hasOpenedDocument = YES;
    
    [self updateCanvasSizeMenu];
    [self updateStateOriginCenteredMenu];
    
    [[g cocosScene] setStageZoom:1];
    [[g cocosScene] setScrollOffset:ccp(0,0)];
}

- (BOOL) application:(NSApplication *)sender openFile:(NSString *)filename
{
    [self openFile:filename];
    return YES;
}

#pragma mark Undo

- (void) revertToState:(id)state
{
    [self saveUndoState];
    [self replaceDocumentData:state];
}

- (void) saveUndoState
{
    if (!currentDocument) return;
    
    NSMutableDictionary* doc = [self docDataFromCurrentNodeGraph];
    
    [currentDocument.undoManager registerUndoWithTarget:self selector:@selector(revertToState:) object:doc];
    currentDocument.lastOperationType = kCCBOperationTypeUnspecified;
    
    currentDocument.isDirty = YES;
    NSTabViewItem* item = [self tabViewItemFromDoc:currentDocument];
    [tabBar setIsEdited:YES ForTabViewItem:item];
    [self updateDirtyMark];
}

#pragma mark Menu options

- (BOOL) addCCObject:(CCNode *)obj toParent:(CCNode*)parent
{
    if (!obj || !parent) return NO;
    
    if ([parent isKindOfClass:[CCMenuItemImage class]])
    {
        [self modalDialogTitle:@"Failed to add item" message:@"You cannot add children to a CCMenuItemImage"];
        return NO;
    }
    if ([obj isKindOfClass:[CCMenuItemImage class]] && ![parent isKindOfClass:[CCMenu class]])
    {
        [self modalDialogTitle:@"Failed to add item" message:@"A CCMenuItem must be a child of CCMenu."];
        return NO;
    }
    if ([parent isKindOfClass:[CCMenu class]] && ![obj isKindOfClass:[CCMenuItem class]])
    {
        [self modalDialogTitle:@"Failed to add item" message:@"You can only add CCMenuItems to a CCMenu."];
        return NO;
    }
    if ([parent isKindOfClass:[CCLabelBMFont class]])
    {
        [self modalDialogTitle:@"Failed to add item" message:@"You cannot add children to a CCLabelBMFont"];
        return NO;
    }
    
    [self saveUndoState];
    [parent addChild:obj];
    [outlineHierarchy reloadData];
    [self setSelectedNode:obj];
    [self updateInspectorFromSelection];
    
    return YES;
}

- (BOOL) addCCObject:(CCNode*)obj asChild:(BOOL)asChild
{
    CCBGlobals* g = [CCBGlobals globals];
    
    CCNode* parent;
    if (!selectedNode) parent = g.rootNode;
    else if (selectedNode == g.rootNode) parent = g.rootNode;
    else parent = selectedNode.parent;
    
    if (asChild)
    {
        parent = selectedNode;
        if (!parent) selectedNode = g.rootNode;
    }
    
    return [self addCCObject:obj toParent:parent];
}

- (IBAction) menuAddPlugInNode:(id)sender
{
    NSLog(@"Add object of type: %@", [sender title]);
    
    CCNode* node = [plugInManager createDefaultNodeOfType:[sender title]];
    [self addCCObject:node asChild:[sender tag]];
}

- (IBAction) menuAddNode:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultNode] asChild:[sender tag]];
}

- (IBAction) menuAddLayer:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultLayer] asChild:[sender tag]];
}

- (IBAction) menuAddLayerColor:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultLayerColor] asChild:[sender tag]];
}

- (IBAction) menuAddLayerGradient:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultLayerGradient] asChild:[sender tag]];
}

- (IBAction) menuAddSprite:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultSprite] asChild:[sender tag]];
}

- (void) dropAddSpriteNamed:(NSString*)spriteFile inSpriteSheet:(NSString*)spriteSheetFile at:(CGPoint)pt parent:(CCNode*)parent
{
    // TODO: Fix!
    /*
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
    if ([parent isKindOfClass:[CCMenu class]])
    {
        BOOL added = [self addCCObject:[cs createDefaultMenuItemImage] toParent:parent];
        if (!added) return;
        if (spriteSheetFile) [self setPSpriteSheetFile:spriteSheetFile];
        [self setPSpriteFileNormal:spriteFile];
    }
    else
    {
        BOOL added = [self addCCObject:[cs createDefaultSprite] toParent:parent];
        if (!added) return;
        if (spriteSheetFile) [self setPSpriteSheetFile:spriteSheetFile];
        [self setPSpriteFile:spriteFile];
    }
    [self setPPositionX:pt.x];
    [self setPPositionY:pt.y];
     */
}

- (void) dropAddSpriteNamed:(NSString*)spriteFile inSpriteSheet:(NSString*)spriteSheetFile at:(CGPoint)pt
{
    // TODO: Fix!
    /*
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
    BOOL added = NO;
    if ([[selectedNode parent] isKindOfClass:[CCMenu class]])
    {
        added = [self addCCObject:[cs createDefaultMenuItemImage] asChild:NO];
        if (!added) return;
    }
    else if ([selectedNode isKindOfClass:[CCMenu class]])
    {
        added = [self addCCObject:[cs createDefaultMenuItemImage] asChild:YES];
        if (!added) return;
    }
    if (added)
    {
        // Added as menu item
        if (spriteSheetFile) [self setPSpriteSheetFile:spriteSheetFile];
        [self setPSpriteFileNormal:spriteFile];
    }
    else
    {
        // Add as sprite
        added = [self addCCObject:[cs createDefaultSprite] asChild:NO];
        if (!added) return;
        
        if (spriteSheetFile) [self setPSpriteSheetFile:spriteSheetFile];
        [self setPSpriteFile:spriteFile];
    }
    
    // Set position
    pt = [[selectedNode parent] convertToNodeSpace:pt];
    [self setPPositionX:pt.x];
    [self setPPositionY:pt.y];
     */
}

- (IBAction) menuAddMenu:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultMenu] asChild:[sender tag]];
}

- (IBAction) menuAddMenuItemImage:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultMenuItemImage] asChild:[sender tag]];
}

- (IBAction) menuAddLabelTTF:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultLabelTTF] asChild:[sender tag]];
}

- (IBAction) menuAddLabelBMFont:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultLabelBMFont] asChild:[sender tag]];
}

- (IBAction) menuAddCCButton:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultButton] asChild:[sender tag]];
}

- (IBAction) menuAddCCNineSlice:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultNineSlice] asChild:[sender tag]];
}

- (IBAction) menuAddCCThreeSlice:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultThreeSlice] asChild:[sender tag]];
}

- (IBAction) menuAddParticleExplosion:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultParticleOfType:kCCBParticleTypeExplosion] asChild:[sender tag]];
}

- (IBAction) menuAddParticleFire:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultParticleOfType:kCCBParticleTypeFire] asChild:[sender tag]];
}

- (IBAction) menuAddParticleFireworks:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultParticleOfType:kCCBParticleTypeFireworks] asChild:[sender tag]];
}

- (IBAction) menuAddParticleFlower:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultParticleOfType:kCCBParticleTypeFlower] asChild:[sender tag]];
}

- (IBAction) menuAddParticleGalaxy:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultParticleOfType:kCCBParticleTypeGalaxy] asChild:[sender tag]];
}

- (IBAction) menuAddParticleMeteor:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultParticleOfType:kCCBParticleTypeMeteor] asChild:[sender tag]];
}

- (IBAction) menuAddParticleRain:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultParticleOfType:kCCBParticleTypeRain] asChild:[sender tag]];
}

- (IBAction) menuAddParticleSmoke:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultParticleOfType:kCCBParticleTypeSmoke] asChild:[sender tag]];
}

- (IBAction) menuAddParticleSnow:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultParticleOfType:kCCBParticleTypeSnow] asChild:[sender tag]];
}

- (IBAction) menuAddParticleSpiral:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultParticleOfType:kCCBParticleTypeSpiral] asChild:[sender tag]];
}

- (IBAction) menuAddParticleSun:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultParticleOfType:kCCBParticleTypeSun] asChild:[sender tag]];
}

- (IBAction) menuAddTemplate:(id)sender
{
    if (!currentDocument) return;
    
    NSMenuItem* item = sender;
    NSLog(@"Add template: %@", [item title]);
    //NSString* fileName = [NSString stringWithFormat:@"%@%@", assetsPath, [item title]];
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultTemplateNodeWithFile:[item title] assetsPath:assetsPath] asChild:[sender tag]];
}

- (IBAction) copy:(id) sender
{
    if (!selectedNode) return;
    
    // Serialize selected node
    //CocosScene* cs = [[CCBGlobals globals] cocosScene];
    NSMutableDictionary* clipDict = [CCBWriterInternal dictionaryFromCCObject:selectedNode];
    NSData* clipData = [NSKeyedArchiver archivedDataWithRootObject:clipDict];
    NSPasteboard* cb = [NSPasteboard generalPasteboard];
    
    [cb declareTypes:[NSArray arrayWithObjects:@"com.cocosbuilder.node", nil] owner:self];
    [cb setData:clipData forType:@"com.cocosbuilder.node"];
}

- (void) doPasteAsChild:(BOOL)asChild
{
    //CocosScene* cs = [[CCBGlobals globals] cocosScene];
    NSPasteboard* cb = [NSPasteboard generalPasteboard];
    NSString* type = [cb availableTypeFromArray:[NSArray arrayWithObjects:@"com.cocosbuilder.node", nil]];
    
    if (type)
    {
        NSData* clipData = [cb dataForType:type];
        NSMutableDictionary* clipDict = [NSKeyedUnarchiver unarchiveObjectWithData:clipData];
        
        //CCNode* clipNode = [CCBReaderInternalV1 ccObjectFromDictionary:clipDict assetsDir:assetsPath owner:NULL];
        CCNode* clipNode = [CCBReaderInternal nodeGraphFromDictionary:clipDict];
        [self addCCObject:clipNode asChild:asChild];
    }
}

- (IBAction) paste:(id) sender
{
    [self doPasteAsChild:NO];
}

- (IBAction) pasteAsChild:(id)sender
{
    [self doPasteAsChild:YES];
}

- (void) deleteNode:(CCNode*)node
{
    CCBGlobals* g= [CCBGlobals globals];
    if (node == g.rootNode) return;
    if (!node) return;
    
    [self saveUndoState];
    [node removeFromParentAndCleanup:YES];
    [outlineHierarchy reloadData];
    selectedNode = NULL;
    [self updateOutlineViewSelection];
}

- (IBAction) delete:(id) sender
{
    if (!selectedNode) return;
    
    [self deleteNode:selectedNode];
}

- (IBAction) cut:(id) sender
{
    CCBGlobals* g = [CCBGlobals globals];
    if (selectedNode == g.rootNode)
    {
        [self modalDialogTitle:@"Failed to cut object" message:@"The root node cannot be removed"];
        return;
    }
    
    [self copy:sender];
    [self delete:sender];
}

- (IBAction) menuNudgeObject:(id)sender
{
    int dir = (int)[sender tag];
    // TODO: Fix!
    /*
    if (dir == 0) self.pPositionX = self.pPositionX - 1;
    if (dir == 1) self.pPositionX = self.pPositionX + 1;
    if (dir == 2) self.pPositionY = self.pPositionY + 1;
    if (dir == 3) self.pPositionY = self.pPositionY - 1;
     */
}

- (IBAction) menuMoveObject:(id)sender
{
    int dir = (int)[sender tag];
    // TODO: Fix!
    /*
    if (dir == 0) self.pPositionX = self.pPositionX - 10;
    if (dir == 1) self.pPositionX = self.pPositionX + 10;
    if (dir == 2) self.pPositionY = self.pPositionY + 10;
    if (dir == 3) self.pPositionY = self.pPositionY - 10;
     */
}

- (IBAction) saveDocumentAs:(id)sender
{
    NSSavePanel* saveDlg = [NSSavePanel savePanel];
    [saveDlg setAllowedFileTypes:[NSArray arrayWithObject:@"ccb"]];
    
    [saveDlg beginSheetModalForWindow:window completionHandler:^(NSInteger result){
        if (result == NSOKButton)
        {
            [self saveFile:[[saveDlg URL] path]];
            currentDocument.fileName = [[saveDlg URL] path];
            [[self tabViewItemFromDoc:currentDocument] setLabel:[currentDocument formattedName]];
        }
    }];
}

- (IBAction) saveDocument:(id)sender
{
    if (currentDocument && currentDocument.fileName)
    {
        [self saveFile:currentDocument.fileName];
    }
    else
    {
        [self saveDocumentAs:sender];
    }
}

- (IBAction) openDocument:(id)sender
{
    // Create the File Open Dialog
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setAllowedFileTypes:[NSArray arrayWithObject:@"ccb"]];
    
    [openDlg beginSheetModalForWindow:window completionHandler:^(NSInteger result){
        if (result == NSOKButton)
        {
            NSArray* files = [openDlg URLs];
            
            for (int i = 0; i < [files count]; i++)
            {
                NSString* fileName = [[files objectAtIndex:i] path];
                [self openFile:fileName];
            }
        }
    }];
}

- (IBAction) newDocument:(id)sender
{
    NewDocWindowController* wc = [[NewDocWindowController alloc] initWithWindowNibName:@"NewDocWindow"];
    
    // Show new document sheet
    [NSApp beginSheet:[wc window] modalForWindow:window modalDelegate:NULL didEndSelector:NULL contextInfo:NULL];
    int acceptedModal = (int)[NSApp runModalForWindow:[wc window]];
    [NSApp endSheet:[wc window]];
    [[wc window] close];
    
    if (acceptedModal)
    {
        // Accepted create document, prompt for place for file
        NSSavePanel* saveDlg = [NSSavePanel savePanel];
        [saveDlg setAllowedFileTypes:[NSArray arrayWithObject:@"ccb"]];
        
        [saveDlg beginSheetModalForWindow:window completionHandler:^(NSInteger result){
            if (result == NSOKButton)
            {
                [self newFile:[[saveDlg URL] path] type:wc.rootObjectType template:wc.templateType stageSize:CGSizeMake(wc.wStage, wc.hStage) origin:wc.originPos];
            }
            [wc release];
        }];
    }
    else
    {
        [wc release];
    }
}

- (IBAction) menuCloseDocument:(id)sender
{
    if (!currentDocument) return;
    NSTabViewItem* item = [self tabViewItemFromDoc:currentDocument];
    if (!item) return;
    
    if ([self tabView:tabView shouldCloseTabViewItem:item])
    {
        [tabView removeTabViewItem:item];
    }
}

- (IBAction) menuSelectBehind:(id)sender
{
    CCBGlobals* g = [CCBGlobals globals];
    [g.cocosScene selectBehind];
}

- (IBAction) menuDeselect:(id)sender
{
    [self setSelectedNode:NULL];
}

- (IBAction) undo:(id)sender
{
    if (!currentDocument) return;
    [currentDocument.undoManager undo];
    currentDocument.lastOperationType = kCCBOperationTypeUnspecified;
}

- (IBAction) redo:(id)sender
{
    if (!currentDocument) return;
    [currentDocument.undoManager redo];
    currentDocument.lastOperationType = kCCBOperationTypeUnspecified;
}

- (int) orientedDeviceTypeForSize:(CGSize)size
{
    for (int i = 1; i < 5; i++)
    {
        if (size.width == defaultCanvasSizes[i].width && size.height == defaultCanvasSizes[i].height) return i;
    }
    return 0;
}

- (void) updateCanvasSizeMenu
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
    CGSize size = [cs stageSize];
    int tag = [self orientedDeviceTypeForSize:size];
    
    [CCBUtil setSelectedSubmenuItemForMenu:menuCanvasSize tag:tag];
}

- (IBAction) menuSetCanvasSize:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
    CGSize oldSize = [cs stageSize];
    
    int tag = (int)[sender tag];
    CGSize size;
    
    if (tag)
    {
        size = defaultCanvasSizes[tag];
    }
    else
    {
        StageSizeWindow* wc = [[[StageSizeWindow alloc] initWithWindowNibName:@"StageSizeWindow"] autorelease];
        
        size = [cs stageSize];
        wc.wStage = size.width;
        wc.hStage = size.height;
        
        int success = [wc runModalSheetForWindow:window];
        
        if (success)
        {
            size.width = wc.wStage;
            size.height = wc.hStage;
        }
    }
    
    if (oldSize.width != size.width || oldSize.height != size.height)
    {
        [self saveUndoState];
        [cs setStageSize:size centeredOrigin:[cs centeredOrigin]];
    }
    
    [self updateCanvasSizeMenu];
}

- (void) updateStateOriginCenteredMenu
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    BOOL centered = [cs centeredOrigin];
    
    if (centered) [menuItemStageCentered setState:NSOnState];
    else [menuItemStageCentered setState:NSOffState];
}

- (IBAction) menuSetStateOriginCentered:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    BOOL centered = ![cs centeredOrigin];
    
    [self saveUndoState];
    [cs setStageSize:[cs stageSize] centeredOrigin:centered];
    
    [self updateStateOriginCenteredMenu];
}

- (void) updateCanvasBorderMenu
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    int tag = [cs stageBorder];
    [CCBUtil setSelectedSubmenuItemForMenu:menuCanvasBorder tag:tag];
}

- (IBAction) menuSetCanvasBorder:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
    int tag = (int)[sender tag];
    [cs setStageBorder:tag];
    [self updateCanvasBorderMenu];
}

- (IBAction) menuZoomIn:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
    float zoom = [cs stageZoom];
    zoom *= 2;
    if (zoom > 8) zoom = 8;
    [cs setStageZoom:zoom];
}

- (IBAction) menuZoomOut:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
    float zoom = [cs stageZoom];
    zoom *= 0.5f;
    if (zoom < 0.125) zoom = 0.125f;
    [cs setStageZoom:zoom];
}

- (IBAction) menuResetView:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    cs.scrollOffset = ccp(0,0);
    [cs setStageZoom:1];
}

- (IBAction) pressedZoom:(id)sender
{
    NSSegmentedControl* sc = sender;
    int selectedItem = [[sc cell] selectedSegment];
    if (selectedItem == 0) [self menuZoomIn:sender];
    else if (selectedItem == 1) [self menuResetView:sender];
    else if (selectedItem == 2) [self menuZoomOut:sender];
}

- (IBAction) pressedToolSelection:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    NSSegmentedControl* sc = sender;
    
    cs.currentTool = [sc selectedSegment];
}

- (IBAction) menuOpenAssetsPanel:(id)sender
{
    [[assetsWindowController window] setIsVisible:![[assetsWindowController window] isVisible]];
}

/*
- (IBAction) menuOpenTemplatePanel:(id)sender
{
    [[templateWindowController window] setIsVisible:![[templateWindowController window] isVisible]];
}*/

- (IBAction) menuReloadAssets:(id)sender
{
    if (!currentDocument) return;
    
    [self updateAssetsView];
    
    [self switchToDocument:currentDocument forceReload:YES];
}

- (IBAction) menuAlignChildren:(id)sender
{
    if (!currentDocument) return;
    if (![self isSelectedNode]) return;
    
    CCArray* children = [selectedNode children];
    if ([children count] == 0) return;
    
    float sum = 0;
    
    for (int i = 0; i < [children count]; i++)
    {
        CCNode* c = [children objectAtIndex:i];
        
        if ([sender tag] == 1) sum += c.position.x;
        else if ([sender tag] == 2) sum += c.position.y;
        else
        {
            c.position = ccp(roundf(c.position.x), roundf(c.position.y));
        }
    }
    
    if ([sender tag])
    {
        float avg = sum/[children count];
        for (int i = 0; i < [children count]; i++)
        {
            CCNode* c = [children objectAtIndex:i];
            
            if ([sender tag] == 1) c.position = ccp(avg, c.position.y);
            else if ([sender tag] == 2) c.position = ccp(c.position.x, avg);
        }
    }
}

- (IBAction) menuDistributeChildren:(id)sender
{
    if (!currentDocument) return;
    if (![self isSelectedNode]) return;
    
    CCArray* children = [selectedNode children];
    if ([children count] <= 2) return;
    
    // TODO: Implement!
}

- (BOOL) windowShouldClose:(id)sender
{
    if ([self hasDirtyDocument])
    {
        NSAlert* alert = [NSAlert alertWithMessageText:@"Quit CocosBuilder" defaultButton:@"Cancel" alternateButton:@"Quit" otherButton:NULL informativeTextWithFormat:@"There are unsaved documents. If you quit now you will lose any changes you have made."];
        [alert setAlertStyle:NSWarningAlertStyle];
        NSInteger result = [alert runModal];
        if (result == NSAlertDefaultReturn) return NO;
    }
    return YES;
}

- (void) windowWillClose:(NSNotification *)notification
{
    [[NSApplication sharedApplication] terminate:self];
}

- (IBAction) menuQuit:(id)sender
{
    if ([self windowShouldClose:self])
    {
        [[NSApplication sharedApplication] terminate:self];
    }
}

#pragma mark Debug

- (IBAction) debugPrintStructure:(id)sender
{
    CCBGlobals* g = [CCBGlobals globals];
    if (g.rootNode) [g.cocosScene printNodes:g.rootNode level:0];
}

- (IBAction) debugPrintExtraProps:(id)sender
{
    CCBGlobals* g = [CCBGlobals globals];
    if (g.rootNode) [g.cocosScene printExtraProps];
}

- (IBAction) debugPrintExtraPropsForSelectedNode:(id)sender
{
    if (!selectedNode)
    {
        NSLog(@"No selected node!");
        return;
    }
    
    CCBGlobals* g = [CCBGlobals globals];
    if (g.rootNode) [g.cocosScene printExtraPropsForNode:selectedNode];
}

@end
