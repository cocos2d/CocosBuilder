//
//  PlugInNode.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlugInNode.h"

@implementation PlugInNode

@synthesize nodeClassName, nodeEditorClassName, nodeProperties, dropTargetSpriteFrameClass, dropTargetSpriteFrameProperty, canBeRoot, canHaveChildren, requireParentClass, requireChildClass;

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
    requireChildClass = [[props objectForKey:@"requireChildClass"] retain];
    requireParentClass = [[props objectForKey:@"requireParentClass"] retain];
    
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

- (void) dealloc
{
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
