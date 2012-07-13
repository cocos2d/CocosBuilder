//
//  PlayerConnection.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayerConnection.h"

static PlayerConnection* sharedPlayerConnection;

@implementation PlayerConnection

+ (PlayerConnection*) sharedPlayerConnection
{
    return  sharedPlayerConnection;
}

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    sharedPlayerConnection = self;
    
    client = [[ThoMoClientStub alloc] initWithProtocolIdentifier:@"CocosPlayer"];
    client.delegate = self;
    
    return self;
}

- (void) run
{
    [client start];
}

- (void) dealloc
{
    [client release];
    [super dealloc];
}

- (void)client:(ThoMoClientStub *)theClient didConnectToServer:(NSString *)aServerIdString
{
    NSLog(@"Connected");
}


- (void)client:(ThoMoClientStub *)theClient didDisconnectFromServer:(NSString *)aServerIdString errorMessage:(NSString *)errorMessage
{
    NSLog(@"Disconnected");
}


- (void)netServiceProblemEncountered:(NSString *)errorMessage onClient:(ThoMoClientStub *)theClient
{
    NSLog(@"Connection problem %@", errorMessage);
}


- (void)clientDidShutDown:(ThoMoClientStub *)theClient
{
    NSLog(@"Client shut down");
}

-(void)client:(ThoMoClientStub *)theClient didReceiveData:(id)theData fromServer:(NSString *)aServerIdString
{}

#pragma mark Sending data

- (void) sendResourceZip:(NSString*) zipPath
{
    NSData* zipData = [NSData dataWithContentsOfFile:zipPath];
    if (!zipData) return;
    
    NSMutableDictionary* msg = [NSMutableDictionary dictionary];
    [msg setObject:@"zip" forKey:@"cmd"];
    [msg setObject:zipData forKey:@"data"];
    
    [client sendToAllServers:msg];
}

@end
