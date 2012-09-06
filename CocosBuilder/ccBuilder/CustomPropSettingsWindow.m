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

#import "CustomPropSettingsWindow.h"
#import "CustomPropSetting.h"
#import "CCNode+NodeInfo.h"
#import "PlugInNode.h"

@interface CustomPropSettingsWindow ()

@end

@implementation CustomPropSettingsWindow

@synthesize settings;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        self.settings = [NSMutableArray array];
    }
    
    return self;
}

- (void) copySettingsForNode:(CCNode *)n
{
    node = n;
    
    [settings release];
    settings = [[NSMutableArray arrayWithCapacity:[node.customProperties count]] retain];
    
    for (CustomPropSetting* setting in node.customProperties)
    {
        [settings addObject:[[setting copy] autorelease]];
    }
}

- (BOOL) sheetIsValid
{
    NSMutableSet* propNames = [NSMutableSet set];
    
    PlugInNode* plugIn = node.plugIn;
    
    for(NSString* propName in plugIn.nodePropertiesDict)
    {
        [propNames addObject:propName];
    }
    
    for (CustomPropSetting* setting in settings)
    {
        // Make sure all properties have names
        if (!setting.name || [setting.name isEqualToString:@""])
        {
            NSAlert* alert = [NSAlert alertWithMessageText:@"Invalid Property Name" defaultButton:@"OK" alternateButton:NULL otherButton:NULL informativeTextWithFormat:@"All custom properties need to have a valid name. Please add names to your properties."];
            [alert beginSheetModalForWindow:[self window] modalDelegate:NULL didEndSelector:NULL contextInfo:NULL];
            return NO;
        }
        
        // Check that names are not duplicates of existing props
        if ([propNames containsObject:setting.name])
        {
            NSAlert* alert = [NSAlert alertWithMessageText:@"Duplicate Property Name" defaultButton:@"OK" alternateButton:NULL otherButton:NULL informativeTextWithFormat:@"The %@ property has the same name as a predefined property. Please find another name.", setting.name];
            [alert beginSheetModalForWindow:[self window] modalDelegate:NULL didEndSelector:NULL contextInfo:NULL];
            return NO;
        }
    }
    
    for (CustomPropSetting* setting in settings)
    {
        // Custom props cannot have same names
        if ([propNames containsObject:setting.name])
        {
            NSAlert* alert = [NSAlert alertWithMessageText:@"Duplicate Property Name" defaultButton:@"OK" alternateButton:NULL otherButton:NULL informativeTextWithFormat:@"The %@ property has the same name as another custom property. Please find another name.", setting.name];
            [alert beginSheetModalForWindow:[self window] modalDelegate:NULL didEndSelector:NULL contextInfo:NULL];
            return NO;
        }
        [propNames addObject:setting.name];
    }
    
    return YES;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void) dealloc
{
    self.settings = NULL;
    [super dealloc];
}

@end
