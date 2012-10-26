//
//  ServerController.h
//  CocosPlayer
//
//  Created by Viktor Lidholt on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThoMoServerStub.h"
#import "cocos2d.h"

@interface ServerController : NSObject <ThoMoServerDelegateProtocol>
{
    ThoMoServerStub* server;
    
    NSMutableSet* connectedClients;
    
    NSFileHandle* pipeReadHandle;
}

@property (nonatomic,copy) NSString* serverStatus;

- (void) start;
- (void) updatePairing;

- (void) sendDeviceName;
- (void) sendResultString:(NSString*) str;
- (void) sendLog:(NSString*)log;

@end
