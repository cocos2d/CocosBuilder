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

#import "PlayerConnection.h"
#import "ProjectSettings.h"
#import "PlayerDeviceInfo.h"
#import "DebuggerConnection.h"
#import "CocosBuilderAppDelegate.h"

static PlayerConnection* sharedPlayerConnection;

@implementation PlayerConnection

@synthesize delegate;
@synthesize selectedServer;
@synthesize dbgConnection;

+ (PlayerConnection*) sharedPlayerConnection
{
    return  sharedPlayerConnection;
}

#pragma mark Handle Debugger Connections

- (void) setupDebugConnection
{
    NSLog(@"updatedDebugConnectionForServer: %@", selectedServer);
    
    if (dbgConnection)
    {
        // Shut down old connection
        self.dbgConnection = NULL;
    }
    
    // Start a new dbg connection
    NSString* deviceIP = [[selectedServer componentsSeparatedByString:@":"] objectAtIndex:0];
    
    self.dbgConnection = [[DebuggerConnection alloc] initWithPlayerConnection:self deviceIP:deviceIP];
    [self.dbgConnection connect];
}

- (void) debugSendBreakpoints:(NSDictionary*) breakpoints
{
    [dbgConnection sendBreakpoints:breakpoints];
}

- (void) debugConnectionStarted
{
    // Send list of breakpoints
    [dbgConnection sendBreakpoints: [CocosBuilderAppDelegate appDelegate].projectSettings.breakpoints];
}

- (void) debugConnectionLost
{
    NSLog(@"debugConnectionLost");
    self.dbgConnection = NULL;
}

#pragma mark Server Configuration

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
    
    [self willChangeValueForKey:@"selectedDeviceInfo"];
    [self didChangeValueForKey:@"selectedDeviceInfo"];
}

- (void) dealloc
{
    [dbgConnection release];
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
    PlayerDeviceInfo* deviceInfo = [connectedServers objectForKey:server];
    if (deviceInfo)
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
        PlayerDeviceInfo* currentDeviceInfo = [connectedServers objectForKey:selectedServer];
        if (!currentDeviceInfo)
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
    
    PlayerDeviceInfo* deviceInfo = [[[PlayerDeviceInfo alloc] init] autorelease];
    deviceInfo.identifier = aServerIdString;
    deviceInfo.deviceName = aServerIdString;
    
    [connectedServers setObject:deviceInfo forKey:aServerIdString];
    
    // Select the server if no other server is selected
    if (!selectedServer)
    {
        self.selectedServer = aServerIdString;
    }
    
    [delegate playerConnection:self updatedPlayerList:connectedServers];
    
    // Update properties
    [self willChangeValueForKey:@"connected"];
    [self didChangeValueForKey:@"connected"];
    
    [self willChangeValueForKey:@"selectedDeviceInfo"];
    [self didChangeValueForKey:@"selectedDeviceInfo"];
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
    
    // Update properties
    [self willChangeValueForKey:@"connected"];
    [self didChangeValueForKey:@"connected"];
    
    [self willChangeValueForKey:@"selectedDeviceInfo"];
    [self didChangeValueForKey:@"selectedDeviceInfo"];
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
    
    if ([cmd isEqualToString:@"deviceinfo"])
    {
        PlayerDeviceInfo* deviceInfo = [connectedServers objectForKey:aServerIdString];
        
        deviceInfo.deviceName = [msg objectForKey:@"devicename"];
        deviceInfo.deviceType = [msg objectForKey:@"devicetype"];
        deviceInfo.preferredResourceType = [msg objectForKey:@"preferredresourcetype"];
        deviceInfo.hasRetinaDisplay = [[msg objectForKey:@"retinadisplay"] boolValue];
        deviceInfo.uuid = [msg objectForKey:@"uuid"];
        deviceInfo.populated = YES;
        
        NSLog(@"Connected device with UUID: %@", deviceInfo.uuid);
        
        [delegate playerConnection:self updatedPlayerList:connectedServers];
        
        // Update properties
        [self willChangeValueForKey:@"connected"];
        [self didChangeValueForKey:@"connected"];
        
        [self willChangeValueForKey:@"selectedDeviceInfo"];
        [self didChangeValueForKey:@"selectedDeviceInfo"];
    }
    else if ([cmd isEqualToString:@"result"])
    {
        NSString* result = [msg objectForKey:@"result"];
        [delegate playerConnection:self receivedResult:result];
    }
    else if ([cmd isEqualToString:@"log"])
    {
        NSString* message = [msg objectForKey:@"string"];
        [delegate playerConnection:self receivedResult:message];
    }
    else if ([cmd isEqualToString:@"filelist"])
    {
        PlayerDeviceInfo* deviceInfo = [connectedServers objectForKey:aServerIdString];
        deviceInfo.fileList = [msg objectForKey:@"filelist"];
        
        NSLog(@"Received filelist: %@", deviceInfo.fileList);
    }
    else if ([cmd isEqualToString:@"running"])
    {
        // Player is now running program, connect debugger
        [self performSelector:@selector(setupDebugConnection) withObject:NULL afterDelay:1.0];
    }
}

- (BOOL) connected
{
    NSLog(@"connected (selectedDeviceInfo: %@)",self.selectedDeviceInfo);
    
    if ([self selectedDeviceInfo]) return YES;
    return NO;
}

- (PlayerDeviceInfo*) selectedDeviceInfo
{
    if (!selectedServer) return NULL;
    PlayerDeviceInfo* deviceInfo = [connectedServers objectForKey:selectedServer];
    if (!deviceInfo) return NULL;
    if (deviceInfo.populated) return deviceInfo;
    return NULL;
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
    [dbgConnection sendMessage: script];
    
    /*
    NSMutableDictionary* msg = [NSMutableDictionary dictionary];
    [msg setObject:@"script" forKey:@"cmd"];
    [msg setObject:script forKey:@"script"];
    
    [self sendMessage:msg];
     */
}

- (void) sendProjectSettings:(ProjectSettings*)settings
{
    NSMutableDictionary* msg = [NSMutableDictionary dictionary];
    [msg setObject:@"settings" forKey:@"cmd"];
    
    // Orientations
    NSMutableArray* orientations = [NSMutableArray arrayWithCapacity:4];
    [orientations addObject:[NSNumber numberWithBool:settings.deviceOrientationPortrait]];
    [orientations addObject:[NSNumber numberWithBool:settings.deviceOrientationUpsideDown]];
    [orientations addObject:[NSNumber numberWithBool:settings.deviceOrientationLandscapeLeft]];
    [orientations addObject:[NSNumber numberWithBool:settings.deviceOrientationLandscapeRight]];
    [msg setObject:orientations forKey:@"orientations"];
    
    // Initial break points
    NSDictionary* files = settings.breakpoints;
    NSMutableDictionary* outFiles = [NSMutableDictionary dictionary];
    for (NSString* file in files)
    {
        NSSet* bps = [files objectForKey:file];
        NSMutableArray* outBps = [NSMutableArray array];
        for (NSNumber* bp in bps)
        {
            [outBps addObject:bp];
        }
        
        [outFiles setObject:outBps forKey:file];
    }
    [msg setObject:outFiles forKey:@"breakpoints"];
    NSLog(@"BREAKPOINTS: %@", outFiles);
    
    [self sendMessage:msg];
}

- (void) sendRunCommand
{
    // Send run command
    NSMutableDictionary* msg = [NSMutableDictionary dictionary];
    [msg setObject:@"run" forKey:@"cmd"];
    
    NSLog(@"Sending run command!");
    [self sendMessage:msg];
    
    // Connect debugger
    //[self performSelector:@selector(setupDebugConnection) withObject:NULL afterDelay:2];
}

- (void) sendStopCommand
{
    NSMutableDictionary* msg = [NSMutableDictionary dictionary];
    [msg setObject:@"stop" forKey:@"cmd"];
    
    NSLog(@"Sending stop command!");
    [self sendMessage:msg];
    
    // Also stop debugger connection
    [dbgConnection shutdown];
}

@end
