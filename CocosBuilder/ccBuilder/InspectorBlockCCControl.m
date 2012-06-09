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

#import "InspectorBlockCCControl.h"
#import "CCBGlobals.h"
#import "CCNode+NodeInfo.h"

@implementation InspectorBlockCCControl

- (void) willBeAdded
{
    btns = [[NSMutableDictionary alloc] init];
    
    selectedEvents = [[selection extraPropForKey:[NSString stringWithFormat:@"%@CtrlEvts", propertyName]] intValue];
    
    [btns setObject:btnDown forKey:[NSNumber numberWithInt:CCControlEventTouchDown]];
    [btns setObject:btnDragInside forKey:[NSNumber numberWithInt:CCControlEventTouchDragInside]];
    [btns setObject:btnDragOutside forKey:[NSNumber numberWithInt:CCControlEventTouchDragOutside]];
    [btns setObject:btnDragEnter forKey:[NSNumber numberWithInt:CCControlEventTouchDragEnter]];
    [btns setObject:btnDragExit forKey:[NSNumber numberWithInt:CCControlEventTouchDragExit]];
    [btns setObject:btnUpInside forKey:[NSNumber numberWithInt:CCControlEventTouchUpInside]];
    [btns setObject:btnUpOutside forKey:[NSNumber numberWithInt:CCControlEventTouchUpOutside]];
    [btns setObject:btnCancel forKey:[NSNumber numberWithInt:CCControlEventTouchCancel]];
    [btns setObject:btnValueChanged forKey:[NSNumber numberWithInt:CCControlEventValueChanged]];
    
    for (NSNumber* evtVal in btns)
    {
        int evt = [evtVal intValue];
        NSButton* btn = [btns objectForKey:evtVal];
        
        if (selectedEvents & evt)
        {
            [btn setState:NSOnState];
        }
        else
        {
            [btn setState:NSOffState];
        }
        
        [btn setTarget:self];
        [btn setAction:@selector(toggledCheck:)];
        [btn setTag:evt];
    }
}

- (void) dealloc
{
    [btns release];
    [super dealloc];
}

- (void) setSelector:(NSString *)selector
{
    if (!selector) selector = @"";
    [selection setExtraProp:selector forKey:propertyName];
}

- (NSString*) selector
{
    NSString* sel = [selection extraPropForKey:propertyName];
    if (!sel) sel = @"";
    return sel;
}

- (void) setTarget:(int)target
{
    [selection setExtraProp:[NSNumber numberWithInt:target] forKey:[NSString stringWithFormat:@"%@Target", propertyName]];
}

- (int) target
{
    return [[selection extraPropForKey:[NSString stringWithFormat:@"%@Target", propertyName]] intValue];
}

- (void) toggledCheck:(id)sender
{
    NSButton* btn = sender;
    
    CCControlEvent evt = [btn tag];
    
    if ([btn state] == NSOnState)
    {
        selectedEvents |= evt;
    }
    else
    {
        selectedEvents &= ~evt;
    }
    
    [selection setExtraProp:[NSNumber numberWithInt:selectedEvents] forKey:[NSString stringWithFormat:@"%@CtrlEvts", propertyName]];
}

@end
