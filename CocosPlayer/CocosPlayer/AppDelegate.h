//
//  AppDelegate.h
//  CocosPlayer
//
//  Created by Viktor Lidholt on 10/11/12.
//  Copyright Zynga 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@class ServerController;
@class PlayerStatusLayer;

// Added only for iOS 6 support
@interface MyNavigationController : UINavigationController <CCDirectorDelegate>
@end

@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window_;
	MyNavigationController *navController_;
	
	CCDirectorIOS	*director_;							// weak ref
    
    ServerController* server;
    NSString* serverStatus;
    PlayerStatusLayer* statusLayer;
    
    BOOL isJSRunning;
    NSUInteger deviceOrientations;
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) MyNavigationController *navController;
@property (readonly) CCDirectorIOS *director;
@property (nonatomic, readonly) BOOL isJSRunning;
@property (nonatomic, assign) NSUInteger deviceOrientations;

+ (AppController*) appController;

- (void) setStatus:(NSString*)status forceStop:(BOOL)forceStop;

- (void) run;
- (void) runJSApp;
- (void) stopJSApp;

- (void) updatePairing;

@end
