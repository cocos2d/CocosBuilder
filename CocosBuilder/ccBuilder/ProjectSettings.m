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
#import "ResourceManager.h"
#import "ResourceManagerUtil.h"
#import "CocosBuilderAppDelegate.h"
#import "PlayerConnection.h"
#import "PlayerDeviceInfo.h"

#import <ApplicationServices/ApplicationServices.h>

@implementation ProjectSettingsGeneratedSpriteSheet

@synthesize isDirty;
@synthesize textureFileFormat;
@synthesize dither;
@synthesize compress;
@synthesize textureFileFormatAndroid;
@synthesize ditherAndroid;
@synthesize textureFileFormatHTML5;
@synthesize ditherHTML5;

- (id)init
{
    self = [super init];
    if (!self) return NULL;
    
    self.isDirty = NO;
    
    self.textureFileFormat = 0; // PNG
    self.dither = YES;
    self.compress = YES;
    
    self.textureFileFormatAndroid = 0;
    self.ditherAndroid = YES;
    
    self.textureFileFormatHTML5 = 0;
    self.ditherHTML5 = YES;
    
    return self;
}

- (id)initWithSerialization:(id)dict
{
    self = [super init];
    if (!self) return NULL;
    
    self.isDirty = [[dict objectForKey:@"isDirty"] boolValue];

    self.textureFileFormat = [[dict objectForKey:@"textureFileFormat"] intValue];
    self.dither = [[dict objectForKey:@"dither"] boolValue];
    self.compress = [[dict objectForKey:@"compress"] boolValue];
    
    self.textureFileFormatAndroid = [[dict objectForKey:@"textureFileFormatAndroid"] intValue];
    self.ditherAndroid = [[dict objectForKey:@"ditherAndroid"] boolValue];
    
    self.textureFileFormatHTML5 = [[dict objectForKey:@"textureFileFormatHTML5"] intValue];
    self.ditherHTML5 = [[dict objectForKey:@"ditherHTML5"] boolValue];

    return self;
}

- (id) serialize
{
    NSMutableDictionary* ser = [NSMutableDictionary dictionary];
    
    [ser setObject:[NSNumber numberWithBool:self.isDirty] forKey:@"isDirty"];

    [ser setObject:[NSNumber numberWithInt:self.textureFileFormat] forKey:@"textureFileFormat"];
    [ser setObject:[NSNumber numberWithBool:self.dither] forKey:@"dither"];
    [ser setObject:[NSNumber numberWithBool:self.compress] forKey:@"compress"];
    
    [ser setObject:[NSNumber numberWithInt:self.textureFileFormatAndroid] forKey:@"textureFileFormatAndroid"];
    [ser setObject:[NSNumber numberWithBool:self.ditherAndroid] forKey:@"ditherAndroid"];
    
    [ser setObject:[NSNumber numberWithInt:self.textureFileFormatHTML5] forKey:@"textureFileFormatHTML5"];
    [ser setObject:[NSNumber numberWithBool:self.ditherHTML5] forKey:@"ditherHTML5"];

    return ser;
}

@end

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
@synthesize isSafariExist;
@synthesize isChromeExist;
@synthesize isFirefoxExist;
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
@synthesize generatedSpriteSheets;
@synthesize breakpoints;
@synthesize versionStr;
@synthesize needRepublish;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    resourcePaths = [[NSMutableArray alloc] init];
    [resourcePaths addObject:[NSMutableDictionary dictionaryWithObject:@"Resources" forKey:@"path"]];
    self.publishDirectory = @"Published-iOS";
    self.publishDirectoryAndroid = @"Published-Android";
    self.publishDirectoryHTML5 = @"Published-HTML5";
    self.onlyPublishCCBs = NO;
    self.flattenPaths = NO;
    self.javascriptBased = YES;
    self.publishToZipFile = NO;
    self.javascriptMainCCB = @"MainScene";
    self.deviceOrientationLandscapeLeft = YES;
    self.deviceOrientationLandscapeRight = YES;
    self.resourceAutoScaleFactor = 4;
    
    self.publishEnablediPhone = YES;
    self.publishEnabledAndroid = NO;
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
    
    self.publishResolutionHTML5_width = 480;
    self.publishResolutionHTML5_height = 320;
    self.publishResolutionHTML5_scale = 1;
    
    breakpoints = [[NSMutableDictionary dictionary] retain];
    
    generatedSpriteSheets = [[NSMutableDictionary dictionary] retain];
    
    // Load available exporters
    self.availableExporters = [NSMutableArray array];
    for (PlugInExport* plugIn in [[PlugInManager sharedManager] plugInsExporters])
    {
        [availableExporters addObject: plugIn.extension];
    }
    
    [self detectBrowserPresence];
    self.versionStr = [self getVersion];
    self.needRepublish = NO;
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
    
    // Load generated sprite sheet settings
    NSDictionary* generatedSpriteSheetsDict = [dict objectForKey:@"generatedSpriteSheets"];
    generatedSpriteSheets = [NSMutableDictionary dictionary];
    if (generatedSpriteSheetsDict)
    {
        for (NSString* ssFile in generatedSpriteSheetsDict)
        {
            NSDictionary* ssDict = [generatedSpriteSheetsDict objectForKey:ssFile];
            ProjectSettingsGeneratedSpriteSheet* ssInfo = [[[ProjectSettingsGeneratedSpriteSheet alloc] initWithSerialization:ssDict] autorelease];
            [generatedSpriteSheets setObject:ssInfo forKey:ssFile];
        }
    }
    [generatedSpriteSheets retain];
    
    NSString* mainCCB = [dict objectForKey:@"javascriptMainCCB"];
    if (!mainCCB) mainCCB = @"";
    self.javascriptMainCCB = mainCCB;
    
    [self detectBrowserPresence];
    
    // Check if we are running a new version of CocosBuilder
    // in which case the project needs to be republished
    NSString* oldVersionHash = [dict objectForKey:@"versionStr"];
    NSString* newVersionHash = [self getVersion];
    if (newVersionHash && ![newVersionHash isEqual:oldVersionHash])
    {
       self.versionStr = [self getVersion];
       self.needRepublish = YES;
    }
    else
    {
       self.needRepublish = NO;
    }
    
    return self;
}

- (void) dealloc
{
    self.versionStr = NULL;
    self.resourcePaths = NULL;
    self.projectPath = NULL;
    self.publishDirectory = NULL;
    self.exporter = NULL;
    self.availableExporters = NULL;
    [generatedSpriteSheets release];
    [breakpoints release];
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
    
    NSMutableDictionary* generatedSpriteSheetsDict = [NSMutableDictionary dictionary];
    for (NSString* ssFile in generatedSpriteSheets)
    {
        ProjectSettingsGeneratedSpriteSheet* ssInfo = [generatedSpriteSheets objectForKey:ssFile];
        id ssDict = [ssInfo serialize];
        [generatedSpriteSheetsDict setObject:ssDict forKey:ssFile];
    }
    [dict setObject:generatedSpriteSheetsDict forKey:@"generatedSpriteSheets"];
    
    if (versionStr)
    {
        [dict setObject:versionStr forKey:@"versionStr"];
    }
    
    [dict setObject:[NSNumber numberWithBool:needRepublish] forKey:@"needRepublish"];
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

- (NSString*) displayCacheDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[[[paths objectAtIndex:0] stringByAppendingPathComponent:@"com.cocosbuilder.CocosBuilder"] stringByAppendingPathComponent:@"display"]stringByAppendingPathComponent:self.projectPathHashed];
}

- (NSString*) publishCacheDirectory
{
    NSString* uuid = [PlayerConnection sharedPlayerConnection].selectedDeviceInfo.uuid;
    NSAssert(uuid, @"No uuid for selected device");
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[[[[paths objectAtIndex:0] stringByAppendingPathComponent:@"com.cocosbuilder.CocosBuilder"] stringByAppendingPathComponent:@"publish"]stringByAppendingPathComponent:self.projectPathHashed] stringByAppendingPathComponent:uuid];
}

- (NSString*) tempSpriteSheetCacheDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"com.cocosbuilder.CocosBuilder"] stringByAppendingPathComponent:@"spritesheet"];
}

- (BOOL) store
{
    return [[self serialize] writeToFile:self.projectPath atomically:YES];
}

- (void) makeSmartSpriteSheet:(RMResource*) res
{
    NSAssert(res.type == kCCBResTypeDirectory, @"Resource must be directory");
    
    NSString* relPath = [ResourceManagerUtil relativePathFromAbsolutePath:res.filePath];
    
    [generatedSpriteSheets setObject:[[[ProjectSettingsGeneratedSpriteSheet alloc] init] autorelease] forKey:relPath];
    
    [self store];
    [[CocosBuilderAppDelegate appDelegate].resManager notifyResourceObserversResourceListUpdated];
}

- (void) removeSmartSpriteSheet:(RMResource*) res
{
    NSAssert(res.type == kCCBResTypeDirectory, @"Resource must be directory");
    
    NSString* relPath = [ResourceManagerUtil relativePathFromAbsolutePath:res.filePath];
    
    [generatedSpriteSheets removeObjectForKey:relPath];
    
    [self store];
    [[CocosBuilderAppDelegate appDelegate].resManager notifyResourceObserversResourceListUpdated];
}

- (ProjectSettingsGeneratedSpriteSheet*) smartSpriteSheetForRes:(RMResource*) res
{
    NSAssert(res.type == kCCBResTypeDirectory, @"Resource must be directory");
    
    NSString* relPath = [ResourceManagerUtil relativePathFromAbsolutePath:res.filePath];
    
    return [generatedSpriteSheets objectForKey:relPath];
}

- (ProjectSettingsGeneratedSpriteSheet*) smartSpriteSheetForSubPath:(NSString*) relPath
{
    return [generatedSpriteSheets objectForKey:relPath];
}

- (void) toggleBreakpointForFile:(NSString*)file onLine:(int)line
{
    // Get breakpoints for file
    NSMutableSet* bps = [breakpoints objectForKey:file];
    if (!bps)
    {
        bps = [NSMutableSet set];
        [breakpoints setObject:bps forKey:file];
    }
    
    NSNumber* num = [NSNumber numberWithInt:line];
    if ([bps containsObject:num])
    {
        [bps removeObject:num];
    }
    else
    {
        [bps addObject:num];
    }
    
    // Send new list of bps to player
    [[PlayerConnection sharedPlayerConnection] debugSendBreakpoints:breakpoints];
}

- (NSSet*) breakpointsForFile:(NSString*)file
{
    NSSet* bps = [breakpoints objectForKey:file];
    if (!bps) bps = [NSSet set];
    
    return bps;
}

- (void) detectBrowserPresence
{
    isSafariExist = FALSE;
    isChromeExist = FALSE;
    isFirefoxExist = FALSE;
    
    OSStatus result = LSFindApplicationForInfo (kLSUnknownCreator, CFSTR("com.apple.Safari"), NULL, NULL, NULL);
    if (result == noErr)
    {
        isSafariExist = TRUE;
    }
    
    result = LSFindApplicationForInfo (kLSUnknownCreator, CFSTR("com.google.Chrome"), NULL, NULL, NULL);
    if (result == noErr)
    {
        isChromeExist = TRUE;
    }

    result = LSFindApplicationForInfo (kLSUnknownCreator, CFSTR("org.mozilla.firefox"), NULL, NULL, NULL);
    if (result == noErr)
    {
        isFirefoxExist = TRUE;
    }
}

- (NSString* ) getVersion
{
    NSString* versionPath = [[NSBundle mainBundle] pathForResource:@"Version" ofType:@"txt" inDirectory:@"version"];
    
    NSString* version = [NSString stringWithContentsOfFile:versionPath encoding:NSUTF8StringEncoding error:NULL];
    return version;
}
@end
