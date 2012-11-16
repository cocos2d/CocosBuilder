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
