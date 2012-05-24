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

#import "AppDelegate.h"
#import "CCBPFileUtils.h"
#import "CCBReader.h"
#import "JSCocoa.h"
#import "ConsoleWindow.h"

@implementation AppDelegate

@synthesize window;
@synthesize console;

- (void) setupCocos2d
{
    // Director
    CCDirectorMac* director = (CCDirectorMac*) [CCDirector sharedDirector];
    director.displayStats = YES;
    director.animationInterval = 1.0/60;
    [director setProjection:kCCDirectorProjection2D];
    
    // GL View
    director.view = glView;
    
    [director setResizeMode:kCCDirectorResize_NoScale];
    
    //[director runWithScene:[CCScene node]];
}

- (void) setupFromAppArguments
{
    // Setup custom file utils
    CCBFileUtils* fileUtils = (CCBFileUtils*)[CCBFileUtils sharedFileUtils];
    
    NSArray* args = [[NSProcessInfo processInfo] arguments];
    
    NSString* baseDirectory = NULL;
    if (args.count == 4)
    {
        baseDirectory = [args objectAtIndex:1];
        int w = [[args objectAtIndex:2] intValue];
        int h = [[args objectAtIndex:3] intValue];
        [window setContentSize:NSMakeSize(w, h)];
    }
    else
    {
        // DEBUG!
        baseDirectory = @"/Users/vlidholt/Library/Caches/com.cocosbuilder.CocosBuilder/publish/84b88bf876bf7f18d8acdadf2cc8cf17";
        [window setContentSize:NSMakeSize(480, 320)];
    }
    
    fileUtils.ccbDirectoryPath = baseDirectory;
}

- (void) setupJavaScript
{
    JSCocoa* jsController = [JSCocoa sharedController];
    
    CCFileUtils* fileUtils = [CCFileUtils sharedFileUtils];
    NSString* cocos2dBridge = [fileUtils fullPathFromRelativePath:@"cocos2d.bridgesupport"];
    
    [[BridgeSupportController sharedController] loadBridgeSupport:cocos2dBridge];
    
    NSString* mainScript = [fileUtils fullPathFromRelativePath:@"main.js"];
    [jsController evalJSFile:mainScript];
}

- (void) setupConsole
{
    console = [[ConsoleWindow alloc] init];
    [console window];
    //[console.window setIsVisible:YES];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self setupConsole];
    [self setupFromAppArguments];
    [self setupCocos2d];
    [self setupJavaScript];
    
    window.delegate = self;
    
    [NSApp activateIgnoringOtherApps:YES];
    //[console.window makeKeyAndOrderFront:self];
}

- (void) windowWillClose:(NSNotification *)notification
{
    // Terminate if main window is closed
    [[NSApplication sharedApplication] terminate:self];
}

- (void)dealloc
{
    [console release];
    
    [super dealloc];
}

- (IBAction)debug:(id)sender
{
    //[console test];
}

@end
