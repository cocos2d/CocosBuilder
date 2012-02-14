//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import "CCBReaderInternalV1.h"
#import <objc/runtime.h>
#import "CCNineSlice.h"
#import "CCButton.h"
#import "CCThreeSlice.h"

#import "NodeInfo.h"
#import "PlugInNode.h"
#import "PlugInManager.h"

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

/*
+ (void) setExtraProp:(NSObject*) prop forKey: (NSString*) key andTag: (int)tag inDictionary:(NSMutableDictionary*)dict
{
    NSMutableDictionary* props = [dict objectForKey:[NSNumber numberWithInt:tag]];
    if (!props)
    {
        props = [NSMutableDictionary dictionary];
        [dict setObject:props forKey:[NSNumber numberWithInt:tag]];
    }
    
    [props setObject:prop forKey:key];
}*/

+ (void) setExtraProp:(NSObject*) prop forKey:(NSString *)key andNode:(CCNode*) node
{
    NodeInfo* info = node.userData;
    [info.extraProps setObject:prop forKey:key];
}

+ (void) setPropsForNode: (CCNode*) node props:(NSDictionary*)props
{
    node.position = [CCBReaderInternalV1 pointValFromDict:props forKey:@"position"];
    
    if (![node isKindOfClass:[CCSprite class]] &&
        ![node isKindOfClass:[CCMenuItemImage class]] &&
        ![node isKindOfClass:[CCLabelBMFont class]])
    {
        node.contentSize = [CCBReaderInternalV1 sizeValFromDict:props forKey:@"contentSize"];
    }
    node.scaleX = [CCBReaderInternalV1 floatValFromDict:props forKey:@"scaleX"];
    node.scaleY = [CCBReaderInternalV1 floatValFromDict:props forKey:@"scaleY"];
    node.anchorPoint = [CCBReaderInternalV1 pointValFromDict:props forKey:@"anchorPoint"];
    node.rotation = [CCBReaderInternalV1 floatValFromDict:props forKey:@"rotation"];
    node.isRelativeAnchorPoint = [CCBReaderInternalV1 boolValFromDict:props forKey:@"isRelativeAnchorPoint"];
    node.visible = [CCBReaderInternalV1 boolValFromDict:props forKey:@"visible"];
    node.tag = [CCBReaderInternalV1 intValFromDict:props forKey:@"tag"];
    
    NSLog(@"Setting customClass=%@", [props objectForKey:@"customClass"]);
        
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
    node.opacity = [CCBReaderInternalV1 intValFromDict:props forKey:@"opacity"];
    node.color = [CCBReaderInternalV1 color3ValFromDict:props forKey:@"color"];
    node.flipX = [CCBReaderInternalV1 boolValFromDict:props forKey:@"flipX"];
    node.flipY = [CCBReaderInternalV1 boolValFromDict:props forKey:@"flipY"];
    node.blendFunc = [CCBReaderInternalV1 blendFuncValFromDict:props forKey:@"blendFunc"];
    
    
    [CCBReaderInternalV1 setExtraProp:[props objectForKey:@"spriteFile"] forKey:@"displayFrame" andNode:node];
    NSString* spriteFramesFile = [props objectForKey:@"spriteFramesFile"];
    if (spriteFramesFile)
    {
        [CCBReaderInternalV1 setExtraProp:spriteFramesFile forKey:@"displayFrameSheet" andNode:node];
    }
    
    [TexturePropertySetter setTextureForNode:node andProperty:@"displayFrame" withFile:[props objectForKey:@"spriteFile"] andSheetFile:[props objectForKey:@"spriteFramesFile"]];
}

+ (void) setPropsForMenu: (CCMenu*) node props:(NSDictionary*)props
{
    node.isMouseEnabled = NO;
}

+ (void) setPropsForMenuItem: (CCMenuItem*) node props:(NSDictionary*)props
{
    [node setIsEnabled:[CCBReaderInternalV1 boolValFromDict:props forKey:@"isEnabled"]];
    [CCBReaderInternalV1 setExtraProp:[props objectForKey:@"selector"] forKey:@"selector" andNode:node];
    [CCBReaderInternalV1 setExtraProp:[props objectForKey:@"target"] forKey:@"target" andNode:node];
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
    node.opacity = [CCBReaderInternalV1 intValFromDict:props forKey:@"opacity"];
    node.color = [CCBReaderInternalV1 color3ValFromDict:props forKey:@"color"];
    
    [CCBReaderInternalV1 setExtraProp:[props objectForKey:@"fontFile"] forKey:@"fontFile" andNode:node];
}

+ (void) setPropsForLabelTTF: (CCLabelTTF*) node props:(NSDictionary*)props
{
    
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
    
    
    [CCBReaderInternalV1 setExtraProp:[props objectForKey:@"spriteFile"] forKey:@"spriteFile" andNode:node];
    
    node.positionType = kCCPositionTypeGrouped;
}

/*
+ (id) createCustomClassWithName:(NSString*)className
{
    if (!className) return NULL;
    if ([className isEqualToString:@""]) return NULL;
    Class c = NSClassFromString(className);
    if (!c)
    {
        NSLog(@"WARNING! Class of type %@ couldn't be found",className);
        return NULL;
    }
    return [c alloc];
}*/

+ (id) createClassFromCCBTemplate:(CCBTemplate*)t
{
    if (!t.customClass) return NULL;
    if ([t.customClass isEqualToString:@""]) return NULL;
    Class c = NSClassFromString(t.customClass);
    if (!c)
    {
        NSLog(@"WARNING! Template class of type %@ couldn't be found",t.customClass);
        return NULL;
    }
    id obj = [c alloc];
    
    if (![obj isKindOfClass:[CCNode class]])
    {
        NSLog(@"WARNING! Trying to add template class not sub class of CCNode (%@)",t.customClass);
        [obj release];
        return NULL;
    }
    
    if ([obj respondsToSelector:@selector(initWithProperties:)])
    {
        [obj performSelector:@selector(initWithProperties:) withObject:t.properties];
    }
    else
    {
        NSLog(@"WARNING! Template object of type %@ does't respond to initWithProperties:", t.customClass);
    }
    [obj autorelease];
    
    return obj;
}

+ (CCNode*) ccObjectFromDictionary: (NSDictionary *)dict assetsDir:(NSString*)path owner:(NSObject*)owner root:(CCNode*) root
{
    NSString* class = [dict objectForKey:@"class"];
    NSDictionary* props = [dict objectForKey:@"properties"];
    NSArray* children = [dict objectForKey:@"children"];
    //NSString* customClass = [props objectForKey:@"customClass"];
    //if (extraProps) customClass = NULL;
    NSString* customClass = @"";
    
    CCNode* node;
    if ([class isEqualToString:@"CCParticleSystem"])
    {
        NSString* spriteFile = [NSString stringWithFormat:@"%@%@", path, [props objectForKey:@"spriteFile"]];
        CCParticleSystem* sys = [[[ARCH_OPTIMAL_PARTICLE_SYSTEM alloc] initWithTotalParticles:2048] autorelease];
        sys.texture = [[CCTextureCache sharedTextureCache] addImage:spriteFile];
        node = sys;
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        [CCBReaderInternalV1 setPropsForParticleSystem:(CCParticleSystem*)node props:props];
    }
    else if ([class isEqualToString:@"CCMenuItemImage"])
    {
        NSString* spriteFileNormal = [NSString stringWithFormat:@"%@%@", path, [props objectForKey:@"spriteFileNormal"]];
        NSString* spriteFileSelected = [NSString stringWithFormat:@"%@%@", path, [props objectForKey:@"spriteFileSelected"]];
        NSString* spriteFileDisabled = [NSString stringWithFormat:@"%@%@", path, [props objectForKey:@"spriteFileDisabled"]];
        
        CCSprite* spriteNormal;
        CCSprite* spriteSelected;
        CCSprite* spriteDisabled;
        
        NSString* spriteSheetFile = [props objectForKey:@"spriteFramesFile"];
        if (spriteSheetFile  && ![spriteSheetFile isEqualToString:@""]) spriteSheetFile = [NSString stringWithFormat:@"%@%@", path, spriteSheetFile];
        
        if (spriteSheetFile && ![spriteSheetFile isEqualToString:@""])
        {
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:spriteSheetFile];
            
            @try {
                spriteNormal = [CCSprite spriteWithSpriteFrameName:[props objectForKey:@"spriteFileNormal"]];
                spriteSelected = [CCSprite spriteWithSpriteFrameName:[props objectForKey:@"spriteFileSelected"]];
                spriteDisabled = [CCSprite spriteWithSpriteFrameName:[props objectForKey:@"spriteFileDisabled"]];
            }
            @catch (NSException *exception)
            {
                spriteNormal = NULL;
                spriteSelected = NULL;
                spriteDisabled = NULL;
            }
        }
        else
        {
            spriteNormal = [CCSprite spriteWithFile:spriteFileNormal];
            spriteSelected = [CCSprite spriteWithFile:spriteFileSelected];
            spriteDisabled = [CCSprite spriteWithFile:spriteFileDisabled];
        }
        
        if (!spriteNormal) spriteNormal = [CCSprite spriteWithFile:@"missing-texture.png"];
        if (!spriteSelected) spriteSelected = [CCSprite spriteWithFile:@"missing-texture.png"];
        if (!spriteDisabled) spriteDisabled = [CCSprite spriteWithFile:@"missing-texture.png"];
        
        node = NULL;//[CCBReader createCustomClassWithName:customClass];
        if(node)
        {
            [((CCMenuItemImage*)node) initWithNormalSprite:spriteNormal selectedSprite:spriteSelected disabledSprite:spriteDisabled target:NULL selector:NULL];
        }
        else
        {
            node = [CCMenuItemImage itemWithNormalSprite:spriteNormal selectedSprite:spriteSelected disabledSprite:spriteDisabled target:NULL selector:NULL];
        }
        
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        [CCBReaderInternalV1 setPropsForMenuItem:(CCMenuItem*)node props:props];
        [CCBReaderInternalV1 setPropsForMenuItemImage:(CCMenuItemImage*)node props:props];
    }
    else if ([class isEqualToString:@"CCMenu"])
    {
        node = [CCMenu menuWithItems: nil];
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        [CCBReaderInternalV1 setPropsForLayer:(CCLayer*)node props:props];
        [CCBReaderInternalV1 setPropsForMenu:(CCMenu*)node props:props];
    }
    else if ([class isEqualToString:@"CCNineSlice"])
    {
        node = [CCNineSlice node];
        [CCBReaderInternalV1 setPropsForNode:node props:props];
    }
    else if([class isEqualToString:@"CCButton"])
    {
        NSObject* target = NULL;
        SEL selector = NULL;
        /*
        if (!extraProps)
        {
            int targetType = [[props objectForKey:@"target"] intValue];
            if (targetType == kCCBMemberVarAssignmentTypeDocumentRoot) target = root;
            else if (targetType == kCCBMemberVarAssignmentTypeOwner) target = owner;
            
            NSString* selectorName = [props objectForKey:@"selector"];
            if (selectorName && ![selectorName isEqualToString:@""] && target)
            {
                selector = NSSelectorFromString(selectorName);
            }
            if (!selector) target = NULL;
            
            if (target && selector)
            {
                if (![target respondsToSelector:selector])
                {
                    NSLog(@"WARNING! CCMenuItemImage target doesn't respond to selector %@",selectorName);
                    target = NULL;
                    selector = NULL;
                }
            }
        }
         */
        NSString* imageNameFormat = [props objectForKey:@"imageNameFormat"];
        
        node = [CCButton buttonWithTarget:target selector:selector];
        [(CCButton*)node setImageNameFormat:imageNameFormat];
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        [CCBReaderInternalV1 setPropsForMenuItem:(CCButton*)node props:props];
    }
    else if([class isEqualToString:@"CCThreeSlice"])
    {
        NSString* imageNameFormat = [props objectForKey:@"imageNameFormat"];
        
        node = [CCThreeSlice node];
        [(CCThreeSlice*)node setImageNameFormat:imageNameFormat];
        [CCBReaderInternalV1 setPropsForNode:node props:props];
    }
    else if ([class isEqualToString:@"CCLabelTTF"])
    {
        NSString* fontName = [props objectForKey:@"fontName"];
        NSString* string = [props objectForKey:@"string"];
        float fontSize = [CCBReaderInternalV1 floatValFromDict:props forKey:@"fontSize"];
        @try {
            node = [CCLabelTTF labelWithString:string fontName:fontName fontSize:fontSize];
        }
        @catch (NSException *exception) {
            node = NULL;
        }
        if (!node) node = [CCLabelTTF labelWithString:string fontName:@"Helvetica" fontSize:24];
        
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        [CCBReaderInternalV1 setPropsForLabelTTF:(CCLabelTTF*)node props:props];
        [CCBReaderInternalV1 setPropsForSprite:(CCLabelTTF*)node props:props];
    }
    else if ([class isEqualToString:@"CCLabelBMFont"])
    {
        NSString* fontFile = [NSString stringWithFormat:@"%@%@", path, [props objectForKey:@"fontFile"]];
        NSString* string = [props objectForKey:@"string"];
        @try {
            node = [CCLabelBMFont labelWithString:string fntFile:fontFile];
        }
        @catch (NSException *exception) {
            node = NULL;
        }
        if (!node) node = [CCLabelBMFont labelWithString:string fntFile:@"missing-font.fnt"];
        
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        [CCBReaderInternalV1 setPropsForLabelBMFont:(CCLabelBMFont*)node props:props];
    }
    else if ([class isEqualToString:@"CCSprite"])
    {
        /*
        NSString* spriteFile = [NSString stringWithFormat:@"%@%@", path, [props objectForKey:@"spriteFile"]];
        NSString* spriteSheetFile = [props objectForKey:@"spriteFramesFile"];
        if (spriteSheetFile && ![spriteSheetFile isEqualToString:@""]) spriteSheetFile = [NSString stringWithFormat:@"%@%@", path, spriteSheetFile];
        
        if (spriteSheetFile && ![spriteSheetFile isEqualToString:@""])
        {
            @try
            {
                [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:spriteSheetFile];
                node = [CCSprite spriteWithSpriteFrameName:[props objectForKey:@"spriteFile"]];
            }
            @catch (NSException *exception) {
                node = NULL;
            }
        }
        else
        {
            node = [CCSprite spriteWithFile:spriteFile];
        }
        
        if (!node) node = [CCSprite spriteWithFile:@"missing-texture.png"];
         */
        node = [[PlugInManager sharedManager] createDefaultNodeOfType:@"CCSprite"];
        
        NSLog(@"Loaded CCSprite: %@",node);
        
#warning FIX!
        //node.userData = [NodeInfo nodeInfoWithPlugIn:[[PlugInManager sharedManager] plugInNodeNamed:@"CCNode"]];
        
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        [CCBReaderInternalV1 setPropsForSprite:(CCSprite*)node props:props];
    }
    else if ([class isEqualToString:@"CCLayerGradient"])
    {
        node = [CCLayerGradient node];
        node = NULL;//[CCBReader createCustomClassWithName:customClass];
        if (node)
        {
            if (![node isKindOfClass:[CCLayerGradient class]])
            {
                NSLog(@"WARNING! %@ is not subclass of CCLayerGradient",customClass);
                node = NULL;
            }
            else
            {
                node = [[node init] autorelease];
            }
        }
        if (!node) node = [CCLayerGradient node];
        
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        [CCBReaderInternalV1 setPropsForLayer:(CCLayer*)node props:props];
        [CCBReaderInternalV1 setPropsForLayerColor:(CCLayerColor*)node props:props];
        [CCBReaderInternalV1 setPropsForLayerGradient:(CCLayerGradient*)node props:props];
    }
    else if ([class isEqualToString:@"CCLayerColor"])
    {
        node = [CCLayerColor node];
        //node = [CCBReader createCustomClassWithName:customClass];
        if (node)
        {
            if (![node isKindOfClass:[CCLayerColor class]])
            {
                NSLog(@"WARNING! %@ is not subclass of CCLayerColor",customClass);
                node = NULL;
            }
            else
            {
                node = [[node init] autorelease];
            }
        }
        if (!node) node = [CCLayerColor node];
        
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        [CCBReaderInternalV1 setPropsForLayer:(CCLayer*)node props:props];
        [CCBReaderInternalV1 setPropsForLayerColor:(CCLayerColor*)node props:props];
    }
    else if ([class isEqualToString:@"CCLayer"])
    {
        node = NULL;//[CCBReader createCustomClassWithName:customClass];
        if (node)
        {
            if (![node isKindOfClass:[CCLayer class]])
            {
                NSLog(@"WARNING! %@ is not subclass of CCLayer",customClass);
                node = NULL;
            }
            else
            {
                node = [[node init] autorelease];
            }
        }
        if (!node) node = [CCLayer node];
        
        [node setUserData: [NodeInfo nodeInfoWithPlugIn:[[PlugInManager sharedManager] plugInNodeNamed:@"CCNode"]] retainData:YES];
        
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        [CCBReaderInternalV1 setPropsForLayer:(CCLayer*)node props:props];
    }
    else if ([class isEqualToString:@"CCBTemplateNode"])
    {
        NSString* templateFile = [props objectForKey:@"templateFile"];
        CCBTemplate* t = [[[CCBTemplate alloc] initWithFile:templateFile assetsPath:path] autorelease];
        node = [[[CCBTemplateNode alloc] initWithTemplate:t] autorelease];
        
        [CCBReaderInternalV1 setPropsForNode:node props:props];
        [CCBReaderInternalV1 setExtraProp:t.customClass forKey:@"customClass" andNode:node];
    }
    else if ([class isEqualToString:@"CCNode"])
    {
        /*
        node = [CCBReader createCustomClassWithName:customClass];
        if (node)
        {
            if (![node isKindOfClass:[CCNode class]])
            {
                NSLog(@"WARNING! %@ is not subclass of CCNode",customClass);
                node = NULL;
            }
            else
            {
                node = [[node init] autorelease];
            }
        }
        if (!node) node = [CCNode node];
         */
        
        /*
        Class c = NSClassFromString(@"CCBPNode");
        node = [[[c alloc] init] autorelease];
        node.userData = [NodeInfo nodeInfoWithPlugIn:[[PlugInManager sharedManager] plugInNodeNamed:@"CCNode"]];
         */
        
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
        int zOrder = [[[childDict objectForKey:@"properties"] objectForKey:@"zOrder"] intValue];
        if (child && node)
        {
            [node addChild:child z:zOrder];
        }
        else
        {
            NSLog(@"WARNING! Failed to add child=%@ to node=%@",child,node);
        }
    }
    
    /*
    // Assign member variables
    if (!extraProps)
    {
        NSString* assignmentName = [props objectForKey:@"memberVarAssignmentName"];
        int assignmentType = [[props objectForKey:@"memberVarAssignmentType"] intValue];
        if (assignmentName && ![assignmentName isEqualToString:@""] && assignmentType)
        {
            NSObject* assignTo = NULL;
            if (assignmentType == kCCBMemberVarAssignmentTypeOwner) assignTo = owner;
            else if (assignmentType == kCCBMemberVarAssignmentTypeDocumentRoot) assignTo = root;
            
            if (assignTo != NULL)
            {
                
                Ivar ivar = class_getInstanceVariable([assignTo class], [assignmentName UTF8String]);
                if (ivar)
                {
                    object_setIvar(assignTo, ivar, node);
                }
                else
                {
                    NSLog(@"WARNING! Couldn't find member variable %@",assignmentName);
                }
            }
            else
            {
                NSLog(@"WARNING! Failed to find assignment object");
            }
        }
        
        // Call the didLoadFromCCB method
        if ([node respondsToSelector:@selector(didLoadFromCCB)])
        {
            [node performSelector:@selector(didLoadFromCCB)];
        }
    }*/
    
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


// CCBTemplate

@implementation CCBTemplate

@synthesize fileName, assetsPath, propertyFile, customClass, previewImage, previewAnchorpoint, properties;

- (id) initWithFile:(NSString*) f assetsPath:(NSString*)ap
{
    self = [super init];
    if (!self) return NULL;
    
    self.assetsPath = ap;
    
    NSString* path = [NSString stringWithFormat:@"%@%@", assetsPath, f];
    path = [CCFileUtils fullPathFromRelativePath:path];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    if (![[dict objectForKey:@"fileType"] isEqualToString:@"CocosBuilderTemplate"])
    {
        NSLog(@"CCBTemplate: Invalid fileType");
        return NULL;
    }
    if (![[dict objectForKey:@"fileVersion"] intValue] > 1)
    {
        NSLog(@"CCBTemplate: File version not supported");
        return NULL;
    }
    
    self.fileName = f;
    self.customClass = [dict objectForKey:@"customClass"];
    self.propertyFile = [dict objectForKey:@"propertyFile"];
    self.previewImage = [dict objectForKey:@"previewImage"];
    
    NSMutableArray* anchor = [dict objectForKey:@"previewAnchorpoint"];
    previewAnchorpoint.x = [[anchor objectAtIndex:0] floatValue];
    previewAnchorpoint.y = [[anchor objectAtIndex:1] floatValue];
    
    NSString* propsPath = [NSString stringWithFormat:@"%@%@", assetsPath, propertyFile];
    propsPath = [CCFileUtils fullPathFromRelativePath:propsPath];
    self.properties = [NSMutableDictionary dictionaryWithContentsOfFile:propsPath];
    
    return self;
}

- (id) initWithNonExistingPath:(NSString*)f
{
    self = [super init];
    if (!self) return NULL;
    
    self.assetsPath = [NSString stringWithFormat:@"%@/",[f stringByDeletingLastPathComponent]];
    self.fileName = [f lastPathComponent];
    self.propertyFile = @"";
    self.customClass = @"";
    self.previewImage = @"";
    self.previewAnchorpoint = ccp(0.5f,0.5f);
    self.properties = NULL;
    
    NSLog(@"assetsPath: %@ fileName: %@", assetsPath, fileName);
    
    return self;
}

- (void) store
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    [dict setObject:@"CocosBuilderTemplate" forKey:@"fileType"];
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"fileVersion"];
    
    if (!fileName) return;
    [dict setObject:fileName forKey:@"fileName"];
    
    if (!customClass) self.customClass = @"CCNode";
    [dict setObject:customClass forKey:@"customClass"];
    
    if (!propertyFile) self.propertyFile = @"";
    [dict setObject:propertyFile forKey:@"propertyFile"];
    
    if (!previewImage) self.previewImage = @"";
    [dict setObject:previewImage forKey:@"previewImage"];
    
    NSMutableArray* anchorArray = [NSMutableArray arrayWithCapacity:2];
    [anchorArray addObject:[NSNumber numberWithFloat: previewAnchorpoint.x]];
    [anchorArray addObject:[NSNumber numberWithFloat: previewAnchorpoint.y]];
    [dict setObject:anchorArray forKey:@"previewAnchorpoint"];
    
    BOOL success = [dict writeToFile:[NSString stringWithFormat:@"%@%@", assetsPath,fileName] atomically:YES];
    
    NSLog(@"wrote ccbtemplate to %@ success=%d",[NSString stringWithFormat:@"%@%@", assetsPath,fileName], success);
    
    NSLog(@"wrote data: %@", dict);
}

- (void) dealloc
{
    self.fileName = NULL;
    self.assetsPath = NULL;
    self.customClass = NULL;
    self.propertyFile = NULL;
    self.previewImage = NULL;
    self.properties = NULL;
    
    [super dealloc];
}

@end


// CCBTemplateNode

@implementation CCBTemplateNode

@synthesize ccbTemplate;

- (id)initWithTemplate:(CCBTemplate*)t
{
    if (!t) return NULL;
    
    NSString* file = t.previewImage;
    if (!file || [file isEqualToString:@""])
    {
        file = @"missing-texture.png";
    }
    else if (t.assetsPath) file = [NSString stringWithFormat:@"%@%@",t.assetsPath,file];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[CCFileUtils fullPathFromRelativePath:file]])
    {
        file = @"missing-texture.png";
    }
    
    self = [super initWithFile:file];
    if (!self)
    {
        NSLog(@"Failed to load template texture: %@", file);
        self = [super initWithFile:@"missing-texture.png"];
    }
    if (!self)
    {
        NSLog(@"Still problem with missing texture! (%@)", file);
        return NULL;
    }
    
    // Initialization code here.
    self.ccbTemplate = t;
    self.anchorPoint = t.previewAnchorpoint;
    
    return self;
}

- (void)dealloc
{
    self.ccbTemplate = NULL;
    [super dealloc];
}

@end
