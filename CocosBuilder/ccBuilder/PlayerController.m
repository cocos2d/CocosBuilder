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
    NSString *appPath = [[NSBundle mainBundle] pathForResource:@"Player" ofType:@"app"];
    NSURL *appURL = [NSURL fileURLWithPath:appPath];
    
    NSArray* arguments = [NSArray arrayWithObjects:ps.publishCacheDirectory, nil];
    
    [[NSWorkspace sharedWorkspace] launchApplicationAtURL:appURL options:0 configuration:[NSDictionary dictionaryWithObject:arguments forKey:NSWorkspaceLaunchConfigurationArguments] error:NULL];
}

@end
