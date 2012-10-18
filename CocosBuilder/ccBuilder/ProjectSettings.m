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

#import "ProjectSettings.h"
#import "NSString+RelativePath.h"
#import "HashValue.h"
#import "PlugInManager.h"
#import "PlugInExport.h"

@implementation ProjectSettings

@synthesize projectPath;
@synthesize resourcePaths;
@synthesize publishDirectory;
@synthesize flattenPaths;
@synthesize publishToZipFile;
@synthesize javascriptBased;
@synthesize javascriptMainCCB;
@synthesize onlyPublishCCBs;
@synthesize exporter;
@synthesize availableExporters;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    resourcePaths = [[NSMutableArray alloc] init];
    [resourcePaths addObject:[NSMutableDictionary dictionaryWithObject:@"." forKey:@"path"]];
    self.publishDirectory = @".";
    self.onlyPublishCCBs = NO;
    self.flattenPaths = YES;
    self.javascriptBased = YES;
    self.publishToZipFile = YES;
    self.javascriptMainCCB = @"MainScene";
    
    // Load available exporters
    self.availableExporters = [NSMutableArray array];
    for (PlugInExport* plugIn in [[PlugInManager sharedManager] plugInsExporters])
    {
        [availableExporters addObject: plugIn.extension];
    }
    
    return self;
}

- (id) initWithSerialization:(id)dict
{
    self = [self init];
    if (!self) return NULL;
    
    // Check filetype
    if (![[dict objectForKey:@"fileType"] isEqualToString:@"CocosBuilderProject"])
    {
        [self release];
        return NULL;
    }
    
    // Read settings
    self.resourcePaths = [dict objectForKey:@"resourcePaths"];
    self.publishDirectory = [dict objectForKey:@"publishDirectory"];
    self.flattenPaths = [[dict objectForKey:@"flattenPaths"] boolValue];
    self.publishToZipFile = [[dict objectForKey:@"publishToZipFile"] boolValue];
    self.javascriptBased = [[dict objectForKey:@"javascriptBased"] boolValue];
    self.onlyPublishCCBs = [[dict objectForKey:@"onlyPublishCCBs"] boolValue];
    self.exporter = [dict objectForKey:@"exporter"];
    
    NSString* mainCCB = [dict objectForKey:@"javascriptMainCCB"];
    if (!mainCCB) mainCCB = @"";
    self.javascriptMainCCB = mainCCB;
    
    return self;
}

- (void) dealloc
{
    self.resourcePaths = NULL;
    self.projectPath = NULL;
    self.publishDirectory = NULL;
    self.exporter = NULL;
    self.availableExporters = NULL;
    [super dealloc];
}

- (NSString*) exporter
{
    if (exporter) return exporter;
    return kCCBDefaultExportPlugIn;
}

- (id) serialize
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    [dict setObject:@"CocosBuilderProject" forKey:@"fileType"];
    [dict setObject:[NSNumber numberWithInt:kCCBProjectSettingsVersion] forKey:@"fileVersion"];
    [dict setObject:resourcePaths forKey:@"resourcePaths"];
    [dict setObject:publishDirectory forKey:@"publishDirectory"];
    [dict setObject:[NSNumber numberWithBool:flattenPaths] forKey:@"flattenPaths"];
    [dict setObject:[NSNumber numberWithBool:publishToZipFile] forKey:@"publishToZipFile"];
    [dict setObject:[NSNumber numberWithBool:javascriptBased] forKey:@"javascriptBased"];
    [dict setObject:[NSNumber numberWithBool:onlyPublishCCBs] forKey:@"onlyPublishCCBs"];
    [dict setObject:self.exporter forKey:@"exporter"];
    
    if (!javascriptMainCCB) self.javascriptMainCCB = @"";
    if (!javascriptBased) self.javascriptMainCCB = @"";
    [dict setObject:javascriptMainCCB forKey:@"javascriptMainCCB"];
    
    return dict;
}

- (NSArray*) absoluteResourcePaths
{
    NSString* projectDirectory = [self.projectPath stringByDeletingLastPathComponent];
    
    NSMutableArray* paths = [NSMutableArray array];
    
    for (NSDictionary* dict in resourcePaths)
    {
        NSString* path = [dict objectForKey:@"path"];
        NSString* absPath = [path absolutePathFromBaseDirPath:projectDirectory];
        [paths addObject:absPath];
    }
    
    if ([paths count] == 0)
    {
        [paths addObject:projectDirectory];
    }
    
    return paths;
}

- (NSString*) projectPathHashed
{
    if (projectPath)
    {
        HashValue* hash = [HashValue md5HashWithString:projectPath];
        return [hash description];
    }
    else
    {
        return NULL;
    }
}

- (NSString*) publishCacheDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[[[paths objectAtIndex:0] stringByAppendingPathComponent:@"com.cocosbuilder.CocosBuilder"] stringByAppendingPathComponent:@"publish"]stringByAppendingPathComponent:self.projectPathHashed];
}

- (BOOL) store
{
    return [[self serialize] writeToFile:self.projectPath atomically:YES];
}

@end
