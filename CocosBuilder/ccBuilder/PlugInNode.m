//
//  PlugInNode.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlugInNode.h"

@implementation PlugInNode

@synthesize nodeClassName, nodeEditorClassName, nodeProperties, dropTargetSpriteFrameClass, dropTargetSpriteFrameProperty, canBeRoot;

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
        NSLog(@"superBundleURL: %@", superBundleURL);
        
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
    [self loadPropertiesForBundle:bundle intoArray:nodeProperties];
    
    // Support for spriteFrame drop targets
    NSDictionary* spriteFrameDrop = [props objectForKey:@"spriteFrameDrop"];
    if (spriteFrameDrop)
    {
        dropTargetSpriteFrameClass = [spriteFrameDrop objectForKey:@"className"];
        dropTargetSpriteFrameProperty = [spriteFrameDrop objectForKey:@"property"];
        
        [dropTargetSpriteFrameClass retain];
        [dropTargetSpriteFrameProperty retain];
    }
    
    // Check if node type can be root node
    canBeRoot = [[props objectForKey:@"canBeRootNode"] boolValue];
    
    return self;
}

- (BOOL) acceptsDroppedSpriteFrameChildren
{
    if (dropTargetSpriteFrameClass && dropTargetSpriteFrameProperty) return YES;
    return NO;
}

- (void) dealloc
{
    [dropTargetSpriteFrameClass release];
    [dropTargetSpriteFrameProperty release];
    [nodeProperties release];
    [nodeClassName release];
    [bundle release];
    [super dealloc];
}

@end
