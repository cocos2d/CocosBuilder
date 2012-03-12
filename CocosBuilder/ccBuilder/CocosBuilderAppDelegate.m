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
#import "PlugInManager.h"
#import "InspectorPosition.h"
#import "NodeInfo.h"
#import "PlugInNode.h"
#import "PlugInExport.h"
#import "TexturePropertySetter.h"
#import "PublishTypeAccessoryView.h"
#import "ResourceManager.h"
#import "ResourceManagerPanel.h"

#import <ExceptionHandling/NSExceptionHandler.h>

@implementation CocosBuilderAppDelegate

@synthesize window, assetsFontListTTF, currentDocument, cocosView, canEditContentSize, canEditCustomClass, hasOpenedDocument, defaultCanvasSize, plugInManager, resManager;

#pragma mark Setup functions

- (void) setupInspectorPane
{
    currentInspectorValues = [[NSMutableDictionary alloc] init];
    
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

- (void) loadFontListTTF
{
    NSMutableDictionary* fontInfo = [NSMutableDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FontListTTF" ofType:@"plist"]];
    self.assetsFontListTTF = [fontInfo objectForKey:@"supportedFonts"];
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

- (void) setupResourceManager
{
    // Load resource manager
    resManager = [ResourceManager sharedManager];
    resManagerPanel = [[ResourceManagerPanel alloc] initWithWindowNibName:@"ResourceManagerPanel"];
    [resManagerPanel.window setIsVisible:NO];
}

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

    [self setupResourceManager];
    [self loadFontListTTF];
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
    CCBDocument* doc = [tabViewItem identifier];
    
    // Remove directory paths from resource manager
    [resManager removeDirectory:doc.rootPath];
    NSArray* paths = [doc.project objectForKey:@"resourcePaths"];
    if (paths)
    {
        for (NSString* path in paths)
        {
            [resManager removeDirectory:path];
        }
    }
    
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
    if (![[self window] makeFirstResponder:[self window]])
    {
        return;
    }
    
    selectedNode = selection;
    [self updateOutlineViewSelection];
    
    if (currentDocument) currentDocument.lastEditedProperty = NULL;
}

- (CCNode*) selectedNode
{
    return selectedNode;
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
    else className = info.plugIn.nodeClassName;
    
    // Assignment name
    NSString* assignmentName = [cs extraPropForKey:@"memberVarAssignmentName" andNode:item];
    if (assignmentName && ![assignmentName isEqualToString:@""]) return [NSString stringWithFormat:@"%@ (%@)",className,assignmentName];
    
    if ([item isKindOfClass:[CCMenuItemImage class]])
    {
        NSString* textureName = [cs extraPropForKey:@"spriteFileNormal" andNode:item];
        if (textureName && ![textureName isEqualToString:@""])
        {
            return [NSString stringWithFormat:@"CCMenuItemImage (%@)", textureName];
        }
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
    NSPasteboard* pb = [info draggingPasteboard];
    
    NSData* clipData = [pb dataForType:@"com.cocosbuilder.node"];
    if (clipData)
    {
        NSMutableDictionary* clipDict = [NSKeyedUnarchiver unarchiveObjectWithData:clipData];
        
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

- (void) refreshProperty:(NSString*) name
{
    InspectorValue* inspectorValue = [currentInspectorValues objectForKey:name];
    if (inspectorValue)
    {
        [inspectorValue refresh];
    }
}

- (int) addInspectorPropertyOfType:(NSString*)type name:(NSString*)prop displayName:(NSString*)displayName extra:(NSString*)e readOnly:(BOOL)readOnly affectsProps:(NSArray*)affectsProps atOffset:(int)offset
{
    NSString* inspectorNibName = [NSString stringWithFormat:@"Inspector%@",type];
    
    // Create inspector
    InspectorValue* inspectorValue = [InspectorValue inspectorOfType:type withSelection:selectedNode andPropertyName:prop andDisplayName:displayName andExtra:e];
    inspectorValue.readOnly = readOnly;
    
    // Save a reference in case it needs to be updated
    if (prop)
    {
        [currentInspectorValues setObject:inspectorValue forKey:prop];
    }
    
    if (affectsProps)
    {
        inspectorValue.affectsProperties = affectsProps;
    }
    
    // Load it's associated view
    [NSBundle loadNibNamed:inspectorNibName owner:inspectorValue];
    NSView* view = inspectorValue.view;
    
    [inspectorValue willBeAdded];
    
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
    // Notifiy panes that they will be removed
    for (NSString* key in currentInspectorValues)
    {
        InspectorValue* v = [currentInspectorValues objectForKey:key];
        [v willBeRemoved];
    }
    
    // Remove all old inspector panes
    NSArray* panes = [inspectorDocumentView subviews];
    for (int i = [panes count]-1; i >= 0 ; i--)
    {
        NSView* pane = [panes objectAtIndex:i];
        [pane removeFromSuperview];
    }
    [currentInspectorValues removeAllObjects];
    
    [inspectorDocumentView setFrameSize:NSMakeSize(233, 1)];
    int paneOffset = 0;
    
    // Add show panes according to selections
    if (!selectedNode) return;
    
    // Always add the code connections pane
    paneOffset = [self addInspectorPropertyOfType:@"CodeConnections" name:@"customClass" displayName:@"" extra:NULL readOnly:YES affectsProps:NULL atOffset:paneOffset];
    
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
            BOOL readOnly = [[propInfo objectForKey:@"readOnly"] boolValue];
            NSArray* affectsProps = [propInfo objectForKey:@"affectsProperties"];
            NSString* extra = [propInfo objectForKey:@"extra"];
            
            paneOffset = [self addInspectorPropertyOfType:type name:name displayName:displayName extra:extra readOnly:readOnly affectsProps:affectsProps atOffset:paneOffset];
        }
    }
    else
    {
        NSLog(@"WARNING info:%@ plugIn:%@ selectedNode: %@", info, plugIn, selectedNode);
    }
    
    [inspectorDocumentView setFrameSize:NSMakeSize(233, paneOffset)];
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
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    CCBDocument* doc = [self currentDocument];
    
    // Add node graph
    NSMutableDictionary* nodeGraph = [CCBWriterInternal dictionaryFromCCObject:g.rootNode];
    [dict setObject:nodeGraph forKey:@"nodeGraph"];
    
    // Add meta data
    [dict setObject:@"CocosBuilder" forKey:@"fileType"];
    [dict setObject:[NSNumber numberWithInt:3] forKey:@"fileVersion"];
    
    [dict setObject:[NSNumber numberWithInt:[g.cocosScene stageSize].width] forKey:@"stageWidth"];
    [dict setObject:[NSNumber numberWithInt:[g.cocosScene stageSize].height] forKey:@"stageHeight"];
    [dict setObject:[NSNumber numberWithBool:[g.cocosScene centeredOrigin]] forKey:@"centeredOrigin"];
    
    if (doc.exportPath && doc.exportPlugIn)
    {
        [dict setObject:doc.exportPlugIn forKey:@"exportPlugIn"];
        [dict setObject:doc.exportPath forKey:@"exportPath"];
        [dict setObject:[NSNumber numberWithBool:doc.exportFlattenPaths] forKey:@"exportFlattenPaths"];
    }
    
    return dict;
}

- (void) prepareForDocumentSwitch
{
    [self setSelectedNode:NULL];
    CCBGlobals* g = [CCBGlobals globals];
    CocosScene* cs = [g cocosScene];
    
    if (![self hasOpenedDocument]) return;
    currentDocument.docData = [self docDataFromCurrentNodeGraph];
    currentDocument.stageZoom = [cs stageZoom];
    currentDocument.stageScrollOffset = [cs scrollOffset];
}

- (void) replaceDocumentData:(NSMutableDictionary*)doc
{
    // Process contents
    CCNode* loadedRoot = [CCBReaderInternal nodeGraphFromDocumentDictionary:doc];
    
    // Replace open document
    CCBGlobals* g = [CCBGlobals globals];
    
    selectedNode = NULL;
    [g.cocosScene replaceRootNodeWith:loadedRoot];
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
    
    // Update active directories for the resource manager
    NSArray* activeDirs = [NSMutableArray arrayWithObject:document.rootPath];
    if (document.project && [document.project objectForKey:@"resourcePaths"])
    {
        activeDirs = [activeDirs arrayByAddingObjectsFromArray:[document.project objectForKey:@"resourcePaths"]];
    }
    //[resManager setActiveDirectory: document.rootPath];
    [resManager setActiveDirectories:activeDirs];
    
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
    [g.cocosScene replaceRootNodeWith:NULL];
    currentDocument.docData = NULL;
    currentDocument.fileName = NULL;
    [g.cocosScene setStageSize:CGSizeMake(0, 0) centeredOrigin:YES];
    
    [outlineHierarchy reloadData];
    
    [resManagerPanel.window setIsVisible:NO];
    
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
    newDoc.exportPath = [doc objectForKey:@"exportPath"];
    newDoc.exportPlugIn = [doc objectForKey:@"exportPlugIn"];
    newDoc.exportFlattenPaths = [[doc objectForKey:@"exportFlattenPaths"] boolValue];
    
    [resManager addDirectory:newDoc.rootPath];
    NSArray* paths = [newDoc.project objectForKey:@"resourcePaths"];
    if (paths)
    {
        for (NSString* path in paths)
        {
            [resManager addDirectory:path];
        }
    }
    
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
    
    currentDocument.isDirty = NO;
    NSTabViewItem* item = [self tabViewItemFromDoc:currentDocument];
    
    if (item)
    {
        [tabBar setIsEdited:NO ForTabViewItem:item];
        [self updateDirtyMark];
    }
        
    [currentDocument.undoManager removeAllActions];
    currentDocument.lastEditedProperty = NULL;
}

- (void) exportFile:(NSString*) fileName withPlugIn:(NSString*) ext
{
    PlugInExport* plugIn = [[PlugInManager sharedManager] plugInExportForExtension:ext];
    if (!plugIn)
    {
        [self modalDialogTitle:@"Plug-in missing" message:[NSString stringWithFormat:@"There is no extension available for publishing to %@-files. Please use the Publish As... option.",ext]];
        return;
    }
    
    NSMutableDictionary* doc = [self docDataFromCurrentNodeGraph];
    NSData* data = [plugIn exportDocument:doc];
    BOOL success = [data writeToFile:fileName atomically:YES];
    if (!success)
    {
        [self modalDialogTitle:@"Publish failed" message:@"Failed to publish the document, please try to publish to another location."];
    }
}

- (void) newFile:(NSString*) fileName type:(NSString*)type stageSize:(CGSize)stageSize origin:(int)origin
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
    
    [g.cocosScene replaceRootNodeWith:[[PlugInManager sharedManager] createDefaultNodeOfType:type]];
    
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

- (void) saveUndoStateWillChangeProperty:(NSString*)prop
{
    if (!currentDocument) return;
    
    if (prop && [currentDocument.lastEditedProperty isEqualToString:prop])
    {
        return;
    }
    
    NSMutableDictionary* doc = [self docDataFromCurrentNodeGraph];
    
    [currentDocument.undoManager registerUndoWithTarget:self selector:@selector(revertToState:) object:doc];
    currentDocument.lastEditedProperty = prop;
    
    currentDocument.isDirty = YES;
    NSTabViewItem* item = [self tabViewItemFromDoc:currentDocument];
    [tabBar setIsEdited:YES ForTabViewItem:item];
    [self updateDirtyMark];
}

- (void) saveUndoState
{
    [self saveUndoStateWillChangeProperty:NULL];
}

#pragma mark Menu options

- (BOOL) addCCObject:(CCNode *)obj toParent:(CCNode*)parent
{
    if (!obj || !parent) return NO;
    
    NodeInfo* nodeInfoParent = parent.userData;
    NodeInfo* nodeInfo = obj.userData;
    
    // Check that the parent supports children
    if (!nodeInfoParent.plugIn.canHaveChildren)
    {
        [self modalDialogTitle:@"Failed to add item" message:[NSString stringWithFormat: @"You cannot add children to a %@",nodeInfoParent.plugIn.nodeClassName]];
        return NO;
    }
    
    // Check if the added node requires a specific type of parent
    NSString* requireParent = nodeInfo.plugIn.requireParentClass;
    if (requireParent && ![requireParent isEqualToString: nodeInfoParent.plugIn.nodeClassName])
    {
        [self modalDialogTitle:@"Failed to add item" message:[NSString stringWithFormat: @"A %@ must be added to a %@",nodeInfo.plugIn.nodeClassName, requireParent]];
        return NO;
    }
    
    // Check if the parent require a specific type of children
    NSArray* requireChild = nodeInfoParent.plugIn.requireChildClass;
    if (requireChild && [requireChild indexOfObject:nodeInfo.plugIn.nodeClassName] == NSNotFound)
    {
        [self modalDialogTitle:@"Failed to add item" message:[NSString stringWithFormat: @"You cannot add a %@ to a %@",nodeInfo.plugIn.nodeClassName, nodeInfoParent.plugIn.nodeClassName]];
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
    CCNode* node = [plugInManager createDefaultNodeOfType:[sender title]];
    [self addCCObject:node asChild:[sender tag]];
}

- (void) dropAddSpriteNamed:(NSString*)spriteFile inSpriteSheet:(NSString*)spriteSheetFile at:(CGPoint)pt parent:(CCNode*)parent
{
    NodeInfo* info = parent.userData;
    PlugInNode* plugIn = info.plugIn;
    
    if (!spriteFile) spriteFile = @"";
    if (!spriteSheetFile) spriteSheetFile = @"";
    
    NSString* class = plugIn.dropTargetSpriteFrameClass;
    NSString* prop = plugIn.dropTargetSpriteFrameProperty;
    
    if (class && prop)
    {
        // Create the node
        CCNode* node = [plugInManager createDefaultNodeOfType:class];
        
        // Set its position
        node.position = pt;
        
        [CCBReaderInternal setProp:prop ofType:@"SpriteFrame" toValue:[NSArray arrayWithObjects:spriteSheetFile, spriteFile, nil] forNode:node];
        
        [self addCCObject:node toParent:parent];
    }
}

- (void) dropAddSpriteNamed:(NSString*)spriteFile inSpriteSheet:(NSString*)spriteSheetFile at:(CGPoint)pt
{
    // Sprite dropped in working canvas
    
    CCNode* node = selectedNode;
    if (!node) node = [[CCBGlobals globals] cocosScene].rootNode;
    
    CCNode* parent = node.parent;
    NodeInfo* info = parent.userData;
    
    if (info.plugIn.acceptsDroppedSpriteFrameChildren)
    {
        [self dropAddSpriteNamed:spriteFile inSpriteSheet:spriteSheetFile at:[parent convertToNodeSpace:pt] parent:parent];
        return;
    }
    
    info = node.userData;
    if (info.plugIn.acceptsDroppedSpriteFrameChildren)
    {
        [self dropAddSpriteNamed:spriteFile inSpriteSheet:spriteSheetFile at:[node convertToNodeSpace:pt] parent:node];
    }
}


- (IBAction) copy:(id) sender
{
    if (!selectedNode) return;
    
    // Serialize selected node
    NSMutableDictionary* clipDict = [CCBWriterInternal dictionaryFromCCObject:selectedNode];
    NSData* clipData = [NSKeyedArchiver archivedDataWithRootObject:clipDict];
    NSPasteboard* cb = [NSPasteboard generalPasteboard];
    
    [cb declareTypes:[NSArray arrayWithObjects:@"com.cocosbuilder.node", nil] owner:self];
    [cb setData:clipData forType:@"com.cocosbuilder.node"];
}

- (void) doPasteAsChild:(BOOL)asChild
{
    NSPasteboard* cb = [NSPasteboard generalPasteboard];
    NSString* type = [cb availableTypeFromArray:[NSArray arrayWithObjects:@"com.cocosbuilder.node", nil]];
    
    if (type)
    {
        NSData* clipData = [cb dataForType:type];
        NSMutableDictionary* clipDict = [NSKeyedUnarchiver unarchiveObjectWithData:clipData];
        
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
    
    if (!selectedNode) return;
    
    
    CGPoint delta;
    if (dir == 0) delta = ccp(-1, 0);
    else if (dir == 1) delta = ccp(1, 0);
    else if (dir == 2) delta = ccp(0, 1);
    else if (dir == 3) delta = ccp(0, -1);
    
    [self saveUndoStateWillChangeProperty:@"position"];
    selectedNode.position = ccpAdd(selectedNode.position, delta);
    [self refreshProperty:@"position"];
}

- (IBAction) menuMoveObject:(id)sender
{
    int dir = (int)[sender tag];
    
    if (!selectedNode) return;
    
    CGPoint delta;
    if (dir == 0) delta = ccp(-10, 0);
    else if (dir == 1) delta = ccp(10, 0);
    else if (dir == 2) delta = ccp(0, 10);
    else if (dir == 3) delta = ccp(0, -10);
    
    [self saveUndoStateWillChangeProperty:@"position"];
    selectedNode.position = ccpAdd(selectedNode.position, delta);
    [self refreshProperty:@"position"];
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

- (IBAction) publishDocumentAs:(id)sender
{
    NSSavePanel* saveDlg = [NSSavePanel savePanel];
    
    // Setup accessory view
    PublishTypeAccessoryView* accessoryView = [[PublishTypeAccessoryView alloc] init];
    accessoryView.savePanel = saveDlg;
    accessoryView.flattenPaths = currentDocument.exportFlattenPaths;
    [NSBundle loadNibNamed:@"PublishTypeAccessoryView" owner:accessoryView];
    NSView* view = accessoryView.view;
    saveDlg.accessoryView = view;
    
    // Set allowed extension
    NSString* defaultFileExtension = [[[PlugInManager sharedManager] plugInExportForIndex:0] extension];
    [saveDlg setAllowedFileTypes:[NSArray arrayWithObject:defaultFileExtension]];
    
    // Set default name
    NSString* exportName = [[currentDocument.fileName lastPathComponent] stringByDeletingPathExtension];
    [saveDlg setNameFieldStringValue:exportName];
    
    // Run the dialog
    [saveDlg beginSheetModalForWindow:window completionHandler:^(NSInteger result){
        if (result == NSOKButton)
        {
            NSString* exportTypeName = [[[PlugInManager sharedManager] plugInExportForIndex: accessoryView.selectedIndex] extension];
            currentDocument.exportPlugIn = exportTypeName;
            currentDocument.exportPath = [[saveDlg URL] path];
            currentDocument.exportFlattenPaths = accessoryView.flattenPaths;
            
            [self exportFile:currentDocument.exportPath withPlugIn:currentDocument.exportPlugIn];
        }
    }];
}

- (IBAction) publishDocument:(id)sender
{
    if (!currentDocument) return;
    
    if (currentDocument.exportPath && 
		currentDocument.exportPlugIn && 
		[[NSFileManager defaultManager] fileExistsAtPath:currentDocument.exportPath] )
    {
        [self exportFile:currentDocument.exportPath withPlugIn:currentDocument.exportPlugIn];
    }
    else
    {
        [self publishDocumentAs:sender];
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
                [self newFile:[[saveDlg URL] path] type:wc.rootObjectType stageSize:CGSizeMake(wc.wStage, wc.hStage) origin:wc.centeredStageOrigin];
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
    currentDocument.lastEditedProperty = NULL;
}

- (IBAction) redo:(id)sender
{
    if (!currentDocument) return;
    [currentDocument.undoManager redo];
    currentDocument.lastEditedProperty = NULL;
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

- (IBAction) menuOpenResourceManager:(id)sender
{
    //[[assetsWindowController window] setIsVisible:![[assetsWindowController window] isVisible]];
    
    [resManagerPanel.window setIsVisible:![resManagerPanel.window isVisible]];
}

- (void) reloadResources
{
    if (!currentDocument) return;
    
    NSLog(@"reloadResources");
    
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
    
    [self switchToDocument:currentDocument forceReload:YES];
}

- (IBAction) menuAlignChildren:(id)sender
{
    if (!currentDocument) return;
    if (!selectedNode) return;
    
#warning Check if node can have children
    
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
        return;
    }
    
    NodeInfo* info = selectedNode.userData;
    NSLog(@"%@",info.extraProps);
}

@end
