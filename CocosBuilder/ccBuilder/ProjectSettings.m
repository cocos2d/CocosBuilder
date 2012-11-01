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
@synthesize publishDirectoryAndroid;
@synthesize publishDirectoryHTML5;
@synthesize publishEnablediPhone;
@synthesize publishEnabledAndroid;
@synthesize publishEnabledHTML5;
@synthesize publishResolution_;
@synthesize publishResolution_hd;
@synthesize publishResolution_ipad;
@synthesize publishResolution_ipadhd;
@synthesize publishResolution_xsmall;
@synthesize publishResolution_small;
@synthesize publishResolution_medium;
@synthesize publishResolution_large;
@synthesize publishResolution_xlarge;
@synthesize publishResolutionHTML5_width;
@synthesize publishResolutionHTML5_height;
@synthesize publishResolutionHTML5_scale;
@synthesize flattenPaths;
@synthesize publishToZipFile;
@synthesize javascriptBased;
@synthesize javascriptMainCCB;
@synthesize onlyPublishCCBs;
@synthesize exporter;
@synthesize availableExporters;
@synthesize deviceOrientationPortrait;
@synthesize deviceOrientationUpsideDown;
@synthesize deviceOrientationLandscapeLeft;
@synthesize deviceOrientationLandscapeRight;
@synthesize resourceAutoScaleFactor;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    resourcePaths = [[NSMutableArray alloc] init];
    [resourcePaths addObject:[NSMutableDictionary dictionaryWithObject:@"." forKey:@"path"]];
    self.publishDirectory = @".";
    self.publishDirectoryAndroid = @".";
    self.publishDirectoryHTML5 = @".";
    self.onlyPublishCCBs = NO;
    self.flattenPaths = YES;
    self.javascriptBased = YES;
    self.publishToZipFile = YES;
    self.javascriptMainCCB = @"MainScene";
    self.deviceOrientationPortrait = YES;
    self.resourceAutoScaleFactor = 4;
    
    self.publishEnablediPhone = YES;
    self.publishEnabledAndroid = YES;
    self.publishEnabledHTML5 = YES;
    
    self.publishResolution_ = YES;
    self.publishResolution_hd = YES;
    self.publishResolution_ipad = YES;
    self.publishResolution_ipadhd = YES;
    self.publishResolution_xsmall = YES;
    self.publishResolution_small = YES;
    self.publishResolution_medium = YES;
    self.publishResolution_large = YES;
    self.publishResolution_xlarge = YES;
    
    self.publishResolutionHTML5_width = 960;
    self.publishResolutionHTML5_height = 640;
    self.publishResolutionHTML5_scale = 2;
    
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
    self.publishDirectoryAndroid = [dict objectForKey:@"publishDirectoryAndroid"];
    self.publishDirectoryHTML5 = [dict objectForKey:@"publishDirectoryHTML5"];
    
    if (!publishDirectory) self.publishDirectory = @"";
    if (!publishDirectoryAndroid) self.publishDirectoryAndroid = @"";
    if (!publishDirectoryHTML5) self.publishDirectoryHTML5 = @"";
    
    self.publishEnablediPhone = [[dict objectForKey:@"publishEnablediPhone"] boolValue];
    self.publishEnabledAndroid = [[dict objectForKey:@"publishEnabledAndroid"] boolValue];
    self.publishEnabledHTML5 = [[dict objectForKey:@"publishEnabledHTML5"] boolValue];
    
    self.publishResolution_ = [[dict objectForKey:@"publishResolution_"] boolValue];
    self.publishResolution_hd = [[dict objectForKey:@"publishResolution_hd"] boolValue];
    self.publishResolution_ipad = [[dict objectForKey:@"publishResolution_ipad"] boolValue];
    self.publishResolution_ipadhd = [[dict objectForKey:@"publishResolution_ipadhd"] boolValue];
    self.publishResolution_xsmall = [[dict objectForKey:@"publishResolution_xsmall"] boolValue];
    self.publishResolution_small = [[dict objectForKey:@"publishResolution_small"] boolValue];
    self.publishResolution_medium = [[dict objectForKey:@"publishResolution_medium"] boolValue];
    self.publishResolution_large = [[dict objectForKey:@"publishResolution_large"] boolValue];
    self.publishResolution_xlarge = [[dict objectForKey:@"publishResolution_xlarge"] boolValue];
    
    self.publishResolutionHTML5_width = [[dict objectForKey:@"publishResolutionHTML5_width"]intValue];
    self.publishResolutionHTML5_height = [[dict objectForKey:@"publishResolutionHTML5_height"]intValue];
    self.publishResolutionHTML5_scale = [[dict objectForKey:@"publishResolutionHTML5_scale"]intValue];
    if (!publishResolutionHTML5_width) publishResolutionHTML5_width = 960;
    if (!publishResolutionHTML5_height) publishResolutionHTML5_height = 640;
    if (!publishResolutionHTML5_scale) publishResolutionHTML5_scale = 2;
    
    self.flattenPaths = [[dict objectForKey:@"flattenPaths"] boolValue];
    self.publishToZipFile = [[dict objectForKey:@"publishToZipFile"] boolValue];
    self.javascriptBased = [[dict objectForKey:@"javascriptBased"] boolValue];
    self.onlyPublishCCBs = [[dict objectForKey:@"onlyPublishCCBs"] boolValue];
    self.exporter = [dict objectForKey:@"exporter"];
    self.deviceOrientationPortrait = [[dict objectForKey:@"deviceOrientationPortrait"] boolValue];
    self.deviceOrientationUpsideDown = [[dict objectForKey:@"deviceOrientationUpsideDown"] boolValue];
    self.deviceOrientationLandscapeLeft = [[dict objectForKey:@"deviceOrientationLandscapeLeft"] boolValue];
    self.deviceOrientationLandscapeRight = [[dict objectForKey:@"deviceOrientationLandscapeRight"] boolValue];
    self.resourceAutoScaleFactor = [[dict objectForKey:@"resourceAutoScaleFactor"]intValue];
    if (resourceAutoScaleFactor == 0) self.resourceAutoScaleFactor = 4;
    
    
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
    [dict setObject:publishDirectoryAndroid forKey:@"publishDirectoryAndroid"];
    [dict setObject:publishDirectoryHTML5 forKey:@"publishDirectoryHTML5"];
    
    [dict setObject:[NSNumber numberWithBool:publishEnablediPhone] forKey:@"publishEnablediPhone"];
    [dict setObject:[NSNumber numberWithBool:publishEnabledAndroid] forKey:@"publishEnabledAndroid"];
    [dict setObject:[NSNumber numberWithBool:publishEnabledHTML5] forKey:@"publishEnabledHTML5"];
    
    
    [dict setObject:[NSNumber numberWithBool:publishResolution_] forKey:@"publishResolution_"];
    [dict setObject:[NSNumber numberWithBool:publishResolution_hd] forKey:@"publishResolution_hd"];
    [dict setObject:[NSNumber numberWithBool:publishResolution_ipad] forKey:@"publishResolution_ipad"];
    [dict setObject:[NSNumber numberWithBool:publishResolution_ipadhd] forKey:@"publishResolution_ipadhd"];
    [dict setObject:[NSNumber numberWithBool:publishResolution_xsmall] forKey:@"publishResolution_xsmall"];
    [dict setObject:[NSNumber numberWithBool:publishResolution_small] forKey:@"publishResolution_small"];
    [dict setObject:[NSNumber numberWithBool:publishResolution_medium] forKey:@"publishResolution_medium"];
    [dict setObject:[NSNumber numberWithBool:publishResolution_large] forKey:@"publishResolution_large"];
    [dict setObject:[NSNumber numberWithBool:publishResolution_xlarge] forKey:@"publishResolution_xlarge"];
    
    [dict setObject:[NSNumber numberWithInt:publishResolutionHTML5_width] forKey:@"publishResolutionHTML5_width"];
    [dict setObject:[NSNumber numberWithInt:publishResolutionHTML5_height] forKey:@"publishResolutionHTML5_height"];
    [dict setObject:[NSNumber numberWithInt:publishResolutionHTML5_scale] forKey:@"publishResolutionHTML5_scale"];
    
    [dict setObject:[NSNumber numberWithBool:flattenPaths] forKey:@"flattenPaths"];
    [dict setObject:[NSNumber numberWithBool:publishToZipFile] forKey:@"publishToZipFile"];
    [dict setObject:[NSNumber numberWithBool:javascriptBased] forKey:@"javascriptBased"];
    [dict setObject:[NSNumber numberWithBool:onlyPublishCCBs] forKey:@"onlyPublishCCBs"];
    [dict setObject:self.exporter forKey:@"exporter"];
    
    [dict setObject:[NSNumber numberWithBool:deviceOrientationPortrait] forKey:@"deviceOrientationPortrait"];
    [dict setObject:[NSNumber numberWithBool:deviceOrientationUpsideDown] forKey:@"deviceOrientationUpsideDown"];
    [dict setObject:[NSNumber numberWithBool:deviceOrientationLandscapeLeft] forKey:@"deviceOrientationLandscapeLeft"];
    [dict setObject:[NSNumber numberWithBool:deviceOrientationLandscapeRight] forKey:@"deviceOrientationLandscapeRight"];
    [dict setObject:[NSNumber numberWithInt:resourceAutoScaleFactor] forKey:@"resourceAutoScaleFactor"];
    
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
