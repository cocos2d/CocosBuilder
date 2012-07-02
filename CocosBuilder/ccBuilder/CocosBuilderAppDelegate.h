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

#import <Cocoa/Cocoa.h>
#import "cocos2d.h"
#import "PSMTabBarControl.h"

enum {
    kCCBCanvasSizeCustom = 0,
    kCCBCanvasSizeIPhoneLandscape,
    kCCBCanvasSizeIPhonePortrait,
    kCCBCanvasSizeIPadLandscape,
    kCCBCanvasSizeIPadPortrait
};

enum {
    kCCBBorderDevice = 0,
    kCCBBorderTransparent,
    kCCBBorderOpaque,
    kCCBBorderNone
};


@class CCBDocument;
@class ProjectSettings;
@class AssetsWindowController;
@class PlugInManager;
@class ResourceManager;
@class ResourceManagerPanel;
@class ResourceManagerOutlineHandler;
@class CCBGLView;
@class CCBTransparentWindow;
@class CCBTransparentView;
@class WarningsWindow;
@class TaskStatusWindow;
@class CCBPublisher;
@class CCBWarnings;
@class PlayerController;
@class SequencerHandler;
@class SequencerScrubberSelectionView;
@class MainWindow;

@interface CocosBuilderAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, NSSplitViewDelegate>
{
    // Cocos2D view
    IBOutlet CCBGLView* cocosView;
    IBOutlet NSView* mainView;
    IBOutlet NSSplitView* splitView;
    
    // Inspector views
    IBOutlet NSScrollView* inspectorScroll;
    NSView* inspectorDocumentView;
    NSMutableDictionary* currentInspectorValues;
    
    // Tabs
    IBOutlet PSMTabBarControl* tabBar;
    NSTabView* tabView;
    
    // Inspector componentes
    IBOutlet NSComboBox* inspectorSpriteName;
    IBOutlet NSTextView* inspectorLabelBMFontString;
    BOOL canEditContentSize;
    BOOL canEditCustomClass;
    
    BOOL lockedScaleRatio;
    
    // Outline view heirarchy
    SequencerHandler* sequenceHandler;
    IBOutlet NSOutlineView* outlineHierarchy;
    IBOutlet SequencerScrubberSelectionView* scrubberSelectionView;
    IBOutlet NSTextField* timeDisplay;
    IBOutlet NSSlider* timeScaleSlider;
    IBOutlet NSScroller* timelineScroller;
    IBOutlet NSScrollView* sequenceScrollView;
    
    // Selections
    CCNode* selectedNode;
    
    // Menus
    IBOutlet NSMenu* menuCanvasSize;
    IBOutlet NSMenu* menuCanvasBorder;
    IBOutlet NSMenu* menuResolution;
    IBOutlet NSMenu* menuContextKeyframe;
    IBOutlet NSMenu* menuContextKeyframeInterpol;
    
    IBOutlet NSPopUpButton* menuTimelinePopup;
    IBOutlet NSMenu* menuTimeline;
    IBOutlet NSTextField* lblTimeline;
    
    CGSize defaultCanvasSizes[5];
    IBOutlet NSMenuItem* menuItemStageCentered;
    BOOL defaultCanvasSize;
    
    // Resource manager
    ResourceManager* resManager;
    ResourceManagerPanel* resManagerPanel;
    
    // Project
    ProjectSettings* projectSettings;
    
    // Project display
    IBOutlet NSOutlineView* outlineProject;
    ResourceManagerOutlineHandler* projectOutlineHandler;
    
    // Documents
    CCBDocument* currentDocument;
    BOOL hasOpenedDocument;
    
    // PlugIns (nodes)
    PlugInManager* plugInManager;
    IBOutlet NSMenu* menuAddObject;
    IBOutlet NSMenu* menuAddObjectAsChild;
    
    // Guides
    BOOL showGuides;
    BOOL snapToGuides;
    
    // Sticky notes
    BOOL showStickyNotes;
    
    // Transparent window for components on top of cocos scene
    CCBTransparentWindow* guiWindow;
    CCBTransparentView* guiView;
    
    // Warnings
    WarningsWindow* publishWarningsWindow;
    
    // Modal status window
    TaskStatusWindow* modalTaskStatusWindow;
    
    // Player
    PlayerController* playerController;
    
    // Animation playback
    BOOL playingBack;
    double playbackLastFrameTime;
    
@private
    MainWindow *window;
    
}

@property (assign) IBOutlet MainWindow *window;

//@property (nonatomic,retain) NSMutableArray* assetsFontListTTF;

@property (nonatomic,readonly) ResourceManager* resManager;
@property (nonatomic,retain) CCBDocument* currentDocument;
@property (nonatomic,assign) BOOL hasOpenedDocument;
@property (nonatomic,readonly) CCBGLView* cocosView;

@property (nonatomic,assign) BOOL canEditContentSize;
@property (nonatomic,assign) BOOL defaultCanvasSize;
@property (nonatomic,assign) BOOL canEditCustomClass;

@property (nonatomic,assign) CCNode* selectedNode;

@property (nonatomic,assign) BOOL showGuides;
@property (nonatomic,assign) BOOL snapToGuides;
@property (nonatomic,assign) BOOL showStickyNotes;

@property (nonatomic,readonly) CCBTransparentView* guiView;
@property (nonatomic,readonly) CCBTransparentWindow* guiWindow;

@property (nonatomic,readonly) IBOutlet NSMenu* menuContextKeyframe;
@property (nonatomic,readonly) IBOutlet NSMenu* menuContextKeyframeInterpol;

@property (nonatomic,retain) ProjectSettings* projectSettings;

@property (nonatomic,retain) PlayerController* playerController;

// Transparent window
- (void) resizeGUIWindow:(NSSize)size;

// PlugIns and properties
@property (nonatomic,readonly) PlugInManager* plugInManager;
- (void) refreshProperty:(NSString*) name;

// Methods
+ (CocosBuilderAppDelegate*) appDelegate;

- (void) updateTimelineMenu;
- (void) updateInspectorFromSelection;
- (void) switchToDocument:(CCBDocument*) document;
- (void) closeLastDocument;
- (void) openFile:(NSString*) fileName;

// Menu options
- (void) dropAddSpriteNamed:(NSString*)spriteFile inSpriteSheet:(NSString*)spriteSheetFile at:(CGPoint)pt parent:(CCNode*)parent;
- (void) dropAddSpriteNamed:(NSString*)spriteFile inSpriteSheet:(NSString*)spriteSheetFile at:(CGPoint)pt;

- (IBAction)menuTimelineSettings:(id)sender;

- (IBAction) menuNudgeObject:(id)sender;
- (IBAction) menuMoveObject:(id)sender;

- (IBAction) menuSelectBehind:(id)sender;
- (IBAction) menuDeselect:(id)sender;

- (IBAction) menuCloseDocument:(id)sender;
- (void) closeProject;

- (BOOL) addCCObject:(CCNode *)obj toParent:(CCNode*)parent atIndex:(int)index;
- (BOOL) addCCObject:(CCNode *)obj toParent:(CCNode*)parent;
- (BOOL) addCCObject:(CCNode*)obj asChild:(BOOL)asChild;
- (void) deleteNode:(CCNode*)node;
- (IBAction) pasteAsChild:(id)sender;
- (IBAction) saveDocument:(id)sender;
- (IBAction) menuQuit:(id)sender;

- (int) orientedDeviceTypeForSize:(CGSize)size;
//- (IBAction) menuSetCanvasSize:(id)sender;
- (void) updateStateOriginCenteredMenu;
- (IBAction) menuSetStateOriginCentered:(id)sender;
- (void) updateCanvasBorderMenu;
- (IBAction) menuSetCanvasBorder:(id)sender;
- (IBAction) menuZoomIn:(id)sender;
- (IBAction) menuZoomOut:(id)sender;

- (IBAction) pressedZoom:(id)sender;
- (IBAction) pressedToolSelection:(id)sender;

- (IBAction) menuOpenResourceManager:(id)sender;
- (void) reloadResources;
- (IBAction) menuAlignChildrenToPixels:(id)sender;
- (IBAction)menuAddStickyNote:(id)sender;
- (IBAction) menuCleanCacheDirectories:(id)sender;

// Undo / Redo
- (void) updateDirtyMark;
- (void) saveUndoState;
- (void) saveUndoStateWillChangeProperty:(NSString*)prop;

- (IBAction) undo:(id)sender;
- (IBAction) redo:(id)sender;

- (IBAction) debug:(id)sender;

// Publishing
- (void) publisher:(CCBPublisher*)publisher finishedWithWarnings:(CCBWarnings*)warnings;

// For warning messages
- (void) modalDialogTitle: (NSString*)title message:(NSString*)msg;

// Modal status messages (progress)
- (void) modalStatusWindowStartWithTitle:(NSString*)title;
- (void) modalStatusWindowFinish;
- (void) modalStatusWindowUpdateStatusText:(NSString*) text;

@end
