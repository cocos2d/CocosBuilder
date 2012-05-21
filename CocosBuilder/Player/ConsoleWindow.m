//
//  ConsoleWindow.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConsoleWindow.h"

@implementation ConsoleWindow

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (!self) return NULL;
    
    // Save std err
    originalStdErr = dup(STDERR_FILENO);
    
    // Setup path to log
    logPath = [NSString stringWithFormat:@"%@%@.log.txt", NSTemporaryDirectory(), [[NSBundle mainBundle] bundleIdentifier]];
    [logPath retain];
    
    // Create log
    [@"" writeToFile:logPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:logPath];
    [fileHandle retain];
    if (!fileHandle) NSLog(@"Opening log at %@ failed", logPath);
    
    int fd = [fileHandle fileDescriptor];
    
    // Redirect stderr
    int err = dup2(fd, STDERR_FILENO);
    if (!err) NSLog(@"Failed to redirect stderr");
    [fileHandle readInBackgroundAndNotify];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataAvailable:) name:NSFileHandleReadCompletionNotification object:fileHandle];
    
    fileOffset = 0;
    
    return self;
}

- (void) dataAvailable:(NSNotification*)notification
{
    // Open log file
    NSFileHandle* f = [NSFileHandle fileHandleForWritingAtPath:logPath];
    if (!f) NSLog(@"Opening log at %@ failed", logPath);
    
    // Get file length
    [f seekToEndOfFile];
    unsigned long long length = [f offsetInFile];
    
    // Read data
    [f seekToFileOffset:fileOffset];
    NSData* data = [f readDataToEndOfFile];
    
    // Convert to string
    NSString* str = [[[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding] autorelease];
    
    NSLog(@"got log: %@", str);
    
    fileOffset = length;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
