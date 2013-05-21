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
#import "PublishSettingsWindow.h"
#import "ProjectSettings.h"
#import "ResourceManagerOutlineHandler.h"
#import "SavePanelLimiter.h"
#import "CCBPublisher.h"
#import "CCBWarnings.h"
#import "WarningsWindow.h"
#import "TaskStatusWindow.h"
#import "SequencerHandler.h"
#import "MainWindow.h"
#import "CCNode+NodeInfo.h"
#import "SequencerNodeProperty.h"
#import "SequencerSequence.h"
#import "SequencerSettingsWindow.h"
#import "SequencerDurationWindow.h"
#import "SequencerKeyframe.h"
#import "SequencerKeyframeEasing.h"
#import "SequencerKeyframeEasingWindow.h"
#import "JavaScriptDocument.h"
#import "PlayerConnection.h"
#import "PlayerConsoleWindow.h"
#import "SequencerUtil.h"
#import "SequencerStretchWindow.h"
#import "SequencerSoundChannel.h"
#import "SequencerCallbackChannel.h"
#import "CustomPropSettingsWindow.h"
#import "CustomPropSetting.h"
#import "MainToolbarDelegate.h"
#import "InspectorSeparator.h"
#import "HelpWindow.h"
#import "APIDocsWindow.h"
#import "NodeGraphPropertySetter.h"
#import "CCBSplitHorizontalView.h"
#import "SpriteSheetSettingsWindow.h"
#import "AboutWindow.h"
#import "CCBHTTPServer.h"
#import "JavaScriptAutoCompleteHandler.h"
#import "CCBFileUtil.h"

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
@synthesize menuContextKeyframe;
@synthesize menuContextKeyframeInterpol;
@synthesize menuContextResManager;
@synthesize outlineProject;
@synthesize errorDescription;
@synthesize selectedNodes;
@synthesize loadedSelectedNodes;
@synthesize panelVisibilityControl;
@synthesize connection;

static CocosBuilderAppDelegate* sharedAppDelegate;

#pragma mark Setup functions

+ (CocosBuilderAppDelegate*) appDelegate
{
    return sharedAppDelegate;
}

- (void) setupInspectorPane
{
    currentInspectorValues = [[NSMutableDictionary alloc] init];
    
    //[inspectorScroll setScrollerStyle: NSScrollerStyleLegacy];
    
    inspectorDocumentView = [[NSFlippedView alloc] initWithFrame:NSMakeRect(0, 0, [inspectorScroll contentSize].width, 1)];
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

- (void) setupSequenceHandler
{
    sequenceHandler = [[SequencerHandler alloc] initWithOutlineView:outlineHierarchy];
    sequenceHandler.scrubberSelectionView = scrubberSelectionView;
    sequenceHandler.timeDisplay = timeDisplay;
    sequenceHandler.timeScaleSlider = timeScaleSlider;
    sequenceHandler.scroller = timelineScroller;
    sequenceHandler.scrollView = sequenceScrollView;
    
    [self updateTimelineMenu];
    [sequenceHandler updateScaleSlider];
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

- (void) setupToolbar
{
    toolbarDelegate = [[MainToolbarDelegate alloc] init];
    toolbar.delegate = toolbarDelegate;
    [toolbarDelegate addPlugInItemsToToolbar:toolbar];
}

- (void) setupPlayerConnection
{
    connection = [[PlayerConnection alloc] init];
    [connection run];
}

- (void) setupResourceManager
{
    // Load resource manager
    resManager = [ResourceManager sharedManager];
    //resManagerPanel = [[ResourceManagerPanel alloc] initWithWindowNibName:@"ResourceManagerPanel"];
    //[resManagerPanel.window setIsVisible:NO];
    
    // Setup project display
    projectOutlineHandler = [[ResourceManagerOutlineHandler alloc] initWithOutlineView:outlineProject resType:kCCBResTypeNone];
}

- (void) setupGUIWindow
{
    NSRect frame = cocosView.frame;
    
    frame.origin = [cocosView convertPoint:NSZeroPoint toView:NULL];
    frame.origin.x += self.window.frame.origin.x;
    frame.origin.y += self.window.frame.origin.y;
    
    guiWindow = [[CCBTransparentWindow alloc] initWithContentRect:frame];
    
    guiView = [[[CCBTransparentView alloc] initWithFrame:cocosView.frame] autorelease];
    [guiWindow setContentView:guiView];
    guiWindow.delegate = self;
    
    [window addChildWindow:guiWindow ordered:NSWindowAbove];
}

- (void) setupAutoCompleteHandler
{
    JavaScriptAutoCompleteHandler* handler = [JavaScriptAutoCompleteHandler sharedAutoCompleteHandler];
    
    NSString* dir = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"autoCompleteDefinitions"];
    
    [handler loadGlobalFilesFromDirectory:dir];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"ApplePersistenceIgnoreState"];
    [self.window center];
    
    selectedNodes = [[NSMutableArray alloc] init];
    loadedSelectedNodes = [[NSMutableArray alloc] init];
    
    sharedAppDelegate = self;
    
    [self setupAutoCompleteHandler];
    
    [[NSExceptionHandler defaultExceptionHandler] setExceptionHandlingMask: NSLogUncaughtExceptionMask | NSLogUncaughtSystemExceptionMask | NSLogUncaughtRuntimeErrorMask];
    
    // iOS
    defaultCanvasSizes[kCCBCanvasSizeIPhoneLandscape] = CGSizeMake(480, 320);
    defaultCanvasSizes[kCCBCanvasSizeIPhonePortrait] = CGSizeMake(320, 480);
    defaultCanvasSizes[kCCBCanvasSizeIPhone5Landscape] = CGSizeMake(568, 320);
    defaultCanvasSizes[kCCBCanvasSizeIPhone5Portrait] = CGSizeMake(320, 568);
    defaultCanvasSizes[kCCBCanvasSizeIPadLandscape] = CGSizeMake(1024, 768);
    defaultCanvasSizes[kCCBCanvasSizeIPadPortrait] = CGSizeMake(768, 1024);
    
    // Android
    defaultCanvasSizes[kCCBCanvasSizeAndroidXSmallLandscape] = CGSizeMake(320, 240);
    defaultCanvasSizes[kCCBCanvasSizeAndroidXSmallPortrait] = CGSizeMake(240, 320);
    defaultCanvasSizes[kCCBCanvasSizeAndroidSmallLandscape] = CGSizeMake(480, 340);
    defaultCanvasSizes[kCCBCanvasSizeAndroidSmallPortrait] = CGSizeMake(340, 480);
    defaultCanvasSizes[kCCBCanvasSizeAndroidMediumLandscape] = CGSizeMake(800, 480);
    defaultCanvasSizes[kCCBCanvasSizeAndroidMediumPortrait] = CGSizeMake(480, 800);
    
    [window setDelegate:self];
    
    [self setupTabBar];
    [self setupInspectorPane];
    [self setupCocos2d];
    [self setupSequenceHandler];
    [self updateInspectorFromSelection];
    
    [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
    
    CocosScene* cs = [CocosScene cocosScene];
    [cs setStageBorder:0];
    [self updateCanvasBorderMenu];
    [self updateJSControlledMenu];
    [self updateDefaultBrowser];
    
    // Load plug-ins
    plugInManager = [PlugInManager sharedManager];
    [plugInManager loadPlugIns];
    
    // Update toolbar with plug-ins
    [self setupToolbar];

    [self setupResourceManager];
    [self setupGUIWindow];
    
    [self setupPlayerConnection];
    
    self.showGuides = YES;
    self.snapToGuides = YES;
    self.showStickyNotes = YES;
    
    [self.window makeKeyWindow];
    
    // Open files
    if(delayOpenFiles)
	{
		[self openFiles:delayOpenFiles];
		[delayOpenFiles release];
		delayOpenFiles = nil;
	}
    
    // Check for first run
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"completedFirstRun"] boolValue])
    {
        [self showHelp:self];
        
        // First run completed
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"completedFirstRun"];
    }
}

#pragma mark Notifications to user

- (void) modalDialogTitle: (NSString*)title message:(NSString*)msg
{
    NSAlert* alert = [NSAlert alertWithMessageText:title defaultButton:@"OK" alternateButton:NULL otherButton:NULL informativeTextWithFormat:@"%@",msg];
    [alert runModal];
}

- (void) modalStatusWindowStartWithTitle:(NSString*)title
{
    if (!modalTaskStatusWindow)
    {
        modalTaskStatusWindow = [[TaskStatusWindow alloc] initWithWindowNibName:@"TaskStatusWindow"];
    }
    
    modalTaskStatusWindow.window.title = title;
    [modalTaskStatusWindow.window center];
    [modalTaskStatusWindow.window makeKeyAndOrderFront:self];
    
    [[NSApplication sharedApplication] runModalForWindow:modalTaskStatusWindow.window];
}

- (void) modalStatusWindowFinish
{
    [[NSApplication sharedApplication] stopModal];
    [modalTaskStatusWindow.window orderOut:self];
}

- (void) modalStatusWindowUpdateStatusText:(NSString*) text
{
    modalTaskStatusWindow.status = text;
}

#pragma mark Handling the gui layer

- (void) resizeGUIWindow:(NSSize)size
{
    NSRect frame = guiView.frame;
    frame.size = size;
    guiView.frame = NSMakeRect(0, 0, frame.size.width, frame.size.height);
    
    frame = cocosView.frame;
    frame.origin = [cocosView convertPoint:NSZeroPoint toView:NULL];
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

#pragma mark Handling selections

- (void) setSelectedNodes:(NSArray*) selection
{
    // Close the color picker
    [[NSColorPanel sharedColorPanel] close];
    
    // Finish editing inspector
    if (![[self window] makeFirstResponder:[self window]])
    {
        return;
    }
    
    // Update selection
    [selectedNodes removeAllObjects];
    if (selection && selection.count > 0)
    {
        [selectedNodes addObjectsFromArray:selection];
        
        // Make sure all nodes have the same parent
        CCNode* lastNode = [selectedNodes objectAtIndex:selectedNodes.count-1];
        CCNode* parent = lastNode.parent;
        
        for (int i = selectedNodes.count -1; i >= 0; i--)
        {
            CCNode* node = [selectedNodes objectAtIndex:i];
            if (node.parent != parent)
            {
                [selectedNodes removeObjectAtIndex:i];
            }
        }
    }
    
    [sequenceHandler updateOutlineViewSelection];
    
    // Handle undo/redo
    if (currentDocument) currentDocument.lastEditedProperty = NULL;
}

- (CCNode*) selectedNode
{
    if (selectedNodes.count == 1)
    {
        return [selectedNodes objectAtIndex:0];
    }
    else
    {
        return NULL;
    }
}

#pragma mark Window Delegate

- (void) windowDidResignMain:(NSNotification *)notification
{
    if (notification.object == self.window)
    {
        CocosScene* cs = [CocosScene cocosScene];
    
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
        CocosScene* cs = [CocosScene cocosScene];
    
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
        [[CocosScene cocosScene].notesLayer showAllNotesLabels];
    }
}

- (void) windowDidResize:(NSNotification *)notification
{
    [sequenceHandler updateScroller];
}




#pragma mark Populate Inspector

- (void) refreshProperty:(NSString*) name
{
    if (!self.selectedNode) return;
    
    InspectorValue* inspectorValue = [currentInspectorValues objectForKey:name];
    if (inspectorValue)
    {
        [inspectorValue refresh];
    }
}


static InspectorValue* lastInspectorValue;
static BOOL hideAllToNextSeparator;

- (int) addInspectorPropertyOfType:(NSString*)type name:(NSString*)prop displayName:(NSString*)displayName extra:(NSString*)e readOnly:(BOOL)readOnly affectsProps:(NSArray*)affectsProps atOffset:(int)offset
{
    NSString* inspectorNibName = [NSString stringWithFormat:@"Inspector%@",type];
    
    // Create inspector
    InspectorValue* inspectorValue = [InspectorValue inspectorOfType:type withSelection:self.selectedNode andPropertyName:prop andDisplayName:displayName andExtra:e];
    lastInspectorValue.inspectorValueBelow = inspectorValue;
    lastInspectorValue = inspectorValue;
    inspectorValue.readOnly = readOnly;
    inspectorValue.rootNode = (self.selectedNode == [CocosScene cocosScene].rootNode);
    
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
    
    //if its a separator, check to see if it isExpanded, if not set all of the next non-separator InspectorValues to hidden and don't touch the offset
    if ([inspectorValue isKindOfClass:[InspectorSeparator class]]) {
        InspectorSeparator* inspectorSeparator = (InspectorSeparator*)inspectorValue;
        hideAllToNextSeparator = NO;
        if (!inspectorSeparator.isExpanded) {
            hideAllToNextSeparator = YES;
        }
        NSRect frame = [view frame];
        [view setFrame:NSMakeRect(0, offset, frame.size.width, frame.size.height)];
        offset += frame.size.height;
    }
    else {
        if (hideAllToNextSeparator) {
            [view setHidden:YES];
        }
        else {
            NSRect frame = [view frame];
            [view setFrame:NSMakeRect(0, offset, frame.size.width, frame.size.height)];
            offset += frame.size.height;
        }
    }
    
    // Add view to inspector and place it at the bottom
    [inspectorDocumentView addSubview:view];
    [view setAutoresizingMask:NSViewWidthSizable];
    
    return offset;
}

- (BOOL) isDisabledProperty:(NSString*)name animatable:(BOOL)animatable
{
    // Only animatable properties can be disabled
    if (!animatable) return NO;
    
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    
    SequencerNodeProperty* seqNodeProp = [self.selectedNode sequenceNodeProperty:name sequenceId:seq.sequenceId];
    
    // Do not disable if animation hasn't been enabled
    if (!seqNodeProp) return NO;
    
    // Disable visiblilty if there are keyframes
    if (seqNodeProp.keyframes.count > 0 && [name isEqualToString:@"visible"]) return YES;
    
    // Do not disable if we are currently at a keyframe
    if ([seqNodeProp hasKeyframeAtTime: seq.timelinePosition]) return NO;
    
    // Between keyframes - disable
    return YES;
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
    if (!self.selectedNode) return;
    
    NodeInfo* info = self.selectedNode.userObject;
    PlugInNode* plugIn = info.plugIn;
    
    BOOL isCCBSubFile = [plugIn.nodeClassName isEqualToString:@"CCBFile"];
    
    // Always add the code connections pane
    if (jsControlled)
    {
        paneOffset = [self addInspectorPropertyOfType:@"CodeConnectionsJS" name:@"customClass" displayName:@"" extra:NULL readOnly:isCCBSubFile affectsProps:NULL atOffset:paneOffset];
    }
    else
    {
        paneOffset = [self addInspectorPropertyOfType:@"CodeConnections" name:@"customClass" displayName:@"" extra:NULL readOnly:isCCBSubFile affectsProps:NULL atOffset:paneOffset];
    }
    
    // Add panes for each property
    
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
            BOOL animated = [[propInfo objectForKey:@"animatable"] boolValue];
            if ([name isEqualToString:@"visible"]) animated = YES;
            if ([self.selectedNode shouldDisableProperty:name]) readOnly = YES;
            
            // Handle Flash skews
            BOOL usesFlashSkew = [self.selectedNode usesFlashSkew];
            if (usesFlashSkew && [name isEqualToString:@"rotation"]) continue;
            if (!usesFlashSkew && [name isEqualToString:@"rotationX"]) continue;
            if (!usesFlashSkew && [name isEqualToString:@"rotationY"]) continue;
            
            // TODO: Handle read only for animated properties
            if ([self isDisabledProperty:name animatable:animated])
            {
                readOnly = YES;
            }
            
            //For the separators; should make this a part of the definition
            if (name == NULL) {
                name = displayName;
            }
            
            paneOffset = [self addInspectorPropertyOfType:type name:name displayName:displayName extra:extra readOnly:readOnly affectsProps:affectsProps atOffset:paneOffset];
        }
    }
    else
    {
        NSLog(@"WARNING info:%@ plugIn:%@ selectedNode: %@", info, plugIn, self.selectedNode);
    }
    
    // Custom properties
    NSString* customClass = [self.selectedNode extraPropForKey:@"customClass"];
    NSArray* customProps = self.selectedNode.customProperties;
    if (customClass && ![customClass isEqualToString:@""])
    {
        if ([customProps count] || !isCCBSubFile)
        {
            paneOffset = [self addInspectorPropertyOfType:@"Separator" name:[self.selectedNode extraPropForKey:@"customClass"] displayName:[self.selectedNode extraPropForKey:@"customClass"] extra:NULL readOnly:YES affectsProps:NULL atOffset:paneOffset];
        }
        
        for (CustomPropSetting* setting in customProps)
        {
            paneOffset = [self addInspectorPropertyOfType:@"Custom" name:setting.name displayName:setting.name extra:NULL readOnly:NO affectsProps:NULL atOffset:paneOffset];
        }
        
        if (!isCCBSubFile)
        {
            paneOffset = [self addInspectorPropertyOfType:@"CustomEdit" name:NULL displayName:@"" extra:NULL readOnly:NO affectsProps:NULL atOffset:paneOffset];
        }
    }
    
    hideAllToNextSeparator = NO;
    
    /*
    // Custom properties from sub ccb
    if (isCCBSubFile)
    {
        CCNode* subCCB = [[selectedNode children] objectAtIndex:0];
        if (subCCB)
        {
            NSString* subCustomClass = [subCCB extraPropForKey:@"customClass"];
            NSArray* subCustomProps = subCCB.customProperties;
            
            if (subCustomClass && ![subCustomClass isEqualToString:@""])
            {
                paneOffset = [self addInspectorPropertyOfType:@"Separator" name:NULL displayName:subCustomClass extra:NULL readOnly:YES affectsProps:NULL atOffset:paneOffset];
                
                for (CustomPropSetting* setting in customProps)
                {
                    
                }
            }
        }
    }
     */
    
    [inspectorDocumentView setFrameSize:NSMakeSize([inspectorScroll contentSize].width, paneOffset)];
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
        NSString* keyEquivalent = @"";
        if (i < 10) keyEquivalent = [NSString stringWithFormat:@"%d",i+1];
        
        NSMenuItem* item = [[[NSMenuItem alloc] initWithTitle:resolution.name action:@selector(menuResolution:) keyEquivalent:keyEquivalent] autorelease];
        item.target = self;
        item.tag = i;
        
        [menuResolution addItem:item];
        if (i == currentDocument.currentResolution) item.state = NSOnState;
        
        i++;
    }
}

- (void) updateTimelineMenu
{
    if (!currentDocument)
    {
        lblTimeline.stringValue = @"";
        lblTimelineChained.stringValue = @"";
        [menuTimelinePopup setEnabled:NO];
        [menuTimelineChainedPopup setEnabled:NO];
        return;
    }
    
    [menuTimelinePopup setEnabled:YES];
    [menuTimelineChainedPopup setEnabled:YES];
    
    // Clear menu
    [menuTimeline removeAllItems];
    [menuTimelineChained removeAllItems];
    
    int currentId = sequenceHandler.currentSequence.sequenceId;
    int chainedId = sequenceHandler.currentSequence.chainedSequenceId;
    
    // Add dummy item
    NSMenuItem* itemDummy = [[[NSMenuItem alloc] initWithTitle:@"Dummy" action:NULL keyEquivalent:@""] autorelease];
    [menuTimelineChained addItem:itemDummy];
    
    // Add empty option for chained seq
    NSMenuItem* itemCh = [[[NSMenuItem alloc] initWithTitle: @"No Chained Timeline" action:@selector(menuSetChainedSequence:) keyEquivalent:@""] autorelease];
    itemCh.target = sequenceHandler;
    itemCh.tag = -1;
    if (chainedId == -1) [itemCh setState:NSOnState];
    [menuTimelineChained addItem:itemCh];
    
    // Add separator item
    [menuTimelineChained addItem:[NSMenuItem separatorItem]];
    
    for (SequencerSequence* seq in currentDocument.sequences)
    {
        // Add to sequence selector
        NSMenuItem* item = [[[NSMenuItem alloc] initWithTitle:seq.name action:@selector(menuSetSequence:) keyEquivalent:@""] autorelease];
        item.target = sequenceHandler;
        item.tag = seq.sequenceId;
        if (currentId == seq.sequenceId) [item setState:NSOnState];
        [menuTimeline addItem:item];
        
        // Add to chained sequence selector
        itemCh = [[[NSMenuItem alloc] initWithTitle: seq.name action:@selector(menuSetChainedSequence:) keyEquivalent:@""] autorelease];
        itemCh.target = sequenceHandler;
        itemCh.tag = seq.sequenceId;
        if (chainedId == seq.sequenceId) [itemCh setState:NSOnState];
        [menuTimelineChained addItem:itemCh];
    }
    
    lblTimeline.stringValue = sequenceHandler.currentSequence.name;
    if (chainedId == -1)
    {
        lblTimelineChained.stringValue = @"No chained timeline";
    }
    else
    {
        for (SequencerSequence* seq in currentDocument.sequences)
        {
            if (seq.sequenceId == chainedId)
            {
                lblTimelineChained.stringValue = seq.name;
                break;
            }
        }
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
    if ([[NSDocumentController sharedDocumentController] hasEditedDocuments])
    {
        return YES;
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
    
    [dict setObject:[NSNumber numberWithBool:jsControlled] forKey:@"jsControlled"];
    
    [dict setObject:[NSNumber numberWithBool:[[CocosScene cocosScene] centeredOrigin]] forKey:@"centeredOrigin"];
    
    [dict setObject:[NSNumber numberWithInt:[[CocosScene cocosScene] stageBorder]] forKey:@"stageBorder"];
    
    // Guides & notes
    [dict setObject:[[CocosScene cocosScene].guideLayer serializeGuides] forKey:@"guides"];
    [dict setObject:[[CocosScene cocosScene].notesLayer serializeNotes] forKey:@"notes"];
    
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
    
    // Sequencer timelines
    if (doc.sequences)
    {
        NSMutableArray* sequences = [NSMutableArray array];
        for (SequencerSequence* seq in doc.sequences)
        {
            [sequences addObject:[seq serialize]];
        }
        [dict setObject:sequences forKey:@"sequences"];
        [dict setObject:[NSNumber numberWithInt:sequenceHandler.currentSequence.sequenceId] forKey:@"currentSequenceId"];
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
    [self setSelectedNodes:NULL];
    CocosScene* cs = [CocosScene cocosScene];
    
    if (![self hasOpenedDocument]) return;
    currentDocument.docData = [self docDataFromCurrentNodeGraph];
    currentDocument.stageZoom = [cs stageZoom];
    currentDocument.stageScrollOffset = [cs scrollOffset];
}

- (void) replaceDocumentData:(NSMutableDictionary*)doc
{
    CCBGlobals* g = [CCBGlobals globals];
    
    [loadedSelectedNodes removeAllObjects];
    
    BOOL centered = [[doc objectForKey:@"centeredOrigin"] boolValue];
    
    // Check for jsControlled
    jsControlled = [[doc objectForKey:@"jsControlled"] boolValue];
    
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
        [[CocosScene cocosScene] setStageSize:CGSizeMake(resolution.width, resolution.height) centeredOrigin: centered];
        
        // Save in current document
        currentDocument.resolutions = resolutions;
        currentDocument.currentResolution = currentResolution;
    }
    else
    {
        // Support old files where the current width and height was stored
        int stageW = [[doc objectForKey:@"stageWidth"] intValue];
        int stageH = [[doc objectForKey:@"stageHeight"] intValue];
        
        [[CocosScene cocosScene] setStageSize:CGSizeMake(stageW, stageH) centeredOrigin:centered];
        
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
    
    // Stage border
    [[CocosScene cocosScene] setStageBorder:[[doc objectForKey:@"stageBorder"] intValue]];
    
    // Setup sequencer timelines
    NSMutableArray* serializedSequences = [doc objectForKey:@"sequences"];
    if (serializedSequences)
    {
        // Load from the file
        int currentSequenceId = [[doc objectForKey:@"currentSequenceId"] intValue];
        SequencerSequence* currentSeq = NULL;
        
        NSMutableArray* sequences = [NSMutableArray array];
        for (id serSeq in serializedSequences)
        {
            SequencerSequence* seq = [[SequencerSequence alloc] initWithSerialization:serSeq];
            [sequences addObject:seq];
            [seq release];
            
            if (seq.sequenceId == currentSequenceId)
            {
                currentSeq = seq;
            }
        }
        
        currentDocument.sequences = sequences;
        sequenceHandler.currentSequence = currentSeq;
    }
    else
    {
        // Setup a default timeline
        NSMutableArray* sequences = [NSMutableArray array];
    
        SequencerSequence* seq = [[SequencerSequence alloc] init];
        seq.name = @"Default Timeline";
        seq.sequenceId = 0;
        seq.autoPlay = YES;
        [sequences addObject:seq];
        [seq release];
    
        currentDocument.sequences = sequences;
        sequenceHandler.currentSequence = seq;
    }
    
    // Process contents
    CCNode* loadedRoot = [CCBReaderInternal nodeGraphFromDocumentDictionary:doc parentSize:CGSizeMake(resolution.width, resolution.height)];
    
    // Replace open document
    self.selectedNodes = NULL;
    [[CocosScene cocosScene] replaceRootNodeWith:loadedRoot];
    [outlineHierarchy reloadData];
    [sequenceHandler updateOutlineViewSelection];
    [self updateInspectorFromSelection];
    
    [sequenceHandler updateExpandedForNode:g.rootNode];
    
    // Setup guides
    id guides = [doc objectForKey:@"guides"];
    if (guides)
    {
        [[CocosScene cocosScene].guideLayer loadSerializedGuides:guides];
    }
    else
    {
        [[CocosScene cocosScene].guideLayer removeAllGuides];
    }
    
    // Setup notes
    id notes = [doc objectForKey:@"notes"];
    if (notes)
    {
        [[CocosScene cocosScene].notesLayer loadSerializedNotes:notes];
    }
    else
    {
        [[CocosScene cocosScene].notesLayer removeAllNotes];
    }
    
    // Restore selections
    self.selectedNodes = loadedSelectedNodes;
    
    [self updateJSControlledMenu];
    [self updateCanvasBorderMenu];
}

- (void) switchToDocument:(CCBDocument*) document forceReload:(BOOL)forceReload
{
    if (!forceReload && [document.fileName isEqualToString:currentDocument.fileName]) return;
    
    [self prepareForDocumentSwitch];
    
    self.currentDocument = document;
    
    NSMutableDictionary* doc = document.docData;
    
    [self replaceDocumentData:doc];
    
    [self updateResolutionMenu];
    [self updateTimelineMenu];
    [self updateStateOriginCenteredMenu];
    
    CocosScene* cs = [CocosScene cocosScene];
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
    self.selectedNodes = NULL;
    [[CocosScene cocosScene] replaceRootNodeWith:NULL];
    [[CocosScene cocosScene] setStageSize:CGSizeMake(0, 0) centeredOrigin:YES];
    [[CocosScene cocosScene].guideLayer removeAllGuides];
    [[CocosScene cocosScene].notesLayer removeAllNotes];
    [[CocosScene cocosScene].rulerLayer mouseExited:NULL];
    self.currentDocument = NULL;
    sequenceHandler.currentSequence = NULL;
    
    [self updateTimelineMenu];
    [outlineHierarchy reloadData];
    
    //[resManagerPanel.window setIsVisible:NO];
    
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
        [[CocosBuilderAppDelegate appDelegate] modalDialogTitle:@"Too Many Directories" message:@"You have created or opened a file which is in a directory with very many sub directories. Please save your ccb-files in a directory together with the resources you use in your project."];
    }
}

- (BOOL) checkForTooManyDirectoriesInCurrentProject
{
    if (!projectSettings) return NO;
    
    if ([ResourceManager sharedManager].tooManyDirectoriesAdded)
    {
        [self closeProject];
        
        [ResourceManager sharedManager].tooManyDirectoriesAdded = NO;
        
        // Notify the user
        [[CocosBuilderAppDelegate appDelegate] modalDialogTitle:@"Too Many Directories" message:@"You have created or opened a project which is in a directory with very many sub directories. Please save your project-files in a directory together with the resources you use in your project."];
        return NO;
    }
    return YES;
}

- (void) copyDefaultResourcesForProject:(ProjectSettings*) settings
{
    NSFileManager* fm = [NSFileManager defaultManager];
    
    // Copy resources to project dir (root directory)
    NSString* srcDir = [[NSBundle mainBundle] pathForResource:@"defaultProjectResources" ofType:@""];
    NSString* dstDir = [settings.absoluteResourcePaths objectAtIndex:0];
    
    NSLog(@"Copy from: %@ to: %@",srcDir,dstDir);
    
    BOOL success = [fm copyItemAtPath:srcDir toPath:dstDir error:NULL];
    NSLog(@"succes: %d",success);
}

- (BOOL) createProject:(NSString*) fileName
{
    // Create a default project
    ProjectSettings* settings = [[[ProjectSettings alloc] init] autorelease];
    settings.projectPath = fileName;
    
    // Copy resources
    [self copyDefaultResourcesForProject:settings];
    
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
    
    [[JavaScriptAutoCompleteHandler sharedAutoCompleteHandler] removeLocalFiles];
    
    [window setTitle:@"CocosBuilder"];

    // Stop local web server
    [[CCBHTTPServer sharedHTTPServer] stop];
    
    // Remove resource paths
    self.projectSettings = NULL;
    [resManager removeAllDirectories];
}

- (BOOL) openProject:(NSString*) fileName
{
    // Close currently open project
    [self closeProject];
    
    // Add to recent list of opened documents
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL fileURLWithPath:fileName]];
    
    NSMutableDictionary* projectDict = [NSMutableDictionary dictionaryWithContentsOfFile:fileName];
    if (!projectDict)
    {
        [self modalDialogTitle:@"Invalid Project File" message:@"Failed to open the project. File may be missing or invalid."];
        return NO;
    }
    
    ProjectSettings* project = [[[ProjectSettings alloc] initWithSerialization:projectDict] autorelease];
    if (!project)
    {
        [self modalDialogTitle:@"Invalid Project File" message:@"Failed to open the project. File is invalid or is created with a newer version of CocosBuilder."];
        return NO;
    }
    project.projectPath = fileName;
    [project store];
    self.projectSettings = project;
    
    [self updateResourcePathsFromProjectSettings];
    
    BOOL success = [self checkForTooManyDirectoriesInCurrentProject];
    
    if (!success) return NO;
    
    // Load autocompletions for all JS files
    NSArray* jsFiles = [CCBFileUtil filesInResourcePathsWithExtension:@"js"];
    for (NSString* jsFile in jsFiles)
    {
        [[JavaScriptAutoCompleteHandler sharedAutoCompleteHandler] loadLocalFile:[resManager toAbsolutePath:jsFile]];
    }
    
    // Update the title of the main window
    [window setTitle:[NSString stringWithFormat:@"CocosBuilder - %@", [fileName lastPathComponent]]];

    // Start local web server
    NSString* docRoot = [projectSettings.publishDirectoryHTML5 absolutePathFromBaseDirPath:[projectSettings.projectPath stringByDeletingLastPathComponent]];
    [[CCBHTTPServer sharedHTTPServer] start:docRoot];
    
    // Open ccb file for project if there is only one
    NSArray* resPaths = project.absoluteResourcePaths;
    if (resPaths.count > 0)
    {
        NSString* resPath = [resPaths objectAtIndex:0];
        
        NSArray* resDir = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resPath error:NULL];
        
        int numCCBFiles = 0;
        NSString* ccbFile = NULL;
        for (NSString* file in resDir)
        {
            if ([file hasSuffix:@".ccb"])
            {
                ccbFile = file;
                numCCBFiles++;
                
                if (numCCBFiles > 1) break;
            }
        }
        
        if (numCCBFiles == 1)
        {
            // Open the ccb file
            [self openFile:[resPath stringByAppendingPathComponent:ccbFile]];
        }
    }
    
    return YES;
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
    
    // Remove selections
    [self setSelectedNodes:NULL];
    
    // Make sure timeline is up to date
    [sequenceHandler updatePropertiesToTimelinePosition];
    
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

- (void) newJSFile:(NSString*) fileName
{
    NSData* jsData = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    [jsData writeToFile:fileName atomically:YES];
    
    [self openJSFile:fileName];
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
    
    [[CocosScene cocosScene].notesLayer removeAllNotes];
    
    self.selectedNodes = NULL;
    [[CocosScene cocosScene] setStageSize:stageSize centeredOrigin:origin];
    
    // Create new node
    [[CocosScene cocosScene] replaceRootNodeWith:[[PlugInManager sharedManager] createDefaultNodeOfType:type]];
    
    // Set default contentSize to 100% x 100%
    if (([type isEqualToString:@"CCNode"] || [type isEqualToString:@"CCLayer"])
        && stageSize.width != 0 && stageSize.height != 0)
    {
        [PositionPropertySetter setSize:NSMakeSize(100, 100) type:kCCBSizeTypePercent forNode:[CocosScene cocosScene].rootNode prop:@"contentSize"];
    }
    
    [outlineHierarchy reloadData];
    [sequenceHandler updateOutlineViewSelection];
    [self updateInspectorFromSelection];
    
    self.currentDocument = [[[CCBDocument alloc] init] autorelease];
    self.currentDocument.resolutions = resolutions;
    self.currentDocument.currentResolution = 0;
    [self updateResolutionMenu];
    
    [self saveFile:fileName];
    
    [self addDocument:currentDocument];
    
    // Setup a default timeline
    NSMutableArray* sequences = [NSMutableArray array];
    
    SequencerSequence* seq = [[[SequencerSequence alloc] init] autorelease];
    seq.name = @"Default Timeline";
    seq.sequenceId = 0;
    seq.autoPlay = YES;
    [sequences addObject:seq];
    
    currentDocument.sequences = sequences;
    sequenceHandler.currentSequence = seq;
    
    
    self.hasOpenedDocument = YES;
    
    [self updateStateOriginCenteredMenu];
    
    [[CocosScene cocosScene] setStageZoom:1];
    [[CocosScene cocosScene] setScrollOffset:ccp(0,0)];
    
    [self checkForTooManyDirectoriesInCurrentDoc];
}

/*
- (BOOL) application:(NSApplication *)sender openFile:(NSString *)filename
{
    [self openProject:filename];
    return YES;
}*/

- (NSString*) findProject:(NSString*) path
{
	NSString* projectFile = nil;
	NSFileManager* fm = [NSFileManager defaultManager];
    
	NSArray* files = [fm contentsOfDirectoryAtPath:path error:NULL];
	for( NSString* file in files )
	{
		if( [file hasSuffix:@".ccbproj"] )
		{
			projectFile = [path stringByAppendingPathComponent:file];
			break;
		}
	}
	return projectFile;
}

- (void)openFiles:(NSArray*)filenames
{
	for( NSString* filename in filenames )
	{
		if( [filename hasSuffix:@".ccb"] )
		{
			NSString* folderPathToSearch = [filename stringByDeletingLastPathComponent];
			NSString* projectFile = [self findProject:folderPathToSearch];
			if( projectFile )
			{
				[self openProject:projectFile];
				[self openFile:filename];
			}
		}
		else if ([filename hasSuffix:@".ccbproj"])
		{
			[self openProject:filename];		
		}
	}
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
	// if resManager isn't initialized wait for it to initialize before opening assets.	
	if(!resManager)
	{
		NSAssert( delayOpenFiles == NULL, @"This shouldn't be set to anything since this value will only get applied once.");
		delayOpenFiles = [[NSMutableArray alloc] initWithArray:filenames];
	}
	else 
	{
		[self openFiles:filenames];
	}
}

- (void) openJSFile:(NSString*) fileName
{
    [self openJSFile:fileName highlightLine:0];
}

- (void) openJSFile:(NSString*) fileName highlightLine:(int)line
{
    NSURL* docURL = [[[NSURL alloc] initFileURLWithPath:fileName] autorelease];
    
    JavaScriptDocument* jsDoc = [[NSDocumentController sharedDocumentController] documentForURL:docURL];
    
    if (!jsDoc)
    {
        jsDoc = [[[JavaScriptDocument alloc] initWithContentsOfURL:docURL ofType:@"JavaScript" error:NULL] autorelease];
        [[NSDocumentController sharedDocumentController] addDocument:jsDoc];
        [jsDoc makeWindowControllers];
    }
    
    [jsDoc showWindows];
    [jsDoc setHighlightedLine:line];
}

- (void) resetJSFilesLineHighlight
{
    NSArray* jsDocs = [[NSDocumentController sharedDocumentController] documents];
    for (int i = 0; i < [jsDocs count]; i++)
    {
        JavaScriptDocument* doc = [jsDocs objectAtIndex:i];
        [doc setHighlightedLine:0];
    }
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
        //[self modalDialogTitle:@"Failed to add item" message:[NSString stringWithFormat: @"You cannot add children to a %@",nodeInfoParent.plugIn.nodeClassName]];
        self.errorDescription = [NSString stringWithFormat: @"You cannot add children to a %@",nodeInfoParent.plugIn.nodeClassName];
        return NO;
    }
    
    // Check if the added node requires a specific type of parent
    NSString* requireParent = nodeInfo.plugIn.requireParentClass;
    if (requireParent && ![requireParent isEqualToString: nodeInfoParent.plugIn.nodeClassName])
    {
        //[self modalDialogTitle:@"Failed to add item" message:[NSString stringWithFormat: @"A %@ must be added to a %@",nodeInfo.plugIn.nodeClassName, requireParent]];
        self.errorDescription = [NSString stringWithFormat: @"A %@ must be added to a %@",nodeInfo.plugIn.nodeClassName, requireParent];
        return NO;
    }
    
    // Check if the parent require a specific type of children
    NSArray* requireChild = nodeInfoParent.plugIn.requireChildClass;
    if (requireChild && [requireChild indexOfObject:nodeInfo.plugIn.nodeClassName] == NSNotFound)
    {
        //[self modalDialogTitle:@"Failed to add item" message:[NSString stringWithFormat: @"You cannot add a %@ to a %@",nodeInfo.plugIn.nodeClassName, nodeInfoParent.plugIn.nodeClassName]];
        self.errorDescription = [NSString stringWithFormat: @"You cannot add a %@ to a %@",nodeInfo.plugIn.nodeClassName, nodeInfoParent.plugIn.nodeClassName];
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
    [self setSelectedNodes: [NSArray arrayWithObject: obj]];
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
    if (!self.selectedNode) parent = g.rootNode;
    else if (self.selectedNode == g.rootNode) parent = g.rootNode;
    else parent = self.selectedNode.parent;
    
    if (asChild)
    {
        parent = self.selectedNode;
        if (!parent) self.selectedNodes = [NSArray arrayWithObject: g.rootNode];
    }
    
    BOOL success = [self addCCObject:obj toParent:parent];
    
    if (!success && !asChild)
    {
        // If failed to add the object, attempt to add it as a child instead
        return [self addCCObject:obj asChild:YES];
    }
    
    return success;
}

- (void) addPlugInNodeNamed:(NSString*)name asChild:(BOOL) asChild
{
    self.errorDescription = NULL;
    CCNode* node = [plugInManager createDefaultNodeOfType:name];
    BOOL success = [self addCCObject:node asChild:asChild];
    
    if (!success && self.errorDescription)
    {
        [self modalDialogTitle:@"Failed to Add Object" message:self.errorDescription];
    }
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
        
        // Round position
        pt.x = roundf(pt.x);
        pt.y = roundf(pt.y);
        
        // Set its position
        [PositionPropertySetter setPosition:NSPointFromCGPoint(pt) forNode:node prop:@"position"];
        
        [CCBReaderInternal setProp:prop ofType:@"SpriteFrame" toValue:[NSArray arrayWithObjects:spriteSheetFile, spriteFile, nil] forNode:node parentSize:CGSizeZero];
        // Set it's displayName to the name of the spriteFile
        node.displayName = [[spriteFile lastPathComponent] stringByDeletingPathExtension];
        [self addCCObject:node toParent:parent];
    }
}

- (void) dropAddSpriteNamed:(NSString*)spriteFile inSpriteSheet:(NSString*)spriteSheetFile at:(CGPoint)pt
{
    // Sprite dropped in working canvas
    
    CCNode* node = self.selectedNode;
    if (!node) node = [CocosScene cocosScene].rootNode;
    
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

- (void) dropAddCCBFileNamed:(NSString*)ccbFile at:(CGPoint)pt parent:(CCNode*)parent
{
    if (!parent)
    {
        if (self.selectedNode != [CocosScene cocosScene].rootNode)
        {
            parent = self.selectedNode.parent;
        }
        if (!parent) parent = [CocosScene cocosScene].rootNode;
        
        pt = [parent convertToNodeSpace:pt];
    }
    
    CCNode* node = [plugInManager createDefaultNodeOfType:@"CCBFile"];
    [NodeGraphPropertySetter setNodeGraphForNode:node andProperty:@"ccbFile" withFile:ccbFile parentSize:parent.contentSize];
    [PositionPropertySetter setPosition:NSPointFromCGPoint(pt) type:kCCBPositionTypeRelativeBottomLeft forNode:node prop:@"position" parentSize:parent.contentSize];
    [self addCCObject:node toParent:parent];
}


- (IBAction) copy:(id) sender
{
    // Copy keyframes
    
    NSArray* keyframes = [sequenceHandler selectedKeyframesForCurrentSequence];
    if ([keyframes count] > 0)
    {
        NSMutableSet* propsSet = [NSMutableSet set];
        NSMutableSet* seqsSet = [NSMutableSet set];
        BOOL duplicatedProps = NO;
        BOOL hasNodeKeyframes = NO;
        BOOL hasChannelKeyframes = NO;
        
        for (int i = 0; i < keyframes.count; i++)
        {
            SequencerKeyframe* keyframe = [keyframes objectAtIndex:i];
            
            NSValue* seqVal = [NSValue valueWithPointer:keyframe.parent];
            if (![seqsSet containsObject:seqVal])
            {
                NSString* propName = keyframe.name;
                
                if (propName)
                {
                    if ([propsSet containsObject:propName])
                    {
                        duplicatedProps = YES;
                        break;
                    }
                    [propsSet addObject:propName];
                    [seqsSet addObject:seqVal];
                    
                    hasNodeKeyframes = YES;
                }
                else
                {
                    hasChannelKeyframes = YES;
                }
            }
        }
        
        if (duplicatedProps)
        {
            [self modalDialogTitle:@"Failed to Copy" message:@"You can only copy keyframes from one node."];
            return;
        }
        
        if (hasChannelKeyframes && hasNodeKeyframes)
        {
            [self modalDialogTitle:@"Failed to Copy" message:@"You cannot copy sound/callback keyframes and node keyframes at once."];
            return;
        }
        
        NSString* clipType = @"com.cocosbuilder.keyframes";
        if (hasChannelKeyframes)
        {
            clipType = @"com.cocosbuilder.channelkeyframes";
        }
        
        // Serialize keyframe
        NSMutableArray* serKeyframes = [NSMutableArray array];
        for (SequencerKeyframe* keyframe in keyframes)
        {
            [serKeyframes addObject:[keyframe serialization]];
        }
        NSData* clipData = [NSKeyedArchiver archivedDataWithRootObject:serKeyframes];
        NSPasteboard* cb = [NSPasteboard generalPasteboard];
        [cb declareTypes:[NSArray arrayWithObject:clipType] owner:self];
        [cb setData:clipData forType:clipType];
        
        return;
    }
    
    // Copy node
    if (!self.selectedNode) return;
    
    // Serialize selected node
    NSMutableDictionary* clipDict = [CCBWriterInternal dictionaryFromCCObject:self.selectedNode];
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
        if (asChild) parentSize = self.selectedNode.contentSize;
        else parentSize = self.selectedNode.parent.contentSize;
        
        CCNode* clipNode = [CCBReaderInternal nodeGraphFromDictionary:clipDict parentSize:parentSize];
        [self addCCObject:clipNode asChild:asChild];
    }
}

- (IBAction) paste:(id) sender
{
    if (!currentDocument) return;
    
    // Paste keyframes
    NSPasteboard* cb = [NSPasteboard generalPasteboard];
    NSString* type = [cb availableTypeFromArray:[NSArray arrayWithObjects:@"com.cocosbuilder.keyframes", @"com.cocosbuilder.channelkeyframes", nil]];
    
    if (type)
    {
        if (!self.selectedNode && [type isEqualToString:@"com.cocosbuilder.keyframes"])
        {
            [self modalDialogTitle:@"Paste Failed" message:@"You need to select a node to paste keyframes"];
            return;
        }
            
        // Unarchive keyframes
        NSData* clipData = [cb dataForType:type];
        NSMutableArray* serKeyframes = [NSKeyedUnarchiver unarchiveObjectWithData:clipData];
        NSMutableArray* keyframes = [NSMutableArray array];
        
        // Save keyframes and find time of first kf
        float firstTime = MAXFLOAT;
        for (id serKeyframe in serKeyframes)
        {
            SequencerKeyframe* keyframe = [[[SequencerKeyframe alloc] initWithSerialization:serKeyframe] autorelease];
            if (keyframe.time < firstTime)
            {
                firstTime = keyframe.time;
            }
            [keyframes addObject:keyframe];
        }
            
        // Adjust times and add keyframes
        SequencerSequence* seq = sequenceHandler.currentSequence;
        
        NSLog(@"keyframes: %@", keyframes);
        
        for (SequencerKeyframe* keyframe in keyframes)
        {
            // Adjust time
            keyframe.time = [seq alignTimeToResolution:keyframe.time - firstTime + seq.timelinePosition];
            
            // Add the keyframe
            if ([type isEqualToString:@"com.cocosbuilder.keyframes"])
            {
                [self.selectedNode addKeyframe:keyframe forProperty:keyframe.name atTime:keyframe.time sequenceId:seq.sequenceId];
            }
            else if ([type isEqualToString:@"com.cocosbuilder.channelkeyframes"])
            {
                if (keyframe.type == kCCBKeyframeTypeCallbacks)
                {
                    [seq.callbackChannel.seqNodeProp setKeyframe:keyframe];
                }
                else if (keyframe.type == kCCBKeyframeTypeSoundEffects)
                {
                    [seq.soundChannel.seqNodeProp setKeyframe:keyframe];
                }
                [[SequencerHandler sharedHandler] redrawTimeline];
            }
        }
        
    }
    
    // Paste nodes
    [self doPasteAsChild:NO];
}

- (IBAction) pasteAsChild:(id)sender
{
    [self doPasteAsChild:YES];
}

- (void) deleteNode:(CCNode*)node
{
    CCBGlobals* g = [CCBGlobals globals];
    
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
    
    self.selectedNodes = NULL;
    [sequenceHandler updateOutlineViewSelection];
}

- (IBAction) delete:(id) sender
{
    // First attempt to delete selected keyframes
    if ([sequenceHandler deleteSelectedKeyframesForCurrentSequence]) return;
    
    // Then delete the selected node
    NSArray* nodesToDelete = [NSArray arrayWithArray:self.selectedNodes];
    for (CCNode* node in nodesToDelete)
    {
        [self deleteNode:node];
    }
}

- (IBAction) cut:(id) sender
{
    CCBGlobals* g = [CCBGlobals globals];
    if (self.selectedNode == g.rootNode)
    {
        [self modalDialogTitle:@"Failed to cut object" message:@"The root node cannot be removed"];
        return;
    }
    
    [self copy:sender];
    [self delete:sender];
}

- (void) moveSelectedObjectWithDelta:(CGPoint)delta
{
    if (self.selectedNodes.count == 0) return;
    
    for (CCNode* selectedNode in self.selectedNodes)
    {
        [self saveUndoStateWillChangeProperty:@"position"];
        
        // Get and update absolute position
        CGPoint absPos = selectedNode.position;
        absPos = ccpAdd(absPos, delta);
        
        // Convert to relative position
        CGSize parentSize = [PositionPropertySetter getParentSize:selectedNode];
        int positionType = [PositionPropertySetter positionTypeForNode:selectedNode prop:@"position"];
        NSPoint newPos = [PositionPropertySetter calcRelativePositionFromAbsolute:NSPointFromCGPoint(absPos) type:positionType parentSize:parentSize];
        
        // Update the selected node
        [PositionPropertySetter setPosition:newPos forNode:selectedNode prop:@"position"];
        [PositionPropertySetter addPositionKeyframeForNode:selectedNode];
        
        [self refreshProperty:@"position"];
    }
}

- (IBAction) menuNudgeObject:(id)sender
{
    int dir = (int)[sender tag];
    
    if (self.selectedNodes.count == 0) return;
    
    CGPoint delta = CGPointZero;
    if (dir == 0) delta = ccp(-1, 0);
    else if (dir == 1) delta = ccp(1, 0);
    else if (dir == 2) delta = ccp(0, 1);
    else if (dir == 3) delta = ccp(0, -1);
    
    [self moveSelectedObjectWithDelta:delta];
}

- (IBAction) menuMoveObject:(id)sender
{
    int dir = (int)[sender tag];
    
    if (self.selectedNodes.count == 0) return;
    
    CGPoint delta = CGPointZero;
    if (dir == 0) delta = ccp(-10, 0);
    else if (dir == 1) delta = ccp(10, 0);
    else if (dir == 2) delta = ccp(0, 10);
    else if (dir == 3) delta = ccp(0, -10);
    
    [self moveSelectedObjectWithDelta:delta];
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
            NSString *filename = [[saveDlg URL] path];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0),
                           dispatch_get_current_queue(), ^{
                [[[CCDirector sharedDirector] view] lockOpenGLContext];
                
                // Save file to new path
                [self saveFile:filename];
                
                // Close document
                [tabView removeTabViewItem:[self tabViewItemFromDoc:currentDocument]];
                
                // Open newly created document
                [self openFile:filename];
                
                [[[CCDirector sharedDirector] view] unlockOpenGLContext];
            });
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

- (IBAction) saveAllDocuments:(id)sender
{
    // Save all JS files
    //[[NSDocumentController sharedDocumentController] saveAllDocuments:sender]; //This API have no effects
    NSArray* JSDocs = [[NSDocumentController sharedDocumentController] documents];
    for (int i = 0; i < [JSDocs count]; i++)
    {
        NSDocument* doc = [JSDocs objectAtIndex:i];
        if (doc.isDocumentEdited)
        {
            [doc saveDocument:sender];
        }
    }
    
    // Save all CCB files
    CCBDocument* oldCurDoc = currentDocument;
    NSArray* docs = [tabView tabViewItems];
    for (int i = 0; i < [docs count]; i++)
    {
        CCBDocument* doc = [(NSTabViewItem*)[docs objectAtIndex:i] identifier];
         if (doc.isDirty)
         {
             [self switchToDocument:doc forceReload:NO];
             [self saveDocument:sender];
         }
    }
    [self switchToDocument:oldCurDoc forceReload:NO];
}

- (void) publishAndRun:(BOOL)run runInBrowser:(NSString *)browser
{
    if (!projectSettings.publishEnabledAndroid
        && !projectSettings.publishEnablediPhone
        && !projectSettings.publishEnabledHTML5)
    {
        [self modalDialogTitle:@"Published Failed" message:@"There are no configured publish target platforms. Please check your Publish Settings."];
        return;
    }
    
    if (run && !browser && ![[PlayerConnection sharedPlayerConnection] connected])
    {
        [self modalDialogTitle:@"No Player Connected" message:@"There is no CocosPlayer connected to CocosBuilder. Make sure that a player is running and that it has the same pairing number as CocosBuilder."];
        return;
    }
    
    CCBWarnings* warnings = [[[CCBWarnings alloc] init] autorelease];
    warnings.warningsDescription = @"Publisher Warnings";
    
    // Setup publisher, publisher is released in publisher:finishedWithWarnings:
    CCBPublisher* publisher = [[CCBPublisher alloc] initWithProjectSettings:projectSettings warnings:warnings];
    publisher.runAfterPublishing = run;
    publisher.browser = browser;
    
    // Check if there are unsaved documents
    if ([self hasDirtyDocument])
    {
        NSAlert* alert = [NSAlert alertWithMessageText:@"Publish Project" defaultButton:@"Save All" alternateButton:@"Cancel" otherButton:@"Don't Save" informativeTextWithFormat:@"There are unsaved documents. Do you want to save before publishing?"];
        [alert setAlertStyle:NSWarningAlertStyle];
        NSInteger result = [alert runModal];
        switch (result) {
            case NSAlertDefaultReturn:
                [self saveAllDocuments:nil];
                // Falling through to publish
            case NSAlertOtherReturn:
                // Open progress window and publish
                [publisher publish];
                [self modalStatusWindowStartWithTitle:@"Publishing"];
                [self modalStatusWindowUpdateStatusText:@"Starting up..."];
                break;
            default:
                break;
        }
    }
    else
    {
        // Open progress window and publish
        [publisher publish];
        [self modalStatusWindowStartWithTitle:@"Publishing"];
        [self modalStatusWindowUpdateStatusText:@"Starting up..."];
    }
}

- (void) publisher:(CCBPublisher*)publisher finishedWithWarnings:(CCBWarnings*)warnings
{
    [self modalStatusWindowFinish];
    
    // Create warnings window if it is not already created
    if (!publishWarningsWindow)
    {
        publishWarningsWindow = [[WarningsWindow alloc] initWithWindowNibName:@"WarningsWindow"];
    }
    
    // Update and show warnings window
    publishWarningsWindow.warnings = warnings;
    
    [[publishWarningsWindow window] setIsVisible:(warnings.warnings.count > 0)];
    
    // Run in Browser
    if (publisher.runAfterPublishing && publisher.browser)
    {
        [[CCBHTTPServer sharedHTTPServer] openBrowser:publisher.browser];
        [self updateDefaultBrowser];
    }
    
    // Run in CocosPlayer
    if (publisher.runAfterPublishing && !publisher.browser)
    {
        [self runProject:self];
    }
    
    [publisher release];
}

- (IBAction)openCocosPlayerConsole:(id)sender
{
    if (!playerConsoleWindow)
    {
        playerConsoleWindow = [[PlayerConsoleWindow alloc] initWithWindowNibName:@"PlayerConsoleWindow"];
    }
    [playerConsoleWindow.window makeKeyAndOrderFront:self];
}

- (IBAction)runProject:(id)sender
{
    // Open CocosPlayer console
    [self openCocosPlayerConsole:sender];
    
    [playerConsoleWindow cleanConsole];
    
    if ([[PlayerConnection sharedPlayerConnection] connected])
    {
        [[PlayerConnection sharedPlayerConnection] sendProjectSettings:projectSettings];
        [[PlayerConnection sharedPlayerConnection] sendRunCommand];
    }
}

- (IBAction) menuPublishProject:(id)sender
{
    [self publishAndRun:NO runInBrowser:NULL];
}

- (IBAction) menuPublishProjectAndRun:(id)sender
{
    [self publishAndRun:YES runInBrowser:NULL];
}

- (IBAction)menuPublishProjectAndRunInBrowser:(id)sender
{
    NSMenuItem* item = (NSMenuItem *)sender;
    [self publishAndRun:YES runInBrowser:item.title];
}

- (IBAction) menuCleanCacheDirectories:(id)sender
{
    projectSettings.needRepublish = YES;
    [projectSettings store];
    [CCBPublisher cleanAllCacheDirectories];
}

// Temporary utility function until new publish system is in place
- (IBAction)menuUpdateCCBsInDirectory:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    
    [openDlg beginSheetModalForWindow:window completionHandler:^(NSInteger result){
        if (result == NSOKButton)
        {
            NSArray* files = [openDlg URLs];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0),
                           dispatch_get_current_queue(), ^{
                [[[CCDirector sharedDirector] view] lockOpenGLContext];
                
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
                            [self performClose:sender];
                        }
                    }
                }
                
                [[[CCDirector sharedDirector] view] unlockOpenGLContext];
            });
        }
    }];
}

- (IBAction) menuProjectSettings:(id)sender
{
    if (!projectSettings) return;
    
    ProjectSettingsWindow* wc = [[[ProjectSettingsWindow alloc] initWithWindowNibName:@"ProjectSettingsWindow"] autorelease];
    wc.projectSettings = self.projectSettings;
    
    int success = [wc runModalSheetForWindow:window];
    if (success)
    {
        [self.projectSettings store];
        [self updateResourcePathsFromProjectSettings];
        [self menuCleanCacheDirectories:sender];
        [self reloadResources];
    }
}

- (IBAction) menuPublishSettings:(id)sender
{
    if (!projectSettings) return;
    
    PublishSettingsWindow* wc = [[[PublishSettingsWindow alloc] initWithWindowNibName:@"PublishSettingsWindow"] autorelease];
    wc.projectSettings = self.projectSettings;
    
    int success = [wc runModalSheetForWindow:window];
    if (success)
    {
        [self.projectSettings store];
        [self updateResourcePathsFromProjectSettings];
        [self menuCleanCacheDirectories:sender];
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
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0),
                           dispatch_get_current_queue(), ^{
                for (int i = 0; i < [files count]; i++)
                {
                    NSString* fileName = [[files objectAtIndex:i] path];
                    [self openProject:fileName];
                }
            });
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
    //[saveDlg setAllowedFileTypes:[NSArray arrayWithObject:@""]];
    //saveDlg.message = @"Save your project file in the same directory as your projects resources.";
    
    [saveDlg beginSheetModalForWindow:window completionHandler:^(NSInteger result){
        if (result == NSOKButton)
        {
            NSString* fileName = [[saveDlg URL] path];
            [[NSFileManager defaultManager] createDirectoryAtPath:fileName withIntermediateDirectories:NO attributes:NULL error:NULL];
            NSString* projectName = [fileName lastPathComponent];
            fileName = [[fileName stringByAppendingPathComponent:projectName] stringByAppendingPathExtension:@"ccbproj"];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0),
                           dispatch_get_current_queue(), ^{
                if ([self createProject: fileName])
                {
                    [self openProject:fileName];
                }
                else
                {
                    [self modalDialogTitle:@"Failed to Create Project" message:@"Failed to create the project, make sure you are saving it to a writable directory."];
                }
            });
        }
    }];
}

- (IBAction) newJSDocument:(id)sender
{
    NSLog(@"New JS Doc");
    
    NSSavePanel* saveDlg = [NSSavePanel savePanel];
    [saveDlg setAllowedFileTypes:[NSArray arrayWithObject:@"js"]];
    
    SavePanelLimiter* limiter = [[SavePanelLimiter alloc] initWithPanel:saveDlg resManager:resManager];
    
    [saveDlg beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        if (result == NSOKButton)
        {
            [self newJSFile:[[saveDlg URL] path]];
        }
        [limiter release];
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
        
        SavePanelLimiter* limiter = [[SavePanelLimiter alloc] initWithPanel:saveDlg resManager:resManager];
        
        [saveDlg beginSheetModalForWindow:window completionHandler:^(NSInteger result){
            if (result == NSOKButton)
            {
                NSString *type = wc.rootObjectType;
                NSMutableArray *resolutions = wc.availableResolutions;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0),
                               dispatch_get_current_queue(), ^{
                    [self newFile:[[saveDlg URL] path] type:type resolutions:resolutions];
                });
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

- (IBAction) performClose:(id)sender
{
    NSLog(@"performClose (AppDelegate)");
    
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
    [[CocosScene cocosScene] selectBehind];
}

- (IBAction) menuDeselect:(id)sender
{
    [self setSelectedNodes:NULL];
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
    for (int i = 1; i <= kCCBNumCanvasDevices; i++)
    {
        if (size.width == defaultCanvasSizes[i].width && size.height == defaultCanvasSizes[i].height) return i;
    }
    return 0;
}

- (void) setResolution:(int)r
{
    
    currentDocument.currentResolution = r;
    
    //
    // No need to call setStageSize here, since it gets called from reloadResources
    //
    //CocosScene* cs = [CocosScene cocosScene];
    //ResolutionSetting* resolution = [currentDocument.resolutions objectAtIndex:r];
    //[cs setStageSize:CGSizeMake(resolution.width, resolution.height) centeredOrigin:[cs centeredOrigin]];
    
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
    [self updateCanvasBorderMenu];
}

- (IBAction)menuEditCustomPropSettings:(id)sender
{
    if (!currentDocument) return;
    if (!self.selectedNode) return;
    
    NSString* customClass = [self.selectedNode extraPropForKey:@"customClass"];
    if (!customClass || [customClass isEqualToString:@""])
    {
        [self modalDialogTitle:@"Custom Class Needed" message:@"To add custom properties to a node you need to use a custom class."];
        return;
    }
    
    CustomPropSettingsWindow* wc = [[[CustomPropSettingsWindow alloc] initWithWindowNibName:@"CustomPropSettingsWindow"] autorelease];
    [wc copySettingsForNode:self.selectedNode];
    
    int success = [wc runModalSheetForWindow:window];
    if (success)
    {
        [self saveUndoStateWillChangeProperty:@"*customPropSettings"];
        self.selectedNode.customProperties = wc.settings;
        [self updateInspectorFromSelection];
    }
}

- (void) updateStateOriginCenteredMenu
{
    CocosScene* cs = [CocosScene cocosScene];
    BOOL centered = [cs centeredOrigin];
    
    if (centered) [menuItemStageCentered setState:NSOnState];
    else [menuItemStageCentered setState:NSOffState];
}

- (IBAction) menuSetStateOriginCentered:(id)sender
{
    CocosScene* cs = [CocosScene cocosScene];
    BOOL centered = ![cs centeredOrigin];
    
    [self saveUndoState];
    [cs setStageSize:[cs stageSize] centeredOrigin:centered];
    
    [self updateStateOriginCenteredMenu];
}

- (void) updateCanvasBorderMenu
{
    CocosScene* cs = [CocosScene cocosScene];
    int tag = [cs stageBorder];
    [CCBUtil setSelectedSubmenuItemForMenu:menuCanvasBorder tag:tag];
}

- (void) updateJSControlledMenu
{
    if (jsControlled)
    {
        [menuItemJSControlled setState:NSOnState];
    }
    else
    {
        [menuItemJSControlled setState:NSOffState];
    }
}

- (void) updateDefaultBrowser
{
    [menuItemSafari setKeyEquivalent:@""];
    [menuItemSafari setState:NSOffState];
    [menuItemChrome setKeyEquivalent:@""];
    [menuItemChrome setState:NSOffState];
    [menuItemFirefox setKeyEquivalent:@""];
    [menuItemFirefox setState:NSOffState];
    
    NSString* defaultBrowser = [[NSUserDefaults standardUserDefaults] valueForKey:@"defaultBrowser"];
    NSMenuItem* defaultBrowserMenuItem;
    if([defaultBrowser isEqual:@"Chrome"])
    {
        defaultBrowserMenuItem = menuItemChrome;
    }else if([defaultBrowser isEqual:@"Firefox"])
    {
        defaultBrowserMenuItem = menuItemFirefox;
    }else{
        defaultBrowserMenuItem = menuItemSafari;
    }
    [defaultBrowserMenuItem setKeyEquivalentModifierMask: NSShiftKeyMask | NSCommandKeyMask];
    [defaultBrowserMenuItem setKeyEquivalent:@"b"];
    [defaultBrowserMenuItem setState:NSOnState];
}

- (IBAction) menuSetCanvasBorder:(id)sender
{
    CocosScene* cs = [CocosScene cocosScene];
    
    int tag = (int)[sender tag];
    [cs setStageBorder:tag];
}

- (IBAction) menuZoomIn:(id)sender
{
    CocosScene* cs = [CocosScene cocosScene];
    
    float zoom = [cs stageZoom];
    zoom *= 1.2;
    if (zoom > 8) zoom = 8;
    [cs setStageZoom:zoom];
}

- (IBAction) menuZoomOut:(id)sender
{
    CocosScene* cs = [CocosScene cocosScene];
    
    float zoom = [cs stageZoom];
    zoom *= 1/1.2f;
    if (zoom < 0.125) zoom = 0.125f;
    [cs setStageZoom:zoom];
}

- (IBAction) menuResetView:(id)sender
{
    CocosScene* cs = [CocosScene cocosScene];
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
    CocosScene* cs = [CocosScene cocosScene];
    NSSegmentedControl* sc = sender;
    
    cs.currentTool = [sc selectedSegment];
}

- (IBAction) pressedPanelVisibility:(id)sender
{
    NSSegmentedControl* sc = sender;
    [window disableUpdatesUntilFlush];
    
    // Left Panel
    if ([sc isSelectedForSegment:0]) {
        
        if ([leftPanel isHidden]) {
            // Show left panel & shrink splitHorizontalView
            NSRect origRect = leftPanel.frame;
            NSRect transitionFrame = NSMakeRect(0,
                                                origRect.origin.y,
                                                origRect.size.width,
                                                origRect.size.height);
                                                     
            [leftPanel setFrame:transitionFrame];
            origRect = splitHorizontalView.frame;
            transitionFrame = NSMakeRect(leftPanel.frame.size.width,
                                         origRect.origin.y,
                                         origRect.size.width-leftPanel.frame.size.width,
                                         origRect.size.height);
                                               
            [splitHorizontalView setFrame:transitionFrame];
            
            [leftPanel setHidden:NO];
            [leftPanel setNeedsDisplay:YES];
            [splitHorizontalView setNeedsDisplay:YES];
        }
    } else {
        
        if (![leftPanel isHidden]) {
            // Hide left panel & expand splitView
            NSRect origRect = leftPanel.frame;
            NSRect transitionFrame = NSMakeRect(-origRect.size.width,
                                                 origRect.origin.y,
                                                 origRect.size.width,
                                                 origRect.size.height);
                                                      
            [leftPanel setFrame:transitionFrame];
            origRect = splitHorizontalView.frame;
            transitionFrame = NSMakeRect(0,
                                         origRect.origin.y,
                                         origRect.size.width+leftPanel.frame.size.width,
                                         origRect.size.height);
                                         
            [splitHorizontalView setFrame:transitionFrame];
            
            [leftPanel setHidden:YES];
            [leftPanel setNeedsDisplay:YES];
            [splitHorizontalView setNeedsDisplay:YES];
        }
    }
    
    
    // Right Panel (InspectorScroll)
    if ([sc isSelectedForSegment:2]) {
        
        if ([rightPanel isHidden]) {
            // Show right panel & shrink splitView
            [rightPanel setHidden:NO];
            NSRect origRect = rightPanel.frame;
            NSRect transitionFrame = NSMakeRect(origRect.origin.x-origRect.size.width,
                                                origRect.origin.y,
                                                origRect.size.width,
                                                origRect.size.height);
                                                
            [rightPanel setFrame:transitionFrame];
            origRect = splitHorizontalView.frame;
            transitionFrame = NSMakeRect(origRect.origin.x,
                                        origRect.origin.y,
                                        origRect.size.width-rightPanel.frame.size.width,
                                         origRect.size.height);
                                        
            [splitHorizontalView setFrame:transitionFrame];
            [rightPanel setNeedsDisplay:YES];
            [splitHorizontalView setNeedsDisplay:YES];
        }
    } else {
        
        if (![rightPanel isHidden]) {
            // Hide right panel & expand splitView
            NSRect origRect = rightPanel.frame;
            NSRect transitionFrame = NSMakeRect(origRect.origin.x+origRect.size.width,
                                                origRect.origin.y,
                                                origRect.size.width,
                                                origRect.size.height);
                                                      
            [rightPanel setFrame:transitionFrame];
            origRect = splitHorizontalView.frame;
            transitionFrame = NSMakeRect(origRect.origin.x,
                                         origRect.origin.y,
                                         origRect.size.width+rightPanel.frame.size.width,
                                         origRect.size.height);
                                               
            [splitHorizontalView setFrame:transitionFrame];
            [rightPanel setHidden:YES];
            [rightPanel setNeedsDisplay:YES];
            [splitHorizontalView setNeedsDisplay:YES];
        }
    }
    
    if ([sc selectedSegment] == 1) {
        [splitHorizontalView toggleBottomView:[sc isSelectedForSegment:1]];
    }
}

- (int) uniqueSequenceIdFromSequences:(NSArray*) seqs
{
    int maxId = -1;
    for (SequencerSequence* seqCheck in seqs)
    {
        if (seqCheck.sequenceId > maxId) maxId = seqCheck.sequenceId;
    }
    return maxId + 1;
}

- (IBAction)menuTimelineSettings:(id)sender
{
    if (!currentDocument) return;
    
    SequencerSettingsWindow* wc = [[[SequencerSettingsWindow alloc] initWithWindowNibName:@"SequencerSettingsWindow"] autorelease];
    [wc copySequences:currentDocument.sequences];
    
    int success = [wc runModalSheetForWindow:window];
    
    if (success)
    {
        // Successfully updated timeline settings
        
        // Check for deleted timelines
        for (SequencerSequence* seq in currentDocument.sequences)
        {
            BOOL foundSeq = NO;
            for (SequencerSequence* newSeq in wc.sequences)
            {
                if (seq.sequenceId == newSeq.sequenceId)
                {
                    foundSeq = YES;
                    break;
                }
            }
            if (!foundSeq)
            {
                // Sequence deleted, remove from all nodes
                [sequenceHandler deleteSequenceId:seq.sequenceId];
            }
        }
        
        // Assign id:s to new sequences
        for (SequencerSequence* seq in wc.sequences)
        {
            if (seq.sequenceId == -1)
            {
                // Find a unique id
                seq.sequenceId = [self uniqueSequenceIdFromSequences:wc.sequences];
            }
        }
    
        // Update the timelines
        currentDocument.sequences = wc.sequences;
        sequenceHandler.currentSequence = [currentDocument.sequences objectAtIndex:0];
    }
}

- (IBAction)menuTimelineNew:(id)sender
{
    if (!currentDocument) return;
    
    // Create new sequence and assign unique id
    SequencerSequence* newSeq = [[[SequencerSequence alloc] init] autorelease];
    newSeq.name = @"Untitled Timeline";
    newSeq.sequenceId = [self uniqueSequenceIdFromSequences:currentDocument.sequences];
    
    // Add it to list
    [currentDocument.sequences addObject:newSeq];
    
    // and set it to current
    sequenceHandler.currentSequence = newSeq;
}

- (IBAction)menuTimelineDuplicate:(id)sender
{
    if (!currentDocument) return;
    
    // Duplicate current timeline
    int newSeqId = [self uniqueSequenceIdFromSequences:currentDocument.sequences];
    SequencerSequence* newSeq = [sequenceHandler.currentSequence duplicateWithNewId:newSeqId];
    
    // Add it to list
    [currentDocument.sequences addObject:newSeq];
    
    // and set it to current
    sequenceHandler.currentSequence = newSeq;
}

- (IBAction)menuTimelineDuration:(id)sender
{
    if (!currentDocument) return;
    
    SequencerDurationWindow* wc = [[[SequencerDurationWindow alloc] initWithWindowNibName:@"SequencerDurationWindow"] autorelease];
    wc.duration = sequenceHandler.currentSequence.timelineLength;
    
    int success = [wc runModalSheetForWindow:window];
    if (success)
    {
        [sequenceHandler deleteKeyframesForCurrentSequenceAfterTime:wc.duration];
        sequenceHandler.currentSequence.timelineLength = wc.duration;
    }
}

- (IBAction) menuOpenResourceManager:(id)sender
{
    //[resManagerPanel.window setIsVisible:![resManagerPanel.window isVisible]];
}

- (void) reloadResources
{
    if (!currentDocument) return;
    
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
    FNTConfigRemoveCache();  
  
    [self switchToDocument:currentDocument forceReload:YES];
    [sequenceHandler updatePropertiesToTimelinePosition];
}

- (IBAction) menuAlignToPixels:(id)sender
{
    if (!currentDocument) return;
    if (self.selectedNodes.count == 0) return;
    
    [self saveUndoStateWillChangeProperty:@"*align"];
    
    // Check if node can have children
    for (CCNode* c in self.selectedNodes)
    {
        int positionType = [PositionPropertySetter positionTypeForNode:c prop:@"position"];
        if (positionType != kCCBPositionTypePercent)
        {
            CGPoint pos = NSPointToCGPoint([PositionPropertySetter positionForNode:c prop:@"position"]);
            pos = ccp(roundf(pos.x), roundf(pos.y));
            [PositionPropertySetter setPosition:NSPointFromCGPoint(pos) forNode:c prop:@"position"];
            [PositionPropertySetter addPositionKeyframeForNode:c];
        }
    }
    
    [self refreshProperty:@"position"];
}

- (void) menuAlignObjectsCenter:(id)sender alignmentType:(int)alignmentType
{
    // Find position
    float alignmentValue = 0;
    
    for (CCNode* node in self.selectedNodes)
    {
        if (alignmentType == kCCBAlignHorizontalCenter)
        {
            alignmentValue += node.position.x;
        }
        else if (alignmentType == kCCBAlignVerticalCenter)
        {
            alignmentValue += node.position.y;
        }
    }
    alignmentValue = alignmentValue/self.selectedNodes.count;
    
    // Align objects
    for (CCNode* node in self.selectedNodes)
    {
        CGPoint newAbsPosition = node.position;
        if (alignmentType == kCCBAlignHorizontalCenter)
        {
            newAbsPosition.x = alignmentValue;
        }
        else if (alignmentType == kCCBAlignVerticalCenter)
        {
            newAbsPosition.y = alignmentValue;
        }
        
        int posType = [PositionPropertySetter positionTypeForNode:node prop:@"position"];
        NSPoint newRelPos = [PositionPropertySetter calcRelativePositionFromAbsolute:NSPointFromCGPoint(newAbsPosition) type:posType parentSize:node.parent.contentSize];
        [PositionPropertySetter setPosition:newRelPos forNode:node prop:@"position"];
        [PositionPropertySetter addPositionKeyframeForNode:node];
    }
}

- (void) menuAlignObjectsEdge:(id)sender alignmentType:(int)alignmentType
{
    CGFloat x;
    CGFloat y;
    
    int nAnchor = self.selectedNodes.count - 1;
    CCNode* nodeAnchor = [self.selectedNodes objectAtIndex:nAnchor];
    
    for (int i = 0; i < self.selectedNodes.count - 1; ++i)
    {
        CCNode* node = [self.selectedNodes objectAtIndex:i];
        
        CGPoint newAbsPosition = node.position;
        
        switch (alignmentType)
        {
            case kCCBAlignLeft:
                x = nodeAnchor.position.x
                - nodeAnchor.contentSize.width * nodeAnchor.scaleX * nodeAnchor.anchorPoint.x;
                
                newAbsPosition.x = x
                + node.contentSize.width * node.scaleX * node.anchorPoint.x;
                break;
            case kCCBAlignRight:
                x = nodeAnchor.position.x
                + nodeAnchor.contentSize.width * nodeAnchor.scaleX * nodeAnchor.anchorPoint.x;
                
                newAbsPosition.x = x
                - node.contentSize.width * node.scaleX * node.anchorPoint.x;
                break;
            case kCCBAlignTop:
                y = nodeAnchor.position.y
                + nodeAnchor.contentSize.height * nodeAnchor.scaleY * nodeAnchor.anchorPoint.y;
                
                newAbsPosition.y = y
                - node.contentSize.height * node.scaleY * node.anchorPoint.y;
                break;
            case kCCBAlignBottom:
                y = nodeAnchor.position.y
                - nodeAnchor.contentSize.height * nodeAnchor.scaleY * nodeAnchor.anchorPoint.y;
                
                newAbsPosition.y = y
                + node.contentSize.height * node.scaleY * node.anchorPoint.y;
                break;
        }
        
        int posType = [PositionPropertySetter positionTypeForNode:node prop:@"position"];
        NSPoint newRelPos = [PositionPropertySetter calcRelativePositionFromAbsolute:NSPointFromCGPoint(newAbsPosition) type:posType parentSize:node.parent.contentSize];
        [PositionPropertySetter setPosition:newRelPos forNode:node prop:@"position"];
        [PositionPropertySetter addPositionKeyframeForNode:node];
    }
 }

- (void) menuAlignObjectsAcross:(id)sender alignmentType:(int)alignmentType
{
    CGFloat x;
    CGFloat cxNode;
    CGFloat xMin;
    CGFloat xMax;
    CGFloat cxTotal;
    CGFloat cxInterval;
    
    if (self.selectedNodes.count < 3)
        return;
    
    cxTotal = 0.0f;
    xMin = FLT_MAX;
    xMax = FLT_MIN;
    
    for (int i = 0; i < self.selectedNodes.count; ++i)
    {
        CCNode* node = [self.selectedNodes objectAtIndex:i];
        
        cxNode = node.contentSize.width * node.scaleX;
        
        x = node.position.x - cxNode * node.anchorPoint.x;
        
        if (xMin > x)
            xMin = x;
        
        if (xMax < x + cxNode)
            xMax = x + cxNode;
        
        cxTotal += cxNode;
    }
    
    cxInterval = (xMax - xMin - cxTotal) / (self.selectedNodes.count - 1);
    
    x = xMin;
    
    NSArray* sortedNodes = [self.selectedNodes sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CCNode* lhs = obj1;
        CCNode* rhs = obj2;
        if (lhs.position.x < rhs.position.x)
            return NSOrderedAscending;
        if (lhs.position.x > rhs.position.x)
            return NSOrderedDescending;
        return NSOrderedSame;
    }];
    
    for (int i = 0; i < self.selectedNodes.count; ++i)
    {
        CCNode* node = [sortedNodes objectAtIndex:i];
        
        CGPoint newAbsPosition = node.position;
        
        cxNode = node.contentSize.width * node.scaleX;
        
        newAbsPosition.x = x + cxNode * node.anchorPoint.x;
        
        x = x + cxNode + cxInterval;
        
        int posType = [PositionPropertySetter positionTypeForNode:node prop:@"position"];
        NSPoint newRelPos = [PositionPropertySetter calcRelativePositionFromAbsolute:NSPointFromCGPoint(newAbsPosition) type:posType parentSize:node.parent.contentSize];
        [PositionPropertySetter setPosition:newRelPos forNode:node prop:@"position"];
        [PositionPropertySetter addPositionKeyframeForNode:node];
    }
}


- (void) menuAlignObjectsDown:(id)sender alignmentType:(int)alignmentType
{
    CGFloat y;
    CGFloat cyNode;
    CGFloat yMin;
    CGFloat yMax;
    CGFloat cyTotal;
    CGFloat cyInterval;
    
    if (self.selectedNodes.count < 3)
        return;
    
    cyTotal = 0.0f;
    yMin = FLT_MAX;
    yMax = FLT_MIN;
    
    for (int i = 0; i < self.selectedNodes.count; ++i)
    {
        CCNode* node = [self.selectedNodes objectAtIndex:i];
        
        cyNode = node.contentSize.height * node.scaleY;
        
        y = node.position.y - cyNode * node.anchorPoint.y;
        
        if (yMin > y)
            yMin = y;
        
        if (yMax < y + cyNode)
            yMax = y + cyNode;
        
        cyTotal += cyNode;
    }
    
    cyInterval = (yMax - yMin - cyTotal) / (self.selectedNodes.count - 1);
    
    y = yMin;
    
    NSArray* sortedNodes = [self.selectedNodes sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CCNode* lhs = obj1;
        CCNode* rhs = obj2;
        if (lhs.position.y < rhs.position.y)
            return NSOrderedAscending;
        if (lhs.position.y > rhs.position.y)
            return NSOrderedDescending;
        return NSOrderedSame;
    }];

    for (int i = 0; i < self.selectedNodes.count; ++i)
    {
        CCNode* node = [sortedNodes objectAtIndex:i];
        
        CGPoint newAbsPosition = node.position;
        
        cyNode = node.contentSize.height * node.scaleY;
        
        newAbsPosition.y = y + cyNode * node.anchorPoint.y;
        
        y = y + cyNode + cyInterval;
        
        int posType = [PositionPropertySetter positionTypeForNode:node prop:@"position"];
        NSPoint newRelPos = [PositionPropertySetter calcRelativePositionFromAbsolute:NSPointFromCGPoint(newAbsPosition) type:posType parentSize:node.parent.contentSize];
        [PositionPropertySetter setPosition:newRelPos forNode:node prop:@"position"];
        [PositionPropertySetter addPositionKeyframeForNode:node];
    }
}

- (void) menuAlignObjectsSize:(id)sender alignmentType:(int)alignmentType
{
    CGFloat x;
    CGFloat y;
    
    int nAnchor = self.selectedNodes.count - 1;
    CCNode* nodeAnchor = [self.selectedNodes objectAtIndex:nAnchor];
 
    for (int i = 0; i < self.selectedNodes.count - 1; ++i)
    {
        CCNode* node = [self.selectedNodes objectAtIndex:i];
        
        switch (alignmentType)
        {
            case kCCBAlignSameWidth:
                x = nodeAnchor.contentSize.width * nodeAnchor.scaleX;
                if (abs(x) >= 0.0001f)
                    x /= node.contentSize.width;
                y = node.scaleY;
                break;
            case kCCBAlignSameHeight:
                x = node.scaleX;
                y = nodeAnchor.contentSize.height * nodeAnchor.scaleY;
                if (abs(y) >= 0.0001f)
                    y /= node.contentSize.height;
                break;
            case kCCBAlignSameSize:
                x = nodeAnchor.contentSize.width * nodeAnchor.scaleX;
                if (abs(x) >= 0.0001f)
                    x /= node.contentSize.width;
                y = nodeAnchor.contentSize.height * nodeAnchor.scaleY;
                if (abs(y) >= 0.0001f)
                    y /= node.contentSize.height;
                break;
        }

        int posType = [PositionPropertySetter positionTypeForNode:node prop:@"scale"];
        
        [PositionPropertySetter setScaledX:x Y:y type:posType forNode:node prop:@"scale"];
        [PositionPropertySetter addPositionKeyframeForNode:node];
    }
}


- (IBAction) menuAlignObjects:(id)sender
{
    if (!currentDocument)
        return;
    
    if (self.selectedNodes.count <= 1)
        return;
    
    [self saveUndoStateWillChangeProperty:@"*align"];
    
    int alignmentType = [sender tag];
    
    switch (alignmentType)
    {
        case kCCBAlignHorizontalCenter:
        case kCCBAlignVerticalCenter:
            [self menuAlignObjectsCenter:sender alignmentType:alignmentType];
            break;
        case kCCBAlignLeft:
        case kCCBAlignRight:
        case kCCBAlignTop:
        case kCCBAlignBottom:
            [self menuAlignObjectsEdge:sender alignmentType:alignmentType];
            break;
        case kCCBAlignAcross:
            [self menuAlignObjectsAcross:sender alignmentType:alignmentType];
            break;
        case kCCBAlignDown:
            [self menuAlignObjectsDown:sender alignmentType:alignmentType];
            break;
        case kCCBAlignSameSize:
        case kCCBAlignSameWidth:
        case kCCBAlignSameHeight:
            [self menuAlignObjectsSize:sender alignmentType:alignmentType];
            break;
    }
}


- (IBAction)menuArrange:(id)sender
{
    int type = [sender tag];
    
    CCNode* node = self.selectedNode;
    CCNode* parent = node.parent;
    
    CCArray* siblings = [node.parent children];
    
    // Check bounds
    if ((type == kCCBArrangeSendToBack || type == kCCBArrangeSendBackward)
        && node.zOrder == 0)
    {
        NSBeep();
        return;
    }
    
    if ((type == kCCBArrangeBringToFront || type == kCCBArrangeBringForward)
        && node.zOrder == siblings.count - 1)
    {
        NSBeep();
        return;
    }
    
    if (siblings.count < 2)
    {
        NSBeep();
        return;
    }
    
    int newIndex = 0;
    
    // Bring forward / send backward
    if (type == kCCBArrangeSendToBack)
    {
        newIndex = 0;
    }
    else if (type == kCCBArrangeBringToFront)
    {
        newIndex = siblings.count -1;
    }
    else if (type == kCCBArrangeSendBackward)
    {
        newIndex = node.zOrder - 1;
    }
    else if (type == kCCBArrangeBringForward)
    {
        newIndex = node.zOrder + 1;
    }
    
    [self deleteNode:node];
    [self addCCObject:node toParent:parent atIndex:newIndex];
}

- (IBAction)menuSetEasing:(id)sender
{
    int easingType = [sender tag];
    [sequenceHandler setContextKeyframeEasingType:easingType];
    [sequenceHandler updatePropertiesToTimelinePosition];
}

- (IBAction)menuSetEasingOption:(id)sender
{
    if (!currentDocument) return;
    
    float opt = [sequenceHandler.contextKeyframe.easing.options floatValue];
    
    
    SequencerKeyframeEasingWindow* wc = [[[SequencerKeyframeEasingWindow alloc] initWithWindowNibName:@"SequencerKeyframeEasingWindow"] autorelease];
    wc.option = opt;
    
    int type = sequenceHandler.contextKeyframe.easing.type;
    if (type == kCCBKeyframeEasingCubicIn
        || type == kCCBKeyframeEasingCubicOut
        || type == kCCBKeyframeEasingCubicInOut)
    {
        wc.optionName = @"Rate:";
    }
    else if (type == kCCBKeyframeEasingElasticIn
             || type == kCCBKeyframeEasingElasticOut
             || type == kCCBKeyframeEasingElasticInOut)
    {
        wc.optionName = @"Period:";
    }
    
    int success = [wc runModalSheetForWindow:window];
    if (success)
    {
        float newOpt = wc.option;
        
        if (newOpt != opt)
        {
            [self saveUndoStateWillChangeProperty:@"*keyframeeasingoption"];
            sequenceHandler.contextKeyframe.easing.options = [NSNumber numberWithFloat:wc.option];
            [sequenceHandler updatePropertiesToTimelinePosition];
        }
    }
}

- (IBAction)menuCreateKeyframesFromSelection:(id)sender
{
    [SequencerUtil createFramesFromSelectedResources];
}

- (IBAction)menuOpenExternal:(id)sender
{
    NSOutlineView* outlineView = [CocosBuilderAppDelegate appDelegate].outlineProject;
    
    NSUInteger idx = [sender tag];
    
    NSString* filename = [[outlineView itemAtRow:idx] filePath];
    if (![[NSWorkspace sharedWorkspace] openFile:filename])
    {
        NSRange slash = [filename rangeOfString:@"/" options:NSBackwardsSearch];
        
        if (slash.location != NSNotFound)
        {
            filename = [filename stringByReplacingCharactersInRange:slash withString: @"/resources-auto/"];
            // Try again
            [[NSWorkspace sharedWorkspace] openFile:filename];
        }
    }
}

- (IBAction)menuCreateSmartSpriteSheet:(id)sender
{
    int selectedRow = [sender tag];
    
    if (selectedRow >= 0 && projectSettings)
    {
        RMResource* res = [outlineProject itemAtRow:selectedRow];
        RMDirectory* dir = res.data;
        
        if (dir.isDynamicSpriteSheet)
        {
            [projectSettings removeSmartSpriteSheet:res];
        }
        else
        {
            [projectSettings makeSmartSpriteSheet:res];
        }
    }
}

- (IBAction)menuEditSmartSpriteSheet:(id)sender
{
    int selectedRow = [sender tag];
    
    if (selectedRow >= 0 && projectSettings)
    {
        RMResource* res = [outlineProject itemAtRow:selectedRow];
        
        ProjectSettingsGeneratedSpriteSheet* ssSettings = [projectSettings smartSpriteSheetForRes:res];
        if (!ssSettings) return;
        
        SpriteSheetSettingsWindow* wc = [[[SpriteSheetSettingsWindow alloc] initWithWindowNibName:@"SpriteSheetSettingsWindow"] autorelease];
        
        wc.compress = ssSettings.compress;
        wc.dither = ssSettings.dither;
        wc.textureFileFormat = ssSettings.textureFileFormat;
        wc.ditherAndroid = ssSettings.ditherAndroid;
        wc.textureFileFormatAndroid = ssSettings.textureFileFormatAndroid;
        wc.textureFileFormatHTML5 = ssSettings.textureFileFormatHTML5;
        wc.ditherHTML5 = ssSettings.ditherHTML5;
        wc.iOSEnabled = projectSettings.publishEnablediPhone;
        wc.androidEnabled = projectSettings.publishEnabledAndroid;
        wc.HTML5Enabled = projectSettings.publishEnabledHTML5;

        int success = [wc runModalSheetForWindow:window];
        
        if (success)
        {
            BOOL settingDirty  = (ssSettings.compress != wc.compress)||
                                 (ssSettings.dither != wc.dither)||
                                 (ssSettings.textureFileFormat != wc.textureFileFormat)||
                                 (ssSettings.ditherAndroid != wc.ditherAndroid)||
                                 (ssSettings.textureFileFormatAndroid != wc.textureFileFormatAndroid)||
                                 (ssSettings.textureFileFormatHTML5 != wc.textureFileFormatHTML5)||
                                 (ssSettings.ditherHTML5 != wc.ditherHTML5);
            if(settingDirty){
                ssSettings.isDirty = YES;
                ssSettings.compress = wc.compress;
                ssSettings.dither = wc.dither;
                ssSettings.textureFileFormat = wc.textureFileFormat;
                ssSettings.ditherAndroid = wc.ditherAndroid;
                ssSettings.textureFileFormatAndroid = wc.textureFileFormatAndroid;
                ssSettings.textureFileFormatHTML5 = wc.textureFileFormatHTML5;
                ssSettings.ditherHTML5 = wc.ditherHTML5;
                [projectSettings store];
            }
        }
    }
}

- (IBAction)menuAlignKeyframeToMarker:(id)sender
{
    [SequencerUtil alignKeyframesToMarker];
}

- (IBAction)menuStretchSelectedKeyframes:(id)sender
{
    SequencerStretchWindow* wc = [[[SequencerStretchWindow alloc] initWithWindowNibName:@"SequencerStretchWindow"] autorelease];
    wc.factor = 1;
    
    int success = [wc runModalSheetForWindow:window];
    if (success)
    {
        [SequencerUtil stretchSelectedKeyframes:wc.factor];
    }
}

- (IBAction)menuReverseSelectedKeyframes:(id)sender
{
    [SequencerUtil reverseSelectedKeyframes];
}

- (IBAction)menuAddStickyNote:(id)sender
{
    CocosScene* cs = [CocosScene cocosScene];
    [cs setStageZoom:1];
    self.showStickyNotes = YES;
    [cs.notesLayer addNote];
}

- (NSString*) keyframePropNameFromTag:(int)tag
{
    if (tag == 0) return @"visible";
    else if (tag == 1) return @"position";
    else if (tag == 2) return @"scale";
    else if (tag == 3) return @"rotation";
    else if (tag == 4) return @"displayFrame";
    else if (tag == 5) return @"opacity";
    else if (tag == 6) return @"color";
    else return NULL;
}

- (IBAction)menuAddKeyframe:(id)sender
{
    int tag = [sender tag];
    [sequenceHandler menuAddKeyframeNamed:[self keyframePropNameFromTag:tag]];
}

- (IBAction)menuJavaScriptControlled:(id)sender
{
    [self saveUndoStateWillChangeProperty:@"*javascriptcontrolled"];
    
    jsControlled = !jsControlled;
    [self updateJSControlledMenu];
    [self updateInspectorFromSelection];
}

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem
{
    if (menuItem.action == @selector(saveDocument:)) return hasOpenedDocument;
    else if (menuItem.action == @selector(saveDocumentAs:)) return hasOpenedDocument;
    else if (menuItem.action == @selector(saveAllDocuments:)) return hasOpenedDocument;
    else if (menuItem.action == @selector(performClose:)) return hasOpenedDocument;
    else if (menuItem.action == @selector(menuCreateKeyframesFromSelection:))
    {
        return (hasOpenedDocument && [SequencerUtil canCreateFramesFromSelectedResources]);
    }
    else if (menuItem.action == @selector(menuAlignKeyframeToMarker:))
    {
        return (hasOpenedDocument && [SequencerUtil canAlignKeyframesToMarker]);
    }
    else if (menuItem.action == @selector(menuStretchSelectedKeyframes:))
    {
        return (hasOpenedDocument && [SequencerUtil canStretchSelectedKeyframes]);
    }
    else if (menuItem.action == @selector(menuReverseSelectedKeyframes:))
    {
        return (hasOpenedDocument && [SequencerUtil canReverseSelectedKeyframes]);
    }
    else if (menuItem.action == @selector(menuAddKeyframe:))
    {
        if (!hasOpenedDocument) return NO;
        if (!self.selectedNode) return NO;
        return [sequenceHandler canInsertKeyframeNamed:[self keyframePropNameFromTag:menuItem.tag]];
    }
    else if (menuItem.action == @selector(menuSetCanvasBorder:))
    {
        if (!hasOpenedDocument) return NO;
        int tag = [menuItem tag];
        if (tag == kCCBBorderNone) return YES;
        CGSize canvasSize = [[CocosScene cocosScene] stageSize];
        if (canvasSize.width == 0 || canvasSize.height == 0) return NO;
        return YES;
    }
    else if (menuItem.action == @selector(menuArrange:))
    {
        if (!hasOpenedDocument) return NO;
        return (self.selectedNode != NULL);
    }
    
    return YES;
}

- (IBAction)menuAbout:(id)sender
{
    NSLog(@"menuAbout");
    if(!aboutWindow)
    {
        aboutWindow = [[AboutWindow alloc] initWithWindowNibName:@"AboutWindow"];
    }
    
    [[aboutWindow window] makeKeyAndOrderFront:self];
}

- (NSUndoManager*) windowWillReturnUndoManager:(NSWindow *)window
{
    return currentDocument.undoManager;
}

#pragma mark Playback countrols

- (void) playbackStep:(id) sender
{
    int frames = [sender intValue];
    if (!currentDocument)
    {
        [self playbackStop:NULL];
    }
    
    if (playingBack)
    {
        // Step forward
        [sequenceHandler.currentSequence stepForward:frames];
        
        if (sequenceHandler.currentSequence.timelinePosition >= sequenceHandler.currentSequence.timelineLength)
        {
            [self playbackStop:NULL];
        }
        else
        {
            double thisTime = [NSDate timeIntervalSinceReferenceDate];
            double requestedDelay = 1/sequenceHandler.currentSequence.timelineResolution;
            double extraTime = thisTime - (playbackLastFrameTime + requestedDelay);
            
            double delayTime = requestedDelay - extraTime;
            playbackLastFrameTime = thisTime;
            int nextStep = 1;
            while (delayTime < 0)
            {
                delayTime += requestedDelay;
                nextStep++;
                
            }
            
            // Call this method again in a little while
            [self performSelector:@selector(playbackStep:) withObject:[NSNumber numberWithInt:nextStep] afterDelay:delayTime];
        }
    }
}

- (IBAction)playbackPlay:(id)sender
{
    if (!self.hasOpenedDocument) return;
    if (playingBack) return;
    
    // Jump to start of sequence if the end is reached
    if (sequenceHandler.currentSequence.timelinePosition >= sequenceHandler.currentSequence.timelineLength)
    {
        sequenceHandler.currentSequence.timelinePosition = 0;
    }
    
    // Deselect all objects to improve performance
    self.selectedNodes = NULL;
    
    // Start playback
    playbackLastFrameTime = [NSDate timeIntervalSinceReferenceDate];
    playingBack = YES;
    [self playbackStep:[NSNumber numberWithInt:1]];
}

- (IBAction)playbackStop:(id)sender
{
    NSLog(@"playbackStop");
    playingBack = NO;
}

- (IBAction)playbackJumpToStart:(id)sender
{
    if (!self.hasOpenedDocument) return;
    sequenceHandler.currentSequence.timelinePosition = 0;
    [[SequencerHandler sharedHandler] updateScrollerToShowCurrentTime];
}

- (IBAction)playbackStepBack:(id)sender
{
    if (!self.hasOpenedDocument) return;
    [sequenceHandler.currentSequence stepBack:1];
}

- (IBAction)playbackStepForward:(id)sender
{
    if (!self.hasOpenedDocument) return;
    [sequenceHandler.currentSequence stepForward:1];
}

- (IBAction)pressedPlaybackControl:(id)sender
{
    NSSegmentedControl* sc = sender;
    
    int tag = [sc selectedSegment];
    if (tag == 0) [self playbackJumpToStart:sender];
    else if (tag == 1) [self playbackStepBack:sender];
    else if (tag == 2) [self playbackStepForward:sender];
    else if (tag == 3) [self playbackStop:sender];
    else if (tag == 4) [self playbackPlay:sender];
    else if (tag == -1)
    {
        NSLog(@"No selected index!!");
    }
}

#pragma mark Delegate methods

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

- (NSSize) windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize
{
    static float minWidth = 1060.0f;
    static float minHeight = 500.0f;
    [splitHorizontalView setNeedsLayout:YES];
    return NSSizeFromCGSize(
                CGSizeMake(
                        frameSize.width<minWidth ? minWidth:frameSize.width,
                        frameSize.height<minHeight ? minHeight:frameSize.height)
    );
}

- (IBAction) menuQuit:(id)sender
{
    if ([self windowShouldClose:self])
    {
        [[NSApplication sharedApplication] terminate:self];
    }
}

- (IBAction)showHelp:(id)sender
{
    if(!helpWindow)
    {
        helpWindow = [[HelpWindow alloc] initWithWindowNibName:@"HelpWindow"];
    }
    
    [[helpWindow window] makeKeyAndOrderFront:self];
}

- (IBAction)showAPIDocs:(id)sender
{
    if(!apiDocsWindow)
    {
        apiDocsWindow = [[APIDocsWindow alloc] initWithWindowNibName:@"APIDocsWindow"];
    }
    
    [[apiDocsWindow window] makeKeyAndOrderFront:self];
}

- (IBAction)reportBug:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/cocos2d/CocosBuilder/issues"]];
}

- (IBAction)visitCommunity:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.cocos2d-iphone.org/forum/forum/16"]];
}

#pragma mark Debug

- (IBAction) debug:(id)sender
{
    NSLog(@"DEBUG");
    
    [resManager debugPrintDirectories];
}

- (void) dealloc
{
    [toolbarDelegate release];
    
    [super dealloc];
}

@end
