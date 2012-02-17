//
//  PlugInManager.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlugInManager.h"
#import "PlugInNode.h"
#import "NodeInfo.h"
#import "CCBReaderInternal.h"

@implementation PlugInManager

@synthesize plugInsNodeNames, plugInsNodeNamesCanBeRoot;

+ (PlugInManager*) sharedManager
{
    static PlugInManager* manager = NULL;
    if (!manager) manager = [[PlugInManager alloc] init];
    return manager;
}

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    plugInsNode = [[NSMutableDictionary alloc] init];
    plugInsNodeNames = [[NSMutableArray alloc] init];
    plugInsNodeNamesCanBeRoot = [[NSMutableArray alloc] init];
    
    return self;
}

- (void) loadPlugIns
{
    // Locate the plug ins
    NSBundle* appBundle = [NSBundle mainBundle];
    NSURL* plugInDir = [appBundle builtInPlugInsURL];
    
    NSArray* plugInPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:plugInDir includingPropertiesForKeys:NULL options:NSDirectoryEnumerationSkipsHiddenFiles error:NULL];
    
    for (int i = 0; i < [plugInPaths count]; i++)
    {
        NSURL* plugInPath = [plugInPaths objectAtIndex:i];
        
        // Verify that this is a plug in
        if (![[plugInPath pathExtension] isEqualToString:@"ccbPlugNode"]) continue;
        
        // Load the bundle
        NSBundle* bundle = [NSBundle bundleWithURL:plugInPath];
        
        if (bundle)
        {
            [bundle load];
            
            PlugInNode* plugIn = [[PlugInNode alloc] initWithBundle:bundle];
            if (plugIn)
            {
                [plugInsNode setObject:plugIn forKey:plugIn.nodeClassName];
                [plugInsNodeNames addObject:plugIn.nodeClassName];
                
                if (plugIn.canBeRoot)
                {
                    [plugInsNodeNamesCanBeRoot addObject:plugIn.nodeClassName];
                }
            }
        }
    }
}

- (void) dealloc
{
    [plugInsNode release];
    [plugInsNodeNames release];
    [plugInsNodeNamesCanBeRoot release];
    [super dealloc];
}

- (PlugInNode*) plugInNodeNamed:(NSString*)name
{
    return [plugInsNode objectForKey:name];
}

- (CCNode*) createDefaultNodeOfType:(NSString*)name
{
    PlugInNode* plugin = [self plugInNodeNamed:name];
    if (!plugin) return NULL;
    
    Class editorClass = NSClassFromString(plugin.nodeEditorClassName);
    
    CCNode* node = [[[editorClass alloc] init] autorelease];
    [node setUserData: [NodeInfo nodeInfoWithPlugIn:plugin] retainData:YES];
    
    // Set default data
    NSMutableArray* plugInProps = plugin.nodeProperties;
    for (int i = 0; i < [plugInProps count]; i++)
    {
        
        NSDictionary* propInfo = [plugInProps objectAtIndex:i];
        
        id defaultValue = [propInfo objectForKey:@"default"];
         
        if (defaultValue)
        {
            NSString* name = [propInfo objectForKey:@"name"];
            NSString* type = [propInfo objectForKey:@"type"];
            
            [CCBReaderInternal setProp:name ofType:type toValue:defaultValue forNode:node];
        }
    }
    
    return node;
}

@end
