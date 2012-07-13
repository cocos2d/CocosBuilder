//
//  PlayerStatusLayer.h
//  CocosPlayer
//
//  Created by Viktor Lidholt on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface PlayerStatusLayer : CCLayer
{
    CCLabelTTF* lblStatus;
}

+ (PlayerStatusLayer*) sharedInstance;

- (void) setStatus:(NSString*)status;

@end
