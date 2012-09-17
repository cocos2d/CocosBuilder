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

#import "PlugInManager.h"
#import "PlugInExport.h"

#if !CCB_BUILDING_COMMANDLINE
#import "PlugInNode.h"
#import "NodeInfo.h"
#import "CCBReaderInternal.h"
#endif

@implementation PlugInManager

#if !CCB_BUILDING_COMMANDLINE
@synthesize plugInsNodeNames, plugInsNodeNamesCanBeRoot;
#endif

@synthesize plugInsExporters;

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
    
#if !CCB_BUILDING_COMMANDLINE
    plugInsNode = [[NSMutableDictionary alloc] init];
    plugInsNodeNames = [[NSMutableArray alloc] init];
    plugInsNodeNamesCanBeRoot = [[NSMutableArray alloc] init];
#endif
    
    plugInsExporters = [[NSMutableArray alloc] init];
    
    return self;
}

- (void) loadPlugIns
{
    // Locate the plug ins
#if CCB_BUILDING_COMMANDLINE
    // This shouldn't be hardcoded.
    NSURL* appURL = nil;
    OSStatus error = LSFindApplicationForInfo(kLSUnknownCreator, (CFStringRef)@"com.cocosbuilder.CocosBuilder", NULL, NULL, (CFURLRef *)&appURL);
    NSBundle *appBundle = nil;
    
    if (error == noErr)
    {
        appBundle = [NSBundle bundleWithURL:appURL];
        [appURL release]; // LS documents that the URL returned must be released.
    }
    else
        appBundle = [NSBundle bundleWithIdentifier:@"com.cocosbuilder.CocosBuilder"]; // last-ditch effort
    
    if (!appBundle)
        return;
#else
    NSBundle* appBundle = [NSBundle mainBundle];
#endif
    
    NSURL* plugInDir = [appBundle builtInPlugInsURL];
    
    NSArray* plugInPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:plugInDir includingPropertiesForKeys:NULL options:NSDirectoryEnumerationSkipsHiddenFiles error:NULL];

#if !CCB_BUILDING_COMMANDLINE    
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
            
            PlugInNode* plugIn = [[[PlugInNode alloc] initWithBundle:bundle] autorelease];
            if (plugIn && !plugIn.isAbstract)
            {
                [plugInsNode setObject:plugIn forKey:plugIn.nodeClassName];
                [plugInsNodeNames addObject:plugIn.nodeClassName];
                
                if (plugIn.canBeRoot)
                {
                    [plugInsNodeNamesCanBeRoot addObject:plugIn.nodeClassName];
                }
            }
            
            // Load icon
            plugIn.icon = [[[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"Icon.png"]] autorelease];
        }
    }
#endif
    
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
            
            PlugInExport* plugIn = [[[PlugInExport alloc] initWithBundle:bundle] autorelease];
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
#if !CCB_BUILDING_COMMANDLINE
    [plugInsNode release];
    [plugInsNodeNames release];
    [plugInsNodeNamesCanBeRoot release];
#endif
    [super dealloc];
}

#if !CCB_BUILDING_COMMANDLINE
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
    [node setUserObject: [NodeInfo nodeInfoWithPlugIn:plugin]];
    
    NodeInfo* nodeInfo = node.userObject;
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
                [CCBReaderInternal setProp:name ofType:type toValue:defaultValue forNode:node parentSize:CGSizeZero];
            }
        }
    }
    
    return node;
}
#endif

- (NSArray*) plugInsExportNames
{
    NSMutableArray* arr = [NSMutableArray array];
    for (int i = 0; i < [plugInsExporters count]; i++)
    {
        PlugInExport* plugIn = [plugInsExporters objectAtIndex:i];
        [arr addObject:plugIn.pluginName];
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
