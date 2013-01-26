/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "ServerController.h"
#import "PlayerStatusLayer.h"
#import "AppDelegate.h"

#import "js_bindings_core.h"
#import "CCBReader.h"

// Predefined messages
NSString *kCCBNetworkStatusStringWaiting = @"Waiting for connections";
NSString *kCCBNetworkStatusStringTooMany = @"Too many connections";
NSString *kCCBNetworkStatusStringConnected = @"Connected";
NSString *kCCBNetworkStatusStringShutDown = @"Server shut down";

NSString *kCCBPlayerStatusStringNotConnected = @"Connect by running CocosBuilder on the same local wireless network as CocosPlayer.\nIf multiple instances of CocosBuilder is run on the same network, use a unique pairing code.";
NSString *kCCBPlayerStatusStringIdle = @"Idle";
NSString *kCCBPlayerStatusStringUnzip = @"Action: Unzip game";
NSString *kCCBPlayerStatusStringStop = @"Action: Stop";
NSString *kCCBPlayerStatusStringPlay = @"Action: Run";
NSString *kCCBPlayerStatusStringScript = @"Action: Executing script";


@implementation ServerController

@synthesize networkStatus, playerStatus;

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
    
	networkStatus = -1;
	playerStatus = -1;
	playerWindowDisplayed = YES;
	
    return self;
}

#pragma mark Redirection of std out

- (void) redirectStdErr
{
    NSPipe* pipe = [NSPipe pipe];
    pipeReadHandle = [pipe fileHandleForReading];
    
    [pipeReadHandle readInBackgroundAndNotify];
    
    int err = dup2([[pipe fileHandleForWriting] fileDescriptor], STDERR_FILENO);
    if (!err) NSLog(@"ConsoleWindow: Failed to redirect stderr");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readData:) name:NSFileHandleReadCompletionNotification object:pipeReadHandle];
    
    [pipeReadHandle retain];
}

- (void) readData:(NSNotification*)notification
{
    [pipeReadHandle readInBackgroundAndNotify] ;
    NSString *str = [[NSString alloc] initWithData: [[notification userInfo] objectForKey: NSFileHandleNotificationDataItem] encoding: NSASCIIStringEncoding] ;
    [self sendLog:str];
}

#pragma mark Control methods

- (void) start
{
    if (server)
    {
        NSLog(@"start");
        
        [server start];
        NSLog(@"Server started, redirecting stderr");
        
        // Redirect std out
        [self redirectStdErr];
    }
}

- (void) startIfNotStarted
{
    if (!server)
    {
        NSLog(@"startIfNotStarted");
        
        server = [[ThoMoServerStub alloc] initWithProtocolIdentifier:[self protocolIdentifier]];
        [server setDelegate:self];
        [server start];
        
        [[[PlayerStatusLayer sharedInstance] lblStatus] setString:kCCBNetworkStatusStringWaiting];
		
		
    }
}

- (void) stop
{
    if (server)
    {
		self.networkStatus = kCCBPlayerStatusStop;
		[[[PlayerStatusLayer sharedInstance] lblInstructions] setString:kCCBPlayerStatusStringStop];

        NSLog(@"stop");
        
        [server stop];
        [server release];
        server = NULL;
        [connectedClients removeAllObjects];
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
    
    [[[PlayerStatusLayer sharedInstance] lblStatus] setString:kCCBNetworkStatusStringWaiting];
}

#pragma mark Helper methods

- (void) executeJavaScript:(NSString*)script
{
	self.playerStatus = kCCBPlayerStatusExecuteScript;
		
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
		
		//[self sendResultString:string];
	}
				  waitUntilDone:NO];
}

- (void) listDirectory:(NSString*)dir prefix:(NSString*)prefix
{
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:NULL];
    for (NSString* file in files)
    {
        NSLog(@"%@%@", prefix, file);
        
        BOOL isDir = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:[dir stringByAppendingPathComponent:file] isDirectory:&isDir] && isDir)
        {
            [self listDirectory:[dir stringByAppendingPathComponent:file] prefix:[prefix stringByAppendingString:@"  "]];
        }
    }
}

- (void) extractZipData:(NSData*)data
{
	self.playerStatus = kCCBPlayerStatusUnzip;

	id runBlock = ^(void) {
		
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
		
		[self listDirectory:dirPath prefix:@""];
		
		/*
		 NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:NULL];
		 for (NSString* file in files)
		 {
		 NSLog(@"File: %@", file);
		 }*/
	};

	double delayInSeconds = 0.01;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), runBlock);
}

-(void) stopJSApp
{
	[[AppController appController] stopJSApp];
	playerWindowDisplayed = YES;
}

-(void) runJSApp
{
	[[AppController appController] runJSApp];
	playerWindowDisplayed = NO;	
}

- (void) stopMain
{
	if( playerStatus == kCCBPlayerStatusPlay ) {
		self.playerStatus = kCCBPlayerStatusStop;
		
		NSThread *cocos2dThread = [[CCDirector sharedDirector] runningThread];
		
		[cocos2dThread performBlock:^(void) {
			[self stopJSApp];
		} waitUntilDone:YES];
		
		// Force update network status
		CCBNetworkStatus tmp = networkStatus;
		networkStatus = -1;
		self.networkStatus = tmp;
	}
}

- (void) runMain
{
	double delayInSeconds = 0.05;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		self.playerStatus = kCCBPlayerStatusPlay;
		[self runJSApp];
	});

}

#pragma mark Server callbacks

- (void) server:(ThoMoServerStub *)theServer acceptedConnectionFromClient:(NSString *)aClientIdString
{
    NSLog(@"New Client: %@", aClientIdString);
    [connectedClients addObject:aClientIdString];
    
    NSLog(@"Num connected clients: %d", connectedClients.count);
    
    if (connectedClients.count == 1)
    {
		self.networkStatus = kCCBNetworkStatusConnected;
        [self sendDeviceName];
    }
    else
    {
		self.networkStatus = kCCBNetworkStatusTooMany;
    }
}

- (void)server:(ThoMoServerStub *)theServer lostConnectionToClient:(NSString *)aClientIdString errorMessage:(NSString *)errorMessage
{
    NSLog(@"Lost Client: %@", aClientIdString);
    [connectedClients removeObject:aClientIdString];
    
    if (connectedClients.count == 0)
    {
		self.networkStatus =  kCCBNetworkStatusWaiting;
    }
    else if (connectedClients.count == 1)
    {
		self.networkStatus = kCCBNetworkStatusConnected;
    }
    else
    {
		self.networkStatus = kCCBNetworkStatusTooMany;
    }
}

- (void)serverDidShutDown:(ThoMoServerStub *)theServer
{
    NSLog(@"serverDidShutdown server: %@",server);
    
    [server release];
    server = NULL;
    [connectedClients removeAllObjects];
    
    [self startIfNotStarted];
}

- (void)netServiceProblemEncountered:(NSString *)errorMessage onServer:(ThoMoServerStub *)theServer
{
    [server stop];
    [server release];
    server = NULL;
    [connectedClients removeAllObjects];
}

- (void) server:(ThoMoServerStub *)theServer didReceiveData:(id)theData fromClient:(NSString *)aClientIdString
{
    if (connectedClients.count != 1) return;
    
    NSDictionary* msg = theData;
    
    NSString* cmd = [msg objectForKey:@"cmd"];
    
    //NSLog(@"cmd: %@", cmd);
    
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

#pragma mark Server/Player status

-(void) setNetworkStatus:(CCBNetworkStatus)aNetworkStatus
{
	if( networkStatus != aNetworkStatus ) {
		networkStatus = aNetworkStatus;
		
		PlayerStatusLayer *statusLayer = [PlayerStatusLayer sharedInstance];
		switch (networkStatus) {
			case kCCBNetworkStatusConnected:
				if( playerWindowDisplayed)
					[[statusLayer lblStatus] setString:kCCBNetworkStatusStringConnected];
				self.playerStatus = kCCBPlayerStatusIdle;
				break;
			case kCCBNetworkStatusShutDown:
				if( playerWindowDisplayed)
					[[statusLayer lblStatus] setString:kCCBNetworkStatusStringShutDown];
				self.playerStatus = kCCBPlayerStatusNotConnected;
				break;
			case kCCBNetworkStatusTooMany:
				if( playerWindowDisplayed)
					[[statusLayer lblStatus] setString:kCCBNetworkStatusStringTooMany];
				[self stopJSApp];
				self.playerStatus = kCCBPlayerStatusNotConnected;
				break;
			case kCCBNetworkStatusWaiting:
				if( playerWindowDisplayed)
					[[statusLayer lblStatus] setString:kCCBNetworkStatusStringWaiting];
				[self stopJSApp];
				break;
				
			default:
				break;
		}
	}
}

-(void) setPlayerStatus:(CCBPlayerStatus)aPlayerStatus
{
	if( playerStatus != aPlayerStatus) {
		playerStatus = aPlayerStatus;
		
		PlayerStatusLayer *statusLayer = [PlayerStatusLayer sharedInstance];

		switch (playerStatus) {
			case kCCBPlayerStatusExecuteScript:
				if( playerWindowDisplayed)
					[[statusLayer lblInstructions] setString:kCCBPlayerStatusStringScript];
				break;
			case kCCBPlayerStatusPlay:
				if( playerWindowDisplayed)
					[[statusLayer lblInstructions] setString:kCCBPlayerStatusStringPlay];
				break;
			case kCCBPlayerStatusStop:
				if( playerWindowDisplayed)
					[[statusLayer lblInstructions] setString:kCCBPlayerStatusStringStop];
				break;
			case kCCBPlayerStatusUnzip:
				if( playerWindowDisplayed)
					[[statusLayer lblInstructions] setString:kCCBPlayerStatusStringUnzip];
				break;
			case kCCBPlayerStatusIdle:
				if( playerWindowDisplayed)
					[[statusLayer lblInstructions] setString:kCCBPlayerStatusStringIdle];
				break;
			case kCCBPlayerStatusNotConnected:
				if( playerWindowDisplayed)
					[[statusLayer lblInstructions] setString:kCCBPlayerStatusStringNotConnected];
				break;
				
			default:
				break;
		}
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
    [msg setObject:@"deviceinfo" forKey:@"cmd"];
    [msg setObject:[[UIDevice currentDevice] name] forKey:@"devicename"];
    [msg setObject:[AppController appController].deviceType forKey:@"devicetype"];
    [msg setObject:[NSNumber numberWithBool:[AppController appController].hasRetinaDisplay] forKey:@"retinadisplay"];
    
    [self sendMessage:msg];
}

- (void) sendResultString:(NSString*) str
{
    NSMutableDictionary* msg = [NSMutableDictionary dictionary];
    [msg setObject:@"result" forKey:@"cmd"];
    [msg setObject:str forKey:@"result"];
    
    [self sendMessage:msg];
}

- (void) sendLog:(NSString*)log
{
    NSMutableDictionary* msg = [NSMutableDictionary dictionary];
    [msg setObject:@"log" forKey:@"cmd"];
    [msg setObject:log forKey:@"string"];
    
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
