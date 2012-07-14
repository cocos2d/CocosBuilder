//
//  ServerController.m
//  CocosPlayer
//
//  Created by Viktor Lidholt on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ServerController.h"
#import "PlayerStatusLayer.h"
#import "AppController.h"

#import "ScriptingCore.h"
#import "CCBReader.h"
#import "js_manual_conversions.h"

@implementation ServerController

#pragma mark Initializers and setup

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    connectedClients = [[NSMutableSet alloc] init];
    
    server = [[ThoMoServerStub alloc] initWithProtocolIdentifier:@"CocosPlayer"];
    [server setDelegate:self];
    
    return self;
}

- (void) start
{
    if (server)
    {
        [server start];
        NSLog(@"Server started");
    }
}

#pragma mark Helper methods

- (void) executeJavaScript:(NSString*)script
{
    NSThread *cocos2dThread = [[CCDirector sharedDirector] runningThread];
	
	[cocos2dThread performBlock:^(void) { 
		NSString * string = @"None\n";
		jsval out;
		BOOL success = [[ScriptingCore sharedInstance] evalString:script outVal:&out];
		
		if(success)
		{
			if(JSVAL_IS_BOOLEAN(out))
			{
				string = [NSString stringWithFormat:@"Result(bool): %@.\n", (JSVAL_TO_BOOLEAN(out)) ? @"true" : @"false"];
			}
			else if(JSVAL_IS_INT(out))
			{
				string = [NSString stringWithFormat:@"Result(int): %i.\n", JSVAL_TO_INT(out)];
			}
			else if(JSVAL_IS_DOUBLE(out))
			{
				string = [NSString stringWithFormat:@"Result(double): %d.\n", JSVAL_TO_DOUBLE(out)];
			}
			else if(JSVAL_IS_STRING(out)) {
				NSString *tmp;
				jsval_to_nsstring( [[ScriptingCore sharedInstance] globalContext], out, &tmp );
				string = [NSString stringWithFormat:@"Result(string): %d.\n", tmp];
			}
			else if (JSVAL_IS_VOID(out) )
				string = @"Result(void):\n";
			else if (JSVAL_IS_OBJECT(out) )
				string = @"Result(object):\n";
		}
		else
		{
			string = [NSString stringWithFormat:@"Error evaluating script:\n#############################\n%@\n#############################\n", script];
		}
		
		[server sendToAllClients:string];
		
	}
				  waitUntilDone:NO];
}

- (void) extractZipData:(NSData*)data
{
    NSString* dirPath = [CCBReader ccbDirectoryPath] ;
    NSString* zipPath = [dirPath stringByAppendingPathComponent:@"ccb.zip"];

    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDirectory])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:NULL error:NULL];
    }
    
    if(![data writeToFile:zipPath atomically:YES])
    {
        NSLog(@"Failed to write zip file");
        return;
    }
    
    if (![CCBReader unzipResources:zipPath])
    {
        NSLog(@"Failed to unzip resources");
    }
    
    NSLog(@"Resources unzipped!");
}

- (void) runMain
{
    NSString* fullScriptPath = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:@"main.js"];
    if (fullScriptPath)
    {
        [[ScriptingCore sharedInstance] runScript:@"main.js"];
    }
}

#pragma mark Server callbacks

- (void) server:(ThoMoServerStub *)theServer acceptedConnectionFromClient:(NSString *)aClientIdString
{
    NSLog(@"New Client: %@", aClientIdString);
    [connectedClients addObject:aClientIdString];
    
    NSLog(@"Num connected clients: %d", connectedClients.count);
    
    if (connectedClients.count == 1)
    {
        [[AppController appController] setStatus:@"Connected" forceStop:NO];
        [self sendDeviceName];
    }
    else
    {
        [[AppController appController] setStatus: @"Connected to more than one client" forceStop:YES];
    }
}

- (void)server:(ThoMoServerStub *)theServer lostConnectionToClient:(NSString *)aClientIdString errorMessage:(NSString *)errorMessage
{
    NSLog(@"Lost Client: %@", aClientIdString);
    [connectedClients removeObject:aClientIdString];
    
    if (connectedClients.count == 0)
    {
        [[AppController appController] setStatus:@"Waiting for connections" forceStop:YES];
    }
    else if (connectedClients.count == 1)
    {
        [[AppController appController] setStatus:@"Connected" forceStop:NO];
    }
    else
    {
        [[AppController appController] setStatus: @"Connected to more than one client" forceStop:YES];
    }
}

- (void)serverDidShutDown:(ThoMoServerStub *)theServer
{
    NSLog(@"Server shut down");
    exit(1);
}

- (void)netServiceProblemEncountered:(NSString *)errorMessage onServer:(ThoMoServerStub *)theServer
{
    NSLog(@"Net service problem: %@", errorMessage);
    exit(1);
}

- (void) server:(ThoMoServerStub *)theServer didReceiveData:(id)theData fromClient:(NSString *)aClientIdString
{
    if (connectedClients.count != 1) return;
    
    NSDictionary* msg = theData;
    
    NSString* cmd = [msg objectForKey:@"cmd"];
    
    NSLog(@"cmd: %@", cmd);
    
    if ([cmd isEqualToString:@"script"])
    {
        NSString* script = [msg objectForKey:@"script"];
        [self executeJavaScript:script];
    }
    else if ([cmd isEqualToString:@"run"])
    {
        [self runMain];
    }
    else if ([cmd isEqualToString:@"zip"])
    {
        NSData* zipData = [msg objectForKey:@"data"];
        [self extractZipData:zipData];
    }
}

#pragma mark Sending messages

- (void) sendDeviceName
{
    NSMutableDictionary* msg = [NSMutableDictionary dictionary];
    [msg setObject:@"devicename" forKey:@"cmd"];
    [msg setObject:[[UIDevice currentDevice] name] forKey:@"devicename"];
    
    [server sendToAllClients:msg];
}

#pragma mark Common

- (void) dealloc
{
    [server release];
    [connectedClients release];
    
    [super dealloc];
}

@end
