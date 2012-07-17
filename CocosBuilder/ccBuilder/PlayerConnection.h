//
//  PlayerConnection.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThoMoClientStub.h"

@class PlayerConnection;

@protocol PlayerConnectionDelegate <NSObject>

- (void) playerConnection: (PlayerConnection*)playerConn updatedPlayerList:(NSDictionary*)playerList;
- (void) playerConnection:(PlayerConnection *)playerConn receivedResult:(NSString*)result;

@end

@interface PlayerConnection : NSObject<ThoMoClientDelegateProtocol>
{
    ThoMoClientStub* client;
    
    NSMutableDictionary* connectedServers;
    NSString* selectedServer;
    
    NSObject<PlayerConnectionDelegate>* delegate;
}

@property (nonatomic,retain) NSObject<PlayerConnectionDelegate>* delegate;
@property (nonatomic,readonly) NSDictionary* connectedServers;
@property (nonatomic,copy) NSString* selectedServer;
@property (nonatomic,readonly) BOOL connected;

+ (PlayerConnection*) sharedPlayerConnection;

- (void) run;
- (void) updatePairing;

- (void) sendResourceZip:(NSString*) zipPath;
- (void) sendRunCommand;
- (void) sendStopCommand;
- (void) sendJavaScript:(NSString*)script;
@end