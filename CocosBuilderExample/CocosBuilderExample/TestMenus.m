//
//  TestMenus.m
//  CocosBuilderExample
//
//  Created by Viktor Lidholt on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestMenus.h"

@implementation TestMenus

// This is a callback for the A button as defined in the ccb file.
- (void) pressedA:(id)sender
{
    // Set the labels text
    [lblText setString:@"Pressed A"];
}

// This is a callback for the B button as defined in the ccb file.
- (void) pressedB:(id)sender
{
    // Set the labels text
    [lblText setString:@"Pressed B"];
}

// This is a callback for the C button as defined in the ccb file,
// the C-button is disabled and you should not be able to tap it.
- (void) pressedC:(id)sender
{
    [lblText setString:@"Pressed C"];
}

@end
