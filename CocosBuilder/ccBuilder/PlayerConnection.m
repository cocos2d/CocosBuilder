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

@synthesize delegate;
@synthesize selectedServer;

+ (PlayerConnection*) sharedPlayerConnection
{
    return  sharedPlayerConnection;
}

- (NSString*) protocolIdentifier
{
    NSString* pairing = [[NSUserDefaults standardUserDefaults] objectForKey:@"pairing"];
    
    if (pairing)
    {
        return [NSString stringWithFormat:@"CocosP-%@",pairing];
    }
    else
    {
        return @"CocosPlayer";
    }
}

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    sharedPlayerConnection = self;
    
    connectedServers = [[NSMutableDictionary alloc] init];
    
    client = [[ThoMoClientStub alloc] initWithProtocolIdentifier:[self protocolIdentifier]];
    client.delegate = self;
    
    return self;
}

- (void) run
{
    [client start];
}

- (void) updatePairing
{
    [client stop];
    [client release];
    [connectedServers removeAllObjects];
    
    client = [[ThoMoClientStub alloc] initWithProtocolIdentifier:[self protocolIdentifier]];
    client.delegate = self;
    [client start];
    
    [selectedServer release];
    selectedServer = NULL;
    
    [delegate playerConnection:self updatedPlayerList:connectedServers];
    
    [self willChangeValueForKey:@"connected"];
    [self didChangeValueForKey:@"connected"];
}

- (void) dealloc
{
    [connectedServers release];
    [selectedServer release];
    [client release];
    [super dealloc];
}

- (NSDictionary*) connectedServers
{
    return connectedServers;
}

- (void) setSelectedServer:(NSString *)server
{
    NSString* serverName = [connectedServers objectForKey:server];
    if (serverName)
    {
        // Server exist
        if (server != selectedServer)
        {
            [selectedServer release];
            selectedServer = [server copy];
        }
    }
    else
    {
        // Server doesn't exist, fall back on current selection
        NSString* currentServerName = [connectedServers objectForKey:selectedServer];
        if (!currentServerName)
        {
            // Current server selection is invalid. Select another one
            if (connectedServers.count == 0)
            {
                // There are no servers
                [selectedServer release];
                selectedServer = NULL;
            }
            else
            {
                // Select another server at random
                [selectedServer release];
                selectedServer = [[[connectedServers keyEnumerator] nextObject] copy];
            }
        }
    }
}

- (void)client:(ThoMoClientStub *)theClient didConnectToServer:(NSString *)aServerIdString
{
    NSLog(@"Connected: %@", aServerIdString);
    
    [connectedServers setObject:aServerIdString forKey:aServerIdString];
    
    // Select the server if no other server is selected
    if (!selectedServer)
    {
        self.selectedServer = aServerIdString;
    }
    
    [delegate playerConnection:self updatedPlayerList:connectedServers];
    
    // Update property
    [self willChangeValueForKey:@"connected"];
    [self didChangeValueForKey:@"connected"];
}


- (void)client:(ThoMoClientStub *)theClient didDisconnectFromServer:(NSString *)aServerIdString errorMessage:(NSString *)errorMessage
{
    NSLog(@"Disconnected: %@", aServerIdString);
    
    [connectedServers removeObjectForKey:aServerIdString];
    
    if ([aServerIdString isEqualToString:selectedServer])
    {
        // Select another server is the current one is disconnected
        [self setSelectedServer:[[connectedServers keyEnumerator] nextObject]];
    }
    
    [delegate playerConnection:self updatedPlayerList:connectedServers];
    
    // Update property
    [self willChangeValueForKey:@"connected"];
    [self didChangeValueForKey:@"connected"];
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
{
    NSDictionary* msg = theData;
    
    NSString* cmd = [msg objectForKey:@"cmd"];
    
    if ([cmd isEqualToString:@"devicename"])
    {
        NSString* serverName = [msg objectForKey:@"devicename"];
        [connectedServers setObject:serverName forKey:aServerIdString];
        [delegate playerConnection:self updatedPlayerList:connectedServers];
        
        NSLog(@"Got device name: %@", serverName);
    }
    else if ([cmd isEqualToString:@"result"])
    {
        NSString* result = [msg objectForKey:@"result"];
        [delegate playerConnection:self receivedResult:result];
    }
}

- (BOOL) connected
{
    if (!selectedServer) return NO;
    if ([connectedServers objectForKey:selectedServer]) return YES;
    return NO;
}

#pragma mark Sending data

- (void) sendMessage:(NSDictionary*) msg
{
    if (![self connected]) return;
    
    [client send:msg toServer:selectedServer];
}

- (void) sendResourceZip:(NSString*) zipPath
{
    NSData* zipData = [NSData dataWithContentsOfFile:zipPath];
    if (!zipData) return;
    
    NSMutableDictionary* msg = [NSMutableDictionary dictionary];
    [msg setObject:@"zip" forKey:@"cmd"];
    [msg setObject:zipData forKey:@"data"];
    
    NSLog(@"Sending zip data (len: %d)", (int)zipData.length);
    [self sendMessage:msg];
}

- (void) sendJavaScript:(NSString*)script
{
    NSMutableDictionary* msg = [NSMutableDictionary dictionary];
    [msg setObject:@"script" forKey:@"cmd"];
    [msg setObject:script forKey:@"script"];
    
    [self sendMessage:msg];
}

- (void) sendRunCommand
{
    NSMutableDictionary* msg = [NSMutableDictionary dictionary];
    [msg setObject:@"run" forKey:@"cmd"];
    
    NSLog(@"Sending run command!");
    [self sendMessage:msg];
}

- (void) sendStopCommand
{
    NSMutableDictionary* msg = [NSMutableDictionary dictionary];
    [msg setObject:@"stop" forKey:@"cmd"];
    
    NSLog(@"Sending stop command!");
    [self sendMessage:msg];
}

@end
