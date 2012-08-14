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
#import "TaskStatusWindow.h"
#import "PlayerController.h"
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
#import "CustomPropSettingsWindow.h"
#import "CustomPropSetting.h"

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
@synthesize playerController;
@synthesize menuContextKeyframe;
@synthesize menuContextKeyframeInterpol;
@synthesize menuContextResManager;
@synthesize outlineProject;

static CocosBuilderAppDelegate* sharedAppDelegate;

#pragma mark Setup functions

+ (CocosBuilderAppDelegate*) appDelegate
{
    return sharedAppDelegate;
}

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

- (void) setupPlayerController
{
    self.playerController = [[[PlayerController alloc] init] autorelease];
}

- (void) setupPlayerConnection
{
    PlayerConnection* connection = [[PlayerConnection alloc] init];
    [connection run];
}

- (void) setupResourceManager
{
    // Load resource manager
    resManager = [ResourceManager sharedManager];
    resManagerPanel = [[ResourceManagerPanel alloc] initWithWindowNibName:@"ResourceManagerPanel"];
    [resManagerPanel.window setIsVisible:NO];
    
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

- (void) setupSplitView
{
    splitView.delegate = self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.window center];
    
    sharedAppDelegate = self;
    
    [[NSExceptionHandler defaultExceptionHandler] setExceptionHandlingMask: NSLogUncaughtExceptionMask | NSLogUncaughtSystemExceptionMask | NSLogUncaughtRuntimeErrorMask];
    
    // iOS
    defaultCanvasSizes[kCCBCanvasSizeIPhoneLandscape] = CGSizeMake(480, 320);
    defaultCanvasSizes[kCCBCanvasSizeIPhonePortrait] = CGSizeMake(320, 480);
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
    [self setupSplitView];
    [self updateInspectorFromSelection];
    
    [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
    
    CocosScene* cs = [CocosScene cocosScene];
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
    
    [self setupPlayerController];
    [self setupPlayerConnection];
    
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
    
    //NSModalSession modalSession = [[NSApplication sharedApplication] beginModalSessionForWindow:modalTaskStatusWindow.window];
    //[[NSApplication sharedApplication] runModalSession:modalSession];
}

- (void) modalStatusWindowFinish
{
    [[NSApplication sharedApplication] stopModal];
    [modalTaskStatusWindow.window orderOut:self];
    
    //[modalTaskStatusWindow.window setIsVisible:NO];
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

- (void) setSelectedNode:(CCNode*) selection
{
    // Close the color picker
    [[NSColorPanel sharedColorPanel] close];
    
    if (![[self window] makeFirstResponder:[self window]])
    {
        return;
    }
    
    selectedNode = selection;
    [sequenceHandler updateOutlineViewSelection];
    
    if (currentDocument) currentDocument.lastEditedProperty = NULL;
}

- (CCNode*) selectedNode
{
    return selectedNode;
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

#pragma mark Split View Delegate

-(void)splitViewWillResizeSubviews:(NSNotification *)notification
{
    [window disableUpdatesUntilFlush];
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

- (BOOL) isDisabledProperty:(NSString*)name animatable:(BOOL)animatable
{
    // Only animatable properties can be disabled
    if (!animatable) return NO;
    
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    
    SequencerNodeProperty* seqNodeProp = [selectedNode sequenceNodeProperty:name sequenceId:seq.sequenceId];
    
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
    if (!selectedNode) return;
    
    NodeInfo* info = selectedNode.userObject;
    PlugInNode* plugIn = info.plugIn;
    
    BOOL isCCBSubFile = [plugIn.nodeClassName isEqualToString:@"CCBFile"];
    
    // Always add the code connections pane
    paneOffset = [self addInspectorPropertyOfType:@"CodeConnections" name:@"customClass" displayName:@"" extra:NULL readOnly:isCCBSubFile affectsProps:NULL atOffset:paneOffset];
    
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
            
            // TODO: Handle read only for animated properties
            if ([self isDisabledProperty:name animatable:animated])
            {
                readOnly = YES;
            }
            
            paneOffset = [self addInspectorPropertyOfType:type name:name displayName:displayName extra:extra readOnly:readOnly affectsProps:affectsProps atOffset:paneOffset];
        }
    }
    else
    {
        NSLog(@"WARNING info:%@ plugIn:%@ selectedNode: %@", info, plugIn, selectedNode);
    }
    
    // Custom properties
    NSString* customClass = [selectedNode extraPropForKey:@"customClass"];
    NSArray* customProps = selectedNode.customProperties;
    if (customClass && ![customClass isEqualToString:@""])
    {
        if ([customProps count] || !isCCBSubFile)
        {
            paneOffset = [self addInspectorPropertyOfType:@"Separator" name:NULL displayName:[selectedNode extraPropForKey:@"customClass"] extra:NULL readOnly:YES affectsProps:NULL atOffset:paneOffset];
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
    
    [dict setObject:[NSNumber numberWithBool:[[CocosScene cocosScene] centeredOrigin]] forKey:@"centeredOrigin"];
    
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
    [self setSelectedNode:NULL];
    CocosScene* cs = [CocosScene cocosScene];
    
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
            SequencerSequence* seq = [[[SequencerSequence alloc] initWithSerialization:serSeq] autorelease];
            [sequences addObject:seq];
            
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
    
        SequencerSequence* seq = [[[SequencerSequence alloc] init] autorelease];
        seq.name = @"Default Timeline";
        seq.sequenceId = 0;
        seq.autoPlay = YES;
        [sequences addObject:seq];
    
        currentDocument.sequences = sequences;
        sequenceHandler.currentSequence = seq;
    }
    
    // Process contents
    CCNode* loadedRoot = [CCBReaderInternal nodeGraphFromDocumentDictionary:doc parentSize:CGSizeMake(resolution.width, resolution.height)];
    
    // Replace open document
    selectedNode = NULL;
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
    selectedNode = NULL;
    [[CocosScene cocosScene] replaceRootNodeWith:NULL];
    currentDocument.docData = NULL;
    currentDocument.fileName = NULL;
    [[CocosScene cocosScene] setStageSize:CGSizeMake(0, 0) centeredOrigin:YES];
    [[CocosScene cocosScene].guideLayer removeAllGuides];
    [[CocosScene cocosScene].notesLayer removeAllNotes];
    [[CocosScene cocosScene].rulerLayer mouseExited:NULL];
    self.currentDocument = NULL;
    sequenceHandler.currentSequence = NULL;
    
    [self updateTimelineMenu];
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
        [[CocosBuilderAppDelegate appDelegate] modalDialogTitle:@"Too Many Directories" message:@"You have created or opened a file which is in a directory with very many sub directories. Please save your ccb-files in a directory together with the resources you use in your project."];
    }
}

- (void) checkForTooManyDirectoriesInCurrentProject
{
    if (!projectSettings) return;
    
    if ([ResourceManager sharedManager].tooManyDirectoriesAdded)
    {
        [self closeProject];
        
        [ResourceManager sharedManager].tooManyDirectoriesAdded = NO;
        
        // Notify the user
        [[CocosBuilderAppDelegate appDelegate] modalDialogTitle:@"Too Many Directories" message:@"You have created or opened a project which is in a directory with very many sub directories. Please save your project-files in a directory together with the resources you use in your project."];
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
    
    [self checkForTooManyDirectoriesInCurrentProject];
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
    
    [[CocosScene cocosScene].notesLayer removeAllNotes];
    
    selectedNode = NULL;
    [[CocosScene cocosScene] setStageSize:stageSize centeredOrigin:origin];
    
    [[CocosScene cocosScene] replaceRootNodeWith:[[PlugInManager sharedManager] createDefaultNodeOfType:type]];
    
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

- (BOOL) application:(NSApplication *)sender openFile:(NSString *)filename
{
    [self openProject:filename];
    return YES;
}

- (void) openJSFile:(NSString*) fileName
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


- (IBAction) copy:(id) sender
{
    // Copy keyframes
    
    NSArray* keyframes = [sequenceHandler selectedKeyframesForCurrentSequence];
    if ([keyframes count] > 0)
    {
        NSMutableSet* propsSet = [NSMutableSet set];
        NSMutableSet* seqsSet = [NSMutableSet set];
        BOOL duplicatedProps = NO;
        
        for (int i = 0; i < keyframes.count; i++)
        {
            SequencerKeyframe* keyframe = [keyframes objectAtIndex:i];
            
            NSValue* seqVal = [NSValue valueWithPointer:keyframe.parent];
            if (![seqsSet containsObject:seqVal])
            {
                NSString* propName = keyframe.name;
                if ([propsSet containsObject:propName])
                {
                    duplicatedProps = YES;
                    break;
                }
                [propsSet addObject:propName];
                [seqsSet addObject:seqVal];
            }
        }
        
        if (duplicatedProps)
        {
            [self modalDialogTitle:@"Failed to Copy" message:@"You can only copy keyframes from one node."];
            return;
        }
        
        // Serialize keyframe
        NSMutableArray* serKeyframes = [NSMutableArray array];
        for (SequencerKeyframe* keyframe in keyframes)
        {
            [serKeyframes addObject:[keyframe serialization]];
        }
        NSData* clipData = [NSKeyedArchiver archivedDataWithRootObject:serKeyframes];
        NSPasteboard* cb = [NSPasteboard generalPasteboard];
        [cb declareTypes:[NSArray arrayWithObject:@"com.cocosbuilder.keyframes"] owner:self];
        [cb setData:clipData forType:@"com.cocosbuilder.keyframes"];
        
        return;
    }
    
    // Copy node
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
    if (!currentDocument) return;
    
    // Paste keyframes
    NSPasteboard* cb = [NSPasteboard generalPasteboard];
    NSString* type = [cb availableTypeFromArray:[NSArray arrayWithObjects:@"com.cocosbuilder.keyframes", nil]];
    
    if (type)
    {
        if (!selectedNode)
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
        
        for (SequencerKeyframe* keyframe in keyframes)
        {
            // Adjust time
            keyframe.time = [seq alignTimeToResolution:keyframe.time - firstTime + seq.timelinePosition];
            
            // Add the keyframe
            [selectedNode addKeyframe:keyframe forProperty:keyframe.name atTime:keyframe.time sequenceId:seq.sequenceId];
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
    
    selectedNode = NULL;
    [sequenceHandler updateOutlineViewSelection];
}

- (IBAction) delete:(id) sender
{
    // First attempt to delete selected keyframes
    if ([sequenceHandler deleteSelectedKeyframesForCurrentSequence]) return;
    
    // Then delete the selected node
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

- (void) moveSelectedObjectWithDelta:(CGPoint)delta
{
    if (!selectedNode) return;
    
    [self saveUndoStateWillChangeProperty:@"position"];
    
    // Get and update absolute position
    CGPoint absPos = selectedNode.position;
    absPos = ccpAdd(absPos, delta);
    
    // Convert to relative position
    CGSize parentSize = [PositionPropertySetter getParentSize:selectedNode];
    int positionType = [PositionPropertySetter positionTypeForNode:selectedNode prop:@"position"];
    NSPoint newPos = [PositionPropertySetter calcRelativePositionFromAbsolute:absPos type:positionType parentSize:parentSize];
    
    // Update the selected node
    [PositionPropertySetter setPosition:newPos forNode:selectedNode prop:@"position"];
    [self refreshProperty:@"position"];
    
    // Update animated value
    NSArray* animValue = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:newPos.x],
                          [NSNumber numberWithFloat:newPos.y],
                          NULL];
    
    NodeInfo* nodeInfo = selectedNode.userObject;
    PlugInNode* plugIn = nodeInfo.plugIn;
    
    if ([plugIn isAnimatableProperty:@"position"])
    {
        SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
        int seqId = seq.sequenceId;
        SequencerNodeProperty* seqNodeProp = [selectedNode sequenceNodeProperty:@"position" sequenceId:seqId];
        
        if (seqNodeProp)
        {
            SequencerKeyframe* keyframe = [seqNodeProp keyframeAtTime:seq.timelinePosition];
            if (keyframe)
            {
                keyframe.value = animValue;
            }
            
            [[SequencerHandler sharedHandler] redrawTimeline];
        }
        else
        {
            [nodeInfo.baseValues setObject:animValue forKey:@"position"];
        }
    }
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
    
    [self moveSelectedObjectWithDelta:delta];
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

- (void) publishAndRun:(BOOL)run
{
    CCBWarnings* warnings = [[[CCBWarnings alloc] init] autorelease];
    warnings.warningsDescription = @"Publisher Warnings";
    
    // Setup publisher
    CCBPublisher* publisher = [[CCBPublisher alloc] initWithProjectSettings:projectSettings warnings:warnings];
    publisher.runAfterPublishing = run;
    
    // Open progress window and publish
    
    [publisher publish];
    
    [self modalStatusWindowStartWithTitle:@"Publishing"];
    [self modalStatusWindowUpdateStatusText:@"Starting up..."];
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
    
    if (publisher.runAfterPublishing)
    {
        //[playerController runPlayerForProject:projectSettings]
        [self runProject:self];
    }
    
    [publisher release];
}

- (IBAction)runProject:(id)sender
{
    // Open CocosPlayer console
    if (!playerConsoleWindow)
    {
        playerConsoleWindow = [[PlayerConsoleWindow alloc] initWithWindowNibName:@"PlayerConsoleWindow"];
    }
    [playerConsoleWindow.window makeKeyAndOrderFront:self];
    
    if ([[PlayerConnection sharedPlayerConnection] connected])
    {
        [[PlayerConnection sharedPlayerConnection] sendRunCommand];
    }
    else
    {
        [self modalDialogTitle:@"No Player Connected" message:@"There is no CocosPlayer connected to CocosBuilder. Make sure that a player is running and that it has the same pairing number as CocosBuilder."];
    }
}

- (IBAction) menuPublishProject:(id)sender
{
    [self publishAndRun:NO];
}

- (IBAction) menuPublishProjectAndRun:(id)sender
{
    [self publishAndRun:YES];
}

- (IBAction) menuCleanCacheDirectories:(id)sender
{
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
                        [self performClose:sender];
                    }
                }
            }
            
            [[[CCDirector sharedDirector] view] unlockOpenGLContext];
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
    for (int i = 1; i <= kCCBNumCanvasDevices; i++)
    {
        if (size.width == defaultCanvasSizes[i].width && size.height == defaultCanvasSizes[i].height) return i;
    }
    return 0;
}

- (void) setResolution:(int)r
{
    CocosScene* cs = [CocosScene cocosScene];
    
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

- (IBAction)menuEditCustomPropSettings:(id)sender
{
    if (!currentDocument) return;
    if (!selectedNode) return;
    
    NSString* customClass = [selectedNode extraPropForKey:@"customClass"];
    if (!customClass || [customClass isEqualToString:@""])
    {
        [self modalDialogTitle:@"Custom Class Needed" message:@"To add custom properties to a node you need to use a custom class."];
        return;
    }
    
    CustomPropSettingsWindow* wc = [[[CustomPropSettingsWindow alloc] initWithWindowNibName:@"CustomPropSettingsWindow"] autorelease];
    [wc copySettingsForNode:selectedNode];
    
    int success = [wc runModalSheetForWindow:window];
    if (success)
    {
        [self saveUndoStateWillChangeProperty:@"*customPropSettings"];
        selectedNode.customProperties = wc.settings;
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

- (IBAction) menuSetCanvasBorder:(id)sender
{
    CocosScene* cs = [CocosScene cocosScene];
    
    int tag = (int)[sender tag];
    [cs setStageBorder:tag];
    [self updateCanvasBorderMenu];
}

- (IBAction) menuZoomIn:(id)sender
{
    CocosScene* cs = [CocosScene cocosScene];
    
    float zoom = [cs stageZoom];
    zoom *= 2;
    if (zoom > 8) zoom = 8;
    [cs setStageZoom:zoom];
}

- (IBAction) menuZoomOut:(id)sender
{
    CocosScene* cs = [CocosScene cocosScene];
    
    float zoom = [cs stageZoom];
    zoom *= 0.5f;
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
    [resManagerPanel.window setIsVisible:![resManagerPanel.window isVisible]];
}

- (void) reloadResources
{
    if (!currentDocument) return;
    
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
    FNTConfigRemoveCache();  
  
    [self switchToDocument:currentDocument forceReload:YES];
}

- (IBAction) menuAlignChildrenToPixels:(id)sender
{
    if (!currentDocument) return;
    if (!selectedNode) return;
    
    // Check if node can have children
    NodeInfo* info = selectedNode.userObject;
    PlugInNode* plugIn = info.plugIn;
    if (!plugIn.canHaveChildren) return;
    
    CCArray* children = [selectedNode children];
    if ([children count] == 0) return;
    
    for (int i = 0; i < [children count]; i++)
    {
        CCNode* c = [children objectAtIndex:i];
        
        int positionType = [PositionPropertySetter positionTypeForNode:c prop:@"position"];
        if (positionType != kCCBPositionTypePercent)
        {
            CGPoint pos = [PositionPropertySetter positionForNode:c prop:@"position"];
            pos = ccp(roundf(pos.x), roundf(pos.y));
            [PositionPropertySetter setPosition:NSPointFromCGPoint(pos) forNode:c prop:@"position"];
        }
    }
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

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem
{
    NSLog(@"validateMenuItem: %@", menuItem);
    
    if (menuItem.action == @selector(saveDocument:)) return hasOpenedDocument;
    else if (menuItem.action == @selector(saveDocumentAs:)) return hasOpenedDocument;
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
    
    return YES;
}

- (NSUndoManager*) windowWillReturnUndoManager:(NSWindow *)window
{
    return currentDocument.undoManager;
}

#pragma mark Playback countrols

- (void) playbackStep
{
    if (!currentDocument)
    {
        [self playbackStop:NULL];
    }
    
    if (playingBack)
    {
        // Step forward
        [sequenceHandler.currentSequence stepForward:1];
        
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
            
            if (requestedDelay < 0)
            {
                // TODO: Handle frame skipping
                requestedDelay = 0;
            }
            
            // Call this method again in a little while
            [self performSelector:@selector(playbackStep) withObject:NULL afterDelay:delayTime];
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
    self.selectedNode = NULL;
    
    // Start playback
    playbackLastFrameTime = [NSDate timeIntervalSinceReferenceDate];
    playingBack = YES;
    [self playbackStep];
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
    [playerController stopPlayer];
    [[NSApplication sharedApplication] terminate:self];
}

- (IBAction) menuQuit:(id)sender
{
    if ([self windowShouldClose:self])
    {
        [playerController stopPlayer];
        [[NSApplication sharedApplication] terminate:self];
    }
}

- (IBAction)showHelp:(id)sender
{
    NSURL* url = [NSURL URLWithString:@"http://cocosbuilder.com/?page_id=68"];
    
    [[NSWorkspace sharedWorkspace] openURL:url];
}

#pragma mark Debug

- (IBAction) debug:(id)sender
{
    NSLog(@"DEBUG");
    
    [resManager debugPrintDirectories];
}

@end
