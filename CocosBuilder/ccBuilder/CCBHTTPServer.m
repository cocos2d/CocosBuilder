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

#import "CCBHTTPServer.h"
#import "NSString+RelativePath.h"
#import "ProjectSettings.h"

@implementation CCBHTTPServer
@synthesize httpServer;

#pragma mark CCBHTTPServer - Alloc, Init & Dealloc

static CCBHTTPServer *_sharedHTTPServer=nil;

+ (CCBHTTPServer *)sharedHTTPServer
{
    if(!_sharedHTTPServer)
        _sharedHTTPServer = [[CCBHTTPServer alloc] init];
    
    return _sharedHTTPServer;
}

+ (id)alloc
{
    NSAssert(_sharedHTTPServer == nil, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

- (id)init
{
    if((self = [super init])){
        httpServer = nil;
    }

    return self;
}

- (void) start:(NSString*)docRoot
{
	// Initalize our http server
	httpServer = [[HTTPServer alloc] init];
	
	// Tell the server to broadcast its presence via Bonjour.
	// This allows browsers such as Safari to automatically discover our service.
	[httpServer setType:@"_http._tcp."];
	
    // Using default port first
    [httpServer setPort:kCCBDefaultPort];
	
	// Serve files from the standard Sites folder
   
    NSLog(@"Setting document root: %@", docRoot);
	
	[httpServer setDocumentRoot:docRoot];
	
	NSError *error = nil;
	if(![httpServer start:&error])
	{
		NSLog(@"Error starting HTTP Server: %@, try let the kernel pick a port for us", error);
        [httpServer setPort:0];
        if(![httpServer start:&error]){
            NSLog(@"Error starting HTTP Server again: %@", error);
        }
        
	}
}

- (void) stop
{
    [httpServer stop];
}

- (void) restart:(NSString *)docRoot
{
    [self stop];
    [self start:docRoot];
}

- (UInt16) listeningPort
{
    return httpServer.listeningPort;
}

- (void) openBrowser:(NSString *)browser
{
    NSString* url = [NSString stringWithFormat:@"http://localhost:%d/index.html", [[CCBHTTPServer sharedHTTPServer] listeningPort]];
    NSArray* urls = [NSArray arrayWithObject:[NSURL URLWithString:url]];
    
    if([browser isEqualToString:@"Safari"])
    {
        [[NSWorkspace sharedWorkspace] openURLs:urls withAppBundleIdentifier:@"com.apple.Safari" options:NSWorkspaceLaunchWithoutActivation additionalEventParamDescriptor:nil launchIdentifiers:nil];
    }else if([browser isEqualToString:@"Firefox"])
    {
        [[NSWorkspace sharedWorkspace] openURLs:urls withAppBundleIdentifier:@"org.mozilla.Firefox" options:NSWorkspaceLaunchWithoutActivation additionalEventParamDescriptor:nil launchIdentifiers:nil];
    }else if([browser isEqualToString:@"Chrome"])
    {
        [[NSWorkspace sharedWorkspace] openURLs:urls withAppBundleIdentifier:@"com.google.Chrome" options:NSWorkspaceLaunchWithoutActivation additionalEventParamDescriptor:nil launchIdentifiers:nil];
    }else{
        // Open a browser and point to local web server we started http://localhost:{port}/index.html
        NSString* url = [NSString stringWithFormat:@"http://localhost:%d/index.html", [[CCBHTTPServer sharedHTTPServer] listeningPort]];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:browser forKey:@"defaultBrowser"];
}
@end
