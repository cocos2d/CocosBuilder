//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

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
@class AssetsWindowController;
@class PlugInManager;

@interface CocosBuilderAppDelegate : NSObject <NSApplicationDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate, NSWindowDelegate>
{
    // Cocos2D view
    IBOutlet CCGLView* cocosView;
    IBOutlet NSView* mainView;
    
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
    IBOutlet NSOutlineView* outlineHierarchy;
    
    // Selections
    CCNode* selectedNode;
    
    // Menus
    IBOutlet NSMenu* menuCanvasSize;
    IBOutlet NSMenu* menuCanvasBorder;
    CGSize defaultCanvasSizes[5];
    IBOutlet NSMenuItem* menuItemStageCentered;
    BOOL defaultCanvasSize;
    
    // Assets
    NSString* assetsPath;
    IBOutlet NSArrayController* assetsList;
    NSMutableArray* assestsImgList;
    NSMutableArray* assetsImgListFiles;
    NSMutableArray* assetsFontList;
    NSMutableArray* assetsSpriteSheetList;
    NSMutableArray* assetsTemplates;
    
    // Assets Panel
    AssetsWindowController* assetsWindowController;
    
    // Documents
    CCBDocument* currentDocument;
    BOOL hasOpenedDocument;
    
    // PlugIns (nodes)
    PlugInManager* plugInManager;
    IBOutlet NSMenu* menuAddObject;
    IBOutlet NSMenu* menuAddObjectAsChild;
    
@private
    NSWindow *window;
    
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic,retain) NSMutableArray* assestsImgList;
@property (nonatomic,retain) NSMutableArray* assetsImgListFiles;
@property (nonatomic,retain) NSMutableArray* assetsFontList;
@property (nonatomic,retain) NSMutableArray* assetsSpriteSheetList;
@property (nonatomic,retain) NSMutableArray* assetsTemplates;

@property (nonatomic,retain) CCBDocument* currentDocument;
@property (nonatomic,assign) BOOL hasOpenedDocument;
@property (nonatomic,retain) NSString* assetsPath;
@property (nonatomic,readonly) CCGLView* cocosView;

@property (nonatomic,assign) BOOL canEditContentSize;
@property (nonatomic,assign) BOOL defaultCanvasSize;
@property (nonatomic,assign) BOOL canEditCustomClass;

- (void) updateAssetsView;

@property (nonatomic,assign) CCNode* selectedNode;

// PlugIns and properties
@property (nonatomic,readonly) PlugInManager* plugInManager;
- (void) refreshProperty:(NSString*) name;

// Methods
- (void) updateInspectorFromSelection;
- (void) switchToDocument:(CCBDocument*) document;
- (void) closeLastDocument;

// Menu options

- (void) dropAddSpriteNamed:(NSString*)spriteFile inSpriteSheet:(NSString*)spriteSheetFile at:(CGPoint)pt parent:(CCNode*)parent;
- (void) dropAddSpriteNamed:(NSString*)spriteFile inSpriteSheet:(NSString*)spriteSheetFile at:(CGPoint)pt;


- (IBAction) menuNudgeObject:(id)sender;
- (IBAction) menuMoveObject:(id)sender;

- (IBAction) menuSelectBehind:(id)sender;
- (IBAction) menuDeselect:(id)sender;

- (IBAction) menuCloseDocument:(id)sender;

- (BOOL) addCCObject:(CCNode *)obj toParent:(CCNode*)parent;
- (BOOL) addCCObject:(CCNode*)obj asChild:(BOOL)asChild;
- (void) deleteNode:(CCNode*)node;
- (IBAction) pasteAsChild:(id)sender;
- (IBAction) saveDocument:(id)sender;
- (IBAction) menuQuit:(id)sender;

- (int) orientedDeviceTypeForSize:(CGSize)size;
- (void) updateCanvasSizeMenu;
- (IBAction) menuSetCanvasSize:(id)sender;
- (void) updateStateOriginCenteredMenu;
- (IBAction) menuSetStateOriginCentered:(id)sender;
- (void) updateCanvasBorderMenu;
- (IBAction) menuSetCanvasBorder:(id)sender;
- (IBAction) menuZoomIn:(id)sender;
- (IBAction) menuZoomOut:(id)sender;

- (IBAction) pressedZoom:(id)sender;
- (IBAction) pressedToolSelection:(id)sender;

- (IBAction) menuOpenAssetsPanel:(id)sender;
- (IBAction) menuReloadAssets:(id)sender;
- (IBAction) menuAlignChildren:(id)sender;

// Undo / Redo
- (void) updateDirtyMark;
- (void) saveUndoState;
- (void) saveUndoStateWillChangeProperty:(NSString*)prop;

- (IBAction) undo:(id)sender;
- (IBAction) redo:(id)sender;

- (IBAction) debugPrintExtraProps:(id)sender;
- (IBAction) debugPrintStructure:(id)sender;
- (IBAction) debugPrintExtraPropsForSelectedNode:(id)sender;

@end
