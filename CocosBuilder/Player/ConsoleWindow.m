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
    
    //setvbuf(stderr, NULL, _IOLBF, 4096 );
    
    pipe = [NSPipe pipe];
    pipeReadHandle = [pipe fileHandleForReading];
    
    [pipeReadHandle readInBackgroundAndNotify];
    
    dup2([[pipe fileHandleForWriting] fileDescriptor], STDERR_FILENO);
    
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

- (void) test
{
    NSLog(@"Calling test");
}

- (void) writeToConsole:(NSString*) str bold:(BOOL)bold
{
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
        NSRange range = NSMakeRange ([[textView string] length], 0);
        [textView scrollRangeToVisible: range];
    }
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.window center];
    [self writeToConsole:@"CocosBuilder Player JS Console\n" bold:NO];
    [textView setFont:[NSFont fontWithName:@"Menlo" size:11]];
}

@end
