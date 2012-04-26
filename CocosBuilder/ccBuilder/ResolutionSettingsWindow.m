//
//  ResolutionSettingsWindow.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ResolutionSettingsWindow.h"
#import "ResolutionSetting.h"

@implementation ResolutionSettingsWindow

@synthesize resolutions;

- (void) copyResolutions:(NSMutableArray *)res
{
    [resolutions release];
    resolutions = [[NSMutableArray arrayWithCapacity:[res count]] retain];
    
    for (ResolutionSetting* resolution in res)
    {
        [resolutions addObject:[[resolution copy] autorelease]];
    }
}

- (BOOL) sheetIsValid
{
    if ([resolutions count] > 0)
    {
        return YES;
    }
    else
    {
        // Display warning!
        NSAlert* alert = [NSAlert alertWithMessageText:@"Missing Resolution" defaultButton:@"OK" alternateButton:NULL otherButton:NULL informativeTextWithFormat:@"You need to have at least one valid resolution setting."];
        [alert beginSheetModalForWindow:[self window] modalDelegate:NULL didEndSelector:NULL contextInfo:NULL];
        
        return NO;
    }
}

- (void) dealloc
{
    [resolutions release];
    [super dealloc];
}

@end
