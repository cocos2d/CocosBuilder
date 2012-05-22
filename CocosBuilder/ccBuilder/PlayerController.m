//
//  PlayerController.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayerController.h"
#import "ProjectSettings.h"

@implementation PlayerController

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    
    return self;
}

- (void) runPlayerForProject:(ProjectSettings*)ps
{
    // Stop the player if it is running
    [self stopPlayer];
    
    NSString *appPath = [[NSBundle mainBundle] pathForResource:@"Player" ofType:@"app"];
    
    // Player dimensions
    int w = 480;
    int h = 320;
    NSArray* arguments = [NSArray arrayWithObjects:
                          ps.publishCacheDirectory,
                          [[NSNumber numberWithInt:w] stringValue],
                          [[NSNumber numberWithInt:h] stringValue],
                          nil];
    
    player = [NSTask launchedTaskWithLaunchPath:[appPath stringByAppendingString:@"/Contents/MacOS/Player"] arguments:arguments];
    [player retain];
}

- (void) stopPlayer
{
    if (player)
    {
        [player terminate];
        [player release];
        player = NULL;
    }
}

@end
