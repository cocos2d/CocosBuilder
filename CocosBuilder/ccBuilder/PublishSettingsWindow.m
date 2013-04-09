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

#import "PublishSettingsWindow.h"
#import "ProjectSettings.h"
#import "CCBHTTPServer.h"
#import "NSString+RelativePath.h"

@implementation PublishSettingsWindow

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
                
                int type = [sender tag];
                
                if (type == 0)
                {
                    projectSettings.publishDirectory = relDirName;
                }
                else if (type == 1)
                {
                    projectSettings.publishDirectoryAndroid = relDirName;
                }
                else if (type == 2)
                {
                    projectSettings.publishDirectoryHTML5 = relDirName;
                }
            }
            
            [[[CCDirector sharedDirector] view] unlockOpenGLContext];
            // Restart local web server
            NSString* docRoot = [projectSettings.publishDirectoryHTML5 absolutePathFromBaseDirPath:[projectSettings.projectPath stringByDeletingLastPathComponent]];
            [[CCBHTTPServer sharedHTTPServer] restart:docRoot];
        }
    }];
}

@end
