//
//  TestButtons.m
//  CocosBuilderExample
//
//  Created by Viktor Lidholt on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestButtons.h"
#import "CCControlButton.h"

@implementation TestButtons

// You can handle many different event types sent by the
// CCControlButton (or other CCControl:s). If you need to catch
// different types sent by one control, you will need to specify
// a method that takes two arguments; the sender and the event.
// You can also chose to ignore the event and only catch the
// sender (make a method with one argument, e.g. handleButton:).
- (void) handleButton:(id)sender event:(CCControlEvent)event
{
    // Set the text of the label to match the event
    NSString* eventName = @"";
    if (event == CCControlEventTouchDown) eventName = @"Touch Down";
    else if (event == CCControlEventTouchDragInside) eventName = @"Touch Drag Inside";
    else if (event == CCControlEventTouchDragOutside) eventName = @"Touch Drag Outside";
    else if (event == CCControlEventTouchDragEnter) eventName = @"Touch Drag Enter";
    else if (event == CCControlEventTouchDragExit) eventName = @"Touch Drag Exit";
    else if (event == CCControlEventTouchUpInside) eventName = @"Touch Up Inside";
    else if (event == CCControlEventTouchUpOutside) eventName = @"Touch Up Outside";
    else if (event == CCControlEventTouchCancel) eventName = @"Touch Cancel";
    else if (event == CCControlEventValueChanged) eventName = @"Value Changed";
    
    [lblText setString:eventName];
}

@end
