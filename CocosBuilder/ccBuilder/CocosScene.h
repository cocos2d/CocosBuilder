//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import "cocos2d.h"
//#import "CCButton.h"
//#import "CCNineSlice.h"
//#import "CCThreeSlice.h"
@class CocosBuilderAppDelegate;
@class CCBTemplateNode;

enum {
    kCCBParticleTypeExplosion = 0,
    kCCBParticleTypeFire,
    kCCBParticleTypeFireworks,
    kCCBParticleTypeFlower,
    kCCBParticleTypeGalaxy,
    kCCBParticleTypeMeteor,
    kCCBParticleTypeRain,
    kCCBParticleTypeSmoke,
    kCCBParticleTypeSnow,
    kCCBParticleTypeSpiral,
    kCCBParticleTypeSun
};

enum {
    kCCBTransformHandleNone = 0,
    kCCBTransformHandleMove,
    kCCBTransformHandleScale,
    kCCBTransformHandleRotate
};

enum {
    kCCBToolSelection = 0,
    kCCBToolGrab
};

@interface CocosScene : CCLayer
{
    CCLayerColor* bgLayer;
    CCLayerColor* stageBgLayer;
    CCLayer* contentLayer;
    CCLayer* selectionLayer;
    CCLayer* borderLayer;
    CCNode* rootNode;
    CCNode* selectedNode;
    CCRenderTexture* renderedScene;
    CocosBuilderAppDelegate* appDelegate;
    
    CGRect rectBtnMove;
    CGRect rectBtnScale;
    CGRect rectBtnRotate;
    
    CGPoint mouseDownPos;
    float transformStartRotation;
    float transformStartScaleX;
    float transformStartScaleY;
    CGPoint transformStartPosition;
    int currentMouseTransform;
    BOOL isMouseTransforming;
    BOOL isPanning;
    CGPoint scrollOffset;
    CGPoint panningStartScrollOffset;
    
    // Selection
    NSMutableArray* nodesAtSelectionPt;
    int currentNodeAtSelectionPtIdx;
    
    CCLayerColor* borderBottom;
    CCLayerColor* borderTop;
    CCLayerColor* borderLeft;
    CCLayerColor* borderRight;
    CCSprite* borderDeviceIPhone;
    CCSprite* borderDeviceIPad;
    
    int stageBorderType;
    float stageZoom;
    
    int currentTool;
}

@property (nonatomic,assign) CCNode* rootNode;
@property (nonatomic,readonly) BOOL isMouseTransforming;
@property (nonatomic,assign) CGPoint scrollOffset;

@property (nonatomic,assign) int currentTool;

// returns a Scene that contains the HelloWorld as the only child
+(id) sceneWithAppDelegate:(CocosBuilderAppDelegate*)app;
-(id) initWithAppDelegate:(CocosBuilderAppDelegate*)app;

- (void) scrollWheel:(NSEvent *)theEvent;

- (void) setExtraProp: (id)val forKey:(NSString*)key andNode:(CCNode*) node;
- (id) extraPropForKey:(NSString*)key andNode:(CCNode*) node;

- (void) setStageSize: (CGSize) size centeredOrigin:(BOOL)centeredOrigin;
- (CGSize) stageSize;
- (BOOL) centeredOrigin;
- (void) setStageBorder:(int)type;
- (int) stageBorder;

- (void) setStageZoom:(float) zoom;
- (float) stageZoom;

- (void) replaceRootNodeWith:(CCNode*)node;

- (void) setSelectedNode:(CCNode*) node;
- (void) updateSelection;
- (void) selectBehind;

- (void) printNodes:(CCNode*)node level:(int)level;
- (void) printExtraProps;
- (void) printExtraPropsForNode:(CCNode*)node;
@end