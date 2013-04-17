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

#import "HelpWindow.h"
#import "HelpPage.h"
#import "MMMarkdown.h"

@interface HelpWindow ()

@end

@implementation HelpWindow

@synthesize mdFiles;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (!self) return NULL;
    
    NSString* docDirPath = [[NSBundle mainBundle] pathForResource:@"Documentation" ofType:@""];
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docDirPath error:NULL];
    
    mdFiles = [[NSMutableArray alloc] init];
    for (NSString* file in files)
    {
        if ([file hasSuffix:@".md"])
        {
            HelpPage* hp = [[[HelpPage alloc] init] autorelease];
            hp.fileName = file;
            [mdFiles addObject:hp];
        }
    }
    
    return self;
}

- (void) loadHelpFile:(HelpPage*)hp
{
    // Load MD File and convert to HTML
    NSString* docPath = [[NSBundle mainBundle] pathForResource:hp.fileName ofType:@"" inDirectory:@"Documentation"];
    NSString* md = [NSString stringWithContentsOfFile:docPath encoding:NSUTF8StringEncoding error:NULL];
    NSString* innerHtml = [MMMarkdown HTMLStringWithMarkdown:md error:NULL];
    
    // Load template
    NSString* templatePath = [[NSBundle mainBundle] pathForResource:@"template" ofType:@"html" inDirectory:@"Documentation"];
    NSString* template = [NSString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:NULL];
    
    // Insert md in template
    NSString* page = [template stringByReplacingOccurrencesOfString:@"<#CONTENT#>" withString:innerHtml];
    
    // Load file into the web view
    NSURL* baseURL = [NSURL fileURLWithPath:[docPath stringByDeletingLastPathComponent]];
    [webView.mainFrame loadHTMLString:page baseURL:baseURL];
}

- (void) tableViewSelectionDidChange:(NSNotification *)notification
{
    HelpPage* page = [mdFiles objectAtIndex:[tableView selectedRow]];
    
    [self loadHelpFile:page];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [webView setPolicyDelegate:self];
    [self loadHelpFile:[mdFiles objectAtIndex:0]];
}


- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id)listener
{
    if ([[[request URL]scheme] isEqualToString:@"file"])
    {
        [listener use];
    }
    else
    {
        [listener ignore];
        // Open in Safari instead
        [[NSWorkspace sharedWorkspace] openURL:[request URL]];
    }
}
@end
