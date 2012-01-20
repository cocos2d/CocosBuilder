//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import "CCBWriter.h"
#import "CCBReader.h"
//#import "CCBTemplateNode.h"
//#import "CCBTemplate.h"
#import "CCNineSlice.h"
#import "CCButton.h"
#import "CCThreeSlice.h"

@implementation CCBWriter

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

#pragma mark Shortcuts for adding properties

+ (void) addPropToDict:(NSMutableDictionary*)dict key:(NSString*) key stringVal:(NSString*) value
{
    [dict setObject:value forKey:key];
}

+ (void) addPropToDict:(NSMutableDictionary*)dict key:(NSString*) key intVal:(int) value
{
    [dict setObject:[NSNumber numberWithInt:value] forKey:key];
}

+ (void) addPropToDict:(NSMutableDictionary*)dict key:(NSString*) key floatVal:(float) value
{
    [dict setObject:[NSNumber numberWithFloat:value] forKey:key];
}

+ (void) addPropToDict:(NSMutableDictionary*)dict key:(NSString*) key boolVal:(BOOL) value
{
    [dict setObject:[NSNumber numberWithBool:value] forKey:key];
}

+ (void) addPropToDict:(NSMutableDictionary*)dict key:(NSString*) key pointVal:(CGPoint) value
{
    NSMutableArray* pt = [NSMutableArray array];
    [pt addObject:[NSNumber numberWithFloat:value.x]];
    [pt addObject:[NSNumber numberWithFloat:value.y]];
    [dict setObject:pt forKey:key];
}

+ (void) addPropToDict:(NSMutableDictionary*)dict key:(NSString*) key sizeVal:(CGSize) value
{
    NSMutableArray* pt = [NSMutableArray array];
    [pt addObject:[NSNumber numberWithFloat:value.width]];
    [pt addObject:[NSNumber numberWithFloat:value.height]];
    [dict setObject:pt forKey:key];
}

+ (void) addPropToDict:(NSMutableDictionary*)dict key:(NSString*) key color3Val:(ccColor3B) value
{
    NSMutableArray* pt = [NSMutableArray array];
    [pt addObject:[NSNumber numberWithInt:value.r]];
    [pt addObject:[NSNumber numberWithInt:value.g]];
    [pt addObject:[NSNumber numberWithInt:value.b]];
    [dict setObject:pt forKey:key];
}

+ (void) addPropToDict:(NSMutableDictionary*)dict key:(NSString*) key color4fVal:(ccColor4F) value
{
    NSMutableArray* pt = [NSMutableArray array];
    [pt addObject:[NSNumber numberWithFloat:value.r]];
    [pt addObject:[NSNumber numberWithFloat:value.g]];
    [pt addObject:[NSNumber numberWithFloat:value.b]];
    [pt addObject:[NSNumber numberWithFloat:value.a]];
    [dict setObject:pt forKey:key];
}

+ (void) addPropToDict:(NSMutableDictionary*)dict key:(NSString*) key blendFuncVal:(ccBlendFunc) value
{
    NSMutableArray* pt = [NSMutableArray array];
    [pt addObject:[NSNumber numberWithInt:value.src]];
    [pt addObject:[NSNumber numberWithInt:value.dst]];
    [dict setObject:pt forKey:key];
}

#pragma mark Writer

+ (NSMutableDictionary*) dictionaryFromCCObject: (CCNode*) node extraProps:(NSDictionary*) extraPropsDict
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    NSMutableDictionary* extraProps = [extraPropsDict objectForKey:[NSNumber numberWithInt:(int)node.tag]];
    
    // CCNode props
    NSString* class = @"CCNode";
    NSMutableDictionary* props = [NSMutableDictionary dictionary];
    [CCBWriter addPropToDict:props key:@"position" pointVal:node.position];
    [CCBWriter addPropToDict:props key:@"contentSize" sizeVal:node.contentSize];
    [CCBWriter addPropToDict:props key:@"scaleX" floatVal:node.scaleX];
    [CCBWriter addPropToDict:props key:@"scaleY" floatVal:node.scaleY];
    [CCBWriter addPropToDict:props key:@"anchorPoint" pointVal:node.anchorPoint];
    [CCBWriter addPropToDict:props key:@"lockedScaleRatio" boolVal:[[extraProps objectForKey:@"lockedScaleRatio"] intValue]];
    [CCBWriter addPropToDict:props key:@"rotation" floatVal:node.rotation];
    [CCBWriter addPropToDict:props key:@"zOrder" intVal:(int)node.zOrder];
    [CCBWriter addPropToDict:props key:@"isRelativeAnchorPoint" boolVal:node.isRelativeAnchorPoint];
    [CCBWriter addPropToDict:props key:@"visible" boolVal:node.visible];
    [CCBWriter addPropToDict:props key:@"tag" intVal:[[extraProps objectForKey:@"tag"] intValue]];
    [CCBWriter addPropToDict:props key:@"isExpanded" boolVal:[[extraProps objectForKey:@"isExpanded"] boolValue]];
    
    // Code Connections
    [CCBWriter addPropToDict:props key:@"customClass" stringVal:[extraProps objectForKey:@"customClass"]];
    [CCBWriter addPropToDict:props key:@"memberVarAssignmentType" intVal:[[extraProps objectForKey:@"memberVarAssignmentType"] intValue]];
    [CCBWriter addPropToDict:props key:@"memberVarAssignmentName" stringVal:[extraProps objectForKey:@"memberVarAssignmentName"]];
    
    // CCLayer props
    if ([node isKindOfClass:[CCLayer class]])
    {
        class = @"CCLayer";
        //CCLayer* layer = (CCLayer*) node;
        [CCBWriter addPropToDict:props key:@"touchEnabled" intVal:[[extraProps objectForKey:@"touchEnabled"] boolValue]];
        [CCBWriter addPropToDict:props key:@"accelerometerEnabled" intVal:[[extraProps objectForKey:@"accelerometerEnabled"] boolValue]];
        [CCBWriter addPropToDict:props key:@"mouseEnabled" intVal:[[extraProps objectForKey:@"mouseEnabled"] boolValue]];
        [CCBWriter addPropToDict:props key:@"keyboardEnabled" intVal:[[extraProps objectForKey:@"keyboardEnabled"] boolValue]];
    }
    
    // CCLayerColor props
    if ([node isKindOfClass:[CCLayerColor class]])
    {
        class = @"CCLayerColor";
        CCLayerColor* layer = (CCLayerColor*) node;
        [CCBWriter addPropToDict:props key:@"color" color3Val:layer.color];
        [CCBWriter addPropToDict:props key:@"opacity" intVal: layer.opacity];
        [CCBWriter addPropToDict:props key:@"blendFunc" blendFuncVal:layer.blendFunc];
    }
    
    // CCLayerGradient props
    if ([node isKindOfClass:[CCLayerGradient class]])
    {
        class = @"CCLayerGradient";
        CCLayerGradient* layer = (CCLayerGradient*) node;
        [CCBWriter addPropToDict:props key:@"color" color3Val:[layer startColor]];
        [CCBWriter addPropToDict:props key:@"opacity" intVal: layer.startOpacity];
        [CCBWriter addPropToDict:props key:@"endColor" color3Val:[layer endColor]];
        [CCBWriter addPropToDict:props key:@"endOpacity" intVal: layer.endOpacity];
        [CCBWriter addPropToDict:props key:@"vector" pointVal: layer.vector];
    }
    
    // CCLabelTTF
    if([node isKindOfClass:[CCLabelTTF class]])
    {
        class = @"CCLabelTTF";
        CCLabelTTF* label = (CCLabelTTF*)node;
        [CCBWriter addPropToDict:props key:@"string" stringVal:[[[label string] copy] autorelease]];
        [CCBWriter addPropToDict:props key:@"fontSize" floatVal:[label fontSize]];
        [CCBWriter addPropToDict:props key:@"fontName" stringVal:[label fontName]];
        
        [CCBWriter addPropToDict:props key:@"spriteFile" stringVal:@""];
        [CCBWriter addPropToDict:props key:@"opacity" intVal:(int)label.opacity];
        [CCBWriter addPropToDict:props key:@"color" color3Val:label.color];
        [CCBWriter addPropToDict:props key:@"flipX" boolVal:label.flipX];
        [CCBWriter addPropToDict:props key:@"flipY" boolVal:label.flipY];
        [CCBWriter addPropToDict:props key:@"blendFunc" blendFuncVal:label.blendFunc];
    }
    
    // CCSprite props
    if ([node isKindOfClass:[CCSprite class]]
        && ![node isKindOfClass:[CCBTemplateNode class]]
        && ![node isKindOfClass:[CCLabelTTF class]]
                                                   )
    {
        class = @"CCSprite";
        CCSprite* sprite = (CCSprite*) node;
        [CCBWriter addPropToDict:props key:@"spriteFile" stringVal:[extraProps objectForKey:@"spriteFile"]];
        [CCBWriter addPropToDict:props key:@"opacity" intVal:(int)sprite.opacity];
        [CCBWriter addPropToDict:props key:@"color" color3Val:sprite.color];
        [CCBWriter addPropToDict:props key:@"flipX" boolVal:sprite.flipX];
        [CCBWriter addPropToDict:props key:@"flipY" boolVal:sprite.flipY];
        [CCBWriter addPropToDict:props key:@"blendFunc" blendFuncVal:sprite.blendFunc];
        
        NSString* spriteSheetFile = [extraProps objectForKey:@"spriteSheetFile"];
        if (spriteSheetFile && ![spriteSheetFile isEqualToString:@""] && ![spriteSheetFile isEqualToString:kCCBUseRegularFile])
        {
            [CCBWriter addPropToDict:props key:@"spriteFramesFile" stringVal:spriteSheetFile];
        }
    }
    
    // CCMenu props
    if ([node isKindOfClass:[CCMenu class]])
    {
        class = @"CCMenu";
        //CCMenu* menu = (CCMenu*) node;
    }
    
    // CCMenuItem props
    if ([node isKindOfClass:[CCMenuItem class]])
    {
        class = @"CCMenuItem";
        CCMenuItem* item = (CCMenuItem*)node;
        [CCBWriter addPropToDict:props key:@"isEnabled" boolVal:[item isEnabled]];
        [CCBWriter addPropToDict:props key:@"selector" stringVal:[extraProps objectForKey:@"selector"]];
        [CCBWriter addPropToDict:props key:@"target" intVal:[[extraProps objectForKey:@"target"] intValue]];
    }
    
    // CCButton props
    if ([node isKindOfClass:[CCButton class]])
    {
        class = @"CCButton";
        CCButton* button = (CCButton*)node;
        NSString* imageNameFormat = [[[button imageNameFormat] copy] autorelease];
        [CCBWriter addPropToDict:props key:@"imageNameFormat" stringVal:imageNameFormat];
    }
    
    // CCThreeSlice props
    if ([node isKindOfClass:[CCThreeSlice class]])
    {
        class = @"CCThreeSlice";
        CCThreeSlice* slice = (CCThreeSlice*)node;
        NSString* imageNameFormat = [[[slice imageNameFormat] copy] autorelease];
        [CCBWriter addPropToDict:props key:@"imageNameFormat" stringVal:imageNameFormat];
    }
    
    // CCMenuItemImage props
    if ([node isKindOfClass:[CCMenuItemImage class]])
    {
        class = @"CCMenuItemImage";
        //CCMenuItemImage* item = (CCMenuItemImage*)node;
        //NSLog(@"spriteFileNormal=%@", [extraProps objectForKey:@"spriteFileNormal"]);
        
        NSString* spriteFileNormal = [extraProps objectForKey:@"spriteFileNormal"];
        NSString* spriteFileSelected = [extraProps objectForKey:@"spriteFileSelected"];
        NSString* spriteFileDisabled = [extraProps objectForKey:@"spriteFileDisabled"];
        
        /*
        if (!spriteFileNormal)
        {
            NSLog(@"%@",extraProps);
        }
        
        if (!spriteFileNormal) spriteFileNormal = @"";
        if (!spriteFileSelected) spriteFileSelected = @"";
        if (!spriteFileDisabled) spriteFileDisabled = @"";
         */
        
        [CCBWriter addPropToDict:props key:@"spriteFileNormal" stringVal:spriteFileNormal];
        [CCBWriter addPropToDict:props key:@"spriteFileSelected" stringVal:spriteFileSelected];
        [CCBWriter addPropToDict:props key:@"spriteFileDisabled" stringVal:spriteFileDisabled];
        
        NSString* spriteSheetFile = [extraProps objectForKey:@"spriteSheetFile"];
        if (spriteSheetFile && ![spriteSheetFile isEqualToString:@""] && ![spriteSheetFile isEqualToString:kCCBUseRegularFile])
        {
            [CCBWriter addPropToDict:props key:@"spriteFramesFile" stringVal:spriteSheetFile];
        }
    }
    
    // CCLabelBMFont props
    if ([node isKindOfClass:[CCLabelBMFont class]])
    {
        class = @"CCLabelBMFont";
        CCLabelBMFont* item = (CCLabelBMFont*)node;
        [CCBWriter addPropToDict:props key:@"fontFile" stringVal:[extraProps objectForKey:@"fontFile"]];
        [CCBWriter addPropToDict:props key:@"string" stringVal:[[[item string] copy] autorelease]];
        [CCBWriter addPropToDict:props key:@"opacity" intVal:(int)item.opacity];
        [CCBWriter addPropToDict:props key:@"color" color3Val:item.color];
    }
    
    // CCParticleSystem props
    if ([node isKindOfClass:[CCParticleSystem class]])
    {
        class = @"CCParticleSystem";
        CCParticleSystem* sys = (CCParticleSystem*)node;
        [CCBWriter addPropToDict:props key:@"spriteFile" stringVal:[extraProps objectForKey:@"spriteFile"]];
        [CCBWriter addPropToDict:props key:@"emitterMode" intVal:(int)sys.emitterMode];
        [CCBWriter addPropToDict:props key:@"emissionRate" floatVal:sys.emissionRate];
        [CCBWriter addPropToDict:props key:@"duration" floatVal:sys.duration];
        [CCBWriter addPropToDict:props key:@"posVar" pointVal:sys.posVar];
        [CCBWriter addPropToDict:props key:@"totalParticles" intVal:(int)sys.totalParticles];
        [CCBWriter addPropToDict:props key:@"life" floatVal:sys.life];
        [CCBWriter addPropToDict:props key:@"lifeVar" floatVal:sys.lifeVar];
        [CCBWriter addPropToDict:props key:@"startSize" intVal:(int)sys.startSize];
        [CCBWriter addPropToDict:props key:@"startSizeVar" intVal:(int)sys.startSizeVar];
        [CCBWriter addPropToDict:props key:@"endSize" intVal:(int)sys.endSize];
        [CCBWriter addPropToDict:props key:@"endSizeVar" intVal:(int)sys.endSizeVar];
        [CCBWriter addPropToDict:props key:@"startSpin" intVal:(int)sys.startSpin];
        [CCBWriter addPropToDict:props key:@"startSpinVar" intVal:(int)sys.startSpinVar];
        [CCBWriter addPropToDict:props key:@"endSpin" intVal:(int)sys.endSpin];
        [CCBWriter addPropToDict:props key:@"endSpinVar" intVal:(int)sys.endSpinVar];
        [CCBWriter addPropToDict:props key:@"startColor" color4fVal:sys.startColor];
        [CCBWriter addPropToDict:props key:@"startColorVar" color4fVal:sys.startColorVar];
        [CCBWriter addPropToDict:props key:@"endColor" color4fVal:sys.endColor];
        [CCBWriter addPropToDict:props key:@"endColorVar" color4fVal:sys.endColorVar];
        [CCBWriter addPropToDict:props key:@"blendFunc" blendFuncVal:sys.blendFunc];
        
        if (sys.emitterMode == kCCParticleModeGravity)
        {
            [CCBWriter addPropToDict:props key:@"gravity" pointVal:sys.gravity];
            [CCBWriter addPropToDict:props key:@"angle" intVal:(int)sys.angle];
            [CCBWriter addPropToDict:props key:@"angleVar" intVal:(int)sys.angleVar];
            [CCBWriter addPropToDict:props key:@"speed" intVal:(int)sys.speed];
            [CCBWriter addPropToDict:props key:@"speedVar" intVal:(int)sys.speedVar];
            [CCBWriter addPropToDict:props key:@"tangentialAccel" intVal:(int)sys.tangentialAccel];
            [CCBWriter addPropToDict:props key:@"tangentialAccelVar" intVal:(int)sys.tangentialAccelVar];
            [CCBWriter addPropToDict:props key:@"radialAccel" intVal:(int)sys.radialAccel];
            [CCBWriter addPropToDict:props key:@"radialAccelVar" intVal:(int)sys.radialAccelVar];
        }
        else
        {
            [CCBWriter addPropToDict:props key:@"startRadius" intVal:(int)sys.startRadius];
            [CCBWriter addPropToDict:props key:@"startRadiusVar" intVal:(int)sys.startRadiusVar];
            [CCBWriter addPropToDict:props key:@"endRadius" intVal:(int)sys.endRadius];
            [CCBWriter addPropToDict:props key:@"endRadiusVar" intVal:(int)sys.endRadiusVar];
            [CCBWriter addPropToDict:props key:@"rotatePerSecond" intVal:(int)sys.rotatePerSecond];
            [CCBWriter addPropToDict:props key:@"rotatePerSecondVar" intVal:(int)sys.rotatePerSecondVar];
        }
    }
    
    // CCMenu props
    if ([node isKindOfClass:[CCNineSlice class]])
    {
        class = @"CCNineSlice";
    }
    
    // Templates
    if ([node isKindOfClass:[CCBTemplateNode class]])
    {
        class = @"CCBTemplateNode";
        CCBTemplateNode* t = (CCBTemplateNode*)node;
        [CCBWriter addPropToDict:props key:@"templateFile" stringVal:t.ccbTemplate.fileName];
    }
    
    // Children
    NSMutableArray* children = [NSMutableArray array];
    
    // No children for CCMenuItemImage!
    if (![node isKindOfClass:[CCMenuItemImage class]] &&
        ![node isKindOfClass:[CCLabelBMFont class]])
    {
        // Visit all children of this node
        for (int i = 0; i < [[node children] count]; i++)
        {
            [children addObject:[CCBWriter dictionaryFromCCObject:[[node children] objectAtIndex:i] extraProps:extraPropsDict]];
        }
    }
    
    // Create node
    [dict setObject:props forKey:@"properties"];
    [dict setObject:class forKey:@"class"];
    [dict setObject:children forKey:@"children"];
    return dict;
}

@end
