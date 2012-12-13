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

#import "CCBPublisher.h"
#import "ProjectSettings.h"
#import "CCBWarnings.h"
#import "NSString+RelativePath.h"
#import "PlugInExport.h"
#import "PlugInManager.h"
#import "CCBGlobals.h"
#import "CocosBuilderAppDelegate.h"
#import "NSString+AppendToFile.h"
#import "PlayerConnection.h"
#import "PlayerDeviceInfo.h"
#import "ResourceManager.h"
#import "CCBFileUtil.h"
#import "Tupac.h"
#import "CCBPublisherTemplate.h"

@implementation CCBPublisher

@synthesize publishFormat;
@synthesize runAfterPublishing;

- (id) initWithProjectSettings:(ProjectSettings*)settings warnings:(CCBWarnings*)w
{
    self = [super init];
    if (!self) return NULL;
    
    // Save settings and warning log
    projectSettings = [settings retain];
    warnings = [w retain];
    
    // Setup extensions to copy
    copyExtensions = [[NSArray alloc] initWithObjects:@"jpg",@"png", @"pvr", @"ccz", @"plist", @"fnt", @"ttf",@"js",@"wav",@"mp3",@"m4a",@"caf", nil];
    
    // Set format to use for exports
    self.publishFormat = projectSettings.exporter;
    
    return self;
}

- (BOOL) srcFile:(NSString*)srcFile isNewerThanDstFile:(NSString*)dstFile
{
    NSDictionary* srcAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:srcFile error:NULL];
    NSDate* srcDate = [srcAttributes objectForKey:NSFileModificationDate];
    
    NSDictionary* dstAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:dstFile error:NULL];
    NSDate* dstDate = [dstAttributes objectForKey:NSFileModificationDate];
    
    if (!srcDate || !dstDate) return YES;
    if ([srcDate compare:dstDate] == NSOrderedDescending) return YES;
    
    return NO;
}

- (BOOL) publishCCBFile:(NSString*)srcFile to:(NSString*)dstFile
{
    PlugInExport* plugIn = [[PlugInManager sharedManager] plugInExportForExtension:publishFormat];
    if (!plugIn)
    {
        [warnings addWarningWithDescription:[NSString stringWithFormat: @"Plug-in is missing for publishing files to %@-format. You can select plug-in in Project Settings.",publishFormat] isFatal:YES];
        return NO;
    }
    
    // Load src file
    NSMutableDictionary* doc = [NSMutableDictionary dictionaryWithContentsOfFile:srcFile];
    if (!doc)
    {
        [warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to publish ccb-file. File is in invalid format: %@",srcFile] isFatal:NO];
        return YES;
    }
    
    // Export file
    plugIn.flattenPaths = projectSettings.flattenPaths;
    plugIn.projectSettings = projectSettings;
    NSData* data = [plugIn exportDocument:doc];
    if (!data)
    {
        [warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to publish ccb-file: %@",srcFile] isFatal:NO];
        return YES;
    }
    
    // Save file
    BOOL success = [data writeToFile:dstFile atomically:YES];
    if (!success)
    {
        [warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to publish ccb-file. Failed to write file: %@",dstFile] isFatal:NO];
        return YES;
    }
    
    return YES;
}

- (BOOL) copyFileIfChanged:(NSString*)srcFile to:(NSString*)dstFile forResolution:(NSString*)resolution
{
    CocosBuilderAppDelegate* ad = [CocosBuilderAppDelegate appDelegate];
    
    // Add to list of copied files
    NSString* localFileName =[dstFile relativePathFromBaseDirPath:outputDir];
    [publishedResources addObject:localFileName];
    
    // Update progress
    [ad modalStatusWindowUpdateStatusText:[NSString stringWithFormat:@"Publishing %@...", localFileName]];
    
    NSFileManager* fm = [NSFileManager defaultManager];
    
    NSString* srcAutoFile = NULL;
    
    NSString* srcFileName = [srcFile lastPathComponent];
    NSString* dstFileName = [dstFile lastPathComponent];
    NSString* srcDir = [srcFile stringByDeletingLastPathComponent];
    NSString* dstDir = [dstFile stringByDeletingLastPathComponent];
    NSString* autoDir = [srcDir stringByAppendingPathComponent:@"resources-auto"];
    srcAutoFile = [autoDir stringByAppendingPathComponent:srcFileName];
    
    [fm createDirectoryAtPath:dstDir withIntermediateDirectories:YES attributes:NULL error:NULL];
    
    if (resolution && ![resolution isEqualToString:@""])
    {
        // Update path to reflect resolution
        srcDir = [srcDir stringByAppendingPathComponent:[@"resources-" stringByAppendingString:resolution]];
        if (!publishToSingleResolution)
        {
            dstDir = [dstDir stringByAppendingPathComponent:[@"resources-" stringByAppendingString:resolution]];
        }
        
        srcFile = [srcDir stringByAppendingPathComponent:srcFileName];
        dstFile = [dstDir stringByAppendingPathComponent:dstFileName];
    }
    
    if ([dstFile isEqualToString:srcFile])
    {
        [warnings addWarningWithDescription:@"Publish will overwrite file in resource directory." isFatal:YES];
        return NO;
    }
    
    // Check that src file exist
    if (![fm fileExistsAtPath:srcFile])
    {
        if ([fm fileExistsAtPath:srcAutoFile])
        {
            // Copy auto file and resize
            [[ResourceManager sharedManager] createCachedImageFromAuto:srcAutoFile saveAs:dstFile forResolution:resolution];
            return YES;
        }
        else
        {
            return YES;
        }
    }
    
    // Check for equal file
    if (!publishToSingleResolution && [fm fileExistsAtPath:dstFile] && [[CCBFileUtil modificationDateForFile:srcFile] isEqualToDate:[CCBFileUtil modificationDateForFile:dstFile]]) return YES;
    
    // Remove old file
    if ([fm fileExistsAtPath:dstFile])
    {
        [fm removeItemAtPath:dstFile error:NULL];
    }
    
    // Just copy the file and update the modification date
    [fm copyItemAtPath:srcFile toPath:dstFile error:NULL];
    [CCBFileUtil setModificationDate:[CCBFileUtil modificationDateForFile:srcFile] forFile:dstFile];
    
    return YES;
}

- (BOOL) publishDirectory:(NSString*) dir subPath:(NSString*) subPath
{
    //NSLog(@"publishDirectory: %@ subPath: %@", dir, subPath);
    
    CocosBuilderAppDelegate* ad = [CocosBuilderAppDelegate appDelegate];
    ResourceManager* resManager = [ResourceManager sharedManager];
    NSArray* resIndependentDirs = [resManager resIndependentDirs];
    
    NSFileManager* fm = [NSFileManager defaultManager];
    
    // Path to output directory for the currently exported path
    NSString* outDir = NULL;
    if (projectSettings.flattenPaths && projectSettings.publishToZipFile)
    {
        outDir = outputDir;
    }
    else
    {
        outDir = [outputDir stringByAppendingPathComponent:subPath];
    }
    
    // Check for generated sprite sheets
    BOOL isGeneratedSpriteSheet = NO;
    //NSString* spriteSheetDefFile = [dir stringByAppendingPathExtension:@"ccbSpriteSheet"];
    
    //NSLog(@"subPath: %@", subPath);
    if ([projectSettings.generatedSpriteSheets objectForKey:subPath])
    {
        isGeneratedSpriteSheet = YES;
        
        // Clear temporary sprite sheet directory
        [fm removeItemAtPath:[projectSettings tempSpriteSheetCacheDirectory] error:NULL];
    }
    
    // Create the directory if it doesn't exist
    if (!isGeneratedSpriteSheet)
    {
        BOOL createdDirs = [fm createDirectoryAtPath:outDir withIntermediateDirectories:YES attributes:NULL error:NULL];
        if (!createdDirs)
        {
            [warnings addWarningWithDescription:@"Failed to create output directory %@" isFatal:YES];
            return NO;
        }
    }
    
    // Add files from main directory
    NSMutableSet* files = [NSMutableSet setWithArray:[fm contentsOfDirectoryAtPath:dir error:NULL]];
    
    // Add files from resolution depentant directories
    for (NSString* publishExt in publishForResolutions)
    {
        NSString* resolutionDir = [dir stringByAppendingPathComponent:publishExt];
        BOOL isDirectory;
        if ([fm fileExistsAtPath:resolutionDir isDirectory:&isDirectory] && isDirectory)
        {
            [files addObjectsFromArray:[fm contentsOfDirectoryAtPath:resolutionDir error:NULL]];
        }
    }
    
    // Add files from the -auto directory
    NSString* autoDir = [dir stringByAppendingPathComponent:@"resources-auto"];
    BOOL isDirAuto;
    if ([fm fileExistsAtPath:autoDir isDirectory:&isDirAuto] && isDirAuto)
    {
        [files addObjectsFromArray:[fm contentsOfDirectoryAtPath:autoDir error:NULL]];
    }
    
    // Iterate through all files
    for (NSString* fileName in files)
    {
        if ([fileName hasPrefix:@"."]) continue;
        
        NSString* filePath = [dir stringByAppendingPathComponent:fileName];
        
        BOOL isDirectory;
        BOOL fileExists = [fm fileExistsAtPath:filePath isDirectory:&isDirectory];
        if (fileExists && isDirectory)
        {
            NSString* childPath = NULL;
            if (subPath) childPath = [NSString stringWithFormat:@"%@/%@", subPath, fileName];
            else childPath = fileName;
            
            // Skip resource independent directories
            if ([resIndependentDirs containsObject:fileName]) continue;
            
            // Skip generated sprite sheets
            if (isGeneratedSpriteSheet) continue;
            
            [self publishDirectory:filePath subPath:childPath];
        }
        else
        {
            // Publish file
            
            // Copy files
            for (NSString* ext in copyExtensions)
            {
                // Skip non png files for generated sprite sheets
                if (isGeneratedSpriteSheet && ![ext isEqualToString:@"png"]) continue;
                
                if ([[fileName lowercaseString] hasSuffix:ext] && !projectSettings.onlyPublishCCBs)
                {
                    // This file should be copied
                    NSString* dstFile = [outDir stringByAppendingPathComponent:fileName];
                    
                    // Use temp cache directory for generated sprite sheets
                    if (isGeneratedSpriteSheet)
                    {
                        dstFile = [[projectSettings tempSpriteSheetCacheDirectory] stringByAppendingPathComponent:fileName];
                    }
                    
                    if (![self copyFileIfChanged:filePath to:dstFile forResolution:NULL]) return NO;
                    
                    if (publishForResolutions)
                    {
                        for (NSString* res in publishForResolutions)
                        {
                            if (![self copyFileIfChanged:filePath to:dstFile forResolution:res]) return NO;
                        }
                    }
                }
            }
            
            // Publish ccb files
            if ([[fileName lowercaseString] hasSuffix:@"ccb"] && !isGeneratedSpriteSheet)
            {
                NSString* strippedFileName = [fileName stringByDeletingPathExtension];
                
                NSString* dstFile = [[outDir stringByAppendingPathComponent:strippedFileName] stringByAppendingPathExtension:publishFormat];
                
                // Add file to list of published files
                NSString* localFileName = [dstFile relativePathFromBaseDirPath:outputDir];
                [publishedResources addObject:localFileName];
                
                if ([dstFile isEqualToString:filePath])
                {
                    [warnings addWarningWithDescription:@"Publish will overwrite files in resource directory." isFatal:YES];
                    return NO;
                }
                
                if (![fm fileExistsAtPath:dstFile] || [self srcFile:filePath isNewerThanDstFile:dstFile])
                {
                    [ad modalStatusWindowUpdateStatusText:[NSString stringWithFormat:@"Publishing %@...", fileName]];
                    
                    // Remove old file
                    [fm removeItemAtPath:dstFile error:NULL];
                    
                    // Copy the file
                    BOOL sucess = [self publishCCBFile:filePath to:dstFile];
                    if (!sucess) return NO;
                }
            }
        }
    }
    
    if (isGeneratedSpriteSheet)
    {
        // Sprite files should have been saved to the temp cache directory, now actually generate the sprite sheets
        NSString* spriteSheetDir = [outDir stringByDeletingLastPathComponent];
        NSString* spriteSheetName = [outDir lastPathComponent];
        
        for (NSString* res in publishForResolutions)
        {
            NSArray* srcDirs = [NSArray arrayWithObjects:
                                [projectSettings.tempSpriteSheetCacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"resources-%@", res]],
                                projectSettings.tempSpriteSheetCacheDirectory,
                                nil];
            
            NSString* spriteSheetFile = NULL;
            if (publishToSingleResolution) spriteSheetFile = outDir;
            else spriteSheetFile = [[spriteSheetDir stringByAppendingPathComponent:[NSString stringWithFormat:@"resources-%@", res]] stringByAppendingPathComponent:spriteSheetName];
            
            Tupac* packer = [Tupac tupac];
            packer.outputName = spriteSheetFile;
            packer.outputFormat = TupacOutputFormatCocos2D;
            packer.directoryPrefix = subPath;
            packer.border = YES;
            [packer createTextureAtlasFromDirectoryPaths:srcDirs];
        }
    }
    
    return YES;
}

// Currently only checks top level of resource directories
- (BOOL) fileExistInResourcePaths:(NSString*)fileName
{
    for (NSString* dir in projectSettings.absoluteResourcePaths)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[dir stringByAppendingPathComponent:fileName]])
        {
            return YES;
        }
    }
    return NO;
}

- (void) addFilesWithExtension:(NSString*)ext inDirectory:(NSString*)dir toArray:(NSMutableArray*)array subPath:(NSString*)subPath
{
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:NULL];
    for (NSString* file in files)
    {
        if ([[file pathExtension] isEqualToString:ext])
        {
            if (projectSettings.flattenPaths || [subPath isEqualToString:@""])
            {
                [array addObject:file];
            }
            else
            {
                [array addObject:[subPath stringByAppendingPathComponent:file]];
            }
        }
        BOOL isDirectory = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:[dir stringByAppendingPathComponent:file] isDirectory:&isDirectory];
        if (isDirectory)
        {
            NSString* childDir = [dir stringByAppendingPathComponent:file];
            NSString* childSubPath = [subPath stringByAppendingPathComponent:file];
            if ([subPath isEqualToString:@""]) childSubPath = file;
            
            [self addFilesWithExtension:ext inDirectory:childDir toArray:array subPath:childSubPath];
        }
    }
}

- (NSArray*) filesInResourcePathsWithExtension:(NSString*)ext
{
    NSMutableArray* files = [NSMutableArray array];
    
    for (NSString* dir in projectSettings.absoluteResourcePaths)
    {
        [self addFilesWithExtension:ext inDirectory:dir toArray:files subPath:@""];
    }
    
    return files;
}

- (void) publishGeneratedFiles
{
    // Create the directory if it doesn't exist
    BOOL createdDirs = [[NSFileManager defaultManager] createDirectoryAtPath:outputDir withIntermediateDirectories:YES attributes:NULL error:NULL];
    if (!createdDirs)
    {
        [warnings addWarningWithDescription:@"Failed to create output directory %@" isFatal:YES];
        return;
    }
    
    if (targetType == kCCBPublisherTargetTypeJSB)
    {
        // Generate main.js file
        
        if (projectSettings.javascriptBased
            && projectSettings.javascriptMainCCB && ![projectSettings.javascriptMainCCB isEqualToString:@""]
            && ![self fileExistInResourcePaths:@"main.js"])
        {
            // Find all jsFiles
            NSArray* jsFiles = [self filesInResourcePathsWithExtension:@"js"];
            NSString* mainFile = [outputDir stringByAppendingPathComponent:@"main.js"];
            
            // Generate file from template
            CCBPublisherTemplate* tmpl = [CCBPublisherTemplate templateWithFile:@"main-jsb.txt"];
            [tmpl setStrings:jsFiles forMarker:@"REQUIRED_FILES" prefix:@"require(\"" suffix:@"\");\n"];
            [tmpl setString:projectSettings.javascriptMainCCB forMarker:@"MAIN_SCENE"];
            
            [tmpl writeToFile:mainFile];
        }
    }
    else if (targetType == kCCBPublisherTargetTypeHTML5)
    {
        // Generate index.html file
        
        NSString* indexFile = [outputDir stringByAppendingPathComponent:@"index.html"];
        
        CCBPublisherTemplate* tmpl = [CCBPublisherTemplate templateWithFile:@"index-html5.txt"];
        [tmpl setString:[NSString stringWithFormat:@"%d",projectSettings.publishResolutionHTML5_width] forMarker:@"WIDTH"];
        [tmpl setString:[NSString stringWithFormat:@"%d",projectSettings.publishResolutionHTML5_height] forMarker:@"HEIGHT"];
        
        [tmpl writeToFile:indexFile];
        
        // Generate boot-html5.js file
        
        NSString* bootFile = [outputDir stringByAppendingPathComponent:@"boot-html5.js"];
        NSArray* jsFiles = [self filesInResourcePathsWithExtension:@"js"];
        
        tmpl = [CCBPublisherTemplate templateWithFile:@"boot-html5.txt"];
        [tmpl setStrings:jsFiles forMarker:@"REQUIRED_FILES" prefix:@"    '" suffix:@"',\n"];
        
        [tmpl writeToFile:bootFile];
        
        // Generate boot2-html5.js file
        
        NSString* boot2File = [outputDir stringByAppendingPathComponent:@"boot2-html5.js"];
        
        tmpl = [CCBPublisherTemplate templateWithFile:@"boot2-html5.txt"];
        [tmpl setString:projectSettings.javascriptMainCCB forMarker:@"MAIN_SCENE"];
        
        [tmpl writeToFile:boot2File];
        
        // Generate main.js file
        
        NSString* mainFile = [outputDir stringByAppendingPathComponent:@"main.js"];
        
        tmpl = [CCBPublisherTemplate templateWithFile:@"main-html5.txt"];
        [tmpl writeToFile:mainFile];
        
        // Generate resources-html5.js file
        
        NSString* resourceListFile = [outputDir stringByAppendingPathComponent:@"resources-html5.js"];
        
        NSString* resourceListStr = @"var ccb_resources = [\n";
        int resCount = 0;
        for (NSString* res in publishedResources)
        {
            NSString* comma = @",";
            if (resCount == [publishedResources count] -1) comma = @"";
            
            NSString* ext = [[res pathExtension] lowercaseString];
            
            NSString* type = NULL;
            
            if ([ext isEqualToString:@"plist"]) type = @"plist";
            else if ([ext isEqualToString:@"png"]) type = @"image";
            else if ([ext isEqualToString:@"jpg"]) type = @"image";
            else if ([ext isEqualToString:@"jpeg"]) type = @"image";
            else if ([ext isEqualToString:@"mp3"]) type = @"effect";
            else if ([ext isEqualToString:@"ccbi"]) type = @"ccbi";
            else if ([ext isEqualToString:@"fnt"]) type = @"fnt";
            
            if (type)
            {
                resourceListStr = [resourceListStr stringByAppendingFormat:@"    {type:'%@', src:\"%@\"}%@\n", type, res, comma];
            }
        }
        
        resourceListStr = [resourceListStr stringByAppendingString:@"];\n"];
        
        [resourceListStr writeToFile:resourceListFile atomically:YES encoding:NSUTF8StringEncoding error:NULL];
        
        // Copy cocos2d.min.js file
        NSString* cocos2dlibFile = [outputDir stringByAppendingPathComponent:@"cocos2d-html5.min.js"];
        NSString* cocos2dlibFileSrc = [[NSBundle mainBundle] pathForResource:@"cocos2d.min.txt" ofType:@"" inDirectory:@"publishTemplates"];
        [[NSFileManager defaultManager] copyItemAtPath: cocos2dlibFileSrc toPath:cocos2dlibFile error:NULL];
    }
    
}

- (BOOL) publishAllToDirectory:(NSString*)dir
{
    outputDir = dir;
    
    publishedResources = [NSMutableSet set];
    
    // Setup paths for automatically generated sprite sheets
    generatedSpriteSheetDirs = [NSMutableArray array];
    for (NSString* dir in projectSettings.generatedSpriteSheets)
    {
        [generatedSpriteSheetDirs addObject:dir];
    }
    
    // Publish resources and ccb-files
    for (NSString* dir in projectSettings.absoluteResourcePaths)
    {
        if (![self publishDirectory:dir subPath:NULL]) return NO;
    }
    
    //NSLog(@"publishedResources: %@", publishedResources);
    
    // Publish generated files
    [self publishGeneratedFiles];
    
    // Yiee Haa!
    return YES;
}

- (BOOL) publish_
{
    if (!runAfterPublishing)
    {
        // Normal publishing
        
        // iOS
        if (projectSettings.publishEnablediPhone)
        {
            targetType = kCCBPublisherTargetTypeJSB;
            
            NSMutableArray* resolutions = [NSMutableArray array];
            
            // Add iPhone resolutions from publishing settings
            if (projectSettings.publishResolution_hd)
            {
                [resolutions addObject:@"iphonehd"];
                [resolutions addObject:@"ipad"];
                [resolutions addObject:@"iphone"];
            }
            if (projectSettings.publishResolution_ipad)
            {
                [resolutions addObject:@"ipad"];
                [resolutions addObject:@"iphonehd"];
                [resolutions addObject:@"iphone"];
            }
            if (projectSettings.publishResolution_ipadhd)
            {
                [resolutions addObject:@"ipadhd"];
                [resolutions addObject:@"ipad"];
                [resolutions addObject:@"iphonehd"];
            }
            publishForResolutions = resolutions;
            
            publishToSingleResolution = NO;
            
            NSString* publishDir = [projectSettings.publishDirectory absolutePathFromBaseDirPath:[projectSettings.projectPath stringByDeletingLastPathComponent]];
            if (![self publishAllToDirectory:publishDir]) return NO;
        }
        
        // Android
        if (projectSettings.publishEnabledAndroid)
        {
            targetType = kCCBPublisherTargetTypeJSB;
            
            NSMutableArray* resolutions = [NSMutableArray array];
            
            if (projectSettings.publishResolution_xsmall)
            {
                [resolutions addObject:@"xsmall"];
            }
            if (projectSettings.publishResolution_small)
            {
                [resolutions addObject:@"small"];
            }
            if (projectSettings.publishResolution_medium)
            {
                [resolutions addObject:@"medium"];
            }
            if (projectSettings.publishResolution_large)
            {
                [resolutions addObject:@"large"];
            }
            if (projectSettings.publishResolution_xlarge)
            {
                [resolutions addObject:@"xlarge"];
            }
            publishForResolutions = resolutions;
            
            publishToSingleResolution = NO;
            
            NSString* publishDir = [projectSettings.publishDirectoryAndroid absolutePathFromBaseDirPath:[projectSettings.projectPath stringByDeletingLastPathComponent]];
            if (![self publishAllToDirectory:publishDir]) return NO;
        }
        
        // HTML 5
        if (projectSettings.publishEnabledHTML5)
        {
            targetType = kCCBPublisherTargetTypeHTML5;
            
            NSMutableArray* resolutions = [NSMutableArray array];
            [resolutions addObject: @"html5"];
            publishForResolutions = resolutions;
            
            publishToSingleResolution = YES;
            
            NSString* publishDir = [projectSettings.publishDirectoryHTML5 absolutePathFromBaseDirPath:[projectSettings.projectPath stringByDeletingLastPathComponent]];
            if (![self publishAllToDirectory:publishDir]) return NO;
            
        }
    }
    else
    {
        // Publish for running on device
        targetType = kCCBPublisherTargetTypeJSB;
        
        PlayerDeviceInfo* deviceInfo = [PlayerConnection sharedPlayerConnection].selectedDeviceInfo;
        if ([deviceInfo.deviceType isEqualToString:@"iPad"])
        {
            // iPad
            if (deviceInfo.hasRetinaDisplay)
            {
                // iPad retina
                publishForResolutions = [NSArray arrayWithObjects:@"ipadhd", nil];
            }
            else
            {
                // iPad normal
                publishForResolutions = [NSArray arrayWithObjects:@"ipad", @"hd", nil];
            }
        }
        else
        {
            // iPhone
            if (deviceInfo.hasRetinaDisplay)
            {
                publishForResolutions = [NSArray arrayWithObjects:@"iphonehd", nil];
            }
            else
            {
                publishForResolutions = NULL;
            }
        }
        
        if (![self publishAllToDirectory:projectSettings.publishCacheDirectory]) return NO;
        
        // Zip up and push
        CocosBuilderAppDelegate* ad = [CocosBuilderAppDelegate appDelegate];
        [ad modalStatusWindowUpdateStatusText:@"Zipping up project..."];
        
        NSString* zipFile = [projectSettings.publishCacheDirectory stringByAppendingPathComponent:@"ccb.zip"];
        
        // Remove the old file
        [[NSFileManager defaultManager] removeItemAtPath:zipFile error:NULL];
        
        // Zip it up!
        NSTask* zipTask = [[NSTask alloc] init];
        [zipTask setCurrentDirectoryPath:outputDir];
        [zipTask setLaunchPath:@"/usr/bin/zip"];
        NSArray* args = [NSArray arrayWithObjects:@"-r", @"-q", zipFile, @".", @"-i", @"*", nil];
        [zipTask setArguments:args];
        [zipTask launch];
        [zipTask waitUntilExit];
        [zipTask release];
        
        // Send to player
        [ad modalStatusWindowUpdateStatusText:@"Sending to player..."];
        
        PlayerConnection* conn = [PlayerConnection sharedPlayerConnection];
        [conn sendResourceZip:zipFile];
    }
    
    return YES;
}

- (void) publish
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self publish_];
        dispatch_sync(dispatch_get_main_queue(), ^{
            CocosBuilderAppDelegate* ad = [CocosBuilderAppDelegate appDelegate];
            [ad publisher:self finishedWithWarnings:warnings];
        });
    });
    
}

+ (void) cleanAllCacheDirectories
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* ccbChacheDir = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"com.cocosbuilder.CocosBuilder"];
    [[NSFileManager defaultManager] removeItemAtPath:ccbChacheDir error:NULL];
}

- (void) dealloc
{
    [copyExtensions release];
    [warnings release];
    [projectSettings release];
    [super dealloc];
}

@end
