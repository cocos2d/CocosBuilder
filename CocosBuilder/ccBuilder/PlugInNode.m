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

#import "PlugInNode.h"

@implementation PlugInNode

@synthesize nodeClassName, nodeEditorClassName, nodeProperties, nodePropertiesDict, dropTargetSpriteFrameClass, dropTargetSpriteFrameProperty, canBeRoot, canHaveChildren, isAbstract, requireParentClass, requireChildClass;

- (void) loadPropertiesForBundle:(NSBundle*) b intoArray:(NSMutableArray*)arr
{
    NSURL* propsURL = [b URLForResource:@"CCBPProperties" withExtension:@"plist"];
    NSMutableDictionary* props = [NSMutableDictionary dictionaryWithContentsOfURL:propsURL];
    
    // Add properties from super classes
    NSString* inheritsFrom = [props objectForKey:@"inheritsFrom"];
    if (inheritsFrom)
    {
        NSBundle* appBundle = [NSBundle mainBundle];
        NSURL* plugInDir = [appBundle builtInPlugInsURL];
        
        NSURL* superBundleURL = [plugInDir URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.ccbPlugNode",inheritsFrom]];
        
        NSBundle* superBundle = [NSBundle bundleWithURL:superBundleURL];
        
        [self loadPropertiesForBundle:superBundle intoArray:arr];
    }
    
    [arr addObjectsFromArray:[props objectForKey:@"properties"]];
    
    // Handle overridden properties
    NSArray* overrides = [props objectForKey:@"propertiesOverridden"];
    if (overrides)
    {
        for (int i = 0; i < [overrides count]; i++)
        {
            NSDictionary* propInfo = [overrides objectAtIndex:i];
            NSString* propName = [propInfo objectForKey:@"name"];
            
            // Find the old property
            for (int oldPropIdx = 0; oldPropIdx < [arr count]; oldPropIdx++)
            {
                NSDictionary* oldPropInfo = [arr objectAtIndex:oldPropIdx];
                if ([[oldPropInfo objectForKey:@"name"] isEqualToString:propName])
                {
                    // This property should be replaced
                    [arr replaceObjectAtIndex:oldPropIdx withObject:propInfo];
                }
            }
        }
    }
}


- (void) setupNodePropsDict
{
    // Transform the nodes info array to a dictionary for quicker lookups of properties
    
    for (int i = 0; i < [nodeProperties count]; i++)
    {
        NSDictionary* propInfo = [nodeProperties objectAtIndex:i];
        
        NSString* propName = [propInfo objectForKey:@"name"];
        if (propName)
        {
            [nodePropertiesDict setObject:propInfo forKey:propName];
        }
    }
}

- (id) initWithBundle:(NSBundle*) b
{
    self = [super init];
    if (!self) return NULL;
    
    bundle = b;
    [bundle retain];
    
    // Load properties
    NSURL* propsURL = [bundle URLForResource:@"CCBPProperties" withExtension:@"plist"];
    NSMutableDictionary* props = [NSMutableDictionary dictionaryWithContentsOfURL:propsURL];
    
    nodeClassName = [[props objectForKey:@"className"] retain];
    nodeEditorClassName = [[props objectForKey:@"editorClassName"] retain];
    
    nodeProperties = [[NSMutableArray alloc] init];
    nodePropertiesDict = [[NSMutableDictionary alloc] init];
    [self loadPropertiesForBundle:bundle intoArray:nodeProperties];
    [self setupNodePropsDict];
    
    // Support for spriteFrame drop targets
    NSDictionary* spriteFrameDrop = [props objectForKey:@"spriteFrameDrop"];
    if (spriteFrameDrop)
    {
        dropTargetSpriteFrameClass = [spriteFrameDrop objectForKey:@"className"];
        dropTargetSpriteFrameProperty = [spriteFrameDrop objectForKey:@"property"];
        
        [dropTargetSpriteFrameClass retain];
        [dropTargetSpriteFrameProperty retain];
    }
    
    // Check if node type can be root node and which children are allowed
    canBeRoot = [[props objectForKey:@"canBeRootNode"] boolValue];
    canHaveChildren = [[props objectForKey:@"canHaveChildren"] boolValue];
    isAbstract = [[props objectForKey:@"isAbstract"] boolValue];
    requireChildClass = [[props objectForKey:@"requireChildClass"] retain];
    requireParentClass = [[props objectForKey:@"requireParentClass"] retain];
    positionProperty = [[props objectForKey:@"positionProperty"] retain];
    
    return self;
}

- (BOOL) acceptsDroppedSpriteFrameChildren
{
    if (dropTargetSpriteFrameClass && dropTargetSpriteFrameProperty) return YES;
    return NO;
}

- (BOOL) dontSetInEditorProperty: (NSString*) prop
{
    NSDictionary* propInfo = [nodePropertiesDict objectForKey:prop];
    BOOL dontSetInEditor = [[propInfo objectForKey:@"dontSetInEditor"] boolValue];
    
    return dontSetInEditor;
}

- (NSString*) positionProperty
{
    if (positionProperty) return positionProperty;
    return @"position";
}

- (NSArray*) readablePropertiesForType:(NSString*)type
{
    NSMutableArray* props = [NSMutableArray array];
    for (NSDictionary* propInfo in nodeProperties)
    {
        if ([[propInfo objectForKey:@"type"] isEqualToString:type] && ![[propInfo objectForKey:@"readOnly"] boolValue])
        {
            [props addObject:[propInfo objectForKey:@"name"]];
        }
    }
    return props;
}

- (NSArray*) animatableProperties
{
    if (cachedAnimatableProperties) return cachedAnimatableProperties;
    
    NSMutableArray* props = [NSMutableArray array];
    for (NSDictionary* propInfo in nodeProperties)
    {
        if ([[propInfo objectForKey:@"animatable"] boolValue])
        {
            [props addObject:[propInfo objectForKey:@"name"]];
        }
    }
    cachedAnimatableProperties = [props retain];
    
    return cachedAnimatableProperties;
}

- (BOOL) isAnimatableProperty:(NSString*)prop
{
    for (NSString* animProp in [self animatableProperties])
    {
        if ([animProp isEqualToString:prop])
        {
            return YES;
        }
    }
    return NO;
}

- (NSString*) propertyTypeForProperty:(NSString*)property
{
    return [[nodePropertiesDict objectForKey:property] objectForKey:@"type"];
}

- (void) dealloc
{
    [cachedAnimatableProperties release];
    [positionProperty release];
    [requireChildClass release];
    [requireParentClass release];
    [dropTargetSpriteFrameClass release];
    [dropTargetSpriteFrameProperty release];
    [nodeProperties release];
    [nodePropertiesDict release];
    [nodeClassName release];
    [bundle release];
    [super dealloc];
}

@end
