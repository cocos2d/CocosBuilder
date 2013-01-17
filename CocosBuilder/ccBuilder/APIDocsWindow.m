//
//  APIDocsWindow.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 1/9/13.
//
//

#import "APIDocsWindow.h"

@interface APIDocsWindow ()

@end

@implementation APIDocsWindow

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSString* docPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"jsdoc"];
    
    NSString* htmlString = [NSString stringWithContentsOfFile:docPath encoding:NSUTF8StringEncoding error:nil];
    
    [[webView mainFrame] loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"jsdoc"]]];
}

@end
