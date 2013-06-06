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

#import "DebuggerTextField.h"

@implementation DebuggerTextField

- (void) additionalInitStuff
{
    history = [[NSMutableArray alloc] init];
    historyPosition = -1;
}

- (id) initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (!self) return NULL;
    
    [self additionalInitStuff];
    
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) return NULL;
    
    [self additionalInitStuff];
    
    return self;
}

- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector: (SEL)aSelector
{
    return [self tryToPerform:aSelector with:aTextView];
}

- (void) addToHistory:(NSString*)script
{
    [history addObject:script];
    historyPosition = [history count];
}

- (void)moveUp:(id)sender
{
    historyPosition -= 1;
    if (historyPosition < 0)
    {
        historyPosition = 0;
        return;
    }
    
    [self setStringValue:[history objectAtIndex:historyPosition]];
    
    NSLog(@"setStringValue: %@ pos: %d", [history objectAtIndex:historyPosition], historyPosition);
    
}

- (void)moveDown:(id)sender
{
    historyPosition += 1;
    
    if (historyPosition >= [history count])
    {
        [self setStringValue:@""];
        historyPosition = [history count];
        return;
    }
    
    [self setStringValue:[history objectAtIndex:historyPosition]];
    
    
    NSLog(@"setStringValue: %@ pos: %D", [history objectAtIndex:historyPosition], historyPosition);
}

- (void)dealloc
{
    [history release];
    [super dealloc];
}

@end
