//
//  CCBReaderInternal.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBReaderInternal.h"
#import "CCBReaderInternalV1.h"
#import "PlugInManager.h"
#import "PlugInNode.h"
#import "NodeInfo.h"
#import "CCBWriter.h"
#import "TexturePropertySetter.h"
#import "CCBGlobals.h"
#import "CocosBuilderAppDelegate.h"

@implementation CCBReaderInternal

+ (CGPoint) deserializePoint:(id) val
{
    float x = [[val objectAtIndex:0] floatValue];
    float y = [[val objectAtIndex:1] floatValue];
    return ccp(x,y);
}

+ (CGSize) deserializeSize:(id) val
{
    float w = [[val objectAtIndex:0] floatValue];
    float h = [[val objectAtIndex:1] floatValue];
    return CGSizeMake(w, h);
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

+ (ccBlendFunc) deserializeBlendFunc:(id) val
{
    ccBlendFunc bf;
    bf.src = [[val objectAtIndex:0] intValue];
    bf.dst = [[val objectAtIndex:1] intValue];
    return bf;
}

+ (CCNode*) ccObjectFromDictionary:(NSDictionary*) dict
{
    NSArray* props = [dict objectForKey:@"properties"];
    NSString* baseClass = [dict objectForKey:@"baseClass"];
    NSArray* children = [dict objectForKey:@"children"];
    
    CCNode* node = [[PlugInManager sharedManager] createDefaultNodeOfType:baseClass];
    if (!node)
    {
        NSLog(@"WARNING! Plug-in missing for %@", baseClass);
        return NULL;
    }
    NodeInfo* nodeInfo = node.userData;
    NSMutableDictionary* extraProps = nodeInfo.extraProps;
    
    int numProps = [props count];
    for (int i = 0; i < numProps; i++)
    {
        NSDictionary* propInfo = [props objectAtIndex:i];
        NSString* type = [propInfo objectForKey:@"type"];
        NSString* name = [propInfo objectForKey:@"name"];
        id serializedValue = [propInfo objectForKey:@"value"];
        
        if ([type isEqualToString:@"Position"]
            || [type isEqualToString:@"Point"]
            || [type isEqualToString:@"PointLock"])
        {
            CGPoint pt = [CCBReaderInternal deserializePoint: serializedValue];
            [node setValue:[NSValue valueWithPoint:pt] forKey:name];
        }
        else if ([type isEqualToString:@"Size"])
        {
            CGSize size = [CCBReaderInternal deserializeSize: serializedValue];
            [node setValue:[NSValue valueWithSize:size] forKey:name];
        }
        else if ([type isEqualToString:@"Scale"]
                 || [type isEqualToString:@"ScaleLock"])
        {
            [node setValue:[serializedValue objectAtIndex:0] forKey:[NSString stringWithFormat:@"%@X",name]];
            [node setValue:[serializedValue objectAtIndex:1] forKey:[NSString stringWithFormat:@"%@Y",name]];
        }
        else if ([type isEqualToString:@"Degrees"])
        {
            float f = [CCBReaderInternal deserializeFloat: serializedValue];
            [node setValue:[NSNumber numberWithFloat:f] forKey:name];
        }
        else if ([type isEqualToString:@"Integer"]
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
            [TexturePropertySetter setTextureForNode:node andProperty:name withFile:spriteFile andSheetFile:spriteSheetFile];
        }
        else if ([type isEqualToString:@"Color3"])
        {
            ccColor3B c = [CCBReaderInternal deserializeColor3:serializedValue];
            NSValue* colorValue = [NSValue value:&c withObjCType:@encode(ccColor3B)];
            [node setValue:colorValue forKey:name];
        }
        else if ([type isEqualToString:@"Blendmode"])
        {
            ccBlendFunc bf = [CCBReaderInternal deserializeBlendFunc:serializedValue];
            NSValue* blendValue = [NSValue value:&bf withObjCType:@encode(ccBlendFunc)];
            [node setValue:blendValue forKey:name];
        }
        else
        {
            NSLog(@"WARNING Unrecognized property type: %@", type);
        }
    }
    
    for (int i = 0; i < [children count]; i++)
    {
        CCNode* child = [CCBReaderInternal ccObjectFromDictionary:[children objectAtIndex:i]];
        [node addChild:child];
    }
    
    return node;
}

+ (CCNode*) nodeGraphFromDictionary:(NSDictionary *)dict
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
        NSLog(@"dict=%@",dict);
    }
    
    NSDictionary* nodeGraph = [dict objectForKey:@"nodeGraph"];
    
    if (fileVersion == 2)
    {
        // Use legacy reader
        return [CCBReaderInternalV1 ccObjectFromDictionary:nodeGraph assetsDir:[[CCBGlobals globals] appDelegate].assetsPath owner:NULL];
    }
    else if (fileVersion > 3)
    {
        NSLog(@"WARNING! Trying to load file made with a newer version of CocosBuilder, please update the CCBReader class");
        return NULL;
    }
    
    return [CCBReaderInternal ccObjectFromDictionary:nodeGraph];
}

@end
