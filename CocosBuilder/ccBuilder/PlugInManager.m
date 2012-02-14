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

@implementation PlugInManager

@synthesize plugInsNodeNames;

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
        if (![[plugInPath pathExtension] isEqualToString:@"bundle"]) continue;
        
        // Load the bundle
        NSBundle* bundle = [NSBundle bundleWithURL:plugInPath];
        [bundle load];
        
        if (bundle)
        {
            PlugInNode* plugIn = [[PlugInNode alloc] initWithBundle:bundle];
            if (plugIn)
            {
                [plugInsNode setObject:plugIn forKey:plugIn.nodeClassName];
                [plugInsNodeNames addObject:plugIn.nodeClassName];
                
                NSLog(@"LOADED PLUGIN: %@", plugIn.nodeClassName);
            }
        }
    }
}

- (void) dealloc
{
    [plugInsNode release];
    [plugInsNodeNames release];
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
    NSLog(@"nodeEditorClassName:%@ editorClass:%@",plugin.nodeEditorClassName, editorClass);
    CCNode* node = [[[editorClass alloc] init] autorelease];
    node.userData = [NodeInfo nodeInfoWithPlugIn:plugin];
    
    return node;
}

@end
