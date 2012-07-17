//
//  PlayerStatusLayer.h
//  CocosPlayer
//
//  Created by Viktor Lidholt on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define kCCBStatusStringWaiting @"Waiting for connections"
#define kCCBStatusStringTooMany @"Too many connections"
#define kCCBStatusStringConnected @"Connected"

@interface PlayerStatusLayer : CCLayer<UITextFieldDelegate>
{
    CCMenuItemImage* btnRun;
    CCMenuItemImage* btnReset;
    CCMenuItemImage* btnPair;
    
    CCLabelTTF* lblStatus;
    CCLabelTTF* lblInstructions;
    CCLabelTTF* lblPair;
}

+ (PlayerStatusLayer*) sharedInstance;

- (void) setStatus:(NSString*)status;

@end
