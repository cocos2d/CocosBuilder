//
//  CCBPublisher.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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
        outputDir = [@"" retain]; // TODO: Create temp directory
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
