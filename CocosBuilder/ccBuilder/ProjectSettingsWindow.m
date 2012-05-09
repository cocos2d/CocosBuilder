//
//  ProjectSettingsWindow.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProjectSettingsWindow.h"
#import "ProjectSettings.h"

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
                
                projectSettings.publishDirectory = dirName;
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
                
                [resDirArrayController addObject:[NSMutableDictionary dictionaryWithObject:dirName forKey:@"path"]];
            }
            
            [[[CCDirector sharedDirector] view] unlockOpenGLContext];
        }
    }];
}

@end
