//
//  PlayerStatusLayer.m
//  CocosPlayer
//
//  Created by Viktor Lidholt on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayerStatusLayer.h"

static PlayerStatusLayer* sharedPlayerStatusLayer = NULL;

@implementation PlayerStatusLayer

+ (PlayerStatusLayer*) sharedInstance
{
    return sharedPlayerStatusLayer;
}

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    sharedPlayerStatusLayer = self;
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    lblStatus = [CCLabelTTF labelWithString:@"Waiting for connections" fontName:@"Helvetica" fontSize:12];
    lblStatus.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:lblStatus];
    
    return self;
}

- (void) setStatus:(NSString*)status
{
    [lblStatus setString:status];
}

@end
