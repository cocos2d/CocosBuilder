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
@class TemplateWindowController;

@interface CocosBuilderAppDelegate : NSObject <NSApplicationDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate, NSWindowDelegate>
{
    // Cocos2D view
    IBOutlet CCGLView* cocosView;
    IBOutlet NSView* mainView;
    
    // Inspector views
    IBOutlet NSScrollView* inspectorScroll;
    NSView* inspectorDocumentView;
    IBOutlet NSView* inspectorNodeView;
    IBOutlet NSView* inspectorLayerView;
    IBOutlet NSView* inspectorSpriteView;
    IBOutlet NSView* inspectorMenuItemView;
    IBOutlet NSView* inspectorMenuItemImageView;
    IBOutlet NSView* inspectorParticleSystemView;
    IBOutlet NSView* inspectorParticleSystemViewGravity;
    IBOutlet NSView* inspectorParticleSystemViewRadius;
    IBOutlet NSView* inspectorLayerColorView;
    IBOutlet NSView* inspectorLayerGradientView;
    IBOutlet NSView* inspectorLabelTTFView;
    IBOutlet NSView* inspectorLabelBMFontView;
    
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
    IBOutlet NSMenu* menuTemplates;
    IBOutlet NSMenu* menuTemplatesAsChild;
    
    // Assets
    NSString* assetsPath;
    //IBOutlet NSTableView* assetsTable;
    IBOutlet NSArrayController* assetsList;
    NSMutableArray* assestsImgList;
    NSMutableArray* assetsImgListFiles;
    NSMutableArray* assetsFontList;
    NSMutableArray* assetsSpriteSheetList;
    NSMutableArray* assetsTemplates;
    
    // Assets Panel
    AssetsWindowController* assetsWindowController;
    
    // Template Panel
    TemplateWindowController* templateWindowController;
    
    // Documents
    CCBDocument* currentDocument;
    BOOL hasOpenedDocument;
    
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

- (void) setSelectedNode:(CCNode*) selection;

// Inspector properties

// Code Connections
@property (nonatomic, retain) NSString* pCustomClass;
@property (nonatomic, assign) int pMemberVarAssignmentType;
@property (nonatomic, retain) NSString* pMemberVarAssignmentName;

// Node
@property (nonatomic, assign) float pPositionX;
@property (nonatomic, assign) float pPositionY;
@property (nonatomic, assign) float pContentSizeW;
@property (nonatomic, assign) float pContentSizeH;
@property (nonatomic, assign) float pAnchorPointX;
@property (nonatomic, assign) float pAnchorPointY;
@property (nonatomic, assign) float pScaleX;
@property (nonatomic, assign) float pScaleY;
@property (nonatomic, assign) BOOL pLockedScaleRatio;
@property (nonatomic, assign) float pRotation;
@property (nonatomic, assign) int pZOrder;
@property (nonatomic, assign) int pTag;
@property (nonatomic, assign) BOOL pRelativeToAnchorpoint;
@property (nonatomic, assign) BOOL pVisible;

// Layer
@property (nonatomic, assign) BOOL pTouchEnabled;
@property (nonatomic, assign) BOOL pAccelerometerEnabled;
@property (nonatomic, assign) BOOL pMouseEnabled;
@property (nonatomic, assign) BOOL pKeyboardEnabled;

// Sprite
@property (nonatomic, retain) NSString* pSpriteFile;
@property (nonatomic, assign) int pOpacity;
@property (nonatomic, assign) NSColor* pColor;
@property (nonatomic, assign) BOOL pFlipX;
@property (nonatomic, assign) BOOL pFlipY;
@property (nonatomic, assign) int pBlendFuncSrc;
@property (nonatomic, assign) int pBlendFuncDst;
@property (nonatomic, retain) NSString* pSpriteSheetFile;

// MenuItem
@property (nonatomic, assign) BOOL pIsEnabled;
@property (nonatomic, retain) NSString* pSelector;
@property (nonatomic, assign) int pTarget;

// MenuItemImage
@property (nonatomic, retain) NSString* pSpriteFileNormal;
@property (nonatomic, retain) NSString* pSpriteFileSelected;
@property (nonatomic, retain) NSString* pSpriteFileDisabled;

// ParticleSystem
@property (nonatomic, assign) int pEmitterMode;
@property (nonatomic, assign) float pEmissionRate;
@property (nonatomic, assign) float pDuration;
@property (nonatomic, assign) int pPosVarX;
@property (nonatomic, assign) int pPosVarY;
@property (nonatomic, assign) int pNumParticles;
@property (nonatomic, assign) float pLife;
@property (nonatomic, assign) float pLifeVar;
@property (nonatomic, assign) int pStartSize;
@property (nonatomic, assign) int pStartSizeVar;
@property (nonatomic, assign) int pEndSize;
@property (nonatomic, assign) int pEndSizeVar;
@property (nonatomic, assign) int pStartSpin;
@property (nonatomic, assign) int pStartSpinVar;
@property (nonatomic, assign) int pEndSpin;
@property (nonatomic, assign) int pEndSpinVar;
@property (nonatomic, assign) NSColor* pStartColor;
@property (nonatomic, assign) NSColor* pStartColorVar;
@property (nonatomic, assign) NSColor* pEndColor;
@property (nonatomic, assign) NSColor* pEndColorVar;
@property (nonatomic, assign) float pGravityX;
@property (nonatomic, assign) float pGravityY;
@property (nonatomic, assign) int pDirection;
@property (nonatomic, assign) int pDirectionVar;
@property (nonatomic, assign) int pSpeed;
@property (nonatomic, assign) int pSpeedVar;
@property (nonatomic, assign) int pTangAcc;
@property (nonatomic, assign) int pTangAccVar;
@property (nonatomic, assign) int pRadialAcc;
@property (nonatomic, assign) int pRadialAccVar;
@property (nonatomic, assign) int pStartRadius;
@property (nonatomic, assign) int pStartRadiusVar;
@property (nonatomic, assign) int pEndRadius;
@property (nonatomic, assign) int pEndRadiusVar;
@property (nonatomic, assign) int pRotate;
@property (nonatomic, assign) int pRotateVar;

// LayerGradient
@property (nonatomic, assign) NSColor* pFadeColor;
@property (nonatomic, assign) int pGradientAngle;

// LabelTTF
@property (nonatomic, retain) NSString* pFontName;

// LabelBMFont
@property (nonatomic, retain) NSString* pString;
@property (nonatomic, retain) NSString* pFontFile;

// Methods
- (void) updateInspectorFromSelection;
- (void) switchToDocument:(CCBDocument*) document;
- (void) closeLastDocument;

- (IBAction) updateSelectionFromInspector;
- (IBAction) setBlendModeNormal:(id)sender;
- (IBAction) setBlendModeAdditive:(id)sender;
- (IBAction) updateLabelBMFontString:(id)sender;
- (IBAction) startSelectedParticle:(id)sender;
- (IBAction) stopSelectedParticle:(id)sender;

// Menu options
- (IBAction) menuAddNode:(id)sender;
- (IBAction) menuAddLayer:(id)sender;
- (IBAction) menuAddSprite:(id)sender;
- (void) dropAddSpriteNamed:(NSString*)spriteFile inSpriteSheet:(NSString*)spriteSheetFile at:(CGPoint)pt parent:(CCNode*)parent;
- (void) dropAddSpriteNamed:(NSString*)spriteFile inSpriteSheet:(NSString*)spriteSheetFile at:(CGPoint)pt;
- (void) dropAddTemplateNamed:(NSString*)templateFile at:(CGPoint)pt parent:(CCNode*)parent;
- (void) dropAddTemplateNamed:(NSString*)templateFile at:(CGPoint)pt;
- (IBAction) menuAddMenu:(id)sender;
- (IBAction) menuAddMenuItemImage:(id)sender;
- (IBAction) menuAddLabelTTF:(id)sender;
- (IBAction) menuAddLabelBMFont:(id)sender;

- (IBAction) menuAddParticleExplosion:(id)sender;
- (IBAction) menuAddParticleFire:(id)sender;
- (IBAction) menuAddParticleFireworks:(id)sender;
- (IBAction) menuAddParticleFlower:(id)sender;
- (IBAction) menuAddParticleGalaxy:(id)sender;
- (IBAction) menuAddParticleMeteor:(id)sender;
- (IBAction) menuAddParticleRain:(id)sender;
- (IBAction) menuAddParticleSmoke:(id)sender;
- (IBAction) menuAddParticleSnow:(id)sender;
- (IBAction) menuAddParticleSun:(id)sender;
- (IBAction) menuAddParticleSpiral:(id)sender;


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
- (IBAction) undo:(id)sender;
- (IBAction) redo:(id)sender;

- (IBAction) debugPrintExtraProps:(id)sender;
- (IBAction) debugPrintStructure:(id)sender;
- (IBAction) debugPrintExtraPropsForSelectedNode:(id)sender;

@end
