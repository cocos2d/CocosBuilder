//
//  ConsoleWindow.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConsoleWindow.h"

@implementation ConsoleWindow

- (id)init
{
    self = [super initWithWindowNibName:@"ConsoleWindow"];
    if (!self) return NULL;
    
    pipe = [NSPipe pipe];
    pipeReadHandle = [pipe fileHandleForReading];
    
    [pipeReadHandle readInBackgroundAndNotify];
    
    dup2([pipeReadHandle fileDescriptor], STDOUT_FILENO);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readData:) name:NSFileHandleReadCompletionNotification object:pipeReadHandle];
    
    
    [pipeReadHandle retain];
    [pipe retain]; // If this line is removed, readData: is being called
    
    return self;
}

- (void) readData:(NSNotification*)notification
{
    NSFileHandle *handle = (NSFileHandle *)[notification object];
    
    NSData* data = [handle availableData];
    
    if (data.length > 0)
    {
        NSLog(@"dataAvailable len: %d", (int)data.length);
    
        NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
        NSLog(@"str: %@", str);
        [self writeToConsole:str];
    }
    
    [handle readInBackgroundAndNotify];
}

- (void) test
{
    NSLog(@"Calling test");
    printf("test\n");
    
    [self writeToConsole:@"foo"]; // Just for testing the console
}

- (void) writeToConsole:(NSString*) str
{
    // Add new line
    str = [str stringByAppendingString:@"\n"];
    
    // Check if we are scrolled to the bottom
    bool scrollToEnd = YES;
    
    id scrollView = (NSScrollView *)textView.superview.superview;
    if ([scrollView isKindOfClass:[NSScrollView class]]) {
        if ([scrollView hasVerticalScroller]) {
            if (textView.frame.size.height > [scrollView frame].size.height) {
                if (1.0f != [scrollView verticalScroller].floatValue)
                    scrollToEnd = NO;
            }
        }
    }
    
    // Append the string
    NSDictionary *attribs = [NSDictionary dictionary];
    NSAttributedString *stringToAppend = [[NSAttributedString alloc] initWithString:str attributes:attribs];
    [[textView textStorage] appendAttributedString:stringToAppend];
    [stringToAppend release];
    
    // Scroll to the end
    if (scrollToEnd)
    {
        NSRange range = NSMakeRange ([[textView string] length], 0);
        [textView scrollRangeToVisible: range];
    }
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.window center];
    [self writeToConsole:@"CocosBuilder Player JS Console"];
    [textView setFont:[NSFont fontWithName:@"Menlo" size:11]];
}

@end
