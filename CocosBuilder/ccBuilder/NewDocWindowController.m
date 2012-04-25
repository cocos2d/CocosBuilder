/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2011 Viktor Lidholt
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

#import "NewDocWindowController.h"
#import "PlugInManager.h"
#import "ResolutionSetting.h"

@implementation NewDocWindowController

@synthesize rootObjectType, rootObjectTypes, resolutions;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (!self) return NULL;
    
    self.rootObjectTypes = [PlugInManager sharedManager].plugInsNodeNamesCanBeRoot;
    self.rootObjectType = [rootObjectTypes objectAtIndex:0];
    
    // Setup default resolutions
    self.resolutions = [NSMutableArray array];
    ResolutionSetting* iPhoneLandscape = [ResolutionSetting settingIPhoneLandscape];
    iPhoneLandscape.enabled = YES;
    [resolutions addObject:iPhoneLandscape];
    [resolutions addObject:[ResolutionSetting settingIPhonePortrait]];
    [resolutions addObject:[ResolutionSetting settingIPadLandscape]];
    [resolutions addObject:[ResolutionSetting settingIPadPortrait]];
    
    return self;
}

- (IBAction)acceptSheet:(id)sender
{
    if ([[self window] makeFirstResponder:[self window]])
    {
        // Verify resolutions
        BOOL foundEnabledResolution = NO;
        for (ResolutionSetting* setting in resolutions)
        {
            if (setting.enabled) foundEnabledResolution = YES;
        }
        
        if (foundEnabledResolution)
        {
            [NSApp stopModalWithCode:1];
        }
        else
        {
            // Display warning!
            NSAlert* alert = [NSAlert alertWithMessageText:@"Missing Resolution" defaultButton:@"OK" alternateButton:NULL otherButton:NULL informativeTextWithFormat:@"You need to have at least one resolution enabled to create a new document."];
            [alert beginSheetModalForWindow:[self window] modalDelegate:NULL didEndSelector:NULL contextInfo:NULL];
        }
    }
}

- (NSMutableArray*) availableResolutions
{
    NSMutableArray* availableResolutions = [NSMutableArray array];
    for (ResolutionSetting* setting in resolutions)
    {
        if (setting.enabled)
        {
            [availableResolutions addObject:setting];
        }
    }
    return availableResolutions;
}

- (IBAction)cancelSheet:(id)sender
{
    [NSApp stopModalWithCode:0];
}

- (void) dealloc
{
    self.rootObjectType = NULL;
    self.resolutions = NULL;
    [super dealloc];
}

@end
