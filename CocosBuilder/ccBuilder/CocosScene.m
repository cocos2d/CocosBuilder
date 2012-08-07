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

#import "CocosScene.h"
#import "CCBGlobals.h"
#import "CocosBuilderAppDelegate.h"
#import "CCBReaderInternalV1.h"
#import "NodeInfo.h"
#import "PlugInManager.h"
#import "PlugInNode.h"
#import "RulersLayer.h"
#import "GuidesLayer.h"
#import "NotesLayer.h"
#import "CCBTransparentWindow.h"
#import "CCBTransparentView.h"
#import "PositionPropertySetter.h"
#import "CCBGLView.h"
#import "MainWindow.h"
#import "CCNode+NodeInfo.h"
#import "SequencerHandler.h"
#import "SequencerSequence.h"
#import "SequencerNodeProperty.h"
#import "SequencerKeyframe.h"

static CocosScene* sharedCocosScene;

@implementation CocosScene

@synthesize rootNode;
@synthesize isMouseTransforming;
@synthesize scrollOffset;
@synthesize currentTool;
@synthesize guideLayer;
@synthesize rulerLayer;
@synthesize notesLayer;

+(id) sceneWithAppDelegate:(CocosBuilderAppDelegate*)app
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	CocosScene *layer = [[[CocosScene alloc] initWithAppDelegate:app] autorelease];
    sharedCocosScene = layer;
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

+ (CocosScene*) cocosScene
{
    return sharedCocosScene;
}

-(void) setupEditorNodes
{
    // Rulers
    rulerLayer = [RulersLayer node];
    [self addChild:rulerLayer z:6];
    
    // Guides
    guideLayer = [GuidesLayer node];
    [self addChild:guideLayer z:3];
    
    // Sticky notes
    notesLayer = [NotesLayer node];
    [self addChild:notesLayer z:5];
    
    // Selection layer
    selectionLayer = [CCLayer node];
    [self addChild:selectionLayer z:4];
    
    // Border layer
    borderLayer = [CCLayer node];
    [self addChild:borderLayer z:1];
    
    ccColor4B borderColor = ccc4(128, 128, 128, 180);
    
    borderBottom = [CCLayerColor layerWithColor:borderColor];
    borderTop = [CCLayerColor layerWithColor:borderColor];
    borderLeft = [CCLayerColor layerWithColor:borderColor];
    borderRight = [CCLayerColor layerWithColor:borderColor];
    
    [borderLayer addChild:borderBottom];
    [borderLayer addChild:borderTop];
    [borderLayer addChild:borderLeft];
    [borderLayer addChild:borderRight];
    
    //borderDeviceIPhone = [CCSprite spriteWithFile:@"frame-iphone.png"];
    //borderDeviceIPad = [CCSprite spriteWithFile:@"frame-ipad.png"];
    borderDevice = [CCSprite node];
    [borderLayer addChild:borderDevice z:1];
    
    // Gray background
    bgLayer = [CCLayerColor layerWithColor:ccc4(128, 128, 128, 255) width:4096 height:4096];
    bgLayer.position = ccp(0,0);
    bgLayer.anchorPoint = ccp(0,0);
    [self addChild:bgLayer z:-1];
    
    // Black content layer
    stageBgLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255) width:0 height:0];
    stageBgLayer.anchorPoint = ccp(0.5,0.5);
    stageBgLayer.ignoreAnchorPointForPosition = NO;
    [self addChild:stageBgLayer z:0];
    
    contentLayer = [CCLayer node];
    [stageBgLayer addChild:contentLayer];
}

- (void) setStageBorder:(int)type
{
    //borderDeviceIPhone.visible = NO;
    //borderDeviceIPad.visible = NO;
    borderDevice.visible = NO;
    
    if (type == kCCBBorderDevice)
    {
        [borderBottom setOpacity:255];
        [borderTop setOpacity:255];
        [borderLeft setOpacity:255];
        [borderRight setOpacity:255];
        
        CCTexture2D* deviceTexture = NULL;
        BOOL rotateDevice = NO;
        
        int devType = [appDelegate orientedDeviceTypeForSize:stageBgLayer.contentSize];
        if (devType == kCCBCanvasSizeIPhonePortrait)
        {
            deviceTexture = [[CCTextureCache sharedTextureCache] addImage:@"frame-iphone.png"];
            rotateDevice = NO;
        }
        else if (devType == kCCBCanvasSizeIPhoneLandscape)
        {
            deviceTexture = [[CCTextureCache sharedTextureCache] addImage:@"frame-iphone.png"];
            rotateDevice = YES;
        }
        else if (devType == kCCBCanvasSizeIPadPortrait)
        {
            deviceTexture = [[CCTextureCache sharedTextureCache] addImage:@"frame-ipad.png"];
            rotateDevice = NO;
        }
        else if (devType == kCCBCanvasSizeIPadLandscape)
        {
            deviceTexture = [[CCTextureCache sharedTextureCache] addImage:@"frame-ipad.png"];
            rotateDevice = YES;
        }
        else if (devType == kCCBCanvasSizeAndroidXSmallPortrait)
        {
            deviceTexture = [[CCTextureCache sharedTextureCache] addImage:@"frame-android-xsmall.png"];
            rotateDevice = NO;
        }
        else if (devType == kCCBCanvasSizeAndroidXSmallLandscape)
        {
            deviceTexture = [[CCTextureCache sharedTextureCache] addImage:@"frame-android-xsmall.png"];
            rotateDevice = YES;
        }
        else if (devType == kCCBCanvasSizeAndroidSmallPortrait)
        {
            deviceTexture = [[CCTextureCache sharedTextureCache] addImage:@"frame-android-small.png"];
            rotateDevice = NO;
        }
        else if (devType == kCCBCanvasSizeAndroidSmallLandscape)
        {
            deviceTexture = [[CCTextureCache sharedTextureCache] addImage:@"frame-android-small.png"];
            rotateDevice = YES;
        }
        else if (devType == kCCBCanvasSizeAndroidMediumPortrait)
        {
            deviceTexture = [[CCTextureCache sharedTextureCache] addImage:@"frame-android-medium.png"];
            rotateDevice = NO;
        }
        else if (devType == kCCBCanvasSizeAndroidMediumLandscape)
        {
            deviceTexture = [[CCTextureCache sharedTextureCache] addImage:@"frame-android-medium.png"];
            rotateDevice = YES;
        }
        
        if (deviceTexture)
        {
            if (rotateDevice) borderDevice.rotation = 90;
            else borderDevice.rotation = 0;
            
            borderDevice.texture = deviceTexture;
            borderDevice.textureRect = CGRectMake(0, 0, deviceTexture.contentSize.width, deviceTexture.contentSize.height);
            
            borderDevice.visible = YES;
        }
    }
    else if (type == kCCBBorderTransparent)
    {
        [borderBottom setOpacity:180];
        [borderTop setOpacity:180];
        [borderLeft setOpacity:180];
        [borderRight setOpacity:180];
    }
    else if (type == kCCBBorderOpaque)
    {
        [borderBottom setOpacity:255];
        [borderTop setOpacity:255];
        [borderLeft setOpacity:255];
        [borderRight setOpacity:255];
    }
    else
    {
        [borderBottom setOpacity:0];
        [borderTop setOpacity:0];
        [borderLeft setOpacity:0];
        [borderRight setOpacity:0];
    }
    
    stageBorderType = type;
}

- (int) stageBorder
{
    return stageBorderType;
}

- (void) setupDefaultNodes
{
}

#pragma mark Stage properties

- (void) setStageSize: (CGSize) size centeredOrigin:(BOOL)centeredOrigin
{
    stageBgLayer.contentSize = size;
    if (centeredOrigin) contentLayer.position = ccp(size.width/2, size.height/2);
    else contentLayer.position = ccp(0,0);
    
    [self setStageBorder:stageBorderType];
    
    if (renderedScene)
    {
        [self removeChild:renderedScene cleanup:YES];
        renderedScene = NULL;
    }
    
    if (size.width > 0 && size.height > 0 && size.width <= 1024 && size.height <= 1024)
    {
        renderedScene = [CCRenderTexture renderTextureWithWidth:size.width height:size.height];
        renderedScene.anchorPoint = ccp(0.5f,0.5f);
        [self addChild:renderedScene];
    }
}

- (CGSize) stageSize
{
    return stageBgLayer.contentSize;
}

- (BOOL) centeredOrigin
{
    return (contentLayer.position.x != 0);
}

- (void) setStageZoom:(float) zoom
{
    float zoomFactor = zoom/stageZoom;
    
    scrollOffset = ccpMult(scrollOffset, zoomFactor);
    
    stageBgLayer.scale = zoom;
    borderDevice.scale = zoom;
    
    stageZoom = zoom;
}

- (float) stageZoom
{
    return stageZoom;
}

#pragma mark Extra properties

/*
- (id) extraPropForKey:(NSString*)key andNode:(CCNode*) node
{
    NodeInfo* info = node.userObject;
    return [info.extraProps objectForKey:key];
}

- (void) setExtraProp: (id)val forKey:(NSString*)key andNode:(CCNode*) node
{
    NodeInfo* info = node.userObject;
    [info.extraProps setObject:val forKey:key];
}
*/

- (void) setupExtraPropsForNode:(CCNode*) node
{
    [node setExtraProp:[NSNumber numberWithInt:-1] forKey:@"tag"];
    [node setExtraProp:[NSNumber numberWithBool:YES] forKey:@"lockedScaleRatio"];
    
    [node setExtraProp:@"" forKey:@"customClass"];
    [node setExtraProp:[NSNumber numberWithInt:0] forKey:@"memberVarAssignmentType"];
    [node setExtraProp:@"" forKey:@"memberVarAssignmentName"];
    
    [node setExtraProp:[NSNumber numberWithBool:YES] forKey:@"isExpanded"];
}

#pragma mark Replacing content

- (void) replaceRootNodeWith:(CCNode*)node
{
    CCBGlobals* g = [CCBGlobals globals];
    
    [contentLayer removeChild:rootNode cleanup:YES];
    
    self.rootNode = node;
    g.rootNode = node;
    
    if (!node) return;
    
    [contentLayer addChild:node];
}

#pragma mark Handle selections

- (void) setSelectedNode:(CCNode*) node
{
    selectedNode = node;
}

- (BOOL) selectedNodeHasReadOnlyProperty:(NSString*)prop
{
    if (!selectedNode) return NO;
    NodeInfo* info = selectedNode.userObject;
    PlugInNode* plugIn = info.plugIn;
    
    NSDictionary* propInfo = [plugIn.nodePropertiesDict objectForKey:prop];
    return [[propInfo objectForKey:@"readOnly"] boolValue];
}

- (void) updateSelection
{
    CCNode* node = selectedNode;
    
    // Clear selection
    [selectionLayer removeAllChildrenWithCleanup:YES];
    
    if (node)
    {
        CCNode* parent = node.parent;
        
        // Add centerpoint
        CGPoint center = [parent convertToWorldSpace: node.position];
        CCSprite* selmarkCenter = [CCSprite spriteWithFile:@"select-pt.png"];
        selmarkCenter.position = center;
        [selectionLayer addChild:selmarkCenter];
        
        CGPoint minCorner = center;
        
        if (node.contentSize.width > 0 && node.contentSize.height > 0)
        {
            CGAffineTransform transform = [node nodeToWorldTransform];
            float angle = -(atan2(transform.b, transform.a)/(M_PI*2))*360;
            
            // Add bounding box markers
            CGPoint bl = [node convertToWorldSpace: ccp(0,0)];
            CCSprite* blSelmark = [CCSprite spriteWithFile:@"select-bl.png"];
            blSelmark.position = bl;
            blSelmark.rotation = angle;
            [selectionLayer addChild:blSelmark];
            
            CGPoint br = [node convertToWorldSpace: ccp(node.contentSize.width,0)];
            CCSprite* brSelmark = [CCSprite spriteWithFile:@"select-br.png"];
            brSelmark.position = br;
            brSelmark.rotation = angle;
            [selectionLayer addChild:brSelmark];
            
            CGPoint tl = [node convertToWorldSpace: ccp(0,node.contentSize.height)];
            CCSprite* tlSelmark = [CCSprite spriteWithFile:@"select-tl.png"];
            tlSelmark.position = tl;
            tlSelmark.rotation = angle;
            [selectionLayer addChild:tlSelmark];
            
            CGPoint tr = [node convertToWorldSpace: ccp(node.contentSize.width,node.contentSize.height)];
            CCSprite* trSelmark = [CCSprite spriteWithFile:@"select-tr.png"];
            trSelmark.position = tr;
            trSelmark.rotation = angle;
            [selectionLayer addChild:trSelmark];
            
            minCorner.x = MIN(minCorner.x, bl.x);
            minCorner.x = MIN(minCorner.x, br.x);
            minCorner.x = MIN(minCorner.x, tl.x);
            minCorner.x = MIN(minCorner.x, tr.x);
            
            minCorner.y = MIN(minCorner.y, bl.y);
            minCorner.y = MIN(minCorner.y, br.y);
            minCorner.y = MIN(minCorner.y, tl.y);
            minCorner.y = MIN(minCorner.y, tr.y);
        }
        
        if (minCorner.x < 10+15) minCorner.x = 10+15;
        if (minCorner.y < 36+15) minCorner.y = 36+15;
        if (minCorner.x > self.contentSize.width - 28*3+6) minCorner.x = self.contentSize.width - 28*3+6;
        if (minCorner.y > self.contentSize.height+6) minCorner.y = self.contentSize.height+6;
        
        minCorner.x = (int)minCorner.x;
        minCorner.y = (int)minCorner.y;
        
        if (currentMouseTransform == kCCBTransformHandleNone ||
            currentMouseTransform == kCCBTransformHandleMove)
        {
            rectBtnMove = CGRectMake(minCorner.x-8, minCorner.y-36, 28, 28);
            rectBtnScale = CGRectMake(minCorner.x-8+28, minCorner.y-36, 28, 28);
            rectBtnRotate = CGRectMake(minCorner.x-8+56, minCorner.y-36, 28, 28);
        }
        
        // Move handle
        CCSprite* btnMove;
        if (currentMouseTransform == kCCBTransformHandleMove) btnMove = [CCSprite spriteWithFile:@"btn-move-hi.png"];
        else btnMove = [CCSprite spriteWithFile:@"btn-move.png"];
        
        btnMove.position = rectBtnMove.origin;
        btnMove.anchorPoint = ccp(0,0);
        [selectionLayer addChild:btnMove z:1];
        
        // Scale handle
        CCSprite* btnScale;
        if (currentMouseTransform == kCCBTransformHandleScale) btnScale = [CCSprite spriteWithFile:@"btn-scale-hi.png"];
        else btnScale = [CCSprite spriteWithFile:@"btn-scale.png"];
        
        btnScale.position = rectBtnScale.origin;
        btnScale.anchorPoint = ccp(0,0);
        [selectionLayer addChild:btnScale z:1];
        if ([self selectedNodeHasReadOnlyProperty:@"scale"]) btnScale.opacity = 127;
        
        // Rotation handle
        CCSprite* btnRotate;
        if (currentMouseTransform == kCCBTransformHandleRotate) btnRotate = [CCSprite spriteWithFile:@"btn-rotate-hi.png"];
        else btnRotate = [CCSprite spriteWithFile:@"btn-rotate.png"];
        if ([self selectedNodeHasReadOnlyProperty:@"rotation"]) btnRotate.opacity = 127;
        
        btnRotate.position = rectBtnRotate.origin;
        btnRotate.anchorPoint = ccp(0,0);
        [selectionLayer addChild:btnRotate z:1];
    }
}

- (void) selectBehind
{
    if (currentNodeAtSelectionPtIdx < 0) return;
    
    currentNodeAtSelectionPtIdx -= 1;
    if (currentNodeAtSelectionPtIdx < 0)
    {
        currentNodeAtSelectionPtIdx = (int)[nodesAtSelectionPt count] -1;
    }
    
    [appDelegate setSelectedNode:[nodesAtSelectionPt objectAtIndex:currentNodeAtSelectionPtIdx]];
}

#pragma mark Handle mouse input

- (CGPoint) convertToDocSpace:(CGPoint)viewPt
{
    return [contentLayer convertToNodeSpace:viewPt];
}

- (CGPoint) convertToViewSpace:(CGPoint)docPt
{
    return [contentLayer convertToWorldSpace:docPt];
}

- (NSString*) positionPropertyForSelectedNode
{
    NodeInfo* info = selectedNode.userObject;
    PlugInNode* plugIn = info.plugIn;
    
    return plugIn.positionProperty;
}

- (void) setSelectedNodePos:(CGPoint) pos
{
    if (!selectedNode) return;
    
    //[selectedNode setValue:[NSValue valueWithPoint:NSPointFromCGPoint(pos)] forKey:[self positionPropertyForSelectedNode]];
    [PositionPropertySetter setPosition:NSPointFromCGPoint(pos) forNode:selectedNode prop:[self positionPropertyForSelectedNode]];
}

- (CGPoint) selectedNodePos
{
    if (!selectedNode) return CGPointZero;
    //return NSPointToCGPoint([[selectedNode valueForKey:[self positionPropertyForSelectedNode]] pointValue]);
    return NSPointToCGPoint([PositionPropertySetter positionForNode:selectedNode prop:[self positionPropertyForSelectedNode]]);
}

- (int) transformHandleUnderPt:(CGPoint)pt
{
    if (!selectedNode) return kCCBTransformHandleNone;
    
    if (CGRectContainsPoint(rectBtnMove, pt)) return kCCBTransformHandleMove;
    else if (CGRectContainsPoint(rectBtnScale, pt)) return kCCBTransformHandleScale;
    else if (CGRectContainsPoint(rectBtnRotate, pt)) return kCCBTransformHandleRotate;
    else return kCCBTransformHandleNone;
}

- (void) nodesUnderPt:(CGPoint)pt rootNode:(CCNode*) node nodes:(NSMutableArray*)nodes
{
    if (!node) return;
    
    NodeInfo* parentInfo = node.parent.userObject;
    PlugInNode* parentPlugIn = parentInfo.plugIn;
    
    if (parentPlugIn && !parentPlugIn.canHaveChildren) return;
    
    CGRect hitRect = [node boundingBox];
    
    // Extend the hit area if it's too small
    if (node.contentSize.width < 10)
    {
        hitRect.origin.x -= 5;
        hitRect.size.width += 10;
    }
    
    if (node.contentSize.height < 10)
    {
        hitRect.origin.y -= 5;
        hitRect.size.height += 10;
    }
    
    CCNode* parent = node.parent;
    CGPoint ptLocal = [parent convertToNodeSpace:pt];
    
    if (CGRectContainsPoint(hitRect, ptLocal))
    {
        [nodes addObject:node];
    }
    
    // Visit children
    for (int i = 0; i < [node.children count]; i++)
    {
        [self nodesUnderPt:pt rootNode:[node.children objectAtIndex:i] nodes:nodes];
    }
    
}

- (BOOL) ccMouseDown:(NSEvent *)event
{
    if (!appDelegate.hasOpenedDocument) return YES;
    
    NSPoint posRaw = [event locationInWindow];
    CGPoint pos = NSPointToCGPoint([appDelegate.cocosView convertPoint:posRaw fromView:NULL]);
    
    if ([notesLayer mouseDown:pos event:event]) return YES;
    if ([guideLayer mouseDown:pos event:event]) return YES;
    
    mouseDownPos = pos;
    
    if (currentTool == kCCBToolGrab || ([event modifierFlags] & NSCommandKeyMask))
    {
        [[NSCursor closedHandCursor] push];
        isPanning = YES;
        panningStartScrollOffset = scrollOffset;
        return YES;
    }
    
    // Check for clicked transform handles
    int th = [self transformHandleUnderPt:pos];
    if (th)
    {
        if (th == kCCBTransformHandleMove)
        {
            transformStartPosition = [selectedNode.parent convertToWorldSpace:[self selectedNodePos]];
        }
        else if (th == kCCBTransformHandleScale)
        {
            transformStartScaleX = [PositionPropertySetter scaleXForNode:selectedNode prop:@"scale"];
            transformStartScaleY = [PositionPropertySetter scaleYForNode:selectedNode prop:@"scale"];
        }
        else if (th == kCCBTransformHandleRotate)
        {
            transformStartRotation = selectedNode.rotation;
        }
        
        // Check for disabled properties
        if (th == kCCBTransformHandleScale
            && [self selectedNodeHasReadOnlyProperty:@"scale"])
        {
            th = kCCBTransformHandleNone;
        }
        else if (th == kCCBTransformHandleRotate
                 && [self selectedNodeHasReadOnlyProperty:@"rotation"])
        {
            th = kCCBTransformHandleNone;
        }
        
        currentMouseTransform = th;
        
        return YES;
    }
    
    [nodesAtSelectionPt removeAllObjects];
    [self nodesUnderPt:pos rootNode:rootNode nodes:nodesAtSelectionPt];
    currentNodeAtSelectionPtIdx = (int)[nodesAtSelectionPt count] -1;
    if (currentNodeAtSelectionPtIdx >= 0)
    {
        [appDelegate setSelectedNode:[nodesAtSelectionPt objectAtIndex:currentNodeAtSelectionPtIdx]];
    }
    else
    {
        [appDelegate setSelectedNode:NULL];
    }
    
    return YES;
}

- (BOOL) ccMouseDragged:(NSEvent *)event
{
    if (!appDelegate.hasOpenedDocument) return YES;
    [self mouseMoved:event];
    
    NSPoint posRaw = [event locationInWindow];
    CGPoint pos = NSPointToCGPoint([appDelegate.cocosView convertPoint:posRaw fromView:NULL]);
    
    if ([notesLayer mouseDragged:pos event:event]) return YES;
    if ([guideLayer mouseDragged:pos event:event]) return YES;
    
    if (currentMouseTransform == kCCBTransformHandleMove)
    {
        NSString* positionProp = [self positionPropertyForSelectedNode];
        
        float xDelta = (int)(pos.x - mouseDownPos.x);
        float yDelta = (int)(pos.y - mouseDownPos.y);
        
        CGSize parentSize = [PositionPropertySetter getParentSize:selectedNode];
        
        // Swap axis for relative positions
        int positionType = [PositionPropertySetter positionTypeForNode:selectedNode prop:positionProp];
        if (positionType == kCCBPositionTypeRelativeBottomRight)
        {
            xDelta = -xDelta;
        }
        else if (positionType == kCCBPositionTypeRelativeTopLeft)
        {
            yDelta = -yDelta;
        }
        else if (positionType == kCCBPositionTypeRelativeTopRight)
        {
            xDelta = -xDelta;
            yDelta = -yDelta;
        }
        else if (positionType == kCCBPositionTypePercent)
        {
            // Handle percental positions
            if (parentSize.width > 0)
            {
                xDelta = (xDelta/parentSize.width)*100.0f;
            }
            else
            {
                xDelta = 0;
            }
            
            if (parentSize.height > 0)
            {
                yDelta = (yDelta/parentSize.height)*100.0f;
            }
            else
            {
                yDelta = 0;
            }
        }
        
        CGPoint newPos = ccp(transformStartPosition.x+xDelta, transformStartPosition.y+yDelta);
        
        // Snap to guides
        if (appDelegate.showGuides && appDelegate.snapToGuides)
        {
            // Convert to absolute position (conversion need to happen in node space)
            CGPoint newAbsPos = [selectedNode.parent convertToNodeSpace:newPos];
            
            newAbsPos = NSPointToCGPoint([PositionPropertySetter calcAbsolutePositionFromRelative:NSPointFromCGPoint(newAbsPos) type:positionType parentSize:parentSize]);
            
            newAbsPos = [selectedNode.parent convertToWorldSpace:newAbsPos];
            
            // Perform snapping (snapping happens in world space)
            newAbsPos = [guideLayer snapPoint:newAbsPos];
            
            // Convert back to relative (conversion need to happen in node space)
            newAbsPos = [selectedNode.parent convertToNodeSpace:newAbsPos];
            
            newAbsPos = NSPointToCGPoint([PositionPropertySetter calcRelativePositionFromAbsolute:NSPointFromCGPoint(newAbsPos) type:positionType parentSize:parentSize]);
            
            newPos = [selectedNode.parent convertToWorldSpace:newAbsPos];
        }
        
        CGPoint newLocalPos = [selectedNode.parent convertToNodeSpace:newPos];
        
        [appDelegate saveUndoStateWillChangeProperty:positionProp];
        [self setSelectedNodePos:newLocalPos];
        [appDelegate refreshProperty:[self positionPropertyForSelectedNode]];
    }
    else if (currentMouseTransform == kCCBTransformHandleScale)
    {
        float xDelta = pos.x - mouseDownPos.x;
        float delta = (int)xDelta;
        
        [appDelegate saveUndoStateWillChangeProperty:@"scale"];
        
        int type = [PositionPropertySetter scaledFloatTypeForNode:selectedNode prop:@"scale"];
        [PositionPropertySetter setScaledX:transformStartScaleX + delta/100.0f Y:transformStartScaleY + delta/100.0f type:type forNode:selectedNode prop:@"scale"];
        
        [appDelegate refreshProperty:@"scale"];
    }
    else if (currentMouseTransform == kCCBTransformHandleRotate)
    {
        float xDelta = pos.x - mouseDownPos.x;
        float delta = (int)xDelta;
        
        [appDelegate saveUndoStateWillChangeProperty:@"rotation"];
        appDelegate.selectedNode.rotation = transformStartRotation + delta/4.0f;
        [appDelegate refreshProperty:@"rotation"];
    }
    else if (isPanning)
    {
        CGPoint delta = ccpSub(pos, mouseDownPos);
        scrollOffset = ccpAdd(panningStartScrollOffset, delta);
    }
    
    return YES;
}

- (void) updateAnimateablePropertyValue:(id)value propName:(NSString*)propertyName type:(int)type
{
    NodeInfo* nodeInfo = selectedNode.userObject;
    PlugInNode* plugIn = nodeInfo.plugIn;
    SequencerHandler* sh = [SequencerHandler sharedHandler];
    
    if ([plugIn isAnimatableProperty:propertyName])
    {
        SequencerSequence* seq = sh.currentSequence;
        int seqId = seq.sequenceId;
        SequencerNodeProperty* seqNodeProp = [selectedNode sequenceNodeProperty:propertyName sequenceId:seqId];
        
        if (seqNodeProp)
        {
            SequencerKeyframe* keyframe = [seqNodeProp keyframeAtTime:seq.timelinePosition];
            if (keyframe)
            {
                keyframe.value = value;
            }
            else
            {
                SequencerKeyframe* keyframe = [[[SequencerKeyframe alloc] init] autorelease];
                keyframe.time = seq.timelinePosition;
                keyframe.value = value;
                keyframe.type = type;
                
                [seqNodeProp setKeyframe:keyframe];
            }
            
            [sh redrawTimeline];
        }
        else
        {
            [nodeInfo.baseValues setObject:value forKey:propertyName];
        }
    }
}

- (BOOL) ccMouseUp:(NSEvent *)event
{
    if (!appDelegate.hasOpenedDocument) return YES;
    
    NSPoint posRaw = [event locationInWindow];
    CGPoint pos = NSPointToCGPoint([appDelegate.cocosView convertPoint:posRaw fromView:NULL]);
    
    if (currentMouseTransform != kCCBTransformHandleNone)
    {
        // Update keyframes & base value
        id value = NULL;
        NSString* propName = NULL;
        int type = kCCBKeyframeTypeDegrees;
        
        if (currentMouseTransform == kCCBTransformHandleRotate)
        {
            value = [NSNumber numberWithFloat: selectedNode.rotation];
            propName = @"rotation";
            type = kCCBKeyframeTypeDegrees;
        }
        else if (currentMouseTransform == kCCBTransformHandleScale)
        {
            float x = [PositionPropertySetter scaleXForNode:selectedNode prop:@"scale"];
            float y = [PositionPropertySetter scaleYForNode:selectedNode prop:@"scale"];
            value = [NSArray arrayWithObjects:
                     [NSNumber numberWithFloat:x],
                     [NSNumber numberWithFloat:y],
                     nil];
            propName = @"scale";
            type = kCCBKeyframeTypeScaleLock;
        }
        else if (currentMouseTransform == kCCBTransformHandleMove)
        {
            CGPoint pt = [PositionPropertySetter positionForNode:selectedNode prop:@"position"];
            value = [NSArray arrayWithObjects:
                     [NSNumber numberWithFloat:pt.x],
                     [NSNumber numberWithFloat:pt.y],
                     nil];
            propName = @"position";
            type = kCCBKeyframeTypePosition;
        }
        
        if (value)
        {
            [self updateAnimateablePropertyValue:value propName:propName type:type];
        }
    }
    
    if ([notesLayer mouseUp:pos event:event]) return YES;
    if ([guideLayer mouseUp:pos event:event]) return YES;
    
    isMouseTransforming = NO;
    
    if (isPanning)
    {
        [NSCursor pop];
        isPanning = NO;
    }
    
    currentMouseTransform = kCCBTransformHandleNone;
    return YES;
}

- (void)mouseMoved:(NSEvent *)event
{
    if (!appDelegate.hasOpenedDocument) return;
    
    NSPoint posRaw = [event locationInWindow];
    CGPoint pos = NSPointToCGPoint([appDelegate.cocosView convertPoint:posRaw fromView:NULL]);
    
    mousePos = pos;
}

- (void)mouseEntered:(NSEvent *)event
{
    mouseInside = YES;
    
    if (!appDelegate.hasOpenedDocument) return;
    
    [rulerLayer mouseEntered:event];
}
- (void)mouseExited:(NSEvent *)event
{
    mouseInside = NO;
    
    if (!appDelegate.hasOpenedDocument) return;
    
    [rulerLayer mouseExited:event];
}

- (void)cursorUpdate:(NSEvent *)event
{
    if (!appDelegate.hasOpenedDocument) return;
    
    if (currentTool == kCCBToolGrab)
    {
        [[NSCursor openHandCursor] set];
    }
}

- (void) scrollWheel:(NSEvent *)theEvent
{
    if (!appDelegate.window.isKeyWindow) return;
    if (isMouseTransforming || isPanning || currentMouseTransform != kCCBTransformHandleNone) return;
    if (!appDelegate.hasOpenedDocument) return;
    
    int dx = [theEvent deltaX]*4;
    int dy = -[theEvent deltaY]*4;
    
    scrollOffset.x = scrollOffset.x+dx;
    scrollOffset.y = scrollOffset.y+dy;
}

#pragma mark Updates every frame

- (void) nextFrame:(ccTime) time
{
    // Recenter the content layer
    BOOL winSizeChanged = !CGSizeEqualToSize(winSize, [[CCDirector sharedDirector] winSize]);
    winSize = [[CCDirector sharedDirector] winSize];
    CGPoint stageCenter = ccp((int)(winSize.width/2+scrollOffset.x) , (int)(winSize.height/2+scrollOffset.y));
    
    self.contentSize = winSize;
    
    stageBgLayer.position = stageCenter;
    renderedScene.position = stageCenter;
    
    if (stageZoom <= 1 || !renderedScene)
    {
        // Use normal rendering
        stageBgLayer.visible = YES;
        renderedScene.visible = NO;
        [[borderDevice texture] setAntiAliasTexParameters];
    }
    else
    {
        // Render with render-texture
        stageBgLayer.visible = NO;
        renderedScene.visible = YES;
        renderedScene.scale = stageZoom;
        [renderedScene beginWithClear:0 g:0 b:0 a:1];
        [contentLayer visit];
        [renderedScene end];
        [[borderDevice texture] setAliasTexParameters];
    }
    
    [self updateSelection];
    
    // Setup border layer
    CGRect bounds = [stageBgLayer boundingBox];
    
    borderBottom.position = ccp(0,0);
    [borderBottom setContentSize:CGSizeMake(winSize.width, bounds.origin.y)];
    
    borderTop.position = ccp(0, bounds.size.height + bounds.origin.y);
    [borderTop setContentSize:CGSizeMake(winSize.width, winSize.height - bounds.size.height - bounds.origin.y)];
    
    borderLeft.position = ccp(0,bounds.origin.y);
    [borderLeft setContentSize:CGSizeMake(bounds.origin.x, bounds.size.height)];
    
    borderRight.position = ccp(bounds.origin.x+bounds.size.width, bounds.origin.y);
    [borderRight setContentSize:CGSizeMake(winSize.width - bounds.origin.x - bounds.size.width, bounds.size.height)];
    
    CGPoint center = ccp(bounds.origin.x+bounds.size.width/2, bounds.origin.y+bounds.size.height/2);
    borderDevice.position = center;
    
    // Update rulers
    origin = ccpAdd(stageCenter, ccpMult(contentLayer.position,stageZoom));
    origin.x -= stageBgLayer.contentSize.width/2 * stageZoom;
    origin.y -= stageBgLayer.contentSize.height/2 * stageZoom;
    
    [rulerLayer updateWithSize:winSize stageOrigin:origin zoom:stageZoom];
    [rulerLayer updateMousePos:mousePos];
    
    // Update guides
    guideLayer.visible = appDelegate.showGuides;
    [guideLayer updateWithSize:winSize stageOrigin:origin zoom:stageZoom];
    
    // Update sticky notes
    notesLayer.visible = appDelegate.showStickyNotes;
    [notesLayer updateWithSize:winSize stageOrigin:origin zoom:stageZoom];
    
    if (winSizeChanged)
    {
        // Update mouse tracking
        if (trackingArea)
        {
            [[appDelegate cocosView] removeTrackingArea:trackingArea];
            [trackingArea release];
        }
        
        trackingArea = [[NSTrackingArea alloc] initWithRect:NSMakeRect(0, 0, winSize.width, winSize.height) options:NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited | NSTrackingCursorUpdate | NSTrackingActiveInKeyWindow  owner:[appDelegate cocosView] userInfo:NULL];
        [[appDelegate cocosView] addTrackingArea:trackingArea];
    }
    
    // Hide the transparent gui window if it has no subviews
    //if ([[appDelegate.guiView subviews] count] == 0)
    //{
    //    appDelegate.guiWindow.isVisible = NO;
    //}
}

#pragma mark Init and dealloc

-(id) initWithAppDelegate:(CocosBuilderAppDelegate*)app;
{
    appDelegate = app;
    
    nodesAtSelectionPt = [[NSMutableArray array] retain];
    
	if( (self=[super init] ))
    {
        
        [self setupEditorNodes];
        [self setupDefaultNodes];
        
        [self schedule:@selector(nextFrame:)];
        
        self.isMouseEnabled = YES;
        
        stageZoom = 1;
        
        [self nextFrame:0];
	}
	return self;
}

- (void) dealloc
{
    [trackingArea release];
    [nodesAtSelectionPt release];
	[super dealloc];
}

#pragma mark Debug


@end
