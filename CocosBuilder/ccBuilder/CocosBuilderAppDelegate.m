//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import "CocosBuilderAppDelegate.h"
#import "CocosScene.h"
#import "NSFlippedView.h"
#import "CCBGlobals.h"
#import "cocos2d.h"
#import "CCBWriter.h"
#import "CCBReader.h"
#import "CCBDocument.h"
#import "NewDocWindowController.h"
#import "CCBSpriteSheetParser.h"
#import "CCBUtil.h"
#import "StageSizeWindow.h"
#import "AssetsWindowController.h"
#import "TemplateWindowController.h"
#import "PlugInManager.h"
#import "InspectorPosition.h"

#import <ExceptionHandling/NSExceptionHandler.h>

@implementation CocosBuilderAppDelegate

@synthesize window, assestsImgList, assetsImgListFiles, assetsFontList, assetsSpriteSheetList, assetsTemplates, currentDocument, assetsPath, cocosView, canEditContentSize, canEditCustomClass, hasOpenedDocument, defaultCanvasSize;

#pragma mark Setup functions

- (void) setupInspectorPane
{
    [NSBundle loadNibNamed:@"InspectorNodeView" owner:self];
    [NSBundle loadNibNamed:@"InspectorLayerView" owner:self];
    [NSBundle loadNibNamed:@"InspectorSpriteView" owner:self];
    [NSBundle loadNibNamed:@"InspectorMenuItemView" owner:self];
    [NSBundle loadNibNamed:@"InspectorMenuItemImageView" owner:self];
    [NSBundle loadNibNamed:@"InspectorParticleSystemView" owner:self];
    [NSBundle loadNibNamed:@"InspectorLayerColorView" owner:self];
    [NSBundle loadNibNamed:@"InspectorLayerGradientView" owner:self];
    [NSBundle loadNibNamed:@"InspectorLabelTTFView" owner:self];
    [NSBundle loadNibNamed:@"InspectorLabelBMFontView" owner:self];
    [NSBundle loadNibNamed:@"InspectorButtonView" owner:self];
    
    inspectorDocumentView = [[NSFlippedView alloc] initWithFrame:NSMakeRect(0, 0, 233, 239+239+121)];
    [inspectorDocumentView setAutoresizesSubviews:YES];
    
    [inspectorDocumentView addSubview:inspectorNodeView];
    [inspectorDocumentView addSubview:inspectorLayerView];
    [inspectorDocumentView addSubview:inspectorSpriteView];
    [inspectorDocumentView addSubview:inspectorMenuItemView];
    [inspectorDocumentView addSubview:inspectorMenuItemImageView];
    [inspectorDocumentView addSubview:inspectorParticleSystemView];
    [inspectorDocumentView addSubview:inspectorLayerColorView];
    [inspectorDocumentView addSubview:inspectorLayerGradientView];
    [inspectorDocumentView addSubview:inspectorLabelTTFView];
    [inspectorDocumentView addSubview:inspectorLabelBMFontView];
    [inspectorDocumentView addSubview:inspectorButtonView];
    
    [inspectorNodeView setAutoresizingMask:NSViewNotSizable];
    [inspectorLayerView setAutoresizingMask:NSViewNotSizable];
    [inspectorSpriteView setAutoresizingMask:NSViewNotSizable];
    [inspectorMenuItemView setAutoresizingMask:NSViewNotSizable];
    [inspectorMenuItemImageView setAutoresizingMask:NSViewNotSizable];
    [inspectorParticleSystemView setAutoresizingMask:NSViewNotSizable];
    [inspectorLayerColorView setAutoresizingMask:NSViewNotSizable];
    [inspectorLayerGradientView setAutoresizingMask:NSViewNotSizable];
    [inspectorLabelTTFView setAutoresizingMask:NSViewNotSizable];
    [inspectorLabelBMFontView setAutoresizingMask:NSViewNotSizable];
    [inspectorButtonView setAutoresizingMask:NSViewNotSizable];
    
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
}

- (void) setupTabBar
{
    // Create tabView
    tabView = [[NSTabView alloc] initWithFrame:NSMakeRect(0, 0, 500, 30)];//kPSMTabBarControlHeight)];
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
    
    //[tabBar retain];
    //[tabBar removeFromSuperview];
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

- (void) setupTemplateWindow
{
    templateWindowController = [[TemplateWindowController alloc] initWithWindowNibName:@"TemplateWindow"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[CCBGlobals globals] setAppDelegate:self];
    
    [[NSExceptionHandler defaultExceptionHandler] setExceptionHandlingMask: NSLogUncaughtExceptionMask | NSLogUncaughtSystemExceptionMask | NSLogUncaughtRuntimeErrorMask];
    
    defaultCanvasSizes[kCCBCanvasSizeIPhoneLandscape] = CGSizeMake(480, 320);
    defaultCanvasSizes[kCCBCanvasSizeIPhonePortrait] = CGSizeMake(320, 480);
    defaultCanvasSizes[kCCBCanvasSizeIPadLandscape] = CGSizeMake(1024, 768);
    defaultCanvasSizes[kCCBCanvasSizeIPadPortrait] = CGSizeMake(768, 1024);
    
    //DMTracker *tracker = [DMTracker defaultTracker];
    //[tracker startApp];
    [window setDelegate:self];
    
    [self setupTabBar];
    [self setupDefaultDocument];
    [self setupInspectorPane];
    [self setupCocos2d];
    [self setupOutlineView];
    [self updateInspectorFromSelection];
    [self setupAssetsWindow];
    [self setupTemplateWindow];
    [self updateAssetsView];
    
    [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setStageBorder:0];
    [self updateCanvasBorderMenu];
    
    NSLog(@"Load PlugIns!");
    PlugInManager* pim = [PlugInManager sharedManager];
    [pim loadPlugIns];
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
        //[outlineHierarchy expandItem:node.parent];
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
    
    //NSMutableArray* children = [item objectForKey:@"children"];
    //return [children count];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if (item == nil) return YES;
    
    CCNode* node = (CCNode*)item;
    CCArray* arr = [node children];
    
    return ([arr count] > 0 &&
            ![item isKindOfClass:[CCMenuItemImage class]] &&
            ![item isKindOfClass:[CCLabelBMFont class]]);
    
    //NSMutableArray* children = [item objectForKey:@"children"];
    //return ([children count] > 0);
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    CCBGlobals* g= [CCBGlobals globals];
    
    if (item == nil) return g.rootNode;
    
    CCNode* node = (CCNode*)item;
    CCArray* arr = [node children];
    return [arr objectAtIndex:index];
    
    
    //NSMutableArray* children = [item objectForKey:@"children"];
    //return [children objectAtIndex:index];
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
    
    // Get class name
    NSString* className = @"";
    NSString* customClass = [cs extraPropForKey:@"customClass" andNode:item];
    if (customClass && ![customClass isEqualToString:@""]) className = customClass;
    else if ([item isKindOfClass:[CCParticleSystem class]]) className = @"CCParticleSystem";
    else className = NSStringFromClass([item class]);
    
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
    CocosScene* cs = [g cocosScene];
    
    CCNode* draggedNode = [items objectAtIndex:0];
    if (draggedNode == g.rootNode) return NO;
    
    NSMutableDictionary* clipDict = [CCBWriter dictionaryFromCCObject:draggedNode extraProps:[cs extraPropsDict]];
    
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
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    NSPasteboard* pb = [info draggingPasteboard];
    
    NSData* clipData = [pb dataForType:@"com.cocosbuilder.node"];
    if (clipData)
    {
        NSMutableDictionary* clipDict = [NSKeyedUnarchiver unarchiveObjectWithData:clipData];
        
        CCNode* clipNode = [CCBReader ccObjectFromDictionary:clipDict extraProps:[cs extraPropsDict] assetsDir:assetsPath owner:NULL];
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
    clipData = [pb dataForType:@"com.cocosbuilder.template"];
    if (clipData)
    {
        NSDictionary* clipDict = [NSKeyedUnarchiver unarchiveObjectWithData:clipData];
        
        //[self dropAddSpriteName
        [self dropAddTemplateNamed:[clipDict objectForKey:@"templateFile"] at:ccp(0,0) parent:item];
        
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

- (int) addInspectorPane:(NSView*)pane offset:(int)offset
{
    NSRect frame = [pane frame];
    [pane setFrame:NSMakeRect(0, offset, frame.size.width, frame.size.height)];
    [pane setHidden:NO];
    return offset+frame.size.height;
}

/*
- (NSString*) stringWithInt:(int)n
{
    return [NSString stringWithFormat:@"%d", n];
}
 */

- (void) populateProperty:(NSString*) propName
{
    [self willChangeValueForKey:propName];
    [self didChangeValueForKey:propName];
}

- (void) populateInspectorNodeView
{
    /*
    self.pCustomClass = self.pCustomClass;
    self.pMemberVarAssignmentType = self.pMemberVarAssignmentType;
    self.pMemberVarAssignmentName = self.pMemberVarAssignmentName;
    
    self.pPositionX = self.pPositionX;
    self.pPositionY = self.pPositionY;
    self.pContentSizeW = self.pContentSizeW;
    self.pContentSizeH = self.pContentSizeH;
    self.pAnchorPointX = self.pAnchorPointX;
    self.pAnchorPointY = self.pAnchorPointY;
    self.pLockedScaleRatio = self.pLockedScaleRatio;
    self.pScaleX = self.pScaleX;
    self.pScaleY = self.pScaleY;
    self.pRotation = self.pRotation;
    self.pZOrder = self.pZOrder;
    self.pTag = self.pTag;
    self.pRelativeToAnchorpoint = self.pRelativeToAnchorpoint;
    self.pVisible = self.pVisible;
    self.pLockedScaleRatio = self.pLockedScaleRatio;
     */
    
    [self populateProperty:@"pCustomClass"];
    [self populateProperty:@"pMemberVarAssignmentType"];
    [self populateProperty:@"pMemberVarAssignmentName"];
    
    [self populateProperty:@"pPositionX"];
    [self populateProperty:@"pPositionY"];
    [self populateProperty:@"pContentSizeW"];
    [self populateProperty:@"pContentSizeH"];
    [self populateProperty:@"pAnchorPointX"];
    [self populateProperty:@"pAnchorPointY"];
    [self populateProperty:@"pLockedScaleRatio"];
    [self populateProperty:@"pScaleX"];
    [self populateProperty:@"pScaleY"];
    [self populateProperty:@"pRotation"];
    [self populateProperty:@"pZOrder"];
    [self populateProperty:@"pTag"];
    [self populateProperty:@"pRelativeToAnchorpoint"];
    [self populateProperty:@"pVisible"];
    
    self.canEditContentSize = YES;
    self.canEditCustomClass = YES;
}

- (void) populateInspectorLayerView
{
    /*
    self.pTouchEnabled = self.pTouchEnabled;
    self.pAccelerometerEnabled = self.pAccelerometerEnabled;
    self.pMouseEnabled = self.pMouseEnabled;
    self.pKeyboardEnabled = self.pKeyboardEnabled;
     */
    
    [self populateProperty:@"pTouchEnabled"];
    [self populateProperty:@"pAccelerometerEnabled"];
    [self populateProperty:@"pMouseEnabled"];
    [self populateProperty:@"pKeyboardEnabled"];
    
    self.canEditContentSize = YES;
    self.canEditCustomClass = YES;
}

- (void) populateInspectorSpriteView
{
    /*
    self.assestsImgList = self.assestsImgList;
    self.assetsSpriteSheetList = self.assetsSpriteSheetList;
    
    int blendFuncSrc = self.pBlendFuncSrc;
    int blendFuncDst = self.pBlendFuncDst;
    
    NSString* spriteFile = self.pSpriteFile;
    self.pSpriteSheetFile = self.pSpriteSheetFile;
    self.pSpriteFile = spriteFile;
    self.pOpacity = self.pOpacity;
    self.pColor = self.pColor;
    self.pFlipX = self.pFlipX;
    self.pFlipY = self.pFlipY;
    self.pBlendFuncSrc = blendFuncSrc;
    self.pBlendFuncDst = blendFuncDst;
     */
    [self populateProperty:@"assestsImgList"];
    [self populateProperty:@"assetsSpriteSheetList"];
    
    [self populateProperty:@"pSpriteSheetFile"];
    if ([[self pSpriteSheetFile] isEqualToString:kCCBUseRegularFile])
    {
        self.assestsImgList = self.assetsImgListFiles;
    }
    else
    {
        self.assestsImgList = [CCBSpriteSheetParser listFramesInSheet:[self pSpriteSheetFile] assetsPath:assetsPath];
    }
    
    [self populateProperty:@"pSpriteFile"];
    [self populateProperty:@"pOpacity"];
    [self populateProperty:@"pColor"];
    [self populateProperty:@"pFlipX"];
    [self populateProperty:@"pFlipY"];
    [self populateProperty:@"blendFuncSrc"];
    [self populateProperty:@"pBlendFuncDst"];
    
    [inspectorSpriteName setEnabled:YES];
    self.canEditContentSize = NO;
    self.canEditCustomClass = NO;
}

- (void) populateInspectorLabelTTFView
{
    /*
    self.pString = self.pString;
    self.pFontName = self.pFontName;
    self.canEditContentSize = NO;
    */
    [self populateProperty:@"pString"];
    [self populateProperty:@"pFontName"];
    [self populateProperty:@"pFontSize"];
    [self populateProperty:@"canEditContentSize"];
    
    [inspectorSpriteName setEnabled:NO];
}

- (void) populateInspectorLabelBMFontView
{
    /*
    self.pColor = self.pColor;
    self.pOpacity = self.pOpacity;
    self.pString = self.pString;
    self.assetsFontList = self.assetsFontList;
    self.canEditContentSize = NO;
    */
    [self populateProperty:@"pColor"];
    [self populateProperty:@"pOpacity"];
    [self populateProperty:@"pString"];
    [self populateProperty:@"assetsFontList"];
    
    self.canEditContentSize = NO;
    self.canEditCustomClass = NO;
}

- (void) populateInspectorMenuItemView
{
    /*
    self.pIsEnabled = self.pIsEnabled;
    self.pSelector = self.pSelector;
    self.pTarget = self.pTarget;
    */
    
    [self populateProperty:@"pIsEnabled"];
    [self populateProperty:@"pSelector"];
    [self populateProperty:@"pTarget"];
    
    self.canEditContentSize = NO;
    self.canEditCustomClass = NO;
    //[inspectorSpriteName setValue:self.pSpriteFile];
}

- (void) populateInspectorMenuItemImageView
{
    /*
    self.assestsImgList = self.assestsImgList;
    self.assetsSpriteSheetList = self.assetsSpriteSheetList;
    //self.pSpriteSheetFile = self.pSpriteSheetFile;
    
    NSString* spriteFileNormal = self.pSpriteFileNormal;
    NSString* spriteFileSelected = self.pSpriteFileSelected;
    NSString* spriteFileDisabled = self.pSpriteFileDisabled;
    self.pSpriteSheetFile = self.pSpriteSheetFile;
    self.pSpriteFileNormal = spriteFileNormal;
    self.pSpriteFileSelected = spriteFileSelected;
    self.pSpriteFileDisabled = spriteFileDisabled;
    */
    [self populateProperty:@"assestsImgList"];
    [self populateProperty:@"assetsSpriteSheetList"];
    
    [self populateProperty:@"pSpriteSheetFile"];
    if ([[self pSpriteSheetFile] isEqualToString:kCCBUseRegularFile])
    {
        self.assestsImgList = self.assetsImgListFiles;
    }
    else
    {
        self.assestsImgList = [CCBSpriteSheetParser listFramesInSheet:[self pSpriteSheetFile] assetsPath:assetsPath];
    }
    
    //[self populateProperty:@"pSpriteSheetFile"];
    [self populateProperty:@"pSpriteFileNormal"];
    [self populateProperty:@"pSpriteFileSelected"];
    [self populateProperty:@"pSpriteFileDisabled"];
    
    
    self.canEditContentSize = NO;
    self.canEditCustomClass = YES;
    //[inspectorSpriteName setValue:self.pSpriteFile];
}

- (void) populateInspectorParticleSystemViewForCurrentMode
{
    /*
    self.pGravityX = self.pGravityX;
    self.pDirection = self.pDirection;
    self.pDirectionVar = self.pDirectionVar;
    self.pSpeed = self.pSpeed;
    self.pSpeedVar = self.pSpeedVar;
    self.pTangAcc = self.pTangAcc;
    self.pTangAccVar = self.pTangAccVar;
    self.pRadialAcc = self.pRadialAcc;
    self.pRadialAccVar = self.pRadialAccVar;
    
    self.pStartRadius = self.pStartRadius;
    self.pStartRadiusVar = self.pStartRadiusVar;
    self.pEndRadius = self.pEndRadius;
    self.pEndRadiusVar = self.pEndRadiusVar;
    self.pRotate = self.pRotate;
    self.pRotateVar = self.pRotateVar;
     */
    
    [self populateProperty:@"pGravityX"];
    [self populateProperty:@"pGravityY"];
    [self populateProperty:@"pDirection"];
    [self populateProperty:@"pDirectionVar"];
    [self populateProperty:@"pSpeed"];
    [self populateProperty:@"pSpeedVar"];
    [self populateProperty:@"pTangAcc"];
    [self populateProperty:@"pTangAccVar"];
    [self populateProperty:@"pRadialAcc"];
    [self populateProperty:@"pRadialAccVar"];
    
    [self populateProperty:@"pStartRadius"];
    [self populateProperty:@"pStartRadiusVar"];
    [self populateProperty:@"pEndRadius"];
    [self populateProperty:@"pEndRadiusVar"];
    [self populateProperty:@"pRotate"];
    [self populateProperty:@"pRotateVar"];
}

- (void) populateInspectorParticleSystemView
{
    /*
    self.assestsImgList = self.assestsImgList;
    
    self.pEmitterMode = self.pEmitterMode;
    self.pNumParticles = self.pNumParticles;
    self.pLife = self.pLife;
    self.pLifeVar = self.pLifeVar;
    self.pStartSize = self.pStartSize;
    self.pStartSizeVar = self.pStartSizeVar;
    self.pEndSize = self.pEndSize;
    self.pEndSizeVar = self.pEndSizeVar;
    self.pStartSpin = self.pStartSpin;
    self.pStartSpinVar = self.pStartSpinVar;
    self.pEndSpin = self.pEndSpin;
    self.pEndSpinVar = self.pEndSpinVar;
    self.pStartColor = self.pStartColor;
    self.pStartColorVar = self.pStartColorVar;
    self.pEndColor = self.pEndColor;
    self.pEndColorVar = self.pEndColorVar;
    self.pBlendFuncSrc = self.pBlendFuncSrc;
    self.pBlendFuncDst = self.pBlendFuncDst;
    
    self.pEmissionRate = self.pEmissionRate;
    self.pDuration = self.pDuration;
    self.pPosVarX = self.pPosVarX;
    self.pPosVarY = self.pPosVarY;
    */
    
    self.assestsImgList = self.assetsImgListFiles;
    //[self populateProperty:@"assestsImgList"];
    
    [self populateProperty:@"pEmitterMode"];
    [self populateProperty:@"pNumParticles"];
    [self populateProperty:@"pLife"];
    [self populateProperty:@"pLifeVar"];
    [self populateProperty:@"pStartSize"];
    [self populateProperty:@"pStartSizeVar"];
    [self populateProperty:@"pEndSize"];
    [self populateProperty:@"pEndSizeVar"];
    [self populateProperty:@"pStartSpin"];
    [self populateProperty:@"pStartSpinVar"];
    [self populateProperty:@"pEndSpin"];
    [self populateProperty:@"pEndSpinVar"];
    [self populateProperty:@"pStartColor"];
    [self populateProperty:@"pStartColorVar"];
    [self populateProperty:@"pEndColor"];
    [self populateProperty:@"pEndColorVar"];
    [self populateProperty:@"pBlendFuncSrc"];
    [self populateProperty:@"pBlendFuncDst"];
    
    [self populateProperty:@"pEmissionRate"];
    [self populateProperty:@"pDuration"];
    [self populateProperty:@"pPosVarX"];
    [self populateProperty:@"pPosVarY"];
    
    int pEmitterMode = [self pEmitterMode];
    if (pEmitterMode == kCCParticleModeGravity)
    {
        [inspectorParticleSystemViewGravity setHidden:NO];
        [inspectorParticleSystemViewRadius setHidden:YES];
    }
    else
    {
        [inspectorParticleSystemViewGravity setHidden:YES];
        [inspectorParticleSystemViewRadius setHidden:NO];
    }
    
    [self populateInspectorParticleSystemViewForCurrentMode];
    
    self.canEditContentSize = NO;
    self.canEditCustomClass = NO;
}

- (void) populateInspectorLayerColorView
{
    /*
    self.pColor = self.pColor;
    self.pOpacity = self.pOpacity;
    self.pBlendFuncSrc = self.pBlendFuncSrc;
    self.pBlendFuncDst = self.pBlendFuncDst;
     */
    
    [self populateProperty:@"pColor"];
    [self populateProperty:@"pOpacity"];
    [self populateProperty:@"pBlendFuncSrc"];
    [self populateProperty:@"pBlendFuncDst"];
    
    self.canEditContentSize = YES;
    self.canEditCustomClass = NO;
}

- (void) populateInspectorLayerGradientView
{
    //self.pFadeColor = self.pFadeColor;
    
    [self populateProperty:@"pFadeColor"];
    
    self.canEditContentSize = YES;
    self.canEditCustomClass = NO;
}

- (void) populateInspectorTemplateNodeView
{
    self.canEditContentSize = NO;
    self.canEditCustomClass = NO;
}

- (void) populateInspectorButtonView
{
    [self populateProperty:@"pImageNameFormat"];

    
    self.canEditContentSize = NO;
    self.canEditCustomClass = YES;
}

- (void) populateInspectorSliceView
{
    [self populateProperty:@"pImageNameFormat"];
    
    
    self.canEditContentSize = YES;
    self.canEditCustomClass = YES;
}

- (void) populateInspectorViews
{
    if ([selectedNode isKindOfClass:[CCNode class]])
    {
        [self populateInspectorNodeView];
    }
    if ([selectedNode isKindOfClass:[CCLayer class]])
    {
        [self populateInspectorLayerView];
    }
    if ([selectedNode isKindOfClass:[CCSprite class]]
        && ![selectedNode isKindOfClass:[CCBTemplateNode class]])
    {
        [self populateInspectorSpriteView];
    }
    if ([selectedNode isKindOfClass:[CCMenuItem class]])
    {
        [self populateInspectorMenuItemView];
    }
    if ([selectedNode isKindOfClass:[CCMenuItemImage class]])
    {
        [self populateInspectorMenuItemImageView];
    }
    if ([selectedNode isKindOfClass:[CCParticleSystem class]])
    {
        [self populateInspectorParticleSystemView];
    }
    if ([selectedNode isKindOfClass:[CCLayerColor class]])
    {
        [self populateInspectorLayerColorView];
    }
    if ([selectedNode isKindOfClass:[CCLayerGradient class]])
    {
        [self populateInspectorLayerGradientView];
    }
    if ([selectedNode isKindOfClass:[CCLabelTTF class]])
    {
        [self populateInspectorLabelTTFView];
    }
    if ([selectedNode isKindOfClass:[CCLabelBMFont class]])
    {
        [self populateInspectorLabelBMFontView];
    }
    if ([selectedNode isKindOfClass:[CCBTemplateNode class]])
    {
        [self populateInspectorTemplateNodeView];
    }
    if ([selectedNode isKindOfClass:[CCButton class]])
    {
        [self populateInspectorButtonView];
    }
    if ([selectedNode isKindOfClass:[CCThreeSlice class]])
    {
        [self populateInspectorSliceView];
    }
}

- (void) updateInspectorFromSelection
{
    // Hide all inspector panes
    NSArray* panes = [inspectorDocumentView subviews];
    for (int i = 0; i < [panes count]; i++)
    {
        NSView* pane = [panes objectAtIndex:i];
        [pane setHidden:YES];
    }
    
    [inspectorDocumentView setFrameSize:NSMakeSize(233, 1)];
    int paneOffset = 0;
    
    // Add show panes according to selections
    if (!selectedNode) return;
    
    if ([selectedNode isKindOfClass:[CCNode class]])
    {
        paneOffset = [self addInspectorPane:inspectorNodeView offset:paneOffset];
    }
    if ([selectedNode isKindOfClass:[CCLayer class]])
    {
        paneOffset = [self addInspectorPane:inspectorLayerView offset:paneOffset];
    }
    if ([selectedNode isKindOfClass:[CCLayerColor class]])
    {
        paneOffset = [self addInspectorPane:inspectorLayerColorView offset:paneOffset];
    }
    if ([selectedNode isKindOfClass:[CCLayerGradient class]])
    {
        paneOffset = [self addInspectorPane:inspectorLayerGradientView offset:paneOffset];
    }
    if ([selectedNode isKindOfClass:[CCSprite class]]
        && ![selectedNode isKindOfClass:[CCBTemplateNode class]])
    {
        paneOffset = [self addInspectorPane:inspectorSpriteView offset:paneOffset];
    }
    if ([selectedNode isKindOfClass:[CCMenuItem class]])
    {
        paneOffset = [self addInspectorPane:inspectorMenuItemView offset:paneOffset];
    }
    if ([selectedNode isKindOfClass:[CCMenuItemImage class]])
    {
        paneOffset = [self addInspectorPane:inspectorMenuItemImageView offset:paneOffset];
    }
    if ([selectedNode isKindOfClass:[CCParticleSystem class]])
    {
        paneOffset = [self addInspectorPane:inspectorParticleSystemView offset:paneOffset];
    }
    if ([selectedNode isKindOfClass:[CCLabelTTF class]])
    {
        paneOffset = [self addInspectorPane:inspectorLabelTTFView offset:paneOffset];
    }
    if ([selectedNode isKindOfClass:[CCLabelBMFont class]])
    {
        paneOffset = [self addInspectorPane:inspectorLabelBMFontView offset:paneOffset];
    }
    if ([selectedNode isKindOfClass:[CCButton class]])
    {
        paneOffset = [self addInspectorPane:inspectorButtonView offset:paneOffset];
    }
    if ([selectedNode isKindOfClass:[CCThreeSlice class]])
    {
        paneOffset = [self addInspectorPane:inspectorButtonView offset:paneOffset];
    }
    
    
#warning Foo
    InspectorPosition* inspectorPos = [InspectorPosition inspectorWithSelection:selectedNode andPropertyName:@"position" andDisplayName:@"Position"];
    [NSBundle loadNibNamed:@"InspectorPosition" owner:inspectorPos];
    NSView* pane = inspectorPos.view;
    
    NSLog(@"pane=%@",pane);
    
    [inspectorDocumentView addSubview:pane];
    [pane setAutoresizingMask:NSViewNotSizable];
    
    NSRect frame = [pane frame];
    [pane setFrame:NSMakeRect(0, paneOffset, frame.size.width, frame.size.height)];
    
    NSLog(@"frame size: %f x %f (offset: %d)", frame.size.width, frame.size.height, paneOffset);
    //return offset+frame.size.height;
    paneOffset += frame.size.height;
    
    NSLog(@"paneOffset: %d",paneOffset);
    
    [inspectorDocumentView setFrameSize:NSMakeSize(233, paneOffset)];
    
    [self populateInspectorViews];
}

- (IBAction) updateSelectionFromInspector
{
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

#pragma mark Properties Code Connections

- (void)setPCustomClass:(NSString *)pCustomClass
{
    if (![self isSelectedNode]) return;
    [self saveUndoState];
    
    if (!pCustomClass) pCustomClass = @"";
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:pCustomClass forKey:@"customClass" andNode:selectedNode];
}

- (NSString*) pCustomClass
{
    if (![self isSelectedNode]) return @"";    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    NSString* cc = [cs extraPropForKey:@"customClass" andNode:selectedNode];
    if (cc) return cc;
    return @"";
}

- (void)setPMemberVarAssignmentName:(NSString *)pMemberVarAssignmentName
{
    if (![self isSelectedNode]) return;
    [self saveUndoState];
    if (!pMemberVarAssignmentName) pMemberVarAssignmentName = @"";
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:pMemberVarAssignmentName forKey:@"memberVarAssignmentName" andNode:selectedNode];
}

- (NSString*) pMemberVarAssignmentName
{
    if (![self isSelectedNode]) return @"";    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    NSString* cc = [cs extraPropForKey:@"memberVarAssignmentName" andNode:selectedNode];
    if (cc) return cc;
    return @"";
}

- (void) setPMemberVarAssignmentType:(int)pMemberVarAssignmentType
{
    if (![self isSelectedNode]) return;
    [self saveUndoState];
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:[NSNumber numberWithInt: pMemberVarAssignmentType] forKey:@"memberVarAssignmentType" andNode:selectedNode];
}

- (int) pMemberVarAssignmentType
{
    if (![self isSelectedNode]) return 0;    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [[cs extraPropForKey:@"memberVarAssignmentType" andNode:selectedNode] intValue];
}

#pragma mark Properties CCNode

- (void)setPPositionX:(float)positionX
{
    if (![self isSelectedNode]) return;
    if (currentDocument.lastOperationType != kCCBOperationTypePosition)
    {
        [self saveUndoState];
        currentDocument.lastOperationType = kCCBOperationTypePosition;
    }
    
    selectedNode.position = ccp(positionX, selectedNode.position.y);
}

- (float)pPositionX
{
    if (![self isSelectedNode]) return 0;
    return selectedNode.position.x;
}

- (void)setPPositionY:(float)positionY
{
    if (![self isSelectedNode]) return;
    if (currentDocument.lastOperationType != kCCBOperationTypePosition)
    {
        [self saveUndoState];
        currentDocument.lastOperationType = kCCBOperationTypePosition;
    }
    
    selectedNode.position = ccp(selectedNode.position.x, positionY);
}

- (float)pPositionY
{
    if (![self isSelectedNode]) return 0;
    return selectedNode.position.y;
}

- (void)setPContentSizeW:(float)pContentSizeW
{
    if (![self isSelectedNode]) return;
    [self saveUndoState];
    
    selectedNode.contentSize = CGSizeMake(pContentSizeW, selectedNode.contentSize.height);
}

- (float)pContentSizeW
{
    if (![self isSelectedNode]) return 0;
    return selectedNode.contentSize.width;
}

- (void)setPContentSizeH:(float)pContentSizeH
{
    if (![self isSelectedNode]) return;
    [self saveUndoState];
    
    selectedNode.contentSize = CGSizeMake(selectedNode.contentSize.width, pContentSizeH);
}

- (float)pContentSizeH
{
    if (![self isSelectedNode]) return 0;
    return selectedNode.contentSize.height;
}

- (void)setPAnchorPointX:(float)anchorPointX
{
    if (![self isSelectedNode]) return;
    [self saveUndoState];
    
    selectedNode.anchorPoint = ccp(anchorPointX, selectedNode.anchorPoint.y);
}

- (float)pAnchorPointX
{
    if (![self isSelectedNode]) return 0;
    return selectedNode.anchorPoint.x;
}

- (void)setPAnchorPointY:(float)anchorPointY
{
    if (![self isSelectedNode]) return;
    [self saveUndoState];
    
    selectedNode.anchorPoint = ccp(selectedNode.anchorPoint.x, anchorPointY);
}

- (float)pAnchorPointY
{
    if (![self isSelectedNode]) return 0;
    return selectedNode.anchorPoint.y;
}

- (void)setPScaleX:(float)scaleX
{
    if (![self isSelectedNode]) return;
    if (currentDocument.lastOperationType != kCCBOperationTypeScale)
    {
        [self saveUndoState];
        currentDocument.lastOperationType = kCCBOperationTypeScale;
    }
    
    selectedNode.scaleX = scaleX;
    if (lockedScaleRatio && self.pScaleX != self.pScaleY) self.pScaleY = scaleX;
}

- (float)pScaleX
{
    if (![self isSelectedNode]) return 0;
    return selectedNode.scaleX;
}

- (void)setPScaleY:(float)scaleY
{
    if (![self isSelectedNode]) return;
    if (currentDocument.lastOperationType != kCCBOperationTypeScale)
    {
        [self saveUndoState];
        currentDocument.lastOperationType = kCCBOperationTypeScale;
    }
    
    selectedNode.scaleY = scaleY;
    if (lockedScaleRatio && self.pScaleX != self.pScaleY) self.pScaleX = scaleY;
}

- (float)pScaleY
{
    if (![self isSelectedNode]) return 0;
    return selectedNode.scaleY;
}

- (BOOL)pLockedScaleRatio
{
    if (![self isSelectedNode]) return 0;
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [[cs extraPropForKey:@"lockedScaleRatio" andNode:selectedNode] boolValue];
}

- (void)setPLockedScaleRatio:(BOOL)pLockedScaleRatio
{
    if (![self isSelectedNode]) return;
    [self saveUndoState];
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:[NSNumber numberWithInt:pLockedScaleRatio] forKey:@"lockedScaleRatio" andNode:selectedNode];
    
    lockedScaleRatio = pLockedScaleRatio;
    if (lockedScaleRatio) self.pScaleY = self.pScaleX;
}

- (void)setPRotation:(float)pRotation
{
    if (![self isSelectedNode]) return;
    if (currentDocument.lastOperationType != kCCBOperationTypeRotate)
    {
        [self saveUndoState];
        currentDocument.lastOperationType = kCCBOperationTypeRotate;
    }
    
    selectedNode.rotation = pRotation;
}

- (float)pRotation
{
    if (![self isSelectedNode]) return 0;
    return selectedNode.rotation;
}

- (void)setPZOrder:(int)pZOrder
{
    if (![self isSelectedNode]) return;
    [self saveUndoState];
    
    CCNode* parent = selectedNode.parent;
    [parent reorderChild:selectedNode z:pZOrder];
}

- (int)pZOrder
{
    if (![self isSelectedNode]) return 0;
    return (int)selectedNode.zOrder;
}

- (void)setPTag:(int)pTag
{
    if (![self isSelectedNode]) return;
    [self saveUndoState];
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:[NSNumber numberWithInt:pTag] forKey:@"tag" andNode:selectedNode];
}

- (int)pTag
{
    if (![self isSelectedNode]) return 0;
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [[cs extraPropForKey:@"tag" andNode:selectedNode] intValue];
}

- (void)setPRelativeToAnchorpoint:(BOOL)pRelativeToAnchorpoint
{
    if (![self isSelectedNode]) return;
    [self saveUndoState];
    
    selectedNode.isRelativeAnchorPoint = pRelativeToAnchorpoint;
}

- (BOOL)pRelativeToAnchorpoint
{
    if (![self isSelectedNode]) return 0;
    return selectedNode.isRelativeAnchorPoint;
}

- (void)setPVisible:(BOOL)pVisible
{
    if (![self isSelectedNode]) return;
    [self saveUndoState];
    
    selectedNode.visible = pVisible;
}

- (BOOL)pVisible
{
    if (![self isSelectedNode]) return 0;
    return selectedNode.visible;
}

#pragma mark Properties Layer

- (void) setPTouchEnabled:(BOOL)pTouchEnabled
{
    if (![self isSelectedLayer]) return;
    [self saveUndoState];
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:[NSNumber numberWithInt:pTouchEnabled] forKey:@"touchEnabled" andNode:selectedNode];
}

- (BOOL) pTouchEnabled
{
    if (![self isSelectedLayer]) return NO;
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [[cs extraPropForKey:@"touchEnabled" andNode:selectedNode] boolValue];
}

- (void) setPAccelerometerEnabled:(BOOL)pAccelerometerEnabled
{
    if (![self isSelectedLayer]) return;
    [self saveUndoState];
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:[NSNumber numberWithInt:pAccelerometerEnabled] forKey:@"accelerometerEnabled" andNode:selectedNode];
}

- (BOOL) pAccelerometerEnabled
{
    if (![self isSelectedLayer]) return NO;
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [[cs extraPropForKey:@"accelerometerEnabled" andNode:selectedNode] boolValue];
}

- (void) setPMouseEnabled:(BOOL)pMouseEnabled
{
    if (![self isSelectedLayer]) return;
    [self saveUndoState];
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:[NSNumber numberWithInt:pMouseEnabled] forKey:@"mouseEnabled" andNode:selectedNode];
}

- (BOOL) pMouseEnabled
{
    if (![self isSelectedLayer]) return NO;
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [[cs extraPropForKey:@"mouseEnabled" andNode:selectedNode] boolValue];
}

- (void) setPKeyboardEnabled:(BOOL)pKeyboardEnabled
{
    if (![self isSelectedLayer]) return;
    [self saveUndoState];
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:[NSNumber numberWithInt:pKeyboardEnabled] forKey:@"keyboardEnabled" andNode:selectedNode];
}

- (BOOL) pKeyboardEnabled
{
    if (![self isSelectedLayer]) return NO;
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [[cs extraPropForKey:@"keyboardEnabled" andNode:selectedNode] boolValue];
}

#pragma mark Properties Sprite

- (void) setPSpriteFile:(NSString *)pSpriteFile
{
    if (![self isSelectedSprite] && ![self isSelectedParticleSystem]) return;
    if (!pSpriteFile) pSpriteFile = @"";
    [self saveUndoState];
    
    NSLog(@"setPSpriteFile: %@", selectedNode);
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:pSpriteFile forKey:@"spriteFile" andNode:selectedNode];
    
    NSString* sheet = [cs extraPropForKey:@"spriteSheetFile" andNode:selectedNode];
    BOOL useSheet = (sheet && ![sheet isEqualToString:@""] && ![sheet isEqualToString:kCCBUseRegularFile]);
    
    if (!useSheet || [self isSelectedParticleSystem])
    {
        NSString* fileName = [NSString stringWithFormat:@"%@%@", assetsPath, pSpriteFile];
        CCTexture2D* texture = [[CCTextureCache sharedTextureCache] addImage:fileName];
        if ([self isSelectedSprite])
        {
            if (!texture) texture = [[CCTextureCache sharedTextureCache] addImage:@"missing-texture.png"];
        }
        else
        {
            if (!texture) texture = [[CCTextureCache sharedTextureCache] addImage:@"missing-particle-texture.png"];
        }
        
        float texW = texture.contentSizeInPixels.width;
        float texH = texture.contentSizeInPixels.height;
        
        if ([self isSelectedSprite])
        {
            CCSprite* sprt = (CCSprite*)selectedNode;
            [sprt setTexture:texture];
            [sprt setTextureRect:CGRectMake(0, 0, texW, texH)];
            
            [self setPContentSizeW:texW];
            [self setPContentSizeH:texH];
        }
        else
        {
            CCParticleSystem* sys = (CCParticleSystem*)selectedNode;
            [sys setTexture:texture];
        }
    }
    else
    {
        CCSprite* sprt = (CCSprite*)selectedNode;
        
        // Use sprite sheet
        CCSpriteFrame* frame;
        @try {
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:pSpriteFile];
        }
        @catch (NSException *exception) {
            frame = NULL;
        }
        
        if (frame)
        {
            [sprt setDisplayFrame:frame];
        }
        else
        {
            // Set missing texture
            CCTexture2D* texture = [[CCTextureCache sharedTextureCache] addImage:@"missing-texture.png"];
            float texW = texture.contentSizeInPixels.width;
            float texH = texture.contentSizeInPixels.height;
            [sprt setTexture:texture];
            [sprt setTextureRect:CGRectMake(0, 0, texW, texH)];
            [self setPContentSizeW:texW];
            [self setPContentSizeH:texH];
        }
    }
}

- (NSString*) pSpriteFile
{
    if (![self isSelectedSprite] && ![self isSelectedParticleSystem]) return @"";
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    NSString* file = [cs extraPropForKey:@"spriteFile" andNode:selectedNode];
    if (!file) return @"";
    return file;
}

- (void) setPSpriteSheetFile:(NSString *)pSpriteSheetFile
{
    if (![self isSelectedSprite] && ![self isSelectedMenuItemImage]) return;
    if (!pSpriteSheetFile) pSpriteSheetFile = @"";
    [self saveUndoState];
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    NSString* oldSpriteSheet = [cs extraPropForKey:@"spriteSheetFile" andNode:selectedNode];
    if (!oldSpriteSheet) oldSpriteSheet = @"";
    [cs setExtraProp:pSpriteSheetFile forKey:@"spriteSheetFile" andNode:selectedNode];
    
    if ([pSpriteSheetFile isEqualToString:kCCBUseRegularFile])
    {
        self.assestsImgList = self.assetsImgListFiles;
    }
    else
    {
        self.assestsImgList = [CCBSpriteSheetParser listFramesInSheet:pSpriteSheetFile assetsPath:assetsPath];
    }
    
    if (![oldSpriteSheet isEqualToString:pSpriteSheetFile])
    {
        if ([self isSelectedSprite])
        {
            // Changed sprite sheets, remove sprite
            [self setPSpriteFile:@""];
        }
        else if ([self isSelectedMenuItemImage])
        {
            [self setPSpriteFileNormal:@""];
            [self setPSpriteFileSelected:@""];
            [self setPSpriteFileDisabled:@""];
        }
    }
}

- (NSString*) pSpriteSheetFile
{
    if (![self isSelectedSprite] && ![self isSelectedMenuItemImage]) return kCCBUseRegularFile;
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    NSString* file = [cs extraPropForKey:@"spriteSheetFile" andNode:selectedNode];
    if (!file) return kCCBUseRegularFile;
    return file;
}

- (void)setPOpacity:(int)pOpacity
{
    if ([self isSelectedSprite])
    {
        [self saveUndoState];
        
        CCSprite* sprt = (CCSprite*)selectedNode;
        sprt.opacity = pOpacity;
    }
    else if ([self isSelectedLabelBMFont])
    {
        [self saveUndoState];
        
        CCLabelBMFont* lbl = (CCLabelBMFont*)selectedNode;
        lbl.opacity = pOpacity;
    }
}

- (int)pOpacity
{
    if ([self isSelectedSprite])
    {
        CCSprite* sprt = (CCSprite*)selectedNode;
        return sprt.opacity;
    }
    else if ([self isSelectedLabelBMFont])
    {
        CCLabelBMFont* lbl = (CCLabelBMFont*)selectedNode;
        return lbl.opacity;
    }
    else
    {
        return 0;
    }
}

- (void) saveUndoStateForColor
{
    if (currentDocument.lastOperationType != kCCBOperationTypeColor)
    {
        [self saveUndoState];
        currentDocument.lastOperationType = kCCBOperationTypeColor;
    }
}

- (void) setPColor:(NSColor *)pColor
{
    CGFloat r, g, b, a;
    [pColor getRed:&r green:&g blue:&b alpha:&a];
    
    if ([self isSelectedSprite])
    {
        [self saveUndoStateForColor];
        
        CCSprite* sprt = (CCSprite*)selectedNode;
        sprt.color = ccc3(r*255, g*255, b*255);
    }
    else if ([self isSelectedLayerGradient])
    {
        [self saveUndoStateForColor];
        
        CCLayerGradient* layer = (CCLayerGradient*)selectedNode;
        [layer setStartColor:ccc3(r*255, g*255, b*255)];
        [layer setStartOpacity: a*255];
    }
    else if ([self isSelectedLayerColor])
    {
        [self saveUndoStateForColor];
        
        CCLayerColor* layer = (CCLayerColor*)selectedNode;
        [layer setColor:ccc3(r*255, g*255, b*255)];
        [layer setOpacity: a*255];
    }
    else if ([self isSelectedLabelBMFont])
    {
        [self saveUndoStateForColor];
        
        CCLabelBMFont* lbl = (CCLabelBMFont*)selectedNode;
        lbl.color = ccc3(r*255, g*255, b*255);
    }
}

- (NSColor*) pColor
{
    if ([self isSelectedSprite])
    {
        CCSprite* sprt = (CCSprite*)selectedNode;
        ccColor3B color = sprt.color;
        return [NSColor colorWithCalibratedRed:color.r/255.0 green:color.g/255.0 blue:color.b/255.0 alpha:1];
    }
    else if ([self isSelectedLayerGradient])
    {
        CCLayerGradient* layer = (CCLayerGradient*)selectedNode;
        ccColor3B color = [layer startColor];
        GLubyte opacity = [layer startOpacity];
        return [NSColor colorWithCalibratedRed:color.r/255.0 green:color.g/255.0 blue:color.b/255.0 alpha:opacity/255.0];
    }
    else if ([self isSelectedLayerColor])
    {
        CCLayerColor* layer = (CCLayerColor*)selectedNode;
        ccColor3B color = layer.color;
        GLubyte opacity = layer.opacity;
        return [NSColor colorWithCalibratedRed:color.r/255.0 green:color.g/255.0 blue:color.b/255.0 alpha:opacity/255.0];
    }
    else if ([self isSelectedLabelBMFont])
    {
        CCLabelBMFont* lbl = (CCLabelBMFont*)selectedNode;
        ccColor3B color = lbl.color;
        return [NSColor colorWithCalibratedRed:color.r/255.0 green:color.g/255.0 blue:color.b/255.0 alpha:1];
    }
    else
    {
        return [NSColor whiteColor];
    }
}

- (void)setPFlipX:(BOOL)pFlipX
{
    if (![self isSelectedSprite]) return;
    [self saveUndoState];
    
    CCSprite* sprt = (CCSprite*)selectedNode;
    sprt.flipX = pFlipX;
}

- (BOOL)pFlipX
{
    if (![self isSelectedSprite]) return NO;
    
    CCSprite* sprt = (CCSprite*)selectedNode;
    return sprt.flipX;
}

- (void)setPFlipY:(BOOL)pFlipY
{
    if (![self isSelectedSprite]) return;
    [self saveUndoState];
    
    CCSprite* sprt = (CCSprite*)selectedNode;
    sprt.flipY = pFlipY;
}

- (BOOL)pFlipY
{
    if (![self isSelectedSprite]) return NO;
    CCSprite* sprt = (CCSprite*)selectedNode;
    return sprt.flipY;
}

- (void)setPBlendFuncSrc:(int)pBlendFuncSrc
{
    if ([self isSelectedSprite])
    {
        [self saveUndoState];
        
        CCSprite* sprt = (CCSprite*)selectedNode;
        ccBlendFunc blend = sprt.blendFunc;
        blend.src = pBlendFuncSrc;
        sprt.blendFunc = blend;
    }
    else if ([self isSelectedParticleSystem])
    {
        [self saveUndoState];
        
        CCParticleSystem* sys = (CCParticleSystem*)selectedNode;
        ccBlendFunc blend = sys.blendFunc;
        blend.src = pBlendFuncSrc;
        sys.blendFunc = blend;
    }
    else if ([self isSelectedLayerColor])
    {
        [self saveUndoState];
        
        CCLayerColor* sys = (CCLayerColor*)selectedNode;
        ccBlendFunc blend = sys.blendFunc;
        blend.src = pBlendFuncSrc;
        sys.blendFunc = blend;
    }
}

- (int) pBlendFuncSrc
{
    if ([self isSelectedSprite])
    {
        CCSprite* sprt = (CCSprite*)selectedNode;
        ccBlendFunc blend = sprt.blendFunc;
        return blend.src;
    }
    else if ([self isSelectedParticleSystem])
    {
        CCParticleSystem* sys = (CCParticleSystem*)selectedNode;
        ccBlendFunc blend = sys.blendFunc;
        return blend.src;
    }
    else if ([self isSelectedLayerColor])
    {
        CCLayerColor* sys = (CCLayerColor*)selectedNode;
        ccBlendFunc blend = sys.blendFunc;
        return blend.src;
    }
    else
    {
        return 0;
    }
}

- (void)setPBlendFuncDst:(int)pBlendFuncDst
{
    if ([self isSelectedSprite])
    {
        [self saveUndoState];
        
        CCSprite* sprt = (CCSprite*)selectedNode;
        ccBlendFunc blend = sprt.blendFunc;
        blend.dst = pBlendFuncDst;
        sprt.blendFunc = blend;
    }
    else if ([self isSelectedParticleSystem])
    {
        [self saveUndoState];
        
        CCParticleSystem* sys = (CCParticleSystem*)selectedNode;
        ccBlendFunc blend = sys.blendFunc;
        blend.dst = pBlendFuncDst;
        sys.blendFunc = blend;
    }
    else if ([self isSelectedLayerColor])
    {
        [self saveUndoState];
        
        CCLayerColor* sys = (CCLayerColor*)selectedNode;
        ccBlendFunc blend = sys.blendFunc;
        blend.dst = pBlendFuncDst;
        sys.blendFunc = blend;
    }
}

- (int) pBlendFuncDst
{
    if ([self isSelectedSprite])
    {
        CCSprite* sprt = (CCSprite*)selectedNode;
        ccBlendFunc blend = sprt.blendFunc;
        return blend.dst;
    }
    else if ([self isSelectedParticleSystem])
    {
        CCParticleSystem* sys = (CCParticleSystem*)selectedNode;
        ccBlendFunc blend = sys.blendFunc;
        return blend.dst;
    }
    else if ([self isSelectedLayerColor])
    {
        CCLayerColor* sys = (CCLayerColor*)selectedNode;
        ccBlendFunc blend = sys.blendFunc;
        return blend.dst;
    }
    else
    {
        return 0;
    }
}

- (IBAction) setBlendModeNormal:(id)sender
{
    [self saveUndoState];
    
    [self setPBlendFuncSrc:GL_ONE];
    [self setPBlendFuncDst:GL_ONE_MINUS_SRC_ALPHA];
}

- (IBAction) setBlendModeAdditive:(id)sender
{
    [self saveUndoState];
    
    [self setPBlendFuncSrc:GL_ONE];
    [self setPBlendFuncDst:GL_ONE];
}

#pragma mark Properties MenuItem

- (void)setPIsEnabled:(BOOL)pIsEnabled
{
    if (![self isSelectedMenuItem]) return;
    [self saveUndoState];
    
    CCMenuItem* item = (CCMenuItem*) selectedNode;
    [item setIsEnabled:pIsEnabled];
}

- (BOOL)pIsEnabled
{
    if (![self isSelectedMenuItem]) return NO;
    CCMenuItem* item = (CCMenuItem*) selectedNode;
    return [item isEnabled];
}

- (void)setPSelector:(NSString *)pSelector
{
    if (![self isSelectedMenuItem]) return;
    [self saveUndoState];
    if (!pSelector) pSelector = @"";
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:pSelector forKey:@"selector" andNode:selectedNode];
}

- (NSString*) pSelector
{
    if (![self isSelectedMenuItem]) return @"";
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [cs extraPropForKey:@"selector" andNode:selectedNode];
}

- (void) setPTarget:(int)pTarget
{
    if (![self isSelectedMenuItem]) return;
    [self saveUndoState];
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:[NSNumber numberWithInt: pTarget] forKey:@"target" andNode:selectedNode];
}

- (int) pTarget
{
    if (![self isSelectedMenuItem]) return 0;
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [[cs extraPropForKey:@"target" andNode:selectedNode] intValue];
}

#pragma mark Properties MenuItemImage

- (BOOL) hasSpriteFileForState:(int)state
{
    if (![self isSelectedMenuItemImage]) return NO;
    
    NSString* statePropName = @"spriteFileNormal";
    if (state == 1) statePropName = @"spriteFileSelected";
    if (state == 2) statePropName = @"spriteFileDisabled";
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    NSString* spriteFile = [cs extraPropForKey:statePropName andNode:selectedNode];
    if (!spriteFile) return NO;
    if ([spriteFile isEqualToString:@""]) return NO;
    return YES;
}

- (void) setPSpriteFile:(NSString *)pSpriteFile forState:(int)state
{
    if (![self isSelectedMenuItemImage]) return;
    if (!pSpriteFile) return;
    [self saveUndoState];
    
    NSString* statePropName = @"spriteFileNormal";
    if (state == 1) statePropName = @"spriteFileSelected";
    if (state == 2) statePropName = @"spriteFileDisabled";
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:pSpriteFile forKey:statePropName andNode:selectedNode];
    
    NSString* sheet = [cs extraPropForKey:@"spriteSheetFile" andNode:selectedNode];
    BOOL useSheet = (sheet && ![sheet isEqualToString:@""] && ![sheet isEqualToString:kCCBUseRegularFile]);
    
    CCSprite* sprt = (CCSprite*)[[selectedNode children] objectAtIndex:state];
    if (!useSheet)
    {
        NSString* fileName = [NSString stringWithFormat:@"%@%@", assetsPath, pSpriteFile];
        CCTexture2D* texture = [[CCTextureCache sharedTextureCache] addImage:fileName];
        if (!texture) texture = [[CCTextureCache sharedTextureCache] addImage:@"missing-texture.png"];
        
        float texW = texture.contentSizeInPixels.width;
        float texH = texture.contentSizeInPixels.height;
        
        
        [sprt setTexture:texture];
        [sprt setTextureRect:CGRectMake(0, 0, texW, texH)];
        
        [self setPContentSizeW:texW];
        [self setPContentSizeH:texH];
    }
    else
    {
        // Use sprite sheet
        CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:pSpriteFile];
        if (frame)
        {
            [sprt setDisplayFrame:frame];
        }
        else
        {
            // Set missing texture
            CCTexture2D* texture = [[CCTextureCache sharedTextureCache] addImage:@"missing-texture.png"];
            float texW = texture.contentSizeInPixels.width;
            float texH = texture.contentSizeInPixels.height;
            [sprt setTexture:texture];
            [sprt setTextureRect:CGRectMake(0, 0, texW, texH)];
            [self setPContentSizeW:texW];
            [self setPContentSizeH:texH];
        }
        
        [self setPContentSizeW:sprt.contentSize.width];
        [self setPContentSizeH:sprt.contentSize.height];
    }
    
    if (pSpriteFile && ![pSpriteFile isEqualToString:@""])
    {
        if (![self hasSpriteFileForState:0]) [self setPSpriteFileNormal:pSpriteFile];
        if (![self hasSpriteFileForState:1]) [self setPSpriteFileSelected:pSpriteFile];
        if (![self hasSpriteFileForState:2]) [self setPSpriteFileDisabled:pSpriteFile];
    }
}

- (void)setPSpriteFileNormal:(NSString *)pSpriteFileNormal
{
    if (!pSpriteFileNormal) pSpriteFileNormal = @"";
    [self setPSpriteFile:pSpriteFileNormal forState:0];
}

- (NSString*) pSpriteFileNormal
{
    if (![self isSelectedMenuItemImage]) return @"";
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [cs extraPropForKey:@"spriteFileNormal" andNode:selectedNode];
}

- (void)setPSpriteFileSelected:(NSString *)pSpriteFileNormal
{
    if (!pSpriteFileNormal) pSpriteFileNormal = @"";
    [self setPSpriteFile:pSpriteFileNormal forState:1];
}

- (NSString*) pSpriteFileSelected
{
    if (![self isSelectedMenuItemImage]) return @"";
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [cs extraPropForKey:@"spriteFileSelected" andNode:selectedNode];
}

- (void)setPSpriteFileDisabled:(NSString *)pSpriteFileNormal
{
    if (!pSpriteFileNormal) pSpriteFileNormal = @"";
    [self setPSpriteFile:pSpriteFileNormal forState:2];
}

- (NSString*) pSpriteFileDisabled
{
    if (![self isSelectedMenuItemImage]) return @"";
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [cs extraPropForKey:@"spriteFileDisabled" andNode:selectedNode];
}

#pragma mark Properties ParticleSystem

- (IBAction) startSelectedParticle:(id)sender
{
    if (![self isSelectedParticleSystem]) return;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    [sys resetSystem];
}
- (IBAction) stopSelectedParticle:(id)sender
{
    if (![self isSelectedParticleSystem]) return;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    [sys stopSystem];
}

- (void) setPEmissionRate:(float)pEmissionRate
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    sys.emissionRate = pEmissionRate;
}

- (float) pEmissionRate
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    return sys.emissionRate;
}

- (void) setPDuration:(float)pDuration
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    sys.duration = pDuration;
}

- (float) pDuration
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    return sys.duration;
}

- (void) setPPosVarX:(int)pPosVarX
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    CGPoint posVar = sys.posVar;
    posVar.x = pPosVarX;
    sys.posVar = posVar;
}

- (int) pPosVarX
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    return sys.posVar.x;
}

- (void) setPPosVarY:(int)pPosVarY
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    CGPoint posVar = sys.posVar;
    posVar.y = pPosVarY;
    sys.posVar = posVar;
}

- (int) pPosVarY
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    return sys.posVar.y;
}

- (void) setPEmitterMode:(int)pEmitterMode
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    sys.emitterMode = pEmitterMode;
    [self populateInspectorParticleSystemViewForCurrentMode];
    
    if (pEmitterMode == kCCParticleModeGravity)
    {
        [inspectorParticleSystemViewGravity setHidden:NO];
        [inspectorParticleSystemViewRadius setHidden:YES];
    }
    else
    {
        [inspectorParticleSystemViewGravity setHidden:YES];
        [inspectorParticleSystemViewRadius setHidden:NO];
    }
}

- (int) pEmitterMode
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    return (int)[sys emitterMode];
}


- (void) setPNumParticles:(int)pNumParticles
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    sys.totalParticles = pNumParticles;
}

- (int) pNumParticles
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    return (int)sys.totalParticles;
}

- (void) setPLife:(float)pLife
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    sys.life = pLife;
}

- (float) pLife
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    return sys.life;
}

- (void) setPLifeVar:(float)pLifeVar
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    sys.lifeVar = pLifeVar;
}

- (float) pLifeVar
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    return sys.lifeVar;
}

- (void) setPStartSize:(int)pStartSize
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    sys.startSize = pStartSize;
}

- (int) pStartSize
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    return sys.startSize;
}

- (void) setPStartSizeVar:(int)pStartSizeVar
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    sys.startSizeVar = pStartSizeVar;
}

- (int) pStartSizeVar
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    return sys.startSizeVar;
}

- (void) setPEndSize:(int)pEndSize
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    sys.endSize = pEndSize;
}

- (int) pEndSize
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    return sys.endSize;
}

- (void) setPEndSizeVar:(int)pEndSizeVar
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    sys.endSizeVar = pEndSizeVar;
}

- (int) pEndSizeVar
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    return sys.endSizeVar;
}

- (void) setPStartSpin:(int)pStartSpin
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    sys.startSpin = pStartSpin;
}

- (int) pStartSpin
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    return sys.startSpin;
}

- (void) setPStartSpinVar:(int)pStartSpinVar
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    sys.startSpinVar = pStartSpinVar;
}

- (int) pStartSpinVar
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    return sys.startSpinVar;
}

- (void) setPEndSpin:(int)pEndSpin
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    sys.endSpin = pEndSpin;
}

- (int) pEndSpin
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    return sys.endSpin;
}

- (void) setPEndSpinVar:(int)pEndSpinVar
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    sys.endSpinVar = pEndSpinVar;
}

- (int) pEndSpinVar
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    return sys.endSpinVar;
}

- (void) setPStartColor:(NSColor *)pStartColor
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    CGFloat r, g, b, a;
    [pStartColor getRed:&r green:&g blue:&b alpha:&a];
    ccColor4F c;
    c.r = r;
    c.g = g;
    c.b = b;
    c.a = a;
    sys.startColor = c;
}

- (NSColor*) pStartColor
{
    if (![self isSelectedParticleSystem]) return [NSColor whiteColor];
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    
    ccColor4F color = sys.startColor;
    return [NSColor colorWithCalibratedRed:color.r green:color.g blue:color.b alpha:color.a];
}

- (void) setPStartColorVar:(NSColor *)pStartColorVar
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    CGFloat r, g, b, a;
    [pStartColorVar getRed:&r green:&g blue:&b alpha:&a];
    ccColor4F c;
    c.r = r;
    c.g = g;
    c.b = b;
    c.a = a;
    sys.startColorVar = c;
}

- (NSColor*) pStartColorVar
{
    if (![self isSelectedParticleSystem]) return [NSColor whiteColor];
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    
    ccColor4F color = sys.startColorVar;
    return [NSColor colorWithCalibratedRed:color.r green:color.g blue:color.b alpha:color.a];
}

- (void) setPEndColor:(NSColor *)pEndColor
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    CGFloat r, g, b, a;
    [pEndColor getRed:&r green:&g blue:&b alpha:&a];
    ccColor4F c;
    c.r = r;
    c.g = g;
    c.b = b;
    c.a = a;
    sys.endColor = c;
}

- (NSColor*) pEndColor
{
    if (![self isSelectedParticleSystem]) return [NSColor whiteColor];
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    
    ccColor4F color = sys.endColor;
    return [NSColor colorWithCalibratedRed:color.r green:color.g blue:color.b alpha:color.a];
}

- (void) setPEndColorVar:(NSColor *)pEndColorVar
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    CGFloat r, g, b, a;
    [pEndColorVar getRed:&r green:&g blue:&b alpha:&a];
    ccColor4F c;
    c.r = r;
    c.g = g;
    c.b = b;
    c.a = a;
    sys.endColorVar = c;
}

- (NSColor*) pEndColorVar
{
    if (![self isSelectedParticleSystem]) return [NSColor whiteColor];
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    
    ccColor4F color = sys.endColorVar;
    return [NSColor colorWithCalibratedRed:color.r green:color.g blue:color.b alpha:color.a];
}

- (void) setPGravityX:(float)pGravityX
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeGravity) return;
    CGPoint gravity = sys.gravity;
    gravity.x = pGravityX;
    sys.gravity = gravity;
}

- (float) pGravityX
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeGravity) return 0;
    return sys.gravity.x;
}

- (void) setPGravityY:(float)pGravityY
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeGravity) return;
    CGPoint gravity = sys.gravity;
    gravity.y = pGravityY;
    sys.gravity = gravity;
}

- (float) pGravityY
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeGravity) return 0;
    return sys.gravity.y;
}

- (void) setPDirection:(int)pDirection
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeGravity) return;
    sys.angle = pDirection;
}

- (int) pDirection
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeGravity) return 0;
    return sys.angle;
}

- (void) setPDirectionVar:(int)pDirectionVar
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeGravity) return;
    sys.angleVar = pDirectionVar;
}

- (int) pDirectionVar
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeGravity) return 0;
    return sys.angleVar;
}

- (void) setPSpeed:(int)pSpeed
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeGravity) return;
    sys.speed = pSpeed;
}

- (int) pSpeed
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeGravity) return 0;
    return sys.speed;
}

- (void) setPSpeedVar:(int)pSpeedVar
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeGravity) return;
    sys.speedVar = pSpeedVar;
}

- (int) pSpeedVar
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeGravity) return 0;
    return sys.speedVar;
}

- (void) setPTangAcc:(int)pTangAcc
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeGravity) return;
    sys.tangentialAccel = pTangAcc;
}

- (int) pTangAcc
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeGravity) return 0;
    return sys.tangentialAccel;
}

- (void) setPTangAccVar:(int)pTangAccVar
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeGravity) return;
    sys.tangentialAccelVar = pTangAccVar;
}

- (int) pTangAccVar
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeGravity) return 0;
    return sys.tangentialAccelVar;
}

- (void) setPRadialAcc:(int)pRadialAcc
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeGravity) return;
    sys.radialAccel = pRadialAcc;
}

- (int) pRadialAcc
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeGravity) return 0;
    return sys.radialAccel;
}

- (void) setPRadialAccVar:(int)pRadialAccVar
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeGravity) return;
    sys.radialAccelVar = pRadialAccVar;
}

- (int) pRadialAccVar
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeGravity) return 0;
    return sys.radialAccelVar;
}

- (void) setPStartRadius:(int)pStartRadius
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeRadius) return;
    sys.startRadius = pStartRadius;
}

- (int) pStartRadius
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeRadius) return 0;
    return sys.startRadius;
}

- (void) setPStartRadiusVar:(int)pStartRadiusVar
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeRadius) return;
    sys.startRadiusVar = pStartRadiusVar;
}

- (int) pStartRadiusVar
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeRadius) return 0;
    return sys.startRadiusVar;
}

- (void) setPEndRadius:(int)pEndRadius
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeRadius) return;
    sys.endRadius = pEndRadius;
}

- (int) pEndRadius
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeRadius) return 0;
    return sys.endRadius;
}

- (void) setPEndRadiusVar:(int)pEndRadiusVar
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeRadius) return;
    sys.endRadiusVar = pEndRadiusVar;
}

- (int) pEndRadiusVar
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeRadius) return 0;
    return sys.endRadiusVar;
}

- (void) setPRotate:(int)pRotate
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeRadius) return;
    sys.rotatePerSecond = pRotate;
}

- (int) pRotate
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeRadius) return 0;
    return sys.rotatePerSecond;
}

- (void) setPRotateVar:(int)pRotateVar
{
    if (![self isSelectedParticleSystem]) return;
    [self saveUndoState];
    
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeRadius) return;
    sys.rotatePerSecondVar = pRotateVar;
}

- (int) pRotateVar
{
    if (![self isSelectedParticleSystem]) return 0;
    CCParticleSystem* sys = (CCParticleSystem*) selectedNode;
    if (sys.emitterMode != kCCParticleModeRadius) return 0;
    return sys.rotatePerSecondVar;
}

#pragma mark Properties LayerGradient

- (void) setPFadeColor:(NSColor *)pFadeColor
{
    if (![self isSelectedLayerGradient]) return;
    if (currentDocument.lastOperationType != kCCBOperationTypeFadeColor)
    {
        [self saveUndoState];
        currentDocument.lastOperationType = kCCBOperationTypeFadeColor;
    }
    
    CCLayerGradient* sys = (CCLayerGradient*) selectedNode;
    CGFloat r, g, b, a;
    [pFadeColor getRed:&r green:&g blue:&b alpha:&a];
    sys.endColor = ccc3(r*255, g*255, b*255);
    sys.endOpacity = a*255;
}

- (NSColor*) pFadeColor
{
    if (![self isSelectedLayerGradient]) return [NSColor whiteColor];
    CCLayerGradient* sys = (CCLayerGradient*) selectedNode;
    
    ccColor3B color = sys.endColor;
    return [NSColor colorWithCalibratedRed:color.r/255.0 green:color.g/255.0 blue:color.b/255.0 alpha:sys.endOpacity/255.0];
}

- (void) setPGradientAngle:(int)pGradientAngle
{
    if (![self isSelectedLayerGradient]) return;
    [self saveUndoState];
    
    CCLayerGradient* layer = (CCLayerGradient*) selectedNode;
    
    float len = sqrtf(layer.vector.x*layer.vector.x + layer.vector.y*layer.vector.y);
    float angle = (pGradientAngle-90)/360.0f*M_PI*2;
    
    layer.vector = ccp(cosf(angle)*len, -sinf(angle)*len);
}

- (int) pGradientAngle
{
    if (![self isSelectedLayerGradient]) return 0;
    CCLayerGradient* layer = (CCLayerGradient*) selectedNode;
    
    return ((int)((atan2f(-layer.vector.y, layer.vector.x)/(M_PI*2))*360+360+90))%360;
}


#pragma mark Properties LabelBMFont

- (void) setPString:(NSString *)pString
{
    if (!pString) pString = @"";
    
    if ([self isSelectedLabelBMFont])
    {
        [self saveUndoState];
        CCLabelBMFont* label = (CCLabelBMFont*) selectedNode;
        [label setString:pString];
    }
    else if ([self isSelectedLabelTTF])
    {
        [self saveUndoState];
        CCLabelTTF* label = (CCLabelTTF*) selectedNode;
        [label setString:pString];
    }
    else
    {
        return;
    }
    
    // Update dimensions
    self.pContentSizeW = selectedNode.contentSize.width;
    self.pContentSizeH = selectedNode.contentSize.height;
}

- (NSString*) pString
{
    if ([self isSelectedLabelBMFont])
    {
        CCLabelBMFont* label = (CCLabelBMFont*) selectedNode;
        NSString* str = [[[label string] copy] autorelease];
        return str;
    }
    else if ([self isSelectedLabelTTF])
    {
        CCLabelTTF* label = (CCLabelTTF*) selectedNode;
        NSString* str = [[[label string] copy] autorelease];
        return str;
    }
    else
    {
        return @"";
    }
}

- (IBAction) updateLabelBMFontString:(id)sender
{    
    self.pString = [inspectorLabelBMFontString string];
}

- (void) setPFontFile:(NSString *)pFontFile
{
    if (![self isSelectedLabelBMFont]) return;
    [self saveUndoState];
    
    if (!pFontFile) pFontFile = @"";
    
    CCLabelBMFont* lbl = (CCLabelBMFont*) selectedNode;
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:pFontFile forKey:@"fontFile" andNode:selectedNode];
    
    NSString* fileName = [NSString stringWithFormat:@"%@%@", assetsPath, pFontFile];
    
    CCLabelBMFont* lblValidate;
    @try
    {
        lblValidate = [[[CCLabelBMFont alloc] initWithString:@"Validation" fntFile:fileName] autorelease];
    }
    @catch (NSException *exception)
    {
        fileName = @"missing-font.fnt";
    }
    if (!lblValidate) fileName = @"missing-font.fnt";
    
    // Store props
    int tag = (int)lbl.tag;
    
    @try
    {
        //lbl = [lbl initWithString:@"New font!" fntFile:fileName];
        [lbl setFntFile:fileName];
    }
    @catch (NSException *exception)
    {
        lbl = NULL;
    }
    if (!lbl) NSLog(@"WARNING! Failed to reinitialize font!");
    
    
    // Reload props
    lbl.tag = tag;
}

- (NSString*) pFontFile
{
    if (![self isSelectedLabelBMFont]) return @"";
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    NSString* fontFile = [cs extraPropForKey:@"fontFile" andNode:selectedNode];
    return fontFile;
}

#pragma mark Properties LabelTTF (not working!)

- (void) setPFontName:(NSString *)fn
{    
    if (![self isSelectedLabelTTF]) return;
    [self saveUndoState];
    
    if (!fn) fn = @"Helvetica";
    CCLabelTTF* label = (CCLabelTTF*) selectedNode;
    
    //[pFontName release];
    //pFontName = fn;
    //[pFontName retain];
    
    [label setFontName:fn];
    
    // Update dimensions
    self.pContentSizeW = label.contentSize.width;
    self.pContentSizeH = label.contentSize.height;
}

- (NSString*) pFontName
{
    if (![self isSelectedLabelTTF]) return @"Helvetica";
    CCLabelTTF* label = (CCLabelTTF*) selectedNode;
    return [label fontName];
}

- (void) setPFontSize: (float)size
{
    if (![self isSelectedLabelTTF]) return;
    [self saveUndoState];
    
    if (!size) size = 24;
    CCLabelTTF* label = (CCLabelTTF*) selectedNode;
    
    [label setFontSize:size];
    
    // Update dimensions
    self.pContentSizeW = label.contentSize.width;
    self.pContentSizeH = label.contentSize.height;
}

- (float) pFontSize
{
    if (![self isSelectedLabelTTF]) return 24;
    CCLabelTTF* label = (CCLabelTTF*) selectedNode;
    return [label fontSize];
}

#pragma mark Properties Button
- (void)setPImageNameFormat:(NSString *)imageNameFormat
{
    if (![self isSelectedNode]) return;
    [self saveUndoState];
    if (!imageNameFormat) imageNameFormat = @"btn_red_pos%d.png";
    
    if([selectedNode isKindOfClass:[CCButton class]])
    {
        CCButton* button = (CCButton*) selectedNode;
        [button setImageNameFormat:imageNameFormat];
    }
    else if([selectedNode isKindOfClass:[CCThreeSlice class]])
    {
        CCThreeSlice* slice = (CCThreeSlice*) selectedNode;
        [slice setImageNameFormat:imageNameFormat];
    }
}

- (NSString*) pImageNameFormat
{
    if (![self isSelectedNode]) return @"";
    
    if([selectedNode isKindOfClass:[CCButton class]])
    {
        CCButton* button = (CCButton*) selectedNode;
        return [button imageNameFormat];
    }
    else if([selectedNode isKindOfClass:[CCThreeSlice class]])
    {
        CCThreeSlice* slice = (CCThreeSlice*) selectedNode;
        return [slice imageNameFormat];
    }
    else
    {
        return @"";
    }
    
}

#pragma mark Document handling

/*
- (void) replaceTopDocWithRootNode:(CCNode*)node extraProps:(NSMutableDictionary*)extraProps
{
    
}
 */
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
    NSMutableDictionary* nodeGraph = [CCBWriter dictionaryFromCCObject:g.rootNode extraProps:[g.cocosScene extraPropsDict]];
    [doc setObject:nodeGraph forKey:@"nodeGraph"];
    
    // Add meta data
    [doc setObject:@"CocosBuilder" forKey:@"fileType"];
    [doc setObject:[NSNumber numberWithInt:2] forKey:@"fileVersion"];
    
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
    CCNode* loadedRoot = [CCBReader nodeGraphFromDictionary:doc extraProps:extraProps assetsDir:assetsPath owner:NULL];
    
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
    
    /*
    // Process contents
    NSMutableDictionary* extraProps = [NSMutableDictionary dictionary];
    CCNode* loadedRoot = [CCBReader nodeGraphFromDictionary:doc extraProps:extraProps assetsDir:assetsPath owner:NULL];
    
    // Replace open document
    CCBGlobals* g = [CCBGlobals globals];
    
    selectedNode = NULL;
    [g.cocosScene replaceRootNodeWith:loadedRoot extraProps:extraProps];
    [outlineHierarchy reloadData];
    [self updateOutlineViewSelection];
    [self updateInspectorFromSelection];
    [outlineHierarchy expandItem:g.rootNode expandChildren:YES];
    
    // Setup stage
    int stageW = [[doc objectForKey:@"stageWidth"] intValue];
    int stageH = [[doc objectForKey:@"stageHeight"] intValue];
    BOOL centered = [[doc objectForKey:@"centeredOrigin"] boolValue];
    
    [g.cocosScene setStageSize:CGSizeMake(stageW, stageH) centeredOrigin:centered];
     */
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
    [[templateWindowController window] setIsVisible:NO];
    
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
    
    //[self replaceTopDocWithRootNode:loadedRoot extraProps:extraProps];
}

- (void) saveFile:(NSString*) fileName
{
    // Add to recent list of opened documents
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL fileURLWithPath:fileName]];
    
    NSMutableDictionary* doc = [self docDataFromCurrentNodeGraph];
    /*
    NSMutableDictionary* doc = [NSMutableDictionary dictionary];
    
    // Add node graph
    NSMutableDictionary* nodeGraph = [CCBWriter dictionaryFromCCObject:g.rootNode extraProps:[g.cocosScene extraPropsDict]];
    [doc setObject:nodeGraph forKey:@"nodeGraph"];
    
    // Add meta data
    [doc setObject:@"CocosBuilder" forKey:@"fileType"];
    [doc setObject:[NSNumber numberWithInt:1] forKey:@"fileVersion"];
    
    [doc setObject:[NSNumber numberWithInt:[g.cocosScene stageSize].width] forKey:@"stageWidth"];
    [doc setObject:[NSNumber numberWithInt:[g.cocosScene stageSize].height] forKey:@"stageHeight"];
    [doc setObject:[NSNumber numberWithBool:[g.cocosScene centeredOrigin]] forKey:@"centeredOrigin"];
    */
     
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
    //selectedNode = obj;
    [self setSelectedNode:obj];
    [self updateInspectorFromSelection];
    //[self updateOutlineViewSelection];
    
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
}

- (void) dropAddSpriteNamed:(NSString*)spriteFile inSpriteSheet:(NSString*)spriteSheetFile at:(CGPoint)pt
{
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
}

- (void) dropAddTemplateNamed:(NSString*)templateFile at:(CGPoint)pt parent:(CCNode*)parent
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultTemplateNodeWithFile:templateFile assetsPath:assetsPath] toParent:parent];
}

- (void) dropAddTemplateNamed:(NSString*)templateFile at:(CGPoint)pt
{
    //NSLog(@"dropAddTemplateNamed: %@", templateFile);
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [self addCCObject:[cs createDefaultTemplateNodeWithFile:templateFile assetsPath:assetsPath] asChild:NO];
    
    // Set position
    pt = [[selectedNode parent] convertToNodeSpace:pt];
    [self setPPositionX:pt.x];
    [self setPPositionY:pt.y];
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
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    NSMutableDictionary* clipDict = [CCBWriter dictionaryFromCCObject:selectedNode extraProps:[cs extraPropsDict]];
    NSData* clipData = [NSKeyedArchiver archivedDataWithRootObject:clipDict];
    NSPasteboard* cb = [NSPasteboard generalPasteboard];
    
    [cb declareTypes:[NSArray arrayWithObjects:@"com.cocosbuilder.node", nil] owner:self];
    [cb setData:clipData forType:@"com.cocosbuilder.node"];
}

- (void) doPasteAsChild:(BOOL)asChild
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    NSPasteboard* cb = [NSPasteboard generalPasteboard];
    NSString* type = [cb availableTypeFromArray:[NSArray arrayWithObjects:@"com.cocosbuilder.node", nil]];
    
    if (type)
    {
        NSData* clipData = [cb dataForType:type];
        NSMutableDictionary* clipDict = [NSKeyedUnarchiver unarchiveObjectWithData:clipData];
        
        CCNode* clipNode = [CCBReader ccObjectFromDictionary:clipDict extraProps:[cs extraPropsDict] assetsDir:assetsPath owner:NULL];
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
    
    if (dir == 0) self.pPositionX = self.pPositionX - 1;
    if (dir == 1) self.pPositionX = self.pPositionX + 1;
    if (dir == 2) self.pPositionY = self.pPositionY + 1;
    if (dir == 3) self.pPositionY = self.pPositionY - 1;
}

- (IBAction) menuMoveObject:(id)sender
{
    int dir = (int)[sender tag];
    
    if (dir == 0) self.pPositionX = self.pPositionX - 10;
    if (dir == 1) self.pPositionX = self.pPositionX + 10;
    if (dir == 2) self.pPositionY = self.pPositionY + 10;
    if (dir == 3) self.pPositionY = self.pPositionY - 10;
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
    
    //[NSApp beginSheet:[wc window] modalForWindow:window modalDelegate:wc didEndSelector:@selector(sheetDidEnd: returnCode: contextInfo:) contextInfo:NULL];
    
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

- (IBAction) menuOpenTemplatePanel:(id)sender
{
    [[templateWindowController window] setIsVisible:![[templateWindowController window] isVisible]];
}

- (IBAction) menuReloadAssets:(id)sender
{
    if (!currentDocument) return;
    
    //[[CCTextureCache sharedTextureCache] removeAllTextures];
    //[CCTextureCache purgeSharedTextureCache];
    
    [self updateAssetsView];
    //[assetsWindowController invalidateImageCache];
    //[self setupAssetsWindow];
    //[templateWindowController reloadData];
    
    
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


/*
- (void) applicationWillFinishLaunching:(NSNotification *)notification
{
    CCBDocumentController* docController = [[CCBDocumentController alloc] init];
    //[window makeFirstResponder:docController];
}
 */


@end
