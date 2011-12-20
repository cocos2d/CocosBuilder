//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CocosScene.h"

@class CocosBuilderAppDelegate;

@interface CCBGlobals : NSObject {
    CCNode* rootNode;
    CocosScene* cocosScene;
    CocosBuilderAppDelegate* appDelegate;
    
    // Settings
    int numRuns;
    BOOL hasDonated;
@private
    
}

@property (nonatomic,retain) CCNode* rootNode;
@property (nonatomic,retain) CocosScene* cocosScene;
@property (nonatomic,retain) CocosBuilderAppDelegate* appDelegate;

// Settings
@property (nonatomic,assign) int numRuns;
@property (nonatomic,assign) BOOL hasDonated;

+ (CCBGlobals*) globals;

- (void) writeSettings;

@end
