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

#import "CCBReaderInternal.h"
#import "CCBReaderInternalV1.h"
#import "PlugInManager.h"
#import "PlugInNode.h"
#import "NodeInfo.h"
#import "CCBWriterInternal.h"
#import "TexturePropertySetter.h"
#import "AnimationPropertySetter.h"
#import "CCBGlobals.h"
#import "CocosBuilderAppDelegate.h"
#import "ResourceManager.h"
#import "NodeGraphPropertySetter.h"
#import "PositionPropertySetter.h"
#import "CCNode+NodeInfo.h"

NSDictionary* renamedProperties = NULL;

@implementation CCBReaderInternal

+ (NSPoint) deserializePoint:(id) val
{
    float x = [[val objectAtIndex:0] floatValue];
    float y = [[val objectAtIndex:1] floatValue];
    return NSMakePoint(x,y);
}

+ (NSSize) deserializeSize:(id) val
{
    float w = [[val objectAtIndex:0] floatValue];
    float h = [[val objectAtIndex:1] floatValue];
    return NSMakeSize(w, h);
}

+ (float) deserializeFloat:(id) val
{
    return [val floatValue];
}

+ (int) deserializeInt:(id) val
{
    return [val intValue];
}

+ (BOOL) deserializeBool:(id) val
{
    return [val boolValue];
}

+ (ccColor3B) deserializeColor3:(id) val
{
    ccColor3B c;
    c.r = [[val objectAtIndex:0] intValue];
    c.g = [[val objectAtIndex:1] intValue];
    c.b = [[val objectAtIndex:2] intValue];
    return c;
}

+ (ccColor4B) deserializeColor4:(id) val
{
    ccColor4B c;
    c.r = [[val objectAtIndex:0] intValue];
    c.g = [[val objectAtIndex:1] intValue];
    c.b = [[val objectAtIndex:2] intValue];
    c.a = [[val objectAtIndex:3] intValue];
    return c;
}

+ (ccColor4F) deserializeColor4F:(id) val
{
    ccColor4F c;
    c.r = [[val objectAtIndex:0] floatValue];
    c.g = [[val objectAtIndex:1] floatValue];
    c.b = [[val objectAtIndex:2] floatValue];
    c.a = [[val objectAtIndex:3] floatValue];
    return c;
}

+ (ccBlendFunc) deserializeBlendFunc:(id) val
{
    ccBlendFunc bf;
    bf.src = [[val objectAtIndex:0] intValue];
    bf.dst = [[val objectAtIndex:1] intValue];
    return bf;
}

+ (void) setProp:(NSString*)name ofType:(NSString*)type toValue:(id)serializedValue forNode:(CCNode*)node parentSize:(CGSize)parentSize
{
    // Fetch info and extra properties
    NodeInfo* nodeInfo = node.userObject;
    NSMutableDictionary* extraProps = nodeInfo.extraProps;
    
    if ([type isEqualToString:@"Position"])
    {
        float x = [[serializedValue objectAtIndex:0] floatValue];
        float y = [[serializedValue objectAtIndex:1] floatValue];
        int posType = 0;
        if ([(NSArray*)serializedValue count] == 3) posType = [[serializedValue objectAtIndex:2] intValue];
        [PositionPropertySetter setPosition:NSMakePoint(x, y) type:posType forNode:node prop:name parentSize:parentSize];
    }
    else if ([type isEqualToString:@"Point"]
        || [type isEqualToString:@"PointLock"])
    {
        NSPoint pt = [CCBReaderInternal deserializePoint: serializedValue];
		
        [node setValue:[NSValue valueWithPoint:pt] forKey:name];
    }
    else if ([type isEqualToString:@"Size"])
    {
        float w = [[serializedValue objectAtIndex:0] floatValue];
        float h = [[serializedValue objectAtIndex:1] floatValue];
        NSSize size =  NSMakeSize(w, h);
        int sizeType = 0;
        if ([(NSArray*)serializedValue count] == 3) sizeType = [[serializedValue objectAtIndex:2] intValue];
        [PositionPropertySetter setSize:size type:sizeType forNode:node prop:name parentSize:parentSize];
    }
    else if ([type isEqualToString:@"Scale"]
             || [type isEqualToString:@"ScaleLock"])
    {
        float x = [[serializedValue objectAtIndex:0] floatValue];
        float y = [[serializedValue objectAtIndex:1] floatValue];
        int scaleType = 0;
        if ([(NSArray*)serializedValue count] >= 3)
        {
            [extraProps setValue:[serializedValue objectAtIndex:2] forKey:[NSString stringWithFormat:@"%@Lock",name]];
            if ([(NSArray*)serializedValue count] == 4)
            {
                scaleType = [[serializedValue objectAtIndex:3] intValue];
            }
        }
        [PositionPropertySetter setScaledX:x Y:y type:scaleType forNode:node prop:name];
    }
    else if ([type isEqualToString:@"FloatXY"])
    {
        float x = [[serializedValue objectAtIndex:0] floatValue];
        float y = [[serializedValue objectAtIndex:1] floatValue];
        [node setValue:[NSNumber numberWithFloat:x] forKey:[name stringByAppendingString:@"X"]];
        [node setValue:[NSNumber numberWithFloat:y] forKey:[name stringByAppendingString:@"Y"]];
    }
    else if ([type isEqualToString:@"Float"]
             || [type isEqualToString:@"Degrees"])
    {
        float f = [CCBReaderInternal deserializeFloat: serializedValue];
        [node setValue:[NSNumber numberWithFloat:f] forKey:name];
    }
    else if ([type isEqualToString:@"FloatScale"])
    {
        float f = 0;
        int type = 0;
        if ([serializedValue isKindOfClass:[NSNumber class]])
        {
            // Support for old files
            f = [serializedValue floatValue];
        }
        else
        {
            f = [[serializedValue objectAtIndex:0] floatValue];
            type = [[serializedValue objectAtIndex:1] intValue];
        }
        [PositionPropertySetter setFloatScale:f type:type forNode:node prop:name];
    }
    else if ([type isEqualToString:@"FloatVar"])
    {
        [node setValue:[serializedValue objectAtIndex:0] forKey:name];
        [node setValue:[serializedValue objectAtIndex:1] forKey:[NSString stringWithFormat:@"%@Var",name]];
    }
    else if ([type isEqualToString:@"Integer"]
             || [type isEqualToString:@"IntegerLabeled"]
             || [type isEqualToString:@"Byte"])
    {
        int d = [CCBReaderInternal deserializeInt: serializedValue];
        [node setValue:[NSNumber numberWithInt:d] forKey:name];
    }
    else if ([type isEqualToString:@"Check"])
    {
        BOOL check = [CCBReaderInternal deserializeBool:serializedValue];
        [node setValue:[NSNumber numberWithBool:check] forKey:name];
    }
    else if ([type isEqualToString:@"Flip"])
    {
        [node setValue:[serializedValue objectAtIndex:0] forKey:[NSString stringWithFormat:@"%@X",name]];
        [node setValue:[serializedValue objectAtIndex:1] forKey:[NSString stringWithFormat:@"%@Y",name]];
    }
    else if ([type isEqualToString:@"SpriteFrame"])
    {
        NSString* spriteSheetFile = [serializedValue objectAtIndex:0];
        NSString* spriteFile = [serializedValue objectAtIndex:1];
        if (!spriteSheetFile || [spriteSheetFile isEqualToString:@""])
        {
            spriteSheetFile = kCCBUseRegularFile;
        }
        
        [extraProps setObject:spriteSheetFile forKey:[NSString stringWithFormat:@"%@Sheet",name]];
        [extraProps setObject:spriteFile forKey:name];
        [TexturePropertySetter setSpriteFrameForNode:node andProperty:name withFile:spriteFile andSheetFile:spriteSheetFile];
    }
    else if ([type isEqualToString:@"Animation"])
    {
        NSString* animationFile = [serializedValue objectAtIndex:0];
        NSString* animationName = [serializedValue objectAtIndex:1];
        if (!animationFile) animationFile = @"";
        if (!animationName) animationName = @"";
        
        [extraProps setObject:animationFile forKey:[NSString stringWithFormat:@"%@Animation",name]];
        [extraProps setObject:animationName forKey:name];
        [AnimationPropertySetter setAnimationForNode:node andProperty:name withName:animationName andFile:animationFile];
    }
    else if ([type isEqualToString:@"Texture"])
    {
        NSString* spriteFile = serializedValue;
        if (!spriteFile) spriteFile = @"";
        [TexturePropertySetter setTextureForNode:node andProperty:name withFile:spriteFile];
        [extraProps setObject:spriteFile forKey:name];
    }
    else if ([type isEqualToString:@"Color3"])
    {
        ccColor3B c = [CCBReaderInternal deserializeColor3:serializedValue];
        NSValue* colorValue = [NSValue value:&c withObjCType:@encode(ccColor3B)];
        [node setValue:colorValue forKey:name];
    }
    else if ([type isEqualToString:@"Color4FVar"])
    {
        ccColor4F c = [CCBReaderInternal deserializeColor4F:[serializedValue objectAtIndex:0]];
        ccColor4F cVar = [CCBReaderInternal deserializeColor4F:[serializedValue objectAtIndex:1]];
        NSValue* cValue = [NSValue value:&c withObjCType:@encode(ccColor4F)];
        NSValue* cVarValue = [NSValue value:&cVar withObjCType:@encode(ccColor4F)];
        [node setValue:cValue forKey:name];
        [node setValue:cVarValue forKey:[NSString stringWithFormat:@"%@Var",name]];
    }
    else if ([type isEqualToString:@"Blendmode"])
    {
        ccBlendFunc bf = [CCBReaderInternal deserializeBlendFunc:serializedValue];
        NSValue* blendValue = [NSValue value:&bf withObjCType:@encode(ccBlendFunc)];
        [node setValue:blendValue forKey:name];
    }
    else if ([type isEqualToString:@"FntFile"])
    {
        NSString* fntFile = serializedValue;
        if (!fntFile) fntFile = @"";
        [TexturePropertySetter setFontForNode:node andProperty:name withFile:fntFile];
        [extraProps setObject:fntFile forKey:name];
    }
    else if ([type isEqualToString:@"Text"]
             || [type isEqualToString:@"String"])
    {
        NSString* str = serializedValue;
        if (!str) str = @"";
        [node setValue:str forKey:name];
    }
    else if ([type isEqualToString:@"FontTTF"])
    {
        NSString* str = serializedValue;
        if (!str) str = @"";
        [TexturePropertySetter setTtfForNode:node andProperty:name withFont:str];
    }
    else if ([type isEqualToString:@"Block"])
    {
        NSString* selector = [serializedValue objectAtIndex:0];
        NSNumber* target = [serializedValue objectAtIndex:1];
        if (!selector) selector = @"";
        if (!target) target = [NSNumber numberWithInt:0];
        [extraProps setObject: selector forKey:name];
        [extraProps setObject:target forKey:[NSString stringWithFormat:@"%@Target",name]];
    }
    else if ([type isEqualToString:@"BlockCCControl"])
    {
        NSString* selector = [serializedValue objectAtIndex:0];
        NSNumber* target = [serializedValue objectAtIndex:1];
        NSNumber* ctrlEvts = [serializedValue objectAtIndex:2];
        if (!selector) selector = @"";
        if (!target) target = [NSNumber numberWithInt:0];
        if (!ctrlEvts) ctrlEvts = [NSNumber numberWithInt:0];
        [extraProps setObject: selector forKey:name];
        [extraProps setObject:target forKey:[NSString stringWithFormat:@"%@Target",name]];
        [extraProps setObject:ctrlEvts forKey:[NSString stringWithFormat:@"%@CtrlEvts",name]];
    }
    else if ([type isEqualToString:@"CCBFile"])
    {
        NSString* ccbFile = serializedValue;
        if (!ccbFile) ccbFile = @"";
        [NodeGraphPropertySetter setNodeGraphForNode:node andProperty:name withFile:ccbFile parentSize:parentSize];
        [extraProps setObject:ccbFile forKey:name];
    }
    else
    {
        NSLog(@"WARNING Unrecognized property type: %@", type);
    }
}

+ (CCNode*) nodeGraphFromDictionary:(NSDictionary*) dict parentSize:(CGSize)parentSize
{
    if (!renamedProperties)
    {
        renamedProperties = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CCBReaderInternalRenamedProps" ofType:@"plist"]];
        
        NSAssert(renamedProperties, @"Failed to load renamed properties dict");
        [renamedProperties retain];
    }
    
    NSArray* props = [dict objectForKey:@"properties"];
    NSString* baseClass = [dict objectForKey:@"baseClass"];
    NSArray* children = [dict objectForKey:@"children"];
    
    // Create the node
    CCNode* node = [[PlugInManager sharedManager] createDefaultNodeOfType:baseClass];
    if (!node)
    {
        NSLog(@"WARNING! Plug-in missing for %@", baseClass);
        return NULL;
    }
    
    
    // Fetch info and extra properties
    NodeInfo* nodeInfo = node.userObject;
    NSMutableDictionary* extraProps = nodeInfo.extraProps;
    PlugInNode* plugIn = nodeInfo.plugIn;
    
    // Flash skew compatibility
    if ([[dict objectForKey:@"usesFlashSkew"] boolValue])
    {
        [node setUsesFlashSkew:YES];
    }
    
    // Set properties for the node
    int numProps = [props count];
    for (int i = 0; i < numProps; i++)
    {
        NSDictionary* propInfo = [props objectAtIndex:i];
        NSString* type = [propInfo objectForKey:@"type"];
        NSString* name = [propInfo objectForKey:@"name"];
        id serializedValue = [propInfo objectForKey:@"value"];
        
        // Check for renamings
        NSDictionary* renameRule = [renamedProperties objectForKey:name];
        if (renameRule)
        {
            name = [renameRule objectForKey:@"newName"];
        }
        
        if ([plugIn dontSetInEditorProperty:name])
        {
            [extraProps setObject:serializedValue forKey:name];
        }
        else
        {
            [CCBReaderInternal setProp:name ofType:type toValue:serializedValue forNode:node parentSize:parentSize];
        }
        id baseValue = [propInfo objectForKey:@"baseValue"];
        if (baseValue) [node setBaseValue:baseValue forProperty:name];
    }
    
    // Set extra properties for code connections
    NSString* customClass = [dict objectForKey:@"customClass"];
    if (!customClass) customClass = @"";
    NSString* memberVarName = [dict objectForKey:@"memberVarAssignmentName"];
    if (!memberVarName) memberVarName = @"";
    int memberVarType = [[dict objectForKey:@"memberVarAssignmentType"] intValue];
    
    [extraProps setObject:customClass forKey:@"customClass"];
    [extraProps setObject:memberVarName forKey:@"memberVarAssignmentName"];
    [extraProps setObject:[NSNumber numberWithInt:memberVarType] forKey:@"memberVarAssignmentType"];
    
    // JS code connections
    NSString* jsController = [dict objectForKey:@"jsController"];
    if (jsController)
    {
        [extraProps setObject:jsController forKey:@"jsController"];
    }
    
    NSString* displayName = [dict objectForKey:@"displayName"];
    if (displayName)
    {
        node.displayName = displayName;
    }
    
    id animatedProps = [dict objectForKey:@"animatedProperties"];
    [node loadAnimatedPropertiesFromSerialization:animatedProps];
    node.seqExpanded = [[dict objectForKey:@"seqExpanded"] boolValue];
    
    CGSize contentSize = node.contentSize;
    for (int i = 0; i < [children count]; i++)
    {
        CCNode* child = [CCBReaderInternal nodeGraphFromDictionary:[children objectAtIndex:i] parentSize:contentSize];
        [node addChild:child z:i];
    }
    
    // Selections
    if ([[dict objectForKey:@"selected"] boolValue])
    {
        [[CocosBuilderAppDelegate appDelegate].loadedSelectedNodes addObject:node];
    }
    
    BOOL isCCBSubFile = [baseClass isEqualToString:@"CCBFile"];
    
    // Load custom properties
    if (isCCBSubFile)
    {
        // For sub ccb files the custom properties are already loaded by the sub file and forwarded. We just need to override the values from the sub ccb file
        [node loadCustomPropertyValuesFromSerialization:[dict objectForKey:@"customProperties"]];
    }
    else
    {
        [node loadCustomPropertiesFromSerialization:[dict objectForKey:@"customProperties"]];
    }
    
    return node;
}

+ (CCNode*) nodeGraphFromDocumentDictionary:(NSDictionary *)dict
{
    return [CCBReaderInternal nodeGraphFromDocumentDictionary:dict parentSize:CGSizeZero];
}

+ (CCNode*) nodeGraphFromDocumentDictionary:(NSDictionary *)dict parentSize:(CGSize) parentSize
{
    if (!dict)
    {
        NSLog(@"WARNING! Trying to load invalid file type (dict is null)");
        return NULL;
    }
    // Load file metadata
    
    NSString* fileType = [dict objectForKey:@"fileType"];
    int fileVersion = [[dict objectForKey:@"fileVersion"] intValue];
    
    if (!fileType  || ![fileType isEqualToString:@"CocosBuilder"])
    {
        NSLog(@"WARNING! Trying to load invalid file type (%@)", fileType);
    }
    
    NSDictionary* nodeGraph = [dict objectForKey:@"nodeGraph"];
    
    if (fileVersion <= 2)
    {
        // Use legacy reader
        NSString* assetsPath = [NSString stringWithFormat:@"%@/", [[ResourceManager sharedManager] mainActiveDirectoryPath]];
        
        return [CCBReaderInternalV1 ccObjectFromDictionary:nodeGraph assetsDir:assetsPath owner:NULL];
    }
    else if (fileVersion > kCCBFileFormatVersion)
    {
        NSLog(@"WARNING! Trying to load file made with a newer version of CocosBuilder");
        return NULL;
    }
    
    return [CCBReaderInternal nodeGraphFromDictionary:nodeGraph parentSize:parentSize];
}

@end
