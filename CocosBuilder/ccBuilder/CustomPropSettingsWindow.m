//
//  CustomPropSettingsWindow.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 8/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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
    
    NSLog(@"propNames: %@", propNames);
    
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
            NSAlert* alert = [NSAlert alertWithMessageText:@"Duplicate Property Name" defaultButton:@"OK" alternateButton:NULL otherButton:NULL informativeTextWithFormat:[NSString stringWithFormat:@"The %@ property has the same name as a predefined property. Please find another name.", setting.name]];
            [alert beginSheetModalForWindow:[self window] modalDelegate:NULL didEndSelector:NULL contextInfo:NULL];
            return NO;
        }
    }
    
    for (CustomPropSetting* setting in settings)
    {
        // Custom props cannot have same names
        if ([propNames containsObject:setting.name])
        {
            NSAlert* alert = [NSAlert alertWithMessageText:@"Duplicate Property Name" defaultButton:@"OK" alternateButton:NULL otherButton:NULL informativeTextWithFormat:[NSString stringWithFormat:@"The %@ property has the same name as another custom property. Please find another name.", setting.name]];
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
