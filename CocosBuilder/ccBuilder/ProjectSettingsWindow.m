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

#import "ProjectSettingsWindow.h"
#import "ProjectSettings.h"
#import "NSString+RelativePath.h"

@implementation ProjectSettingsWindow

@synthesize projectSettings;

- (IBAction)selectPublishDirectory:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    
    [openDlg beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSOKButton)
        {
            [[[CCDirector sharedDirector] view] lockOpenGLContext];
            
            NSArray* files = [openDlg URLs];
            
            for (int i = 0; i < [files count]; i++)
            {
                NSString* dirName = [[files objectAtIndex:i] path];
                NSString* projectDir = [projectSettings.projectPath stringByDeletingLastPathComponent];
                NSString* relDirName = [dirName relativePathFromBaseDirPath:projectDir];
                
                projectSettings.publishDirectory = relDirName;
            }
            
            [[[CCDirector sharedDirector] view] unlockOpenGLContext];
        }
    }];
}


- (IBAction)addResourceDirectory:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    
    [openDlg beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSOKButton)
        {
            [[[CCDirector sharedDirector] view] lockOpenGLContext];
            
            NSArray* files = [openDlg URLs];
            
            for (int i = 0; i < [files count]; i++)
            {
                NSString* dirName = [[files objectAtIndex:i] path];
                NSString* projectDir = [projectSettings.projectPath stringByDeletingLastPathComponent];
                NSString* relDirName = [dirName relativePathFromBaseDirPath:projectDir];
                
                // Check for duplicate
                BOOL isDuplicate = NO;
                for (NSDictionary* row in projectSettings.resourcePaths)
                {
                    NSString* path = [row objectForKey:@"path"];
                    if ([path isEqualToString:relDirName]) isDuplicate = YES;
                }
                
                if (!isDuplicate)
                {
                    [resDirArrayController addObject:[NSMutableDictionary dictionaryWithObject:relDirName forKey:@"path"]];
                }
            }
            
            [[[CCDirector sharedDirector] view] unlockOpenGLContext];
        }
    }];
}

@end
