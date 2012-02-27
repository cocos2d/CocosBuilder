//
//  PlugInManager.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlugInManager.h"
#import "PlugInNode.h"
#import "PlugInExport.h"
#import "NodeInfo.h"
#import "CCBReaderInternal.h"

@implementation PlugInManager

@synthesize plugInsNodeNames, plugInsNodeNamesCanBeRoot, plugInsExporters;

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
    
    plugInsExporters = [[NSMutableArray alloc] init];
    
    return self;
}

- (void) loadPlugIns
{
    // Locate the plug ins
    NSBundle* appBundle = [NSBundle mainBundle];
    NSURL* plugInDir = [appBundle builtInPlugInsURL];
    
    NSArray* plugInPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:plugInDir includingPropertiesForKeys:NULL options:NSDirectoryEnumerationSkipsHiddenFiles error:NULL];
    
    // Load PlugIn nodes
    for (int i = 0; i < [plugInPaths count]; i++)
    {
        NSURL* plugInPath = [plugInPaths objectAtIndex:i];
        
        // Verify that this is a node plug-in
        if (![[plugInPath pathExtension] isEqualToString:@"ccbPlugNode"]) continue;
        
        // Load the bundle
        NSBundle* bundle = [NSBundle bundleWithURL:plugInPath];
        
        if (bundle)
        {
            NSLog(@"Loading PlugIn: %@", [plugInPath lastPathComponent]);
            
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
    
    // Load PlugIn exporters
    for (int i = 0; i < [plugInPaths count]; i++)
    {
        NSURL* plugInPath = [plugInPaths objectAtIndex:i];
        
        // Verify that this is an exporter plug-in
        if (![[plugInPath pathExtension] isEqualToString:@"ccbPlugExport"]) continue;
        
        // Load the bundle
        NSBundle* bundle = [NSBundle bundleWithURL:plugInPath];
        if (bundle)
        {
            NSLog(@"Loading PlugIn: %@", [plugInPath lastPathComponent]);
            
            [bundle load];
            
            PlugInExport* plugIn = [[PlugInExport alloc] initWithBundle:bundle];
            if (plugIn)
            {
                NSString* plugInName = [[plugInPath lastPathComponent] stringByDeletingPathExtension];
                plugIn.pluginName = plugInName;
                
                [plugInsExporters addObject:plugIn];
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
    
    NodeInfo* nodeInfo = node.userData;
    NSMutableDictionary* extraProps = nodeInfo.extraProps;
    
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
            
            if ([[propInfo objectForKey:@"dontSetInEditor"] boolValue])
            {
                // Use an extra prop instead of the real object property
                [extraProps setObject:defaultValue forKey:name];
            }
            else
            {
                // Set the property on the object
                [CCBReaderInternal setProp:name ofType:type toValue:defaultValue forNode:node];
            }
        }
    }
    
    return node;
}

- (NSArray*) plugInsExportNames
{
    NSMutableArray* arr = [NSMutableArray array];
    for (int i = 0; i < [plugInsExporters count]; i++)
    {
        PlugInExport* plugIn = [plugInsExporters objectAtIndex:i];
        [arr addObject:plugIn.pluginName];
        
        NSLog(@"Adding plugInName: %@", plugIn.pluginName);
    }
    return arr;
}

- (PlugInExport*) plugInExportForIndex:(int)idx
{
    return [plugInsExporters objectAtIndex:idx];
}

- (PlugInExport*) plugInExportForExtension:(NSString*)ext
{
    for (int i = 0; i < [plugInsExporters count]; i++)
    {
        PlugInExport* plugIn = [plugInsExporters objectAtIndex:i];
        if ([[plugIn extension] isEqualToString:ext])
        {
            return plugIn;
        }
    }
    return NULL;
}

@end
