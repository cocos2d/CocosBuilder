//
//  PlayerController.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ProjectSettings;

@interface PlayerController : NSObject
{
    NSRunningApplication* player;
}


- (void) runPlayerForProject:(ProjectSettings*)ps;

- (void) stopPlayer;

@end
