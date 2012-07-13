//
//  PlayerConnection.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThoMoClientStub.h"

@interface PlayerConnection : NSObject<ThoMoClientDelegateProtocol>
{
    ThoMoClientStub* client;
}

+ (PlayerConnection*) sharedPlayerConnection;

- (void) run;

- (void) sendResourceZip:(NSString*) zipPath;
- (void) sendRunCommand;
@end
