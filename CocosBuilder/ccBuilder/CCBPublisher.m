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
#import "CCBDirectoryComparer.h"
#import "ResourceManager.h"
#import "ResourceManagerUtil.h"

@implementation CCBPublisher

@synthesize publishFormat;
@synthesize runAfterPublishing;
@synthesize browser;

- (id) initWithProjectSettings:(ProjectSettings*)settings warnings:(CCBWarnings*)w
{
    self = [super init];
    if (!self) return NULL;
    
    // Save settings and warning log
    projectSettings = [settings retain];
    warnings = [w retain];
    
    // Setup extensions to copy
    copyExtensions = [[NSArray alloc] initWithObjects:@"jpg",@"png", @"pvr", @"ccz", @"plist", @"fnt", @"ttf",@"js", @"json", @"wav",@"mp3",@"m4a",@"caf", nil];
    
    // Set format to use for exports
    self.publishFormat = projectSettings.exporter;
    
    return self;
}

- (NSDate*) latestModifiedDateForDirectory:(NSString*) dir
{
    NSDate* latestDate = [CCBFileUtil modificationDateForFile:dir];
    
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:NULL];
    for (NSString* file in files)
    {
        NSString* absFile = [dir stringByAppendingPathComponent:file];
        
        BOOL isDir = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:absFile isDirectory:&isDir])
        {
            NSDate* fileDate = NULL;
            
            if (isDir)
            {
                fileDate = [self latestModifiedDateForDirectory:absFile];
            }
            else
            {
                fileDate = [CCBFileUtil modificationDateForFile:absFile];
            }
            
            if ([fileDate compare:latestDate] == NSOrderedDescending)
            {
                latestDate = fileDate;
            }
        }
    }
    
    return latestDate;
}

- (void) addRenamingRuleFrom:(NSString*)src to: (NSString*)dst
{
    if (projectSettings.flattenPaths)
    {
        src = [src lastPathComponent];
        dst = [dst lastPathComponent];
    }
    
    if ([src isEqualToString:dst]) return;
    
    // Add the file to the dictionary
    [renamedFiles setObject:dst forKey:src];
}

/*
- (BOOL) srcFile:(NSString*)srcFile isNewerThanDstFile:(NSString*)dstFile
{
    NSDictionary* srcAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:srcFile error:NULL];
    NSDate* srcDate = [srcAttributes objectForKey:NSFileModificationDate];
    
    NSDictionary* dstAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:dstFile error:NULL];
    NSDate* dstDate = [dstAttributes objectForKey:NSFileModificationDate];
    
    if (!srcDate || !dstDate) return YES;
    if ([srcDate compare:dstDate] == NSOrderedDescending) return YES;
    
    return NO;
}*/

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

- (BOOL) copyFileIfChanged:(NSString*)srcFile to:(NSString*)dstFile forResolution:(NSString*)resolution isSpriteSheet:(BOOL)isSpriteSheet outDir: (NSString*)outDir srcDate: (NSDate*) srcDate
{
    CocosBuilderAppDelegate* ad = [CocosBuilderAppDelegate appDelegate];
    
    // Add to list of copied files
    NSString* localFileName =[dstFile relativePathFromBaseDirPath:outputDir];
    
    if (isSpriteSheet)
    {
        // Skip sprite sheets that are already published
        NSString* spriteSheetDir = [outDir stringByDeletingLastPathComponent];
        NSString* spriteSheetName = [outDir lastPathComponent];
        
        NSString *subPath = [[ResourceManagerUtil relativePathFromAbsolutePath:srcFile] stringByDeletingLastPathComponent];
        
        ProjectSettingsGeneratedSpriteSheet* ssSettings = [projectSettings smartSpriteSheetForSubPath:subPath];

        NSString* spriteSheetFile = NULL;
        if (publishToSingleResolution) spriteSheetFile = outDir;
        else spriteSheetFile = [[spriteSheetDir stringByAppendingPathComponent:[NSString stringWithFormat:@"resources-%@", resolution]] stringByAppendingPathComponent:spriteSheetName];
        
        NSDate* dstDate = [CCBFileUtil modificationDateForFile:[spriteSheetFile stringByAppendingPathExtension:@"plist"]];
        if (dstDate && [dstDate isEqualToDate:srcDate] && !ssSettings.isDirty)
        {
            return YES;
        }
    }
    else
    {
        // Add the file name to published resource list
        [publishedResources addObject:localFileName];
    }
    
    // Update progress
    [ad modalStatusWindowUpdateStatusText:[NSString stringWithFormat:@"Publishing %@...", [dstFile lastPathComponent]]];
    
    // Find out which file to copy for the current resolution
    NSFileManager* fm = [NSFileManager defaultManager];
    
    NSString* srcAutoFile = NULL;
    
    NSString* srcFileName = [srcFile lastPathComponent];
    NSString* dstFileName = [dstFile lastPathComponent];
    NSString* srcDir = [srcFile stringByDeletingLastPathComponent];
    NSString* dstDir = [dstFile stringByDeletingLastPathComponent];
    NSString* autoDir = [srcDir stringByAppendingPathComponent:@"resources-auto"];
    srcAutoFile = [autoDir stringByAppendingPathComponent:srcFileName];
    
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
    
    [fm createDirectoryAtPath:dstDir withIntermediateDirectories:YES attributes:NULL error:NULL];
    
    if ([dstFile isEqualToString:srcFile])
    {
        [warnings addWarningWithDescription:@"Publish will overwrite file in resource directory." isFatal:YES];
        return NO;
    }
    
    // Copy auto-sized images
    if (![fm fileExistsAtPath:srcFile])
    {
        if ([fm fileExistsAtPath:srcAutoFile] && resolution != NULL)
        {
            // Check if resized image already exists
            NSDate* srcDate = [CCBFileUtil modificationDateForFile:srcAutoFile];
            NSDate* dstDate = [CCBFileUtil modificationDateForFile:dstFile];
            if ([srcDate isEqualToDate:dstDate]) return YES;
            
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
    if (/*!publishToSingleResolution && */[fm fileExistsAtPath:dstFile] && [[CCBFileUtil modificationDateForFile:srcFile] isEqualToDate:[CCBFileUtil modificationDateForFile:dstFile]]) return YES;
    
    // Remove old file
    if ([fm fileExistsAtPath:dstFile])
    {
        [fm removeItemAtPath:dstFile error:NULL];
    }
    
    // Check if file should be converted
    NSString* srcExt = [[srcFile pathExtension] lowercaseString];
    NSString* dstExt = [[dstFile pathExtension] lowercaseString];
    if ([srcExt isEqualToString:dstExt])
    {
        // Just copy the file and update the modification date
        [fm copyItemAtPath:srcFile toPath:dstFile error:NULL];
    }
    else if ([srcExt isEqualToString:@"wav"])
    {
        // TODO: Also convert to m4a/mp3 and possibly other formats, also make custom settings
        if ([dstExt isEqualToString:@"caf"])
        {
            // Convert wav to caf
            NSTask* convTask = [[NSTask alloc] init];
            [convTask setCurrentDirectoryPath:[srcFile stringByDeletingLastPathComponent]];
            
            [convTask setLaunchPath:@"/usr/bin/afconvert"];
            NSArray* args = [NSArray arrayWithObjects:@"-f", @"caff", @"-d", @"LEI16@44100", @"-c", @"1", srcFile, dstFile, nil];
            [convTask setArguments:args];
            [convTask launch];
            [convTask waitUntilExit];
            [convTask release];
        }
        else if ([dstExt isEqualToString:@"mp3"])
        {
            // Convert to mp3
            NSTask* convTask = [[NSTask alloc] init];
            [convTask setCurrentDirectoryPath:[srcFile stringByDeletingLastPathComponent]];
            [convTask setLaunchPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"lame"]];
            NSMutableArray* args = [NSMutableArray arrayWithObjects:
                                    @"-V2", srcFile, dstFile,
                                    nil];
            [convTask setArguments:args];
            [convTask setStandardOutput:[NSFileHandle fileHandleWithNullDevice]];
            [convTask setStandardError:[NSFileHandle fileHandleWithNullDevice]];
            [convTask launch];
            [convTask waitUntilExit];
            [convTask release];
        }
        else if ([dstExt isEqualToString:@"ogg"])
        {
            // Convert to ogg
            NSTask* convTask = [[NSTask alloc] init];
            [convTask setCurrentDirectoryPath:[srcFile stringByDeletingLastPathComponent]];
            [convTask setLaunchPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"oggenc"]];
            NSMutableArray* args = [NSMutableArray arrayWithObjects:
                                    @"-q3", @"-o", dstFile, srcFile,
                                    nil];
            [convTask setArguments:args];
            [convTask launch];
            [convTask waitUntilExit];
            [convTask release];
        }
    }
    
    [CCBFileUtil setModificationDate:[CCBFileUtil modificationDateForFile:srcFile] forFile:dstFile];
    
    return YES;
}

- (BOOL) publishDirectory:(NSString*) dir subPath:(NSString*) subPath
{
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
    NSDate* srcSpriteSheetDate = NULL;
    
    if ([projectSettings.generatedSpriteSheets objectForKey:subPath])
    {
        isGeneratedSpriteSheet = YES;
        srcSpriteSheetDate = [self latestModifiedDateForDirectory:dir];
        
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
            
            // Skip the empty folder
            if ([[fm contentsOfDirectoryAtPath:filePath error:NULL] count] == 0)  continue;
            
            // Skip the fold no .ccb files when onlyPublishCCBs is true
            if(projectSettings.onlyPublishCCBs && ![self containsCCBFile:filePath]) continue;
            
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
                    
                    // Make conversion rules for audio
                    NSString* newFormat = NULL;
                    
                    if ([ext isEqualToString:@"wav"])
                    {
                        if (targetType == kCCBPublisherTargetTypeIPhone)
                        {
                            newFormat = @"caf";
                        }
                        else if (targetType == kCCBPublisherTargetTypeHTML5)
                        {
                            newFormat = @"mp3";
                        }
                        else if (targetType == kCCBPublisherTargetTypeAndroid)
                        {
                            newFormat = @"ogg";
                        }
                    }
                    /*
                    else if ([ext isEqualToString:@"mp3"])
                    {
                        if (targetType == kCCBPublisherTargetTypeAndroid)
                        {
                            newFormat = @"ogg";
                        }
                    }
                     */
                
                    if (newFormat)
                    {
                        // Set new name
                        dstFile = [[dstFile stringByDeletingPathExtension] stringByAppendingPathExtension:newFormat];
                        
                        // Add to conversion table
                        NSString* localName = fileName;
                        if (subPath) localName = [subPath stringByAppendingPathComponent:fileName];
                        
                        [self addRenamingRuleFrom:localName to:[[localName stringByDeletingPathExtension] stringByAppendingPathExtension:newFormat]];
                    }
                
                    // Copy file (and possibly convert)
                    if (![self copyFileIfChanged:filePath to:dstFile forResolution:NULL isSpriteSheet:isGeneratedSpriteSheet outDir:outDir srcDate: srcSpriteSheetDate]) return NO;
                    
                    if (publishForResolutions)
                    {
                        for (NSString* res in publishForResolutions)
                        {
                            if (![self copyFileIfChanged:filePath to:dstFile forResolution:res isSpriteSheet:isGeneratedSpriteSheet outDir:outDir srcDate: srcSpriteSheetDate]) return NO;
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
                
                NSDate* srcDate = [CCBFileUtil modificationDateForFile:filePath];
                NSDate* dstDate = [CCBFileUtil modificationDateForFile:dstFile];
                
                //if (![fm fileExistsAtPath:dstFile] || [self srcFile:filePath isNewerThanDstFile:dstFile])
                if (![srcDate isEqualToDate:dstDate])
                {
                    [ad modalStatusWindowUpdateStatusText:[NSString stringWithFormat:@"Publishing %@...", fileName]];
                    
                    // Remove old file
                    [fm removeItemAtPath:dstFile error:NULL];
                    
                    // Copy the file
                    BOOL sucess = [self publishCCBFile:filePath to:dstFile];
                    if (!sucess) return NO;
                    
                    [CCBFileUtil setModificationDate:srcDate forFile:dstFile];
                }
            }
        }
    }
    
    if (isGeneratedSpriteSheet)
    {
        // Sprite files should have been saved to the temp cache directory, now actually generate the sprite sheets
        NSString* spriteSheetDir = [outDir stringByDeletingLastPathComponent];
        NSString* spriteSheetName = [outDir lastPathComponent];
        ProjectSettingsGeneratedSpriteSheet* ssSettings = [projectSettings smartSpriteSheetForSubPath:subPath];

        // Check if sprite sheet needs to be re-published
        for (NSString* res in publishForResolutions)
        {
            NSArray* srcDirs = [NSArray arrayWithObjects:
                                [projectSettings.tempSpriteSheetCacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"resources-%@", res]],
                                projectSettings.tempSpriteSheetCacheDirectory,
                                nil];
            
            NSString* spriteSheetFile = NULL;
            if (publishToSingleResolution) spriteSheetFile = outDir;
            else spriteSheetFile = [[spriteSheetDir stringByAppendingPathComponent:[NSString stringWithFormat:@"resources-%@", res]] stringByAppendingPathComponent:spriteSheetName];
            
            // Skip publish if sprite sheet exists and is up to date
            NSDate* dstDate = [CCBFileUtil modificationDateForFile:[spriteSheetFile stringByAppendingPathExtension:@"plist"]];
            if (dstDate && [dstDate isEqualToDate:srcSpriteSheetDate] && !ssSettings.isDirty)
            {
                continue;
            }
                        
            Tupac* packer = [Tupac tupac];
            packer.outputName = spriteSheetFile;
            packer.outputFormat = TupacOutputFormatCocos2D;
            
            if (targetType == kCCBPublisherTargetTypeIPhone)
            {
                packer.imageFormat = ssSettings.textureFileFormat;
                packer.compress = ssSettings.compress;
                packer.dither = ssSettings.dither;
            }
            else if (targetType == kCCBPublisherTargetTypeAndroid)
            {
                packer.imageFormat = ssSettings.textureFileFormatAndroid;
                packer.compress = NO;
                packer.dither = ssSettings.ditherAndroid;
            }
            else if (targetType == kCCBPublisherTargetTypeHTML5)
            {
                packer.imageFormat = ssSettings.textureFileFormatHTML5;
                packer.compress = NO;
                packer.dither = ssSettings.ditherHTML5;
            }
            
            // Update progress
            [ad modalStatusWindowUpdateStatusText:[NSString stringWithFormat:@"Generating sprite sheet %@...", [[subPath stringByAppendingPathExtension:@"plist"] lastPathComponent]]];
            
            // Pack texture
            packer.directoryPrefix = subPath;
            packer.border = YES;
            [packer createTextureAtlasFromDirectoryPaths:srcDirs];
            
            // Set correct modification date
            [CCBFileUtil setModificationDate:srcSpriteSheetDate forFile:[spriteSheetFile stringByAppendingPathExtension:@"plist"]];
        }
        
        [publishedResources addObject:[subPath stringByAppendingPathExtension:@"plist"]];
        [publishedResources addObject:[subPath stringByAppendingPathExtension:@"png"]];
        
        if (ssSettings.isDirty) {
            ssSettings.isDirty = NO;
            [projectSettings store];
        }
    }
    
    return YES;
}

- (BOOL) containsCCBFile:(NSString*) dir
{
    NSFileManager* fm = [NSFileManager defaultManager];
    ResourceManager* resManager = [ResourceManager sharedManager];
    NSArray* files = [fm contentsOfDirectoryAtPath:dir error:NULL];
    NSArray* resIndependentDirs = [resManager resIndependentDirs];
    
    for (NSString* file in files) {
        BOOL isDirectory;
        NSString* filePath = [dir stringByAppendingPathComponent:file];
        
        if([fm fileExistsAtPath:filePath isDirectory:&isDirectory]){
            if(isDirectory){
                // Skip resource independent directories
                if ([resIndependentDirs containsObject:file]) {
                    continue;
                }else if([self containsCCBFile:filePath]){
                    return YES;
                }
            }else{
                if([[file lowercaseString] hasSuffix:@"ccb"]){
                    return YES;
                }
            }
        }
    }
    return NO;
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

/*
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
}*/

- (void) publishGeneratedFiles
{
    // Create the directory if it doesn't exist
    BOOL createdDirs = [[NSFileManager defaultManager] createDirectoryAtPath:outputDir withIntermediateDirectories:YES attributes:NULL error:NULL];
    if (!createdDirs)
    {
        [warnings addWarningWithDescription:@"Failed to create output directory %@" isFatal:YES];
        return;
    }
    
    if (targetType == kCCBPublisherTargetTypeIPhone || targetType == kCCBPublisherTargetTypeAndroid)
    {
        // Generate main.js file
        
        if (projectSettings.javascriptBased
            && projectSettings.javascriptMainCCB && ![projectSettings.javascriptMainCCB isEqualToString:@""]
            && ![self fileExistInResourcePaths:@"main.js"])
        {
            // Find all jsFiles
            NSArray* jsFiles = [CCBFileUtil filesInResourcePathsWithExtension:@"js"];
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
        NSArray* jsFiles = [CCBFileUtil filesInResourcePathsWithExtension:@"js"];
        
        tmpl = [CCBPublisherTemplate templateWithFile:@"boot-html5.txt"];
        [tmpl setStrings:jsFiles forMarker:@"REQUIRED_FILES" prefix:@"    '" suffix:@"',\n"];
        
        [tmpl writeToFile:bootFile];
        
        // Generate boot2-html5.js file
        
        NSString* boot2File = [outputDir stringByAppendingPathComponent:@"boot2-html5.js"];
        
        tmpl = [CCBPublisherTemplate templateWithFile:@"boot2-html5.txt"];
        [tmpl setString:projectSettings.javascriptMainCCB forMarker:@"MAIN_SCENE"];
        [tmpl setString:[NSString stringWithFormat:@"%d", projectSettings.publishResolutionHTML5_scale] forMarker:@"RESOLUTION_SCALE"];
        
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
            else if ([ext isEqualToString:@"mp3"]) type = @"sound";
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
    
    // Generate file lookup
    NSMutableDictionary* fileLookup = [NSMutableDictionary dictionary];
    
    NSMutableDictionary* metadata = [NSMutableDictionary dictionary];
    [metadata setObject:[NSNumber numberWithInt:1] forKey:@"version"];
    
    [fileLookup setObject:metadata forKey:@"metadata"];
    [fileLookup setObject:renamedFiles forKey:@"filenames"];
    
    NSString* lookupFile = [outputDir stringByAppendingPathComponent:@"fileLookup.plist"];
    
    [fileLookup writeToFile:lookupFile atomically:YES];
}

- (BOOL) publishAllToDirectory:(NSString*)dir
{
    outputDir = dir;
    
    publishedResources = [NSMutableSet set];
    renamedFiles = [NSMutableDictionary dictionary];
    
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
    
    // Publish generated files
    [self publishGeneratedFiles];
    
    // Yiee Haa!
    return YES;
}

- (BOOL) archiveToFile:(NSString*)file
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // Remove the old file
    [manager removeItemAtPath:file error:NULL];
    
    // Zip it up!
    NSTask* zipTask = [[NSTask alloc] init];
    [zipTask setCurrentDirectoryPath:outputDir];
    
    [zipTask setLaunchPath:@"/usr/bin/zip"];
    NSArray* args = [NSArray arrayWithObjects:@"-r", @"-q", file, @".", @"-i", @"*", nil];
    [zipTask setArguments:args];
    [zipTask launch];
    [zipTask waitUntilExit];
    [zipTask release];
    
    return [manager fileExistsAtPath:file];
}

- (BOOL) archiveToFile:(NSString*)file diffFrom:(NSDictionary*) diffFiles
{
    if (!diffFiles) diffFiles = [NSDictionary dictionary];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // Remove the old file
    [manager removeItemAtPath:file error:NULL];
    
    // Create diff
    CCBDirectoryComparer* dc = [[[CCBDirectoryComparer alloc] init] autorelease];
    [dc loadDirectory:outputDir];
    NSArray* fileList = [dc diffWithFiles:diffFiles];
    
    // Zip it up!
    NSTask* zipTask = [[NSTask alloc] init];
    [zipTask setCurrentDirectoryPath:outputDir];
    
    [zipTask setLaunchPath:@"/usr/bin/zip"];
    NSMutableArray* args = [NSMutableArray arrayWithObjects:@"-r", @"-q", file, @".", @"-i", nil];
    
    for (NSString* f in fileList)
    {
        [args addObject:f];
    }
    
    [zipTask setArguments:args];
    [zipTask launch];
    [zipTask waitUntilExit];
    [zipTask release];
    
    return [manager fileExistsAtPath:file];
}

- (BOOL) publish_
{
    // Remove all old publish directories if user has cleaned the cache
    if (projectSettings.needRepublish)
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString* publishDir;
        
        publishDir = [projectSettings.publishDirectory absolutePathFromBaseDirPath:[projectSettings.projectPath stringByDeletingLastPathComponent]];
        [fm removeItemAtPath:publishDir error:NULL];
        
        publishDir = [projectSettings.publishDirectoryAndroid absolutePathFromBaseDirPath:[projectSettings.projectPath stringByDeletingLastPathComponent]];
        [fm removeItemAtPath:publishDir error:NULL];
        
        publishDir = [projectSettings.publishDirectoryHTML5 absolutePathFromBaseDirPath:[projectSettings.projectPath stringByDeletingLastPathComponent]];
        [fm removeItemAtPath:publishDir error:NULL];
    }
    
    if (!runAfterPublishing)
    {
        // Normal publishing
        
        // iOS
        if (projectSettings.publishEnablediPhone)
        {
            targetType = kCCBPublisherTargetTypeIPhone;
            
            NSMutableArray* resolutions = [NSMutableArray array];
            
            // Add iPhone resolutions from publishing settings
            if (projectSettings.publishResolution_)
            {
                [resolutions addObject:@"iphone"];
            }
            if (projectSettings.publishResolution_hd)
            {
                [resolutions addObject:@"iphonehd"];
            }
            if (projectSettings.publishResolution_ipad)
            {
                [resolutions addObject:@"ipad"];
            }
            if (projectSettings.publishResolution_ipadhd)
            {
                [resolutions addObject:@"ipadhd"];
            }
            publishForResolutions = resolutions;
            
            publishToSingleResolution = NO;
            
            NSString* publishDir = [projectSettings.publishDirectory absolutePathFromBaseDirPath:[projectSettings.projectPath stringByDeletingLastPathComponent]];
            
            if (projectSettings.publishToZipFile)
            {
                // Publish archive
                NSString *zipFile = [publishDir stringByAppendingPathComponent:@"ccb.zip"];
                
                if (![self publishAllToDirectory:projectSettings.publishCacheDirectory] || ![self archiveToFile:zipFile]) return NO;
            } else
            {
                // Publish files
                if (![self publishAllToDirectory:publishDir]) return NO;
            }
        }
        
        // Android
        if (projectSettings.publishEnabledAndroid)
        {
            targetType = kCCBPublisherTargetTypeAndroid;
            
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
            
            if (projectSettings.publishToZipFile)
            {
                // Publish archive
                NSString *zipFile = [publishDir stringByAppendingPathComponent:@"ccb.zip"];
                
                if (![self publishAllToDirectory:projectSettings.publishCacheDirectory] || ![self archiveToFile:zipFile]) return NO;
            } else
            {
                // Publish files
                if (![self publishAllToDirectory:publishDir]) return NO;
            }
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
            
            if (projectSettings.publishToZipFile)
            {
                // Publish archive
                NSString *zipFile = [publishDir stringByAppendingPathComponent:@"ccb.zip"];
                
                if (![self publishAllToDirectory:projectSettings.publishCacheDirectory] || ![self archiveToFile:zipFile]) return NO;
            } else
            {
                // Publish files
                if (![self publishAllToDirectory:publishDir]) return NO;
            }
        }
        
    }
    else
    {
        if (browser)
        {
            // Publish for running in browser
            targetType = kCCBPublisherTargetTypeHTML5;
            
            NSMutableArray* resolutions = [NSMutableArray array];
            [resolutions addObject: @"html5"];
            publishForResolutions = resolutions;
            
            publishToSingleResolution = YES;
            
            NSString* publishDir = [projectSettings.publishDirectoryHTML5 absolutePathFromBaseDirPath:[projectSettings.projectPath stringByDeletingLastPathComponent]];
            
            if (![self publishAllToDirectory:publishDir]) return NO;
        }
        else
        {
            // Publish for running on device
            targetType = kCCBPublisherTargetTypeIPhone;
            
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
            else if ([deviceInfo.deviceType isEqualToString:@"iPhone"])
            {
                // iPhone
                if (deviceInfo.hasRetinaDisplay)
                {
                    publishForResolutions = [NSArray arrayWithObjects:@"iphonehd", nil];
                }
                else
                {
                    publishForResolutions = [NSArray arrayWithObjects:@"iphone", nil];
                }
            }
            else if ([deviceInfo.deviceType isEqualToString:@"Android"])
            {
                targetType = kCCBPublisherTargetTypeAndroid;
                
                publishForResolutions = [NSArray arrayWithObjects:deviceInfo.preferredResourceType, nil];
            }
            
            if (![self publishAllToDirectory:projectSettings.publishCacheDirectory]) return NO;
            
            // Zip up and push
            CocosBuilderAppDelegate* ad = [CocosBuilderAppDelegate appDelegate];
            [ad modalStatusWindowUpdateStatusText:@"Zipping up project..."];
            
            // Archive
            NSString *zipFile = [projectSettings.publishCacheDirectory stringByAppendingPathComponent:@"ccb.zip"];
            [self archiveToFile:zipFile diffFrom:deviceInfo.fileList];
            // TODO: Fix diffFrom
            
            // Send to player
            [ad modalStatusWindowUpdateStatusText:@"Sending to player..."];
            
            PlayerConnection* conn = [PlayerConnection sharedPlayerConnection];
            [conn sendResourceZip:zipFile];
        }
    }
    
    // Once published, set needRepublish back to NO
    if (projectSettings.needRepublish)
    {
        projectSettings.needRepublish = NO;
        [projectSettings store];
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
