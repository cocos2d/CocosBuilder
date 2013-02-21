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

#import "cocos2d.h"

#import "AppDelegate.h"
#import "jsb_core.h"

#import "ServerController.h"
#import "PlayerStatusLayer.h"
#import "CCBReader.h"

static BOOL firstTime = YES;

@implementation MyNavigationController

// The available orientations should be defined in the Info.plist file.
// And in iOS 6+ only, you can override it in the Root View controller in the "supportedInterfaceOrientations" method.
// Only valid for iOS 6+. NOT VALID for iOS 4 / 5.
-(NSUInteger)supportedInterfaceOrientations
{
    if (![AppController appController].isJSRunning)
    {
        // iPhone only
        if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
            return UIInterfaceOrientationMaskPortrait;
        
        // iPad only
        return UIInterfaceOrientationMaskPortrait;
    }
    else
    {
        return [AppController appController].deviceOrientations;
    }
}

// Supported orientations. Customize it for your own needs
// Only valid on iOS 4 / 5. NOT VALID for iOS 6.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (![AppController appController].isJSRunning)
    {
        // iPhone only
        if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
            return UIInterfaceOrientationIsPortrait(interfaceOrientation);
        
        // iPad only
        // iPhone only
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    }
    else
    {
		NSUInteger converted = 0;
		switch (interfaceOrientation) {

			case UIDeviceOrientationPortrait:
				converted = UIInterfaceOrientationMaskPortrait;
				break;
			case UIDeviceOrientationPortraitUpsideDown:
				converted = UIInterfaceOrientationMaskPortraitUpsideDown;
				break;
			case UIDeviceOrientationLandscapeRight:
				converted = UIInterfaceOrientationMaskLandscapeRight;
				break;
			case UIDeviceOrientationLandscapeLeft:
				converted = UIInterfaceOrientationMaskLandscapeLeft;
				break;
		}
        if (converted & [AppController appController].deviceOrientations)
			return YES;
		return NO;
    }
}

// This is needed for iOS4 and iOS5 in order to ensure
// that the 1st scene has the correct dimensions
// This is not needed on iOS6 and could be added to the application:didFinish...
-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil) {
		// Run the JS
		//[[JSBCore sharedInstance] runScript:@"main.js"];
		
		// Run it only if it is not already running
		if( firstTime ) {
			[[AppController appController] run];
			firstTime = NO;
		}
	}
}
@end



static AppController* appController = NULL;

@implementation AppController

@synthesize window=window_, navController=navController_, director=director_;
@synthesize deviceOrientations;
@synthesize isJSRunning;
@synthesize hasRetinaDisplay;
@synthesize deviceType;
@synthesize server;

+ (AppController*) appController
{
    return appController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    appController = self;
    
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	
	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];

	// Multiple Touches enabled
	[glView setMultipleTouchEnabled:YES];

	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
	
	director_.wantsFullScreenLayout = YES;
	
	// Display FSP and SPF
	[director_ setDisplayStats:YES];
	
	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];
	
	// attach the openglView to the director
	[director_ setView:glView];
	
	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
//	[director setProjection:kCCDirectorProjection3D];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
    self.hasRetinaDisplay = [director_ enableRetinaDisplay:YES];
    
    if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
    {
        self.deviceType = @"iPhone";
    }
    else
    {
        self.deviceType = @"iPad";
    }
    
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
    
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
    
    
    // Configure CCFileUtils for CocosBuilder
    sharedFileUtils.searchPath =
        [NSArray arrayWithObjects:
         [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ResourcesCCB"],
         [CCBReader ccbDirectoryPath],
         [[NSBundle mainBundle] resourcePath],
         @"js",
         nil];
    sharedFileUtils.enableiPhoneResourcesOniPad = YES;
    sharedFileUtils.searchMode = kCCFileUtilsSearchDirectoryMode;
    [sharedFileUtils buildSearchResolutionsOrder];
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	
	// Create a Navigation Controller with the Director
	navController_ = [[MyNavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;

	// for rotation and other messages
	[director_ setDelegate:navController_];
	
	// set the Navigation Controller as the root view controller
	[window_ setRootViewController:navController_];
	
	// make main window visible
	[window_ makeKeyAndVisible];
	
    // Disable automatic sleep mode
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
	return YES;
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window_ release];
	[navController_ release];
	
	[super dealloc];
}

- (CCScene*) createStatusScene
{
    statusLayer = (PlayerStatusLayer*)[CCBReader nodeGraphFromFile:@"StatusLayer.ccbi"];
    
    CCScene* statusScene = [CCScene node];
    [statusScene addChild:statusLayer];
    
    return statusScene;
}

-(void) run
{
	// Init server
    if (!server)
    {
        server = [[ServerController alloc] init];
        [server start];
		
		[server setNetworkStatus:kCCBNetworkStatusWaiting];
    }

    // Run status scene
    [[CCDirector sharedDirector] runWithScene:[self createStatusScene]];
}

- (void) restartCocos2d
{
    UIView* mainView = [CCDirector sharedDirector].view.superview;
    [[CCDirector sharedDirector].view removeFromSuperview];
    [[CCDirector sharedDirector] end];
    
    director_ = (CCDirectorIOS*)[CCDirector sharedDirector];
    CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
    [glView setMultipleTouchEnabled:YES];
    
    [director_ setView:glView];
    
    [mainView addSubview:glView];
    
    // Create a Navigation Controller with the Director
	navController_ = [[MyNavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
    
	// for rotation and other messages
    
	[director_ setDelegate:navController_];
	
	// set the Navigation Controller as the root view controller
	[window_ setRootViewController:navController_];

    // XXX: There is no need to run a scene now. It will be run later
//    [director_ runWithScene:[CCScene node]];
}

- (void) runJSApp_
{
	NSLog(@"CocosPlayer: starting new game");

    statusLayer = NULL;
    
    NSString* fullScriptPath = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:@"main.js"];
    if (fullScriptPath)
    {
        isJSRunning = YES;
        
        [self restartCocos2d];
        
        // Load fileLookup file
        [[CCFileUtils sharedFileUtils] loadFilenameLookupDictionaryFromFile:@"fileLookup.plist"];
        
        NSLog(@"fileLookup.plist: %@", [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:@"fileLookup.plist"]);
        
        // Run script
        [[JSBCore sharedInstance] runScript:@"main.js"];
        
    }
    else
    {
        NSLog(@"CocosPlayer: Failed to find main.js");
    }
}

- (void) runJSApp
{
    [self performSelector:@selector(runJSApp_) withObject:NULL afterDelay:0];
	server.playerWindowDisplayed = NO;
}

- (void) stopJSApp
{
	if( isJSRunning ) {
		NSLog(@"CocosPlayer: stopping game");
		
		isJSRunning = NO;
		
		[self restartCocos2d];
		[SimpleAudioEngine end];
		if( [director_ runningScene] )
			[director_ replaceScene:[self createStatusScene]];
		else
			[director_ runWithScene:[self createStatusScene]];
	}
}

- (void) updatePairing
{
    [server updatePairing];
}
@end
