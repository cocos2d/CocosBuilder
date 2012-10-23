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
    
    // Setup base output directory
    if (projectSettings.publishToZipFile)
    {
        outputDir = [projectSettings.publishCacheDirectory retain];
    }
    else
    {
        outputDir = [[projectSettings.publishDirectory absolutePathFromBaseDirPath:[projectSettings.projectPath stringByDeletingLastPathComponent]] retain];
    }
    
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

- (void) clearResourceLog
{
    NSString* logPath = [[projectSettings.projectPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"ccbresourcelog"];
    [@"" writeToFile:logPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}

- (void) writeToResourceLogSubPath: (NSString*) subpath file:(NSString*)file
{
    NSString* logPath = [[projectSettings.projectPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"ccbresourcelog"];
    
    NSString* str = NULL;
    if (subpath && !projectSettings.flattenPaths)
    {
        str = [subpath stringByAppendingPathComponent:file];
    }
    else
    {
        str = file;
    }
    str = [str stringByAppendingString:@"\n"];
    
    [str appendToFile:logPath usingEncoding:NSUTF8StringEncoding];
}

- (BOOL) publishDirectory:(NSString*) dir subPath:(NSString*) subPath
{
    CocosBuilderAppDelegate* ad = [CocosBuilderAppDelegate appDelegate];
    
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
    
    // Create the directory if it doesn't exist
    BOOL createdDirs = [fm createDirectoryAtPath:outDir withIntermediateDirectories:YES attributes:NULL error:NULL];
    if (!createdDirs)
    {
        [warnings addWarningWithDescription:@"Failed to create output directory %@" isFatal:YES];
        return NO;
    }
    
    NSArray* files = [fm contentsOfDirectoryAtPath:dir error:NULL];
    
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
            
            [self publishDirectory:filePath subPath:childPath];
        }
        else if (fileExists)
        {
            // Publish file
            
            // Copy files
            for (NSString* ext in copyExtensions)
            {
                if ([[fileName lowercaseString] hasSuffix:ext])
                {
                    // This file should be copied
                    NSString* dstFile = [outDir stringByAppendingPathComponent:fileName];
                    [self writeToResourceLogSubPath:subPath file:fileName];
                    
                    // Igore resource copies if setting is only publish ccb-files
                    if (!projectSettings.onlyPublishCCBs)
                    {
                        if ([dstFile isEqualToString:filePath])
                        {
                            [warnings addWarningWithDescription:@"Publish will overwrite file in resource directory." isFatal:YES];
                            return NO;
                        }
                    
                        if (![fm fileExistsAtPath:dstFile] || [self srcFile:filePath isNewerThanDstFile:dstFile])
                        {
                            [ad modalStatusWindowUpdateStatusText:[NSString stringWithFormat:@"Copying %@...", fileName]];
                        
                            // Remove old file
                            [fm removeItemAtPath:dstFile error:NULL];
                        
                            // Copy the file
                            BOOL sucess = [fm copyItemAtPath:filePath toPath:dstFile error:NULL];
                            if (!sucess) [warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to publish file: %@", fileName]];
                        }
                    }
                }
            }
            
            // Publish ccb files
            if ([[fileName lowercaseString] hasSuffix:@"ccb"])
            {
                NSString* strippedFileName = [fileName stringByDeletingPathExtension];
                
                NSString* dstFile = [[outDir stringByAppendingPathComponent:strippedFileName] stringByAppendingPathExtension:publishFormat];
                [self writeToResourceLogSubPath:subPath file:[strippedFileName stringByAppendingPathExtension:publishFormat]];
                
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
    
    // Generate main.js file
    if (projectSettings.javascriptBased
        && projectSettings.javascriptMainCCB && ![projectSettings.javascriptMainCCB isEqualToString:@""]
        && ![self fileExistInResourcePaths:@"main.js"])
    {
        // Find all jsFiles
        NSArray* jsFiles = [self filesInResourcePathsWithExtension:@"js"];
        
        NSMutableString* main = [NSMutableString string];
        
        
        [main appendString:@"// Autogenerated main.js file\n\n"];
        
        [main appendString:@"require(\"jsb_constants.js\");\n"];
        for (NSString* jsFile in jsFiles)
        {
            [main appendFormat:@"require(\"%@\");\n",jsFile];
        }
        
        [main appendString:@"\nfunction main()\n"];
        [main appendString:@"{\n"];
        [main appendFormat:@"\tvar scene = cc.Reader.loadAsScene(\"%@\");\n",projectSettings.javascriptMainCCB];
        [main appendString:@"\tvar director = cc.Director.getInstance();\n"];
        [main appendString:@"\tvar runningScene = director.getRunningScene();\n"];
        [main appendString:@"\tif (runningScene === null) director.runWithScene(scene);\n"];
        [main appendString:@"\telse director.replaceScene(scene);\n"];
        [main appendString:@"}\n\n"];
        [main appendString:@"main();\n"];
        
        NSLog(@"main.js:\n%@", main);
        
        NSData* mainData = [main dataUsingEncoding:NSUTF8StringEncoding];
        NSString* mainFile = [outputDir stringByAppendingPathComponent:@"main.js"];
        
        [mainData writeToFile:mainFile atomically:YES];
    }
}

- (BOOL) publish_
{
    CocosBuilderAppDelegate* ad = [CocosBuilderAppDelegate appDelegate];
    
    [self publishGeneratedFiles];
    for (NSString* dir in projectSettings.absoluteResourcePaths)
    {
        if (![self publishDirectory:dir subPath:NULL]) return NO;
    }
    
    if (runAfterPublishing && !projectSettings.publishToZipFile)
    {
        // We also need to publish to the temp directory
        outputDir = projectSettings.publishCacheDirectory;
        [self publishGeneratedFiles];
        for (NSString* dir in projectSettings.absoluteResourcePaths)
        {
            if (![self publishDirectory:dir subPath:NULL]) return NO;
        }
    }
    
    if (projectSettings.publishToZipFile || runAfterPublishing)
    {
        [ad modalStatusWindowUpdateStatusText:@"Zipping up project..."];
        
        NSString* zipFile = NULL;
        if (runAfterPublishing)
        {
            zipFile = [projectSettings.publishCacheDirectory stringByAppendingPathComponent:@"ccb.zip"];
        }
        else
        {
            zipFile = [[projectSettings.publishDirectory absolutePathFromBaseDirPath:[projectSettings.projectPath stringByDeletingLastPathComponent]] stringByAppendingPathComponent:@"ccb.zip"];
        }
        
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
        
        if (runAfterPublishing)
        {
            [ad modalStatusWindowUpdateStatusText:@"Sending to player..."];
            
            // Send to player
            PlayerConnection* conn = [PlayerConnection sharedPlayerConnection];
            [conn sendResourceZip:zipFile];
        }
    }
    
    return YES;
}

- (void) publish
{
    [self clearResourceLog];
    
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
    [outputDir release];
    [super dealloc];
}

@end
