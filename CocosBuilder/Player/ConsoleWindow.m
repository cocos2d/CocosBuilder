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

#import "ConsoleWindow.h"

@implementation ConsoleWindow

- (id)init
{
    self = [super initWithWindowNibName:@"ConsoleWindow"];
    if (!self) return NULL;
    
    pipe = [NSPipe pipe];
    pipeReadHandle = [pipe fileHandleForReading];
    
    [pipeReadHandle readInBackgroundAndNotify];
    
    int err = dup2([[pipe fileHandleForWriting] fileDescriptor], STDERR_FILENO);
    if (!err) NSLog(@"ConsoleWindow: Failed to redirect stderr");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readData:) name:NSFileHandleReadCompletionNotification object:pipeReadHandle];
    
    [pipeReadHandle retain];
    
    return self;
}

- (void) readData:(NSNotification*)notification
{
    [pipeReadHandle readInBackgroundAndNotify] ;
    NSString *str = [[NSString alloc] initWithData: [[notification userInfo] objectForKey: NSFileHandleNotificationDataItem] encoding: NSASCIIStringEncoding] ;
    [self writeToConsole:str bold:YES];
}

- (BOOL) isScrolledToBottom
{
    BOOL scrollToEnd = YES;
    
    id scrollView = (NSScrollView *)textView.superview.superview;
    if ([scrollView isKindOfClass:[NSScrollView class]]) {
        if ([scrollView hasVerticalScroller]) {
            if (textView.frame.size.height > [scrollView frame].size.height) {
                if (1.0f != [scrollView verticalScroller].floatValue)
                    scrollToEnd = NO;
            }
        }
    }
    return scrollToEnd;
}

- (void) scrollToBottom
{
    NSRange range = NSMakeRange ([[textView string] length], 0);
    [textView scrollRangeToVisible: range];
}

- (void) writeToConsole:(NSString*) str bold:(BOOL)bold
{
    // Check if we are scrolled to the bottom
    BOOL scrollToEnd = [self isScrolledToBottom];
    
    // Append the string
    NSFont* font = NULL;
    if (bold) font = [NSFont fontWithName:@"Menlo-Bold" size:11];
    else font = [NSFont fontWithName:@"Menlo" size:11];
    
    NSMutableDictionary *attribs = [NSMutableDictionary dictionary];
    [attribs setObject:font forKey:NSFontAttributeName];
    
    NSAttributedString *stringToAppend = [[NSAttributedString alloc] initWithString:str attributes:attribs];
    [[textView textStorage] appendAttributedString:stringToAppend];
    [stringToAppend release];
    
    // Scroll to the end
    if (scrollToEnd)
    {
        [self scrollToBottom];
    }
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.window center];
    [self writeToConsole:@"CocosBuilder Player JavaScript Console\n" bold:NO];
    
    self.window.delegate = self;
}

- (void) windowWillStartLiveResize:(NSNotification *)notification
{
    scrolledToBottomWhenResizing = [self isScrolledToBottom];
}

- (void) windowDidResize:(NSNotification *)notification
{
    if (scrolledToBottomWhenResizing)
    {
        [self scrollToBottom];
    }
}

@end
