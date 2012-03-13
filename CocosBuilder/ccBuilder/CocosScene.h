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

#import "cocos2d.h"
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