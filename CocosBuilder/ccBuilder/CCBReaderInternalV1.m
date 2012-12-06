/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
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

#import "CCBReaderInternalV1.h"
#import "CCBReaderInternal.h"
#import "CCBWriterInternal.h"
#import "CCBGlobals.h"
#import <objc/runtime.h>
#import "NodeInfo.h"
#import "PlugInNode.h"
#import "PlugInManager.h"
#import "CCNode+NodeInfo.h"
#import "PositionPropertySetter.h"

#import "TexturePropertySetter.h"

@implementation CCBReaderInternalV1

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark Read properties from dictionary

+ (int) intValFromDict:(NSDictionary*) dict forKey:(NSString*) key
{
    return [[dict valueForKey:key] intValue];
}

+ (float) floatValFromDict:(NSDictionary*) dict forKey:(NSString*) key
{
    return [[dict valueForKey:key] floatValue];
}

+ (BOOL) boolValFromDict:(NSDictionary*) dict forKey:(NSString*) key
{
    return [[dict valueForKey:key] boolValue];
}

+ (CGPoint) pointValFromDict:(NSDictionary*) dict forKey:(NSString*) key
{
    NSArray* arr = [dict valueForKey:key];
    if (!arr) return ccp(0,0);
    float x = [[arr objectAtIndex:0] floatValue];
    float y = [[arr objectAtIndex:1] floatValue];
    return ccp(x, y);
}

+ (CGSize) sizeValFromDict:(NSDictionary*) dict forKey:(NSString*) key
{
    NSArray* arr = [dict valueForKey:key];
    float w = [[arr objectAtIndex:0] floatValue];
    float h = [[arr objectAtIndex:1] floatValue];
    return CGSizeMake(w, h);
}

+ (ccColor3B) color3ValFromDict:(NSDictionary*) dict forKey:(NSString*) key
{
    NSArray* arr = [dict valueForKey:key];
    int r = [[arr objectAtIndex:0] intValue];
    int g = [[arr objectAtIndex:1] intValue];
    int b = [[arr objectAtIndex:2] intValue];
    return ccc3(r, g, b);
}

+ (ccColor4F) color4fValFromDict:(NSDictionary*) dict forKey:(NSString*) key
{
    NSArray* arr = [dict valueForKey:key];
    ccColor4F color;
    color.r = [[arr objectAtIndex:0] floatValue];
    color.g = [[arr objectAtIndex:1] floatValue];
    color.b = [[arr objectAtIndex:2] floatValue];
    color.a = [[arr objectAtIndex:3] floatValue];
    return color;
}

+ (ccBlendFunc) blendFuncValFromDict:(NSDictionary*) dict forKey:(NSString*) key
{
    NSArray* arr = [dict valueForKey:key];
    int src = [[arr objectAtIndex:0] intValue];
    int dst = [[arr objectAtIndex:1] intValue];
    ccBlendFunc blendFunc;
    blendFunc.src = src;
    blendFunc.dst = dst;
    
    return blendFunc;
}

#pragma mark Store extra properties (only used by editor)

+ (void) setExtraProp:(NSObject*) prop forKey:(NSString *)key andNode:(CCNode*) node
{
    NodeInfo* info = node.userObject;
    [info.extraProps setObject:prop forKey:key];
}

+ (void) setPropsForNode: (CCNode*) node props:(NSDictionary*)props
{
    CGPoint position = [CCBReaderInternalV1 pointValFromDict:props forKey:@"position"];
    [PositionPropertySetter setPosition:NSPointFromCGPoint(position) type:0 forNode:node prop:@"position"];
    
    if (![node isKindOfClass:[CCSprite class]] &&
        ![node isKindOfClass:[CCMenuItemImage class]] &&
        ![node isKindOfClass:[CCLabelBMFont class]])
    {
        CGSize contentSize = [CCBReaderInternalV1 sizeValFromDict:props forKey:@"contentSize"];
        [PositionPropertySetter setSize:NSSizeFromCGSize(contentSize) type:0 forNode:node prop:@"contentSize"];
    }
    float scaleX = [CCBReaderInternalV1 floatValFromDict:props forKey:@"scaleX"];
    float scaleY = [CCBReaderInternalV1 floatValFromDict:props forKey:@"scaleY"];
    
    [PositionPropertySetter setScaledX:scaleX Y:scaleY type:0 forNode:node prop:@"scale"];
    
    node.anchorPoint = [CCBReaderInternalV1 pointValFromDict:props forKey:@"anchorPoint"];
    node.rotation = [CCBReaderInternalV1 floatValFromDict:props forKey:@"rotation"];
    node.ignoreAnchorPointForPosition = ![CCBReaderInternalV1 boolValFromDict:props forKey:@"isRelativeAnchorPoint"];
    node.visible = [CCBReaderInternalV1 boolValFromDict:props forKey:@"visible"];
    node.tag = [CCBReaderInternalV1 intValFromDict:props forKey:@"tag"];
        
        [CCBReaderInternalV1 setExtraProp:[props objectForKey:@"customClass"] forKey:@"customClass" andNode:node];
        [CCBReaderInternalV1 setExtraProp:[props objectForKey:@"memberVarAssignmentType"] forKey:@"memberVarAssignmentType" andNode:node];
        [CCBReaderInternalV1 setExtraProp:[props objectForKey:@"memberVarAssignmentName"] forKey:@"memberVarAssignmentName" andNode:node];
        [CCBReaderInternalV1 setExtraProp:[props objectForKey:@"lockedScaleRatio"] forKey:@"lockedScaleRatio" andNode:node];
        
        // Expanded nodes
        BOOL isExpanded;
        NSNumber* isExpandedObj = [props objectForKey:@"isExpanded"];
        if (isExpandedObj) isExpanded = [isExpandedObj boolValue];
        else isExpanded = YES;
        
        [CCBReaderInternalV1 setExtraProp:[NSNumber numberWithBool:isExpanded] forKey:@"isExpanded" andNode:node];
}

+ (void) setPropsForLayer: (CCLayer*) node props:(NSDictionary*)props
{
    [CCBReaderInternalV1 setExtraProp:[props objectForKey:@"touchEnabled"] forKey:@"touchEnabled" andNode:node];
    [CCBReaderInternalV1 setExtraProp:[props objectForKey:@"accelerometerEnabled"] forKey:@"accelerometerEnabled" andNode:node];
    [CCBReaderInternalV1 setExtraProp:[props objectForKey:@"mouseEnabled"] forKey:@"mouseEnabled" andNode:node];
    [CCBReaderInternalV1 setExtraProp:[props objectForKey:@"keyboardEnabled"] forKey:@"keyboardEnabled" andNode:node];
}

+ (void) setPropsForLayerColor: (CCLayerColor*) node props:(NSDictionary*)props
{
    [node setColor: [CCBReaderInternalV1 color3ValFromDict:props forKey:@"color"]];
    [node setOpacity: [CCBReaderInternalV1 intValFromDict:props forKey:@"opacity"]];
    node.blendFunc = [CCBReaderInternalV1 blendFuncValFromDict:props forKey:@"blendFunc"];
}

+ (void) setPropsForLayerGradient: (CCLayerGradient*) node props:(NSDictionary*)props
{
    [node setStartColor: [CCBReaderInternalV1 color3ValFromDict:props forKey:@"color"]];
    [node setStartOpacity: [CCBReaderInternalV1 intValFromDict:props forKey:@"opacity"]];
    [node setEndColor: [CCBReaderInternalV1 color3ValFromDict:props forKey:@"endColor"]];
    [node setEndOpacity: [CCBReaderInternalV1 intValFromDict:props forKey:@"endOpacity"]];
    node.vector = [CCBReaderInternalV1 pointValFromDict:props forKey:@"vector"];
}

+ (void) setPropsForSprite: (CCSprite*) node props:(NSDictionary*)props
{
    [CCBReaderInternalV1 setExtraProp:[props objectForKey:@"spriteFile"] forKey:@"displayFrame" andNode:node];
    NSString* spriteFramesFile = [props objectForKey:@"spriteFramesFile"];
    if (!spriteFramesFile || [spriteFramesFile isEqualToString:@""])
    {
        spriteFramesFile = kCCBUseRegularFile;
    }
    [CCBReaderInternalV1 setExtraProp:spriteFramesFile forKey:@"displayFrameSheet" andNode:node];
    
    [TexturePropertySetter setSpriteFrameForNode:node andProperty:@"displayFrame" withFile:[props objectForKey:@"spriteFile"] andSheetFile:[props objectForKey:@"spriteFramesFile"]];
    
    node.opacity = [CCBReaderInternalV1 intValFromDict:props forKey:@"opacity"];
    node.color = [CCBReaderInternalV1 color3ValFromDict:props forKey:@"color"];
    node.flipX = [CCBReaderInternalV1 boolValFromDict:props forKey:@"flipX"];
    node.flipY = [CCBReaderInternalV1 boolValFromDict:props forKey:@"flipY"];
    node.blendFunc = [CCBReaderInternalV1 blendFuncValFromDict:props forKey:@"blendFunc"];
}

+ (void) setPropsForMenu: (CCMenu*) node props:(NSDictionary*)props
{
    node.mouseEnabled = NO;
}

+ (void) setPropsForMenuItem: (CCMenuItem*) node props:(NSDictionary*)props
{
    [node setIsEnabled:[CCBReaderInternalV1 boolValFromDict:props forKey:@"isEnabled"]];
    [CCBReaderInternalV1 setExtraProp:[props objectForKey:@"selector"] forKey:@"block" andNode:node];
    [CCBReaderInternalV1 setExtraProp:[props objectForKey:@"target"] forKey:@"blockTarget" andNode:node];
    NSString* spriteFramesFile = [props objectForKey:@"spriteFramesFile"];
    if (spriteFramesFile)
    {
        [CCBReaderInternalV1 setExtraProp:spriteFramesFile forKey:@"spriteSheetFile" andNode:node];
    }
}

+ (void) setPropsForMenuItemImage: (CCMenuItemImage*) node props:(NSDictionary*)props
{
    [CCBReaderInternalV1 setExtraProp:[props objectForKey:@"spriteFileNormal"] forKey:@"spriteFileNormal" andNode:node];
    [CCBReaderInternalV1 setExtraProp:[props objectForKey:@"spriteFileSelected"] forKey:@"spriteFileSelected" andNode:node];
    [CCBReaderInternalV1 setExtraProp:[props objectForKey:@"spriteFileDisabled"] forKey:@"spriteFileDisabled" andNode:node];
}

+ (void) setPropsForLabelBMFont: (CCLabelBMFont*) node props:(NSDictionary*)props
{
    NSString* string = [props objectForKey:@"string"];
    
    node.opacity = [CCBReaderInternalV1 intValFromDict:props forKey:@"opacity"];
    node.color = [CCBReaderInternalV1 color3ValFromDict:props forKey:@"color"];
    node.string = string;
    
    [CCBReaderInternalV1 setExtraProp:[props objectForKey:@"fontFile"] forKey:@"fontFile" andNode:node];
}

+ (void) setPropsForLabelTTF: (CCLabelTTF*) node props:(NSDictionary*)props
{
    NSString* fontName = [props objectForKey:@"fontName"];
    NSString* string = [props objectForKey:@"string"];
    float fontSize = [CCBReaderInternalV1 floatValFromDict:props forKey:@"fontSize"];
    
    node.fontSize = fontSize;
    node.string = string;
    node.fontName = fontName;
}

+ (void) setPropsForParticleSystem: (CCParticleSystem*) node props:(NSDictionary*)props
{
    node.emitterMode = [CCBReaderInternalV1 intValFromDict:props forKey:@"emitterMode"];
    node.emissionRate = [CCBReaderInternalV1 floatValFromDict:props forKey:@"emissionRate"];
    node.duration = [CCBReaderInternalV1 floatValFromDict:props forKey:@"duration"];
    node.posVar = [CCBReaderInternalV1 pointValFromDict:props forKey:@"posVar"];
    node.totalParticles = [CCBReaderInternalV1 intValFromDict:props forKey:@"totalParticles"];
    node.life = [CCBReaderInternalV1 floatValFromDict:props forKey:@"life"];
    node.lifeVar = [CCBReaderInternalV1 floatValFromDict:props forKey:@"lifeVar"];
    node.startSize = [CCBReaderInternalV1 intValFromDict:props forKey:@"startSize"];
    node.startSizeVar = [CCBReaderInternalV1 intValFromDict:props forKey:@"startSizeVar"];
    node.endSize = [CCBReaderInternalV1 intValFromDict:props forKey:@"endSize"];
    node.endSizeVar = [CCBReaderInternalV1 intValFromDict:props forKey:@"endSizeVar"];
    if ([node isKindOfClass:[CCParticleSystemQuad class]])
    {
        node.startSpin = [CCBReaderInternalV1 intValFromDict:props forKey:@"startSpin"];
        node.startSpinVar = [CCBReaderInternalV1 intValFromDict:props forKey:@"startSpinVar"];
        node.endSpin = [CCBReaderInternalV1 intValFromDict:props forKey:@"endSpin"];
        node.endSpinVar = [CCBReaderInternalV1 intValFromDict:props forKey:@"endSpinVar"];
    }
    node.startColor = [CCBReaderInternalV1 color4fValFromDict:props forKey:@"startColor"];
    node.startColorVar = [CCBReaderInternalV1 color4fValFromDict:props forKey:@"startColorVar"];
    node.endColor = [CCBReaderInternalV1 color4fValFromDict:props forKey:@"endColor"];
    node.endColorVar = [CCBReaderInternalV1 color4fValFromDict:props forKey:@"endColorVar"];
    node.blendFunc = [CCBReaderInternalV1 blendFuncValFromDict:props forKey:@"blendFunc"];
    
    if (node.emitterMode == kCCParticleModeGravity)
    {
        node.gravity = [CCBReaderInternalV1 pointValFromDict:props forKey:@"gravity"];
        node.angle = [CCBReaderInternalV1 intValFromDict:props forKey:@"angle"];
        node.angleVar = [CCBReaderInternalV1 intValFromDict:props forKey:@"angleVar"];
        node.speed = [CCBReaderInternalV1 intValFromDict:props forKey:@"speed"];
        node.speedVar = [CCBReaderInternalV1 intValFromDict:props forKey:@"speedVar"];
        node.tangentialAccel = [CCBReaderInternalV1 intValFromDict:props forKey:@"tangentialAccel"];
        node.tangentialAccelVar = [CCBReaderInternalV1 intValFromDict:props forKey:@"tangentialAccelVar"];
        node.radialAccel = [CCBReaderInternalV1 intValFromDict:props forKey:@"radialAccel"];
        node.radialAccelVar = [CCBReaderInternalV1 intValFromDict:props forKey:@"radialAccelVar"];
    }
    else
    {
        node.startRadius = [CCBReaderInternalV1 intValFromDict:props forKey:@"startRadius"];
        node.startRadiusVar = [CCBReaderInternalV1 intValFromDict:props forKey:@"startRadiusVar"];
        node.endRadius = [CCBReaderInternalV1 intValFromDict:props forKey:@"endRadius"];
        node.endRadiusVar = [CCBReaderInternalV1 intValFromDict:props forKey:@"endRadiusVar"];
        node.rotatePerSecond = [CCBReaderInternalV1 intValFromDict:props forKey:@"rotatePerSecond"];
        node.rotatePerSecondVar = [CCBReaderInternalV1 intValFromDict:props forKey:@"rotatePerSecondVar"];
    }
    
    
    [CCBReaderInternalV1 setExtraProp:[props objectForKey:@"spriteFile"] forKey:@"texture" andNode:node];
}

+ (CCNode*) ccObjectFromDictionary: (NSDictionary *)dict assetsDir:(NSString*)path owner:(NSObject*)owner root:(CCNode*) root
{
    NSString* class = [dict objectForKey:@"class"];
    NSDictionary* props = [dict objectForKey:@"properties"];
    NSArray* children = [dict objectForKey:@"children"];
    
    CCNode* node;
    if ([class isEqualToString:@"CCParticleSystem"])
    {
        node = [[PlugInManager sharedManager] createDefaultNodeOfType:@"CCParticleSystemQuad"];
        
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        [CCBReaderInternalV1 setPropsForParticleSystem:(CCParticleSystem*)node props:props];
        
        [TexturePropertySetter setTextureForNode:node andProperty:@"texture" withFile:[props objectForKey:@"spriteFile"]];
    }
    else if ([class isEqualToString:@"CCMenuItemImage"])
    {
        node = [[PlugInManager sharedManager] createDefaultNodeOfType:@"CCMenuItemImage"];
        
        NSString* fileNor = [props objectForKey:@"spriteFileNormal"];
        NSString* fileSel = [props objectForKey:@"spriteFileSelected"];
        NSString* fileDis = [props objectForKey:@"spriteFileDisabled"];
        NSString* fileSheet = [props objectForKey:@"spriteFramesFile"];
        
        if (!fileNor) fileNor = @"";
        if (!fileSel) fileSel = @"";
        if (!fileDis) fileDis = @"";
        if (!fileSheet || [fileSheet isEqualToString:@""]) fileSheet = kCCBUseRegularFile;
        
        [TexturePropertySetter setSpriteFrameForNode:node andProperty:@"normalSpriteFrame" withFile:fileNor andSheetFile:fileSheet];
        [node setExtraProp:fileNor forKey:@"normalSpriteFrame"];
        [node setExtraProp:fileSheet forKey:@"normalSpriteFrameSheet"];
        
        [TexturePropertySetter setSpriteFrameForNode:node andProperty:@"selectedSpriteFrame" withFile:fileSel andSheetFile:fileSheet];
        [node setExtraProp:fileSel forKey:@"selectedSpriteFrame"];
        [node setExtraProp:fileSheet forKey:@"selectedSpriteFrameSheet"];
        
        [TexturePropertySetter setSpriteFrameForNode:node andProperty:@"disabledSpriteFrame" withFile:fileDis andSheetFile:fileSheet];
        [node setExtraProp:fileDis forKey:@"disabledSpriteFrame"];
        [node setExtraProp:fileSheet forKey:@"disabledSpriteFrameSheet"];
        
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        [CCBReaderInternalV1 setPropsForMenuItem:(CCMenuItem*)node props:props];
        [CCBReaderInternalV1 setPropsForMenuItemImage:(CCMenuItemImage*)node props:props];
    }
    else if ([class isEqualToString:@"CCMenu"])
    {
        node = [[PlugInManager sharedManager] createDefaultNodeOfType:@"CCMenu"];
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        [CCBReaderInternalV1 setPropsForLayer:(CCLayer*)node props:props];
        [CCBReaderInternalV1 setPropsForMenu:(CCMenu*)node props:props];
    }
    else if ([class isEqualToString:@"CCNineSlice"])
    {
        node = [[PlugInManager sharedManager] createDefaultNodeOfType:@"CCNode"];
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        NSLog(@"WARNING! CCNineSlice not supported, replacing with CCNode!");
    }
    else if([class isEqualToString:@"CCButton"])
    {
        /*
        NSObject* target = NULL;
        SEL selector = NULL;
        NSString* imageNameFormat = [props objectForKey:@"imageNameFormat"];
        
        node = [CCButton buttonWithTarget:target selector:selector];
        [(CCButton*)node setImageNameFormat:imageNameFormat];
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        [CCBReaderInternalV1 setPropsForMenuItem:(CCButton*)node props:props];
         */
        
        node = [[PlugInManager sharedManager] createDefaultNodeOfType:@"CCNode"];
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        NSLog(@"WARNING! CCButton not supported, replacing with CCNode!");
    }
    else if([class isEqualToString:@"CCThreeSlice"])
    {
        /*
        NSString* imageNameFormat = [props objectForKey:@"imageNameFormat"];
        
        node = [CCThreeSlice node];
        [(CCThreeSlice*)node setImageNameFormat:imageNameFormat];
        [CCBReaderInternalV1 setPropsForNode:node props:props];
         */
        
        node = [[PlugInManager sharedManager] createDefaultNodeOfType:@"CCNode"];
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        NSLog(@"WARNING! CCButton not supported, replacing with CCNode!");
    }
    else if ([class isEqualToString:@"CCLabelTTF"])
    {
        node = [[PlugInManager sharedManager] createDefaultNodeOfType:@"CCLabelTTF"];
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        [CCBReaderInternalV1 setPropsForLabelTTF:(CCLabelTTF*)node props:props];
        [CCBReaderInternalV1 setPropsForSprite:(CCLabelTTF*)node props:props];
    }
    else if ([class isEqualToString:@"CCLabelBMFont"])
    {
        node = [[PlugInManager sharedManager] createDefaultNodeOfType:@"CCLabelBMFont"];
        
        [TexturePropertySetter setFontForNode:node andProperty:@"fntFile" withFile:[props objectForKey:@"fontFile"]];
        
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        [CCBReaderInternalV1 setPropsForLabelBMFont:(CCLabelBMFont*)node props:props];
    }
    else if ([class isEqualToString:@"CCSprite"])
    {
        node = [[PlugInManager sharedManager] createDefaultNodeOfType:@"CCSprite"];
        
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        [CCBReaderInternalV1 setPropsForSprite:(CCSprite*)node props:props];
    }
    else if ([class isEqualToString:@"CCLayerGradient"])
    {
        node = [[PlugInManager sharedManager] createDefaultNodeOfType:@"CCLayerGradient"];
        
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        [CCBReaderInternalV1 setPropsForLayer:(CCLayer*)node props:props];
        [CCBReaderInternalV1 setPropsForLayerColor:(CCLayerColor*)node props:props];
        [CCBReaderInternalV1 setPropsForLayerGradient:(CCLayerGradient*)node props:props];
    }
    else if ([class isEqualToString:@"CCLayerColor"])
    {
        node = [[PlugInManager sharedManager] createDefaultNodeOfType:@"CCLayerColor"];
        
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        [CCBReaderInternalV1 setPropsForLayer:(CCLayer*)node props:props];
        [CCBReaderInternalV1 setPropsForLayerColor:(CCLayerColor*)node props:props];
    }
    else if ([class isEqualToString:@"CCLayer"])
    {
        node = [[PlugInManager sharedManager] createDefaultNodeOfType:@"CCLayer"];
        
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        [CCBReaderInternalV1 setPropsForLayer:(CCLayer*)node props:props];
    }
    else if ([class isEqualToString:@"CCBTemplateNode"])
    {
        node = [[PlugInManager sharedManager] createDefaultNodeOfType:@"CCNode"];
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        NSLog(@"WARNING! CCBTemplateNode not supported, replacing with CCNode!");
    }
    else if ([class isEqualToString:@"CCNode"])
    {
        node = [[PlugInManager sharedManager] createDefaultNodeOfType:@"CCNode"];
        
        [CCBReaderInternalV1 setPropsForNode:node props:props];
    }
    else
    {
        NSLog(@"WARNING! Failed to load node of type: %@", class);
        return NULL;
    }
    
    if (!root) root = node;
    
    // Add children
    for (int i = 0; i < [children count]; i++)
    {
        NSDictionary* childDict = [children objectAtIndex:i];
        CCNode* child = [CCBReaderInternalV1 ccObjectFromDictionary:childDict assetsDir:path owner:owner root:root];
        //int zOrder = [[[childDict objectForKey:@"properties"] objectForKey:@"zOrder"] intValue];
        if (child && node)
        {
            [node addChild:child z:i];
        }
        else
        {
            NSLog(@"WARNING! Failed to add child=%@ to node=%@",child,node);
        }
    }
    
    return node;
}

+ (CCNode*) ccObjectFromDictionary: (NSDictionary *)dict assetsDir:(NSString*)path owner:(NSObject*)owner
{
    return [CCBReaderInternalV1 ccObjectFromDictionary:dict assetsDir:path owner:owner root:NULL];
}

+ (CCNode*) nodeGraphFromDictionary:(NSDictionary *)dict assetsDir:(NSString*)path owner:(NSObject *)owner
{
    if (!dict)
    {
        NSLog(@"WARNING! Trying to load invalid file type");
        return NULL;
    }
    // Load file metadata
    
    NSString* fileType = [dict objectForKey:@"fileType"];
    int fileVersion = [[dict objectForKey:@"fileVersion"] intValue];
    
    if (!fileType  || ![fileType isEqualToString:@"CocosBuilder"])
    {
        NSLog(@"WARNING! Trying to load invalid file type");
    }
    if (fileVersion > 2)
    {
        NSLog(@"WARNING! Trying to load file made with a newer version of CocosBuilder, please update the CCBReader class");
        return NULL;
    }
    
    NSDictionary* nodeGraph = [dict objectForKey:@"nodeGraph"];
    return [CCBReaderInternalV1 ccObjectFromDictionary:nodeGraph assetsDir:path owner:(NSObject*) owner];
}

+ (CCNode*) nodeGraphFromDictionary:(NSDictionary *)dict owner:(id) owner
{
    return [CCBReaderInternalV1 nodeGraphFromDictionary:dict assetsDir:@"" owner:owner];
}

+ (CCNode*) nodeGraphFromDictionary:(NSDictionary*) dict
{
    return [CCBReaderInternalV1 nodeGraphFromDictionary:dict assetsDir:@"" owner:NULL];
}

+ (CCNode*) nodeGraphFromFile:(NSString*) file owner:(id)owner
{
    NSString* path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:file];
    return [CCBReaderInternalV1 nodeGraphFromDictionary:[NSMutableDictionary dictionaryWithContentsOfFile:path] owner:owner];
}

+ (CCNode*) nodeGraphFromFile:(NSString *)file
{
    return [CCBReaderInternalV1 nodeGraphFromFile:file owner:NULL];
}

+ (CCScene*) sceneWithNodeGraphFromFile:(NSString*) file
{
    return [CCBReaderInternalV1 sceneWithNodeGraphFromFile:file owner:NULL];
}

+ (CCScene*) sceneWithNodeGraphFromFile:(NSString *)file owner:(id)owner
{
    CCNode* node = [CCBReaderInternalV1 nodeGraphFromFile:file owner:owner];
    CCScene* scene = [CCScene node];
    [scene addChild:node];
    return scene;
}

@end