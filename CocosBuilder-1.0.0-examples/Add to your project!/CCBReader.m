//
//  CCBReader.m
//  ccBuilder
//
//  Created by Viktor Lidholt on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CCBReader.h"
#import <objc/runtime.h>

@implementation CCBReader

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

+ (void) setExtraProp:(NSObject*) prop forKey: (NSString*) key andTag: (int)tag inDictionary:(NSMutableDictionary*)dict
{
    NSMutableDictionary* props = [dict objectForKey:[NSNumber numberWithInt:tag]];
    if (!props)
    {
        props = [NSMutableDictionary dictionary];
        [dict setObject:props forKey:[NSNumber numberWithInt:tag]];
    }
    
    [props setObject:prop forKey:key];
}

+ (void) setPropsForNode: (CCNode*) node props:(NSDictionary*)props extraProps:(NSMutableDictionary*) extraProps
{
    node.position = [CCBReader pointValFromDict:props forKey:@"position"];
    
    if (![node isKindOfClass:[CCSprite class]] &&
        ![node isKindOfClass:[CCMenuItemImage class]] &&
        ![node isKindOfClass:[CCLabelBMFont class]])
    {
        node.contentSize = [CCBReader sizeValFromDict:props forKey:@"contentSize"];
    }
    node.scaleX = [CCBReader floatValFromDict:props forKey:@"scaleX"];
    node.scaleY = [CCBReader floatValFromDict:props forKey:@"scaleY"];
    node.anchorPoint = [CCBReader pointValFromDict:props forKey:@"anchorPoint"];
    node.rotation = [CCBReader floatValFromDict:props forKey:@"rotation"];
    node.isRelativeAnchorPoint = [CCBReader boolValFromDict:props forKey:@"isRelativeAnchorPoint"];
    node.visible = [CCBReader boolValFromDict:props forKey:@"visible"];
    if (extraProps)
    {
        if (node.tag == -1)
        {
            node.tag = [extraProps count] + 1;
        }
        int tag = [CCBReader intValFromDict:props forKey:@"tag"];
        [CCBReader setExtraProp:[NSNumber numberWithInt:tag] forKey:@"tag" andTag:(int)node.tag inDictionary:extraProps];
        
        [CCBReader setExtraProp:[props objectForKey:@"customClass"] forKey:@"customClass" andTag:(int)node.tag inDictionary:extraProps];
        [CCBReader setExtraProp:[props objectForKey:@"memberVarAssignmentType"] forKey:@"memberVarAssignmentType" andTag:(int)node.tag inDictionary:extraProps];
        [CCBReader setExtraProp:[props objectForKey:@"memberVarAssignmentName"] forKey:@"memberVarAssignmentName" andTag:(int)node.tag inDictionary:extraProps];
        [CCBReader setExtraProp:[props objectForKey:@"lockedScaleRatio"] forKey:@"lockedScaleRatio" andTag:(int)node.tag inDictionary:extraProps];
        
        // Expanded nodes
        BOOL isExpanded;
        NSNumber* isExpandedObj = [props objectForKey:@"isExpanded"];
        if (isExpandedObj) isExpanded = [isExpandedObj boolValue];
        else isExpanded = YES;
        
        [CCBReader setExtraProp:[NSNumber numberWithBool:isExpanded] forKey:@"isExpanded" andTag:(int)node.tag inDictionary:extraProps];
    }
    else
    {
        node.tag = [CCBReader intValFromDict:props forKey:@"tag"];
    }
}

+ (void) setPropsForLayer: (CCLayer*) node props:(NSDictionary*)props extraProps:(NSMutableDictionary*) extraProps
{
    if (extraProps)
    {
        [CCBReader setExtraProp:[props objectForKey:@"touchEnabled"] forKey:@"touchEnabled" andTag:(int)node.tag inDictionary:extraProps];
        [CCBReader setExtraProp:[props objectForKey:@"accelerometerEnabled"] forKey:@"accelerometerEnabled" andTag:(int)node.tag inDictionary:extraProps];
        [CCBReader setExtraProp:[props objectForKey:@"mouseEnabled"] forKey:@"mouseEnabled" andTag:(int)node.tag inDictionary:extraProps];
        [CCBReader setExtraProp:[props objectForKey:@"keyboardEnabled"] forKey:@"keyboardEnabled" andTag:(int)node.tag inDictionary:extraProps];
    }
    else
    {
        // Update these props for Mac / iOS
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
        node.isMouseEnabled = [[props objectForKey:@"mouseEnabled"] boolValue];
        node.isKeyboardEnabled = [[props objectForKey:@"keyboardEnabled"] boolValue];
#endif
        
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
        node.isTouchEnabled = [[props objectForKey:@"touchEnabled"] boolValue];
        node.isAccelerometerEnabled = [[props objectForKey:@"accelerometerEnabled"] boolValue];
#endif
    }
}

+ (void) setPropsForLayerColor: (CCLayerColor*) node props:(NSDictionary*)props extraProps:(NSMutableDictionary*) extraProps
{
    [node setColor: [CCBReader color3ValFromDict:props forKey:@"color"]];
    [node setOpacity: [CCBReader intValFromDict:props forKey:@"opacity"]];
    node.blendFunc = [CCBReader blendFuncValFromDict:props forKey:@"blendFunc"];
}

+ (void) setPropsForLayerGradient: (CCLayerGradient*) node props:(NSDictionary*)props extraProps:(NSMutableDictionary*) extraProps
{
    [node setStartColor: [CCBReader color3ValFromDict:props forKey:@"color"]];
    [node setStartOpacity: [CCBReader intValFromDict:props forKey:@"opacity"]];
    [node setEndColor: [CCBReader color3ValFromDict:props forKey:@"endColor"]];
    [node setEndOpacity: [CCBReader intValFromDict:props forKey:@"endOpacity"]];
    node.vector = [CCBReader pointValFromDict:props forKey:@"vector"];
}

+ (void) setPropsForSprite: (CCSprite*) node props:(NSDictionary*)props extraProps:(NSMutableDictionary*) extraProps
{
    node.opacity = [CCBReader intValFromDict:props forKey:@"opacity"];
    node.color = [CCBReader color3ValFromDict:props forKey:@"color"];
    node.flipX = [CCBReader boolValFromDict:props forKey:@"flipX"];
    node.flipY = [CCBReader boolValFromDict:props forKey:@"flipY"];
    node.blendFunc = [CCBReader blendFuncValFromDict:props forKey:@"blendFunc"];
    if (extraProps)
    {
        [CCBReader setExtraProp:[props objectForKey:@"spriteFile"] forKey:@"spriteFile" andTag:(int)node.tag inDictionary:extraProps];
        NSString* spriteFramesFile = [props objectForKey:@"spriteFramesFile"];
        if (spriteFramesFile)
        {
            [CCBReader setExtraProp:spriteFramesFile forKey:@"spriteSheetFile" andTag:(int)node.tag inDictionary:extraProps];
        }
    }
}

+ (void) setPropsForMenu: (CCMenu*) node props:(NSDictionary*)props extraProps:(NSMutableDictionary*) extraProps
{
    if (extraProps)
    {
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
        node.isMouseEnabled = NO;
#endif
    }
}

+ (void) setPropsForMenuItem: (CCMenuItem*) node props:(NSDictionary*)props extraProps:(NSMutableDictionary*) extraProps
{
    [node setIsEnabled:[CCBReader boolValFromDict:props forKey:@"isEnabled"]];
    if (extraProps)
    {
        [CCBReader setExtraProp:[props objectForKey:@"selector"] forKey:@"selector" andTag:(int)node.tag inDictionary:extraProps];
        [CCBReader setExtraProp:[props objectForKey:@"target"] forKey:@"target" andTag:(int)node.tag inDictionary:extraProps];
        NSString* spriteFramesFile = [props objectForKey:@"spriteFramesFile"];
        if (spriteFramesFile)
        {
            [CCBReader setExtraProp:spriteFramesFile forKey:@"spriteSheetFile" andTag:(int)node.tag inDictionary:extraProps];
        }
    }
}

+ (void) setPropsForMenuItemImage: (CCMenuItemImage*) node props:(NSDictionary*)props extraProps:(NSMutableDictionary*) extraProps
{
    if (extraProps)
    {
        [CCBReader setExtraProp:[props objectForKey:@"spriteFileNormal"] forKey:@"spriteFileNormal" andTag:(int)node.tag inDictionary:extraProps];
        [CCBReader setExtraProp:[props objectForKey:@"spriteFileSelected"] forKey:@"spriteFileSelected" andTag:(int)node.tag inDictionary:extraProps];
        [CCBReader setExtraProp:[props objectForKey:@"spriteFileDisabled"] forKey:@"spriteFileDisabled" andTag:(int)node.tag inDictionary:extraProps];
    }
}

+ (void) setPropsForLabelBMFont: (CCLabelBMFont*) node props:(NSDictionary*)props extraProps:(NSMutableDictionary*)extraProps
{
    node.opacity = [CCBReader intValFromDict:props forKey:@"opacity"];
    node.color = [CCBReader color3ValFromDict:props forKey:@"color"];
    if (extraProps)
    {
        [CCBReader setExtraProp:[props objectForKey:@"fontFile"] forKey:@"fontFile" andTag:(int)node.tag inDictionary:extraProps];
    }
}

+ (void) setPropsForParticleSystem: (CCParticleSystem*) node props:(NSDictionary*)props extraProps:(NSMutableDictionary*) extraProps
{
    
    
    node.emitterMode = [CCBReader intValFromDict:props forKey:@"emitterMode"];
    node.emissionRate = [CCBReader floatValFromDict:props forKey:@"emissionRate"];
    node.duration = [CCBReader floatValFromDict:props forKey:@"duration"];
    node.posVar = [CCBReader pointValFromDict:props forKey:@"posVar"];
    node.totalParticles = [CCBReader intValFromDict:props forKey:@"totalParticles"];
    node.life = [CCBReader floatValFromDict:props forKey:@"life"];
    node.lifeVar = [CCBReader floatValFromDict:props forKey:@"lifeVar"];
    node.startSize = [CCBReader intValFromDict:props forKey:@"startSize"];
    node.startSizeVar = [CCBReader intValFromDict:props forKey:@"startSizeVar"];
    node.endSize = [CCBReader intValFromDict:props forKey:@"endSize"];
    node.endSizeVar = [CCBReader intValFromDict:props forKey:@"endSizeVar"];
    if ([node isKindOfClass:[CCParticleSystemQuad class]])
    {
        node.startSpin = [CCBReader intValFromDict:props forKey:@"startSpin"];
        node.startSpinVar = [CCBReader intValFromDict:props forKey:@"startSpinVar"];
        node.endSpin = [CCBReader intValFromDict:props forKey:@"endSpin"];
        node.endSpinVar = [CCBReader intValFromDict:props forKey:@"endSpinVar"];
    }
    node.startColor = [CCBReader color4fValFromDict:props forKey:@"startColor"];
    node.startColorVar = [CCBReader color4fValFromDict:props forKey:@"startColorVar"];
    node.endColor = [CCBReader color4fValFromDict:props forKey:@"endColor"];
    node.endColorVar = [CCBReader color4fValFromDict:props forKey:@"endColorVar"];
    node.blendFunc = [CCBReader blendFuncValFromDict:props forKey:@"blendFunc"];
    
    if (node.emitterMode == kCCParticleModeGravity)
    {
        node.gravity = [CCBReader pointValFromDict:props forKey:@"gravity"];
        node.angle = [CCBReader intValFromDict:props forKey:@"angle"];
        node.angleVar = [CCBReader intValFromDict:props forKey:@"angleVar"];
        node.speed = [CCBReader intValFromDict:props forKey:@"speed"];
        node.speedVar = [CCBReader intValFromDict:props forKey:@"speedVar"];
        node.tangentialAccel = [CCBReader intValFromDict:props forKey:@"tangentialAccel"];
        node.tangentialAccelVar = [CCBReader intValFromDict:props forKey:@"tangentialAccelVar"];
        node.radialAccel = [CCBReader intValFromDict:props forKey:@"radialAccel"];
        node.radialAccelVar = [CCBReader intValFromDict:props forKey:@"radialAccelVar"];
    }
    else
    {
        node.startRadius = [CCBReader intValFromDict:props forKey:@"startRadius"];
        node.startRadiusVar = [CCBReader intValFromDict:props forKey:@"startRadiusVar"];
        node.endRadius = [CCBReader intValFromDict:props forKey:@"endRadius"];
        node.endRadiusVar = [CCBReader intValFromDict:props forKey:@"endRadiusVar"];
        node.rotatePerSecond = [CCBReader intValFromDict:props forKey:@"rotatePerSecond"];
        node.rotatePerSecondVar = [CCBReader intValFromDict:props forKey:@"rotatePerSecondVar"];
    }
    
    if (extraProps)
    {
        [CCBReader setExtraProp:[props objectForKey:@"spriteFile"] forKey:@"spriteFile" andTag:(int)node.tag inDictionary:extraProps];
    }
    node.positionType = kCCPositionTypeGrouped;
}

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
}

+ (CCNode*) ccObjectFromDictionary: (NSDictionary *)dict extraProps: (NSMutableDictionary*) extraProps assetsDir:(NSString*)path owner:(NSObject*)owner root:(CCNode*) root
{
    NSString* class = [dict objectForKey:@"class"];
    NSDictionary* props = [dict objectForKey:@"properties"];
    NSArray* children = [dict objectForKey:@"children"];
    NSString* customClass = [props objectForKey:@"customClass"];
    if (extraProps) customClass = NULL;
    
    CCNode* node;
    if ([class isEqualToString:@"CCParticleSystem"])
    {
        NSString* spriteFile = [NSString stringWithFormat:@"%@%@", path, [props objectForKey:@"spriteFile"]];
        CCParticleSystem* sys = [[[ARCH_OPTIMAL_PARTICLE_SYSTEM alloc] initWithTotalParticles:2048] autorelease];
        sys.texture = [[CCTextureCache sharedTextureCache] addImage:spriteFile];
        node = sys;
        [CCBReader setPropsForNode:node props:props extraProps:extraProps];
        [CCBReader setPropsForParticleSystem:(CCParticleSystem*)node props:props extraProps:extraProps];
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
        
        NSObject* target = NULL;
        SEL selector = NULL;
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
        
        node = [CCMenuItemImage itemFromNormalSprite:spriteNormal selectedSprite:spriteSelected disabledSprite:spriteDisabled target:target selector:selector];
        
        [CCBReader setPropsForNode:node props:props extraProps:extraProps];
        [CCBReader setPropsForMenuItem:(CCMenuItem*)node props:props extraProps:extraProps];
        [CCBReader setPropsForMenuItemImage:(CCMenuItemImage*)node props:props extraProps:extraProps];
    }
    else if ([class isEqualToString:@"CCMenu"])
    {
        node = [CCMenu menuWithItems: nil];
        [CCBReader setPropsForNode:node props:props extraProps:extraProps];
        [CCBReader setPropsForLayer:(CCLayer*)node props:props extraProps:extraProps];
        [CCBReader setPropsForMenu:(CCMenu*)node props:props extraProps:extraProps];
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
        
        [CCBReader setPropsForNode:node props:props extraProps:extraProps];
        [CCBReader setPropsForLabelBMFont:(CCLabelBMFont*)node props:props extraProps:extraProps];
    }
    else if ([class isEqualToString:@"CCSprite"])
    {
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
        
        [CCBReader setPropsForNode:node props:props extraProps:extraProps];
        [CCBReader setPropsForSprite:(CCSprite*)node props:props extraProps:extraProps];
    }
    else if ([class isEqualToString:@"CCLayerGradient"])
    {
        //node = [CCLayerGradient node];
        node = [CCBReader createCustomClassWithName:customClass];
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
        
        [CCBReader setPropsForNode:node props:props extraProps:extraProps];
        [CCBReader setPropsForLayer:(CCLayer*)node props:props extraProps:extraProps];
        [CCBReader setPropsForLayerColor:(CCLayerColor*)node props:props extraProps:extraProps];
        [CCBReader setPropsForLayerGradient:(CCLayerGradient*)node props:props extraProps:extraProps];
    }
    else if ([class isEqualToString:@"CCLayerColor"])
    {
        //node = [CCLayerColor node];
        node = [CCBReader createCustomClassWithName:customClass];
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
        
        [CCBReader setPropsForNode:node props:props extraProps:extraProps];
        [CCBReader setPropsForLayer:(CCLayer*)node props:props extraProps:extraProps];
        [CCBReader setPropsForLayerColor:(CCLayerColor*)node props:props extraProps:extraProps];
    }
    else if ([class isEqualToString:@"CCLayer"])
    {
        node = [CCBReader createCustomClassWithName:customClass];
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
        
        [CCBReader setPropsForNode:node props:props extraProps:extraProps];
        [CCBReader setPropsForLayer:(CCLayer*)node props:props extraProps:extraProps];
    }
    else if ([class isEqualToString:@"CCNode"])
    {
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
        
        [CCBReader setPropsForNode:node props:props extraProps:extraProps];
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
        CCNode* child = [CCBReader ccObjectFromDictionary:childDict extraProps:extraProps assetsDir:path owner:owner root:root];
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
    }
    
    return node;
}

+ (CCNode*) ccObjectFromDictionary: (NSDictionary *)dict extraProps: (NSMutableDictionary*) extraProps assetsDir:(NSString*)path owner:(NSObject*)owner
{
    return [CCBReader ccObjectFromDictionary:dict extraProps:extraProps assetsDir:path owner:owner root:NULL];
}

+ (CCNode*) nodeGraphFromDictionary:(NSDictionary *)dict extraProps: (NSMutableDictionary*) extraProps assetsDir:(NSString*)path owner:(NSObject *)owner
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
    if (fileVersion > 1)
    {
        NSLog(@"WARNING! Trying to load file made with a newer version of CocosBuilder, please update the CCBReader class");
        return NULL;
    }
    
    NSDictionary* nodeGraph = [dict objectForKey:@"nodeGraph"];
    return [CCBReader ccObjectFromDictionary:nodeGraph extraProps:extraProps assetsDir:path owner:(NSObject*) owner];
}

+ (CCNode*) nodeGraphFromDictionary:(NSDictionary *)dict owner:(id) owner
{
    return [CCBReader nodeGraphFromDictionary:dict extraProps:NULL assetsDir:@"" owner:owner];
}

+ (CCNode*) nodeGraphFromDictionary:(NSDictionary*) dict
{
    return [CCBReader nodeGraphFromDictionary:dict extraProps:NULL assetsDir:@"" owner:NULL];
}

+ (CCNode*) nodeGraphFromFile:(NSString*) file owner:(id)owner
{
    NSString* path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:file];
    return [CCBReader nodeGraphFromDictionary:[NSMutableDictionary dictionaryWithContentsOfFile:path] owner:owner];
}

+ (CCNode*) nodeGraphFromFile:(NSString *)file
{
    return [CCBReader nodeGraphFromFile:file owner:NULL];
}

+ (CCScene*) sceneWithNodeGraphFromFile:(NSString*) file
{
    return [CCBReader sceneWithNodeGraphFromFile:file owner:NULL];
}

+ (CCScene*) sceneWithNodeGraphFromFile:(NSString *)file owner:(id)owner
{
    CCNode* node = [CCBReader nodeGraphFromFile:file owner:owner];
    CCScene* scene = [CCScene node];
    [scene addChild:node];
    return scene;
}

@end
