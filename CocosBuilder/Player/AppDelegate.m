//
//  AppDelegate.m
//  Player
//
//  Created by Viktor Lidholt on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "CCBPFileUtils.h"
#import "CCBReader.h"
#import "JSCocoa.h"

@implementation AppDelegate

@synthesize window;

- (void)dealloc
{
    [super dealloc];
}

- (void) setupCocos2d
{
    // Director
    CCDirectorMac* director = (CCDirectorMac*) [CCDirector sharedDirector];
    director.displayStats = YES;
    director.animationInterval = 1.0/60;
    [director setProjection:kCCDirectorProjection2D];
    
    // GL View
    director.view = glView;
    [window center];
    
    [director setResizeMode:kCCDirectorResize_NoScale];
    
    //[director runWithScene:[CCScene node]];
}

- (void) setupFromAppArguments
{
    // Setup custom file utils
    CCBFileUtils* fileUtils = (CCBFileUtils*)[CCBFileUtils sharedFileUtils];
    
    NSArray* args = [[NSProcessInfo processInfo] arguments];
    
    NSString* baseDirectory = NULL;
    if (args.count == 2)
    {
        baseDirectory = [args objectAtIndex:1];
    }
    else
    {
        // DEBUG!
        baseDirectory = @"/Users/vlidholt/Library/Caches/com.cocosbuilder.CocosBuilder/publish/84b88bf876bf7f18d8acdadf2cc8cf17";
    }
    
    NSLog(@"Published directory: %@", baseDirectory);
    
    fileUtils.ccbDirectoryPath = baseDirectory;
}

- (void) setupJavaScript
{
    jsController = [[JSCocoa alloc] init];
    
    CCFileUtils* fileUtils = [CCFileUtils sharedFileUtils];
    NSString* cocos2dBridge = [fileUtils fullPathFromRelativePath:@"cocos2d.bridgesupport"];
    
    NSLog(@"bridge path: %@", cocos2dBridge);
    
    [[BridgeSupportController sharedController] loadBridgeSupport:cocos2dBridge];
    
    NSString* mainScript = [fileUtils fullPathFromRelativePath:@"main.js"];
    
    NSLog(@"main.js: %@", mainScript);
    [jsController evalJSFile:mainScript];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self setupFromAppArguments];
    [self setupCocos2d];
    
    [self setupJavaScript];
}

@end
