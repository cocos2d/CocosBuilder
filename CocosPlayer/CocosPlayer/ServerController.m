//
//  ServerController.m
//  CocosPlayer
//
//  Created by Viktor Lidholt on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ServerController.h"
#import "PlayerStatusLayer.h"
#import "AppDelegate.h"

#import "js_bindings_core.h"
#import "CCBReader.h"

@implementation ServerController

#pragma mark Initializers and setup

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
    
    connectedClients = [[NSMutableSet alloc] init];
    
    server = [[ThoMoServerStub alloc] initWithProtocolIdentifier:[self protocolIdentifier]];
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

- (void) updatePairing
{
    // Stop old server
    [server stop];
    [server release];
    server = NULL;
    [connectedClients removeAllObjects];
    
    // Start new server
    server = [[ThoMoServerStub alloc] initWithProtocolIdentifier:[self protocolIdentifier]];
    [server setDelegate:self];
    [server start];
    
    [[PlayerStatusLayer sharedInstance] setStatus:kCCBStatusStringWaiting];
}

#pragma mark Helper methods

- (void) executeJavaScript:(NSString*)script
{
    NSThread *cocos2dThread = [[CCDirector sharedDirector] runningThread];
	
	[cocos2dThread performBlock:^(void) { 
		NSString * string = @"None\n";
		jsval out;
		BOOL success = [[JSBCore sharedInstance] evalString:script outVal:&out];
		
		if(success)
		{
            /*
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
             */
            string = @"Success\n";
		}
		else
		{
			string = [NSString stringWithFormat:@"Error evaluating script:\n#############################\n%@\n#############################\n", script];
		}
		
		[self sendResultString:string];
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
    
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:NULL];
    for (NSString* file in files)
    {
        NSLog(@"File: %@", file);
    }
}

- (void) stopMain
{
    [[AppController appController] stopJSApp];
}

- (void) runMain
{
    [[AppController appController] runJSApp];
}

#pragma mark Server callbacks

- (void) server:(ThoMoServerStub *)theServer acceptedConnectionFromClient:(NSString *)aClientIdString
{
    NSLog(@"New Client: %@", aClientIdString);
    [connectedClients addObject:aClientIdString];
    
    NSLog(@"Num connected clients: %d", connectedClients.count);
    
    if (connectedClients.count == 1)
    {
        [[AppController appController] setStatus:kCCBStatusStringConnected forceStop:NO];
        [self sendDeviceName];
    }
    else
    {
        [[AppController appController] setStatus: kCCBStatusStringTooMany forceStop:YES];
    }
}

- (void)server:(ThoMoServerStub *)theServer lostConnectionToClient:(NSString *)aClientIdString errorMessage:(NSString *)errorMessage
{
    NSLog(@"Lost Client: %@", aClientIdString);
    [connectedClients removeObject:aClientIdString];
    
    if (connectedClients.count == 0)
    {
        [[AppController appController] setStatus:kCCBStatusStringWaiting forceStop:YES];
    }
    else if (connectedClients.count == 1)
    {
        [[AppController appController] setStatus:kCCBStatusStringConnected forceStop:NO];
    }
    else
    {
        [[AppController appController] setStatus: kCCBStatusStringTooMany forceStop:YES];
    }
}

- (void)serverDidShutDown:(ThoMoServerStub *)theServer
{
}

- (void)netServiceProblemEncountered:(NSString *)errorMessage onServer:(ThoMoServerStub *)theServer
{
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
    else if ([cmd isEqualToString:@"stop"])
    {
        [self stopMain];
    }
    else if ([cmd isEqualToString:@"zip"])
    {
        NSData* zipData = [msg objectForKey:@"data"];
        [self extractZipData:zipData];
    }
    else if ([cmd isEqualToString:@"settings"])
    {
        NSArray* arr = [msg objectForKey:@"orientations"];
        
        NSUInteger orientations = 0;
        
        if ([[arr objectAtIndex:0] boolValue]) orientations |= UIInterfaceOrientationMaskPortrait;
        if ([[arr objectAtIndex:1] boolValue]) orientations |= UIInterfaceOrientationMaskPortraitUpsideDown;
        if ([[arr objectAtIndex:2] boolValue]) orientations |= UIInterfaceOrientationMaskLandscapeLeft;
        if ([[arr objectAtIndex:3] boolValue]) orientations |= UIInterfaceOrientationMaskLandscapeRight;
        
        [AppController appController].deviceOrientations = orientations;
    }
}

#pragma mark Sending messages

- (void) sendMessage:(NSDictionary*) msg
{
    if (connectedClients.count == 1)
    {
        [server sendToAllClients:msg];
    }
}

- (void) sendDeviceName
{
    NSMutableDictionary* msg = [NSMutableDictionary dictionary];
    [msg setObject:@"devicename" forKey:@"cmd"];
    [msg setObject:[[UIDevice currentDevice] name] forKey:@"devicename"];

    [self sendMessage:msg];
}

- (void) sendResultString:(NSString*) str
{
    NSMutableDictionary* msg = [NSMutableDictionary dictionary];
    [msg setObject:@"result" forKey:@"cmd"];
    [msg setObject:str forKey:@"result"];
    
    [self sendMessage:msg];
}

#pragma mark Common

- (void) dealloc
{
    [server release];
    [connectedClients release];
    
    [super dealloc];
}

@end
