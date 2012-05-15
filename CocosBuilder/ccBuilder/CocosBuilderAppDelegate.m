/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2011 Viktor Lidholt
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

#import "CocosBuilderAppDelegate.h"
#import "CocosScene.h"
#import "CCBGLView.h"
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
#import "ResolutionSettingsWindow.h"
#import "PlugInManager.h"
#import "InspectorPosition.h"
#import "NodeInfo.h"
#import "PlugInNode.h"
#import "PlugInExport.h"
#import "TexturePropertySetter.h"
#import "PositionPropertySetter.h"
#import "PublishTypeAccessoryView.h"
#import "ResourceManager.h"
#import "ResourceManagerPanel.h"
#import "GuidesLayer.h"
#import "RulersLayer.h"
#import "NSString+RelativePath.h"
#import "CCBTransparentWindow.h"
#import "CCBTransparentView.h"
#import "NotesLayer.h"
#import "ResolutionSetting.h"
#import "ProjectSettingsWindow.h"
#import "ProjectSettings.h"
#import "ResourceManagerOutlineHandler.h"
#import "SavePanelLimiter.h"
#import "CCBPublisher.h"
#import "CCBWarnings.h"
#import "WarningsWindow.h"

#import <ExceptionHandling/NSExceptionHandler.h>

@implementation CocosBuilderAppDelegate

@synthesize window;
@synthesize projectSettings;
@synthesize currentDocument;
@synthesize cocosView;
@synthesize canEditContentSize;
@synthesize canEditCustomClass;
@synthesize hasOpenedDocument;
@synthesize defaultCanvasSize;
@synthesize plugInManager;
@synthesize resManager;
@synthesize showGuides;
@synthesize snapToGuides;
@synthesize guiView;
@synthesize guiWindow;
@synthesize showStickyNotes;

#pragma mark Setup functions

- (void) setupInspectorPane
{
    currentInspectorValues = [[NSMutableDictionary alloc] init];
    
    inspectorDocumentView = [[NSFlippedView alloc] initWithFrame:NSMakeRect(0, 0, 233, 239+239+121)];
    [inspectorDocumentView setAutoresizesSubviews:YES];
    [inspectorDocumentView setAutoresizingMask:NSViewWidthSizable];
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
	
	NSAssert( [NSThread currentThread] == [[CCDirector sharedDirector] runningThread], @"cocos2d shall run on the Main Thread. Compile CocosBuilder with CC_DIRECTOR_MAC_THREAD=2");
}

- (void) setupOutlineView
{
    [outlineHierarchy setDataSource:self];
    [outlineHierarchy setDelegate:self];
    [outlineHierarchy reloadData];
    
    [outlineHierarchy registerForDraggedTypes:[NSArray arrayWithObjects: @"com.cocosbuilder.node", @"com.cocosbuilder.texture", @"com.cocosbuilder.template", NULL]];
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

/*
- (void) setupDefaultDocument
{
	//currentDocument = [[CCBDocument alloc] init];
}*/

- (void) setupResourceManager
{
    // Load resource manager
    resManager = [ResourceManager sharedManager];
    resManagerPanel = [[ResourceManagerPanel alloc] initWithWindowNibName:@"ResourceManagerPanel"];
    [resManagerPanel.window setIsVisible:NO];
    
    // Setup project display
    projectOutlineHandler = [[ResourceManagerOutlineHandler alloc] initWithOutlineView:outlineProject resType:kCCBResTypeCCBFile];
}

- (void) setupGUIWindow
{
    NSRect frame = cocosView.frame;
    
    frame.origin.x += self.window.frame.origin.x;
    frame.origin.y += self.window.frame.origin.y;
    
    guiWindow = [[CCBTransparentWindow alloc] initWithContentRect:frame];
    
    guiView = [[[CCBTransparentView alloc] initWithFrame:cocosView.frame] autorelease];
    [guiWindow setContentView:guiView];
    guiWindow.delegate = self;
    
    [window addChildWindow:guiWindow ordered:NSWindowAbove];
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
    //[self setupDefaultDocument];
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
    [self setupGUIWindow];
    
    self.showGuides = YES;
    self.snapToGuides = YES;
    
    self.showStickyNotes = YES;
    
    [self.window makeKeyWindow];
}

#pragma mark Notifications to user

- (void) modalDialogTitle: (NSString*)title message:(NSString*)msg
{
    NSAlert* alert = [NSAlert alertWithMessageText:title defaultButton:@"OK" alternateButton:NULL otherButton:NULL informativeTextWithFormat:msg];
    [alert runModal];
}

#pragma mark Handling the gui layer

- (void) resizeGUIWindow:(NSSize)size
{
    NSRect frame = guiView.frame;
    frame.size = size;
    guiView.frame = NSMakeRect(0, 0, frame.size.width, frame.size.height);
    
    frame = cocosView.frame;
    frame.origin.x += self.window.frame.origin.x;
    frame.origin.y += self.window.frame.origin.y;
    
    [guiWindow setFrameOrigin:frame.origin];
    
    
    frame = guiWindow.frame;
    frame.size = size;
    [guiWindow setFrame:frame display:YES];
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
    //CCBDocument* doc = [tabViewItem identifier];
    
    // Remove directory paths from resource manager
    
    /*
    [resManager removeDirectory:doc.rootPath];
    NSArray* paths = [doc.project objectForKey:@"resourcePaths"];
    if (paths)
    {
        for (NSString* path in paths)
        {
            [resManager removeDirectory:path];
        }
    }*/
    
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
    NodeInfo* info = node.userObject;
    PlugInNode* plugIn = info.plugIn;
    
    if ([arr count] == 0) return NO;
    if (!plugIn.canHaveChildren) return NO;
    
    return YES;
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
    NodeInfo* info = node.userObject;
    
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
        
        CCNode* clipNode= [CCBReaderInternal nodeGraphFromDictionary:clipDict parentSize:CGSizeZero];
        if (![self addCCObject:clipNode toParent:item atIndex:index]) return NO;
        
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
    if (notification.object == self.window)
    {
        CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
        if (![[CCDirector sharedDirector] isPaused])
        {
            [[CCDirector sharedDirector] pause];
            [cs pauseSchedulerAndActions];
        }
    }
}

- (void) windowDidBecomeMain:(NSNotification *)notification
{
    if (notification.object == self.window)
    {
        CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
        if ([[CCDirector sharedDirector] isPaused])
        {
            [[CCDirector sharedDirector] resume];
            [cs resumeSchedulerAndActions];
        }
    }
}

- (void)windowDidResignKey:(NSNotification *)notification
{
    if (notification.object == guiWindow)
    {
        [guiView setSubviews:[NSArray array]];
        [[[CCBGlobals globals] cocosScene].notesLayer showAllNotesLabels];
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
    NodeInfo* info = selectedNode.userObject;
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

#pragma mark Populating menus

- (void) updateResolutionMenu
{
    if (!currentDocument) return;
    
    // Clear the menu
    [menuResolution removeAllItems];
    
    // Add all new resolutions
    int i = 0;
    for (ResolutionSetting* resolution in currentDocument.resolutions)
    {
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:resolution.name action:@selector(menuResolution:) keyEquivalent:[NSString stringWithFormat:@"%d",i+1]];
        item.target = self;
        item.tag = i;
        
        [menuResolution addItem:item];
        if (i == currentDocument.currentResolution) item.state = NSOnState;
        
        i++;
    }
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
    [dict setObject:[NSNumber numberWithInt:kCCBFileFormatVersion] forKey:@"fileVersion"];
    
    [dict setObject:[NSNumber numberWithBool:[g.cocosScene centeredOrigin]] forKey:@"centeredOrigin"];
    
    // Guides & notes
    [dict setObject:[[g cocosScene].guideLayer serializeGuides] forKey:@"guides"];
    [dict setObject:[[g cocosScene].notesLayer serializeNotes] forKey:@"notes"];
    
    // Resolutions
    if (doc.resolutions)
    {
        NSMutableArray* resolutions = [NSMutableArray array];
        for (ResolutionSetting* r in doc.resolutions)
        {
            [resolutions addObject:[r serialize]];
        }
        [dict setObject:resolutions forKey:@"resolutions"];
        [dict setObject:[NSNumber numberWithInt:doc.currentResolution] forKey:@"currentResolution"];
    }
    
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
    [self.window makeKeyWindow];
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
    CCBGlobals* g = [CCBGlobals globals];
    
    BOOL centered = [[doc objectForKey:@"centeredOrigin"] boolValue];
    
    // Setup stage & resolutions
    NSMutableArray* serializedResolutions = [doc objectForKey:@"resolutions"];
    if (serializedResolutions)
    {
        // Load resolutions
        NSMutableArray* resolutions = [NSMutableArray array];
        for (id serRes in serializedResolutions)
        {
            ResolutionSetting* resolution = [[[ResolutionSetting alloc] initWithSerialization:serRes] autorelease];
            [resolutions addObject:resolution];
        }
        int currentResolution = [[doc objectForKey:@"currentResolution"] intValue];
        ResolutionSetting* resolution = [resolutions objectAtIndex:currentResolution];
        
        // Update CocosScene
        [g.cocosScene setStageSize:CGSizeMake(resolution.width, resolution.height) centeredOrigin: centered];
        
        // Save in current document
        currentDocument.resolutions = resolutions;
        currentDocument.currentResolution = currentResolution;
    }
    else
    {
        // Support old files where the current width and height was stored
        int stageW = [[doc objectForKey:@"stageWidth"] intValue];
        int stageH = [[doc objectForKey:@"stageHeight"] intValue];
        
        [g.cocosScene setStageSize:CGSizeMake(stageW, stageH) centeredOrigin:centered];
        
        // Setup a basic resolution and attach it to the current document
        ResolutionSetting* resolution = [[[ResolutionSetting alloc] init] autorelease];
        resolution.width = stageW;
        resolution.height = stageH;
        resolution.centeredOrigin = centered;
        
        NSMutableArray* resolutions = [NSMutableArray arrayWithObject:resolution];
        currentDocument.resolutions = resolutions;
        currentDocument.currentResolution = 0;
    }
    [self updateResolutionMenu];
    
    ResolutionSetting* resolution = [currentDocument.resolutions objectAtIndex:currentDocument.currentResolution];
    
    // Process contents
    CCNode* loadedRoot = [CCBReaderInternal nodeGraphFromDocumentDictionary:doc parentSize:CGSizeMake(resolution.width, resolution.height)];
    
    // Replace open document
    selectedNode = NULL;
    [g.cocosScene replaceRootNodeWith:loadedRoot];
    [outlineHierarchy reloadData];
    [self updateOutlineViewSelection];
    [self updateInspectorFromSelection];
    
    [self updateExpandedForNode:g.rootNode];
    
    // Setup guides
    id guides = [doc objectForKey:@"guides"];
    if (guides)
    {
        [g.cocosScene.guideLayer loadSerializedGuides:guides];
    }
    else
    {
        [g.cocosScene.guideLayer removeAllGuides];
    }
    
    // Setup notes
    id notes = [doc objectForKey:@"notes"];
    if (notes)
    {
        [g.cocosScene.notesLayer loadSerializedNotes:notes];
    }
    else
    {
        [g.cocosScene.notesLayer removeAllNotes];
    }
}

- (void) switchToDocument:(CCBDocument*) document forceReload:(BOOL)forceReload
{
    if (!forceReload && [document.fileName isEqualToString:currentDocument.fileName]) return;
    
    [self prepareForDocumentSwitch];
    
    self.currentDocument = document;
    
    NSMutableDictionary* doc = document.docData;
    
    [self replaceDocumentData:doc];
    
    [self updateResolutionMenu];
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
    [g.cocosScene.guideLayer removeAllGuides];
    [g.cocosScene.notesLayer removeAllNotes];
    [g.cocosScene.rulerLayer mouseExited:NULL];
    self.currentDocument = NULL;
    
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

- (void) checkForTooManyDirectoriesInCurrentDoc
{
    if (!currentDocument) return;
    
    if ([ResourceManager sharedManager].tooManyDirectoriesAdded)
    {
        // Close document if it has too many sub directories
        NSTabViewItem* item = [self tabViewItemFromDoc:currentDocument];
        [tabView removeTabViewItem:item];
        
        [ResourceManager sharedManager].tooManyDirectoriesAdded = NO;
        
        // Notify the user
        [[[CCBGlobals globals] appDelegate] modalDialogTitle:@"Too Many Directories" message:@"You have created or opened a file which is in a directory with very many sub directories. Please save your ccb-files in a directory together with the resources you use in your project."];
    }
}

- (BOOL) createProject:(NSString*) fileName
{
    // Create a default project
    ProjectSettings* settings = [[[ProjectSettings alloc] init] autorelease];
    settings.projectPath = fileName;
    return [settings store];
}

- (void) updateResourcePathsFromProjectSettings
{
    [resManager removeAllDirectories];
    
    // Setup links to directories
    for (NSString* dir in [projectSettings absoluteResourcePaths])
    {
        [resManager addDirectory:dir];
    }
    [[ResourceManager sharedManager] setActiveDirectories:[projectSettings absoluteResourcePaths]];
}

- (void) closeProject
{
    while ([tabView numberOfTabViewItems] > 0)
    {
        NSTabViewItem* item = [self tabViewItemFromDoc:currentDocument];
        if (!item) return;
        
        if ([self tabView:tabView shouldCloseTabViewItem:item])
        {
            [tabView removeTabViewItem:item];
        }
        else
        {
            // Aborted close project
            return;
        }
    }
    
    // Remove resource paths
    self.projectSettings = NULL;
    [resManager removeAllDirectories];
}

- (void) openProject:(NSString*) fileName
{
    // TODO: Close currently open project
    [self closeProject];
    
    // Add to recent list of opened documents
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL fileURLWithPath:fileName]];
    
    NSMutableDictionary* projectDict = [NSMutableDictionary dictionaryWithContentsOfFile:fileName];
    if (!projectDict)
    {
        [self modalDialogTitle:@"Invalid Project File" message:@"Failed to open the project. File may be missing or invalid."];
        return;
    }
    
    ProjectSettings* project = [[[ProjectSettings alloc] initWithSerialization:projectDict] autorelease];
    if (!project)
    {
        [self modalDialogTitle:@"Invalid Project File" message:@"Failed to open the project. File is invalid or is created with a newer version of CocosBuilder."];
        return;
    }
    project.projectPath = fileName;
    
    self.projectSettings = project;
    
    [self updateResourcePathsFromProjectSettings];
}

- (void) openFile:(NSString*) fileName
{
	[[[CCDirector sharedDirector] view] lockOpenGLContext];
    
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
    
    [self switchToDocument:newDoc];
     
    [self addDocument:newDoc];
    self.hasOpenedDocument = YES;
    
    [self checkForTooManyDirectoriesInCurrentDoc];
    
	[[[CCDirector sharedDirector] view] unlockOpenGLContext];
}

- (void) saveFile:(NSString*) fileName
{
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

- (void) newFile:(NSString*) fileName type:(NSString*)type resolutions: (NSMutableArray*) resolutions;
{
    BOOL origin = NO;
    ResolutionSetting* resolution = [resolutions objectAtIndex:0];
    CGSize stageSize = CGSizeMake(resolution.width, resolution.height);
    
    // Close old doc if neccessary
    CCBDocument* oldDoc = [self findDocumentFromFile:fileName];
    if (oldDoc)
    {
        NSTabViewItem* item = [self tabViewItemFromDoc:oldDoc];
        if (item) [tabView removeTabViewItem:item];
    }
    
    [self prepareForDocumentSwitch];
    
    CCBGlobals* g = [CCBGlobals globals];
    [g.cocosScene.notesLayer removeAllNotes];
    
    selectedNode = NULL;
    [g.cocosScene setStageSize:stageSize centeredOrigin:origin];
    
    [g.cocosScene replaceRootNodeWith:[[PlugInManager sharedManager] createDefaultNodeOfType:type]];
    
    [outlineHierarchy reloadData];
    [self updateOutlineViewSelection];
    [self updateInspectorFromSelection];
    
    self.currentDocument = [[[CCBDocument alloc] init] autorelease];
    self.currentDocument.resolutions = resolutions;
    self.currentDocument.currentResolution = 0;
    [self updateResolutionMenu];
    
    [self saveFile:fileName];
    
    [self addDocument:currentDocument];
    
    self.hasOpenedDocument = YES;
    
    [self updateStateOriginCenteredMenu];
    
    [[g cocosScene] setStageZoom:1];
    [[g cocosScene] setScrollOffset:ccp(0,0)];
    
    [self checkForTooManyDirectoriesInCurrentDoc];
}

- (BOOL) application:(NSApplication *)sender openFile:(NSString *)filename
{
    [self openProject:filename];
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

- (BOOL) addCCObject:(CCNode *)obj toParent:(CCNode*)parent atIndex:(int)index
{
    if (!obj || !parent) return NO;
    
    NodeInfo* nodeInfoParent = parent.userObject;
    NodeInfo* nodeInfo = obj.userObject;
    
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
    
    // Add object and change zOrder of objects after this child
    if (index == -1)
    {
        // Add at end of array
        [parent addChild:obj z:[parent.children count]];
    }
    else
    {
        // Update zValues of children after this node
        CCArray* children = parent.children;
        for (int i = index; i < [children count]; i++)
        {
            CCNode* child = [children objectAtIndex:i];
            child.zOrder += 1;
        }
        [parent addChild:obj z:index];
        [parent sortAllChildren];
    }
    
    [outlineHierarchy reloadData];
    [self setSelectedNode:obj];
    [self updateInspectorFromSelection];
    
    return YES;
}

- (BOOL) addCCObject:(CCNode *)obj toParent:(CCNode *)parent
{
    return [self addCCObject:obj toParent:parent atIndex:-1];
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
    NodeInfo* info = parent.userObject;
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
        [PositionPropertySetter setPosition:pt forNode:node prop:@"position"];
        
        [CCBReaderInternal setProp:prop ofType:@"SpriteFrame" toValue:[NSArray arrayWithObjects:spriteSheetFile, spriteFile, nil] forNode:node parentSize:CGSizeZero];
        
        [self addCCObject:node toParent:parent];
    }
}

- (void) dropAddSpriteNamed:(NSString*)spriteFile inSpriteSheet:(NSString*)spriteSheetFile at:(CGPoint)pt
{
    // Sprite dropped in working canvas
    
    CCNode* node = selectedNode;
    if (!node) node = [[CCBGlobals globals] cocosScene].rootNode;
    
    CCNode* parent = node.parent;
    NodeInfo* info = parent.userObject;
    
    if (info.plugIn.acceptsDroppedSpriteFrameChildren)
    {
        [self dropAddSpriteNamed:spriteFile inSpriteSheet:spriteSheetFile at:[parent convertToNodeSpace:pt] parent:parent];
        return;
    }
    
    info = node.userObject;
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
        
        CGSize parentSize;
        if (asChild) parentSize = selectedNode.contentSize;
        else parentSize = selectedNode.parent.contentSize;
        
        CCNode* clipNode = [CCBReaderInternal nodeGraphFromDictionary:clipDict parentSize:parentSize];
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
    
    // Change zOrder of nodes after this one
    int zOrder = node.zOrder;
    CCArray* siblings = [node.parent children];
    for (int i = zOrder+1; i < [siblings count]; i++)
    {
        CCNode* sibling = [siblings objectAtIndex:i];
        sibling.zOrder -= 1;
    }
    
    [node removeFromParentAndCleanup:YES];
    
    [node.parent sortAllChildren];
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
    CGPoint newPos = ccpAdd([PositionPropertySetter positionForNode:selectedNode prop:@"position"], delta);
    [PositionPropertySetter setPosition:newPos forNode:selectedNode prop:@"position"];
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
    CGPoint newPos = ccpAdd([PositionPropertySetter positionForNode:selectedNode prop:@"position"], delta);
    [PositionPropertySetter setPosition:newPos forNode:selectedNode prop:@"position"];
    [self refreshProperty:@"position"];
}

- (IBAction) saveDocumentAs:(id)sender
{
    if (!currentDocument) return;
    
    NSSavePanel* saveDlg = [NSSavePanel savePanel];
    [saveDlg setAllowedFileTypes:[NSArray arrayWithObject:@"ccb"]];
    SavePanelLimiter* limter = [[SavePanelLimiter alloc] initWithPanel:saveDlg resManager:resManager];
    
    [saveDlg beginSheetModalForWindow:window completionHandler:^(NSInteger result){
        if (result == NSOKButton)
        {
            [[[CCDirector sharedDirector] view] lockOpenGLContext];
            
            // Save file to new path
            [self saveFile:[[saveDlg URL] path]];
            
            // Close document
            [tabView removeTabViewItem:[self tabViewItemFromDoc:currentDocument]];
            
            // Open newly created document
            [self openFile:[[saveDlg URL] path]];
            
            [[[CCDirector sharedDirector] view] unlockOpenGLContext];
        }
        [limter release];
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

- (IBAction) menuPublishProject:(id)sender
{
    CCBWarnings* warnings = [[[CCBWarnings alloc] init] autorelease];
    
    CCBPublisher* publisher = [[CCBPublisher alloc] initWithProjectSettings:projectSettings warnings:warnings];
    [publisher publish];
    
    // Create warnings window if it is not already created
    if (!publishWarningsWindow)
    {
        publishWarningsWindow = [[WarningsWindow alloc] initWithWindowNibName:@"WarningsWindow"];
    }
    
    // Update and show warnings window
    publishWarningsWindow.warnings = warnings;
    [[publishWarningsWindow window] setIsVisible:YES];
}

- (IBAction) menuPublishProjectAndRun:(id)sender
{
    
}

// Temporary utility function until new publish system is in place
- (IBAction)publishDirectory:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    
    [openDlg beginSheetModalForWindow:window completionHandler:^(NSInteger result){
        if (result == NSOKButton)
        {
            [[[CCDirector sharedDirector] view] lockOpenGLContext];
            
            NSArray* files = [openDlg URLs];
            
            for (int i = 0; i < [files count]; i++)
            {
                NSString* dirName = [[files objectAtIndex:i] path];
                
                NSArray* arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirName error:NULL];
                for(NSString* file in arr)
                {
                    if ([file hasSuffix:@".ccb"])
                    {
                        NSString* absPath = [dirName stringByAppendingPathComponent:file];
                        [self openFile:absPath];
                        [self saveFile:absPath];
                        //[self publishDocument:NULL];
                        [self menuCloseDocument:sender];
                    }
                }
            }
            
            [[[CCDirector sharedDirector] view] unlockOpenGLContext];
        }
    }];
}

- (IBAction) menuProjectSettings:(id)sender
{
    if (!currentDocument) return;
    
    ProjectSettingsWindow* wc = [[[ProjectSettingsWindow alloc] initWithWindowNibName:@"ProjectSettingsWindow"] autorelease];
    wc.projectSettings = self.projectSettings;
    
    int success = [wc runModalSheetForWindow:window];
    if (success)
    {
        [self.projectSettings store];
        [self updateResourcePathsFromProjectSettings];
        [self reloadResources];
    }
}

- (IBAction) openDocument:(id)sender
{
    // Create the File Open Dialog
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setAllowedFileTypes:[NSArray arrayWithObject:@"ccbproj"]];
    
    [openDlg beginSheetModalForWindow:window completionHandler:^(NSInteger result){
        if (result == NSOKButton)
        {
            NSArray* files = [openDlg URLs];
            
            for (int i = 0; i < [files count]; i++)
            {
                NSString* fileName = [[files objectAtIndex:i] path];
                [self openProject:fileName];
            }
        }
    }];
}

- (IBAction) menuCloseProject:(id)sender
{
    [self closeProject];
}

- (IBAction) menuNewProject:(id)sender
{
    // Accepted create document, prompt for place for file
    NSSavePanel* saveDlg = [NSSavePanel savePanel];
    [saveDlg setAllowedFileTypes:[NSArray arrayWithObject:@"ccbproj"]];
    
    [saveDlg beginSheetModalForWindow:window completionHandler:^(NSInteger result){
        if (result == NSOKButton)
        {
            NSString* fileName = [[saveDlg URL] path];
            if ([self createProject: fileName])
            {
                [self openProject:fileName];
            }
            else
            {
                [self modalDialogTitle:@"Failed to Create Project" message:@"Failed to create the project, make sure you are saving it to a writable directory."];
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
        
#warning FIX
        SavePanelLimiter* limiter = [[SavePanelLimiter alloc] initWithPanel:saveDlg resManager:resManager];
        
        [saveDlg beginSheetModalForWindow:window completionHandler:^(NSInteger result){
            if (result == NSOKButton)
            {
                [self newFile:[[saveDlg URL] path] type:wc.rootObjectType resolutions:wc.availableResolutions];
            }
            [wc release];
            [limiter release];
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

- (void) setResolution:(int)r
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
    ResolutionSetting* resolution = [currentDocument.resolutions objectAtIndex:r];
    currentDocument.currentResolution = r;
    
    [cs setStageSize:CGSizeMake(resolution.width, resolution.height) centeredOrigin:[cs centeredOrigin]];
    
    [self updateResolutionMenu];
    [self reloadResources];
    
    // Update size of root node
    [PositionPropertySetter refreshAllPositions];
}

- (IBAction) menuEditResolutionSettings:(id)sender
{
    if (!currentDocument) return;
    
    ResolutionSettingsWindow* wc = [[[ResolutionSettingsWindow alloc] initWithWindowNibName:@"ResolutionSettingsWindow"] autorelease];
    [wc copyResolutions: currentDocument.resolutions];
    
    int success = [wc runModalSheetForWindow:window];
    if (success)
    {
        currentDocument.resolutions = wc.resolutions;
        [self updateResolutionMenu];
        [self setResolution:0];
    }
}

- (IBAction)menuResolution:(id)sender
{
    if (!currentDocument) return;
    
    [self setResolution:(int)[sender tag]];
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
    
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
    
    [self switchToDocument:currentDocument forceReload:YES];
}

- (IBAction) menuAlignChildren:(id)sender
{
#warning TODO: Fix with new position types
    if (!currentDocument) return;
    if (!selectedNode) return;
    
    // Check if node can have children
    NodeInfo* info = selectedNode.userObject;
    PlugInNode* plugIn = info.plugIn;
    if (!plugIn.canHaveChildren) return;
    
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

- (IBAction)menuAddStickyNote:(id)sender
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setStageZoom:1];
    self.showStickyNotes = YES;
    [cs.notesLayer addNote];
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

- (IBAction) debug:(id)sender
{
    NSLog(@"DEBUG");
    
    NSLog(@"currentDocument.resolutions: %@",currentDocument.resolutions);
}

@end
