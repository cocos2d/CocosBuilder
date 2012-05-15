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

@implementation CCBPublisher

@synthesize publishFormat;

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
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSLog(@"paths: %@", paths);
        outputDir = [[[[paths objectAtIndex:0] stringByAppendingPathComponent:@"com.cocosbuilder.CocosBuilder"] stringByAppendingPathComponent:@"publish"]stringByAppendingPathComponent:projectSettings.projectPathHashed];
        
        outputDir = [outputDir retain]; // TODO: Create temp directory
        
        NSLog(@"outputDir: %@", outputDir);
    }
    else
    {
        outputDir = [[projectSettings.publishDirectory absolutePathFromBaseDirPath:[projectSettings.projectPath stringByDeletingLastPathComponent]] retain];
    }
    
    // Setup extensions to copy
    copyExtensions = [[NSArray alloc] initWithObjects:@"jpg",@"png", @"pvr", @"ccz", @"plist", @"fnt", nil];
    
    // Set default format to use for exports
    self.publishFormat = @"ccbi";
    
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

- (BOOL) publishDirectory:(NSString*) dir subPath:(NSString*) subPath
{
    NSFileManager* fm = [NSFileManager defaultManager];
    
    // Path to output directory for the currently exported path
    NSString* outDir = outDir = [outputDir stringByAppendingPathComponent:subPath];
    
    NSLog(@"DIR %@", outDir);
    
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
                    NSString* dstFile = NULL;
                    if (subPath) dstFile = [NSString stringWithFormat:@"%@/%@/%@",outputDir,subPath,fileName];
                    else dstFile = [NSString stringWithFormat:@"%@/%@",outputDir,fileName];
                    
                    if ([dstFile isEqualToString:filePath])
                    {
                        [warnings addWarningWithDescription:@"Publish will overwrite file in resource directory." isFatal:YES];
                        return NO;
                    }
                    
                    if (![fm fileExistsAtPath:dstFile] || [self srcFile:filePath isNewerThanDstFile:dstFile])
                    {
                        NSLog(@"COPY %@",fileName);
                        
                        // Remove old file
                        [fm removeItemAtPath:dstFile error:NULL];
                        
                        // Copy the file
                        BOOL sucess = [fm copyItemAtPath:filePath toPath:dstFile error:NULL];
                        if (!sucess) [warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to publish file: %@", fileName]];
                    }
                }
            }
            
            // Publish ccb files
            if ([[fileName lowercaseString] hasSuffix:@"ccb"])
            {
                NSString* strippedFileName = [fileName stringByDeletingPathExtension];
                
                NSString* dstFile = NULL;
                if (subPath) dstFile = [NSString stringWithFormat:@"%@/%@/%@.%@",outputDir,subPath,strippedFileName, publishFormat];
                else dstFile = [NSString stringWithFormat:@"%@/%@.%@",outputDir,strippedFileName, publishFormat];
                
                if ([dstFile isEqualToString:filePath])
                {
                    [warnings addWarningWithDescription:@"Publish will overwrite files in resource directory." isFatal:YES];
                    return NO;
                }
                
                if (![fm fileExistsAtPath:dstFile] || [self srcFile:filePath isNewerThanDstFile:dstFile])
                {
                    NSLog(@"PUBLISH %@",fileName);
                    
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

- (BOOL) publish
{
    for (NSString* dir in projectSettings.absoluteResourcePaths)
    {
        if (![self publishDirectory:dir subPath:NULL]) return NO;
    }
    
    if (projectSettings.publishToZipFile)
    {
        NSLog(@"ZIPPING");
        
        // Zip it up!
        NSTask* zipTask = [[NSTask alloc] init];
        [zipTask setCurrentDirectoryPath:outputDir];
        [zipTask setLaunchPath:@"/usr/bin/zip"];
        NSArray* args = [NSArray arrayWithObjects:@"-r", @"-q", [[projectSettings.publishDirectory absolutePathFromBaseDirPath:[projectSettings.projectPath stringByDeletingLastPathComponent]] stringByAppendingPathComponent:@"ccb.zip"], @".", @"-i", @"*", nil];
        [zipTask setArguments:args];
        
        NSLog(@"ZIP args: %@", args);
        
        [zipTask launch];
        [zipTask waitUntilExit];
    }
    
    //[NSSound soundNamed:
    
    NSLog(@"PUBLISH SUCCESSFUL!");
    
    return YES;
}

- (void) dealloc
{
    [warnings release];
    [projectSettings release];
    [outputDir release];
    [super dealloc];
}

@end
