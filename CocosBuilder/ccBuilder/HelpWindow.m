//
//  HelpWindow.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 8/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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
