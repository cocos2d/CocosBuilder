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

#import <Foundation/Foundation.h>
#import "ThoMoClientStub.h"

@class PlayerConnection;
@class ProjectSettings;
@class PlayerDeviceInfo;
@class DebuggerConnection;

@protocol PlayerConnectionDelegate <NSObject>

- (void) playerConnection: (PlayerConnection*)playerConn updatedPlayerList:(NSDictionary*)playerList;
- (void) playerConnection:(PlayerConnection *)playerConn receivedResult:(NSString*)result;
- (void) playerConnection:(PlayerConnection *)playerConn receivedDebuggerResult:(NSString *)result;
@end

@interface PlayerConnection : NSObject<ThoMoClientDelegateProtocol>
{
    ThoMoClientStub* client;
    
    NSMutableDictionary* connectedServers;
    NSString* selectedServer;
    
    NSObject<PlayerConnectionDelegate>* delegate;
    
    DebuggerConnection* dbgConnection;
}

@property (nonatomic,retain) NSObject<PlayerConnectionDelegate>* delegate;
@property (nonatomic,readonly) NSDictionary* connectedServers;
@property (nonatomic,copy) NSString* selectedServer;
@property (nonatomic,readonly) BOOL connected;
@property (nonatomic,readonly) PlayerDeviceInfo* selectedDeviceInfo;
@property (nonatomic,retain) DebuggerConnection* dbgConnection;

+ (PlayerConnection*) sharedPlayerConnection;

- (void) run;
- (void) updatePairing;

- (void) sendResourceZip:(NSString*) zipPath;
- (void) sendProjectSettings:(ProjectSettings*)settings;
- (void) sendRunCommand;
- (void) sendStopCommand;
- (void) sendJavaScript:(NSString*)script;

- (void) debugSendBreakpoints:(NSDictionary*) breakpoints;
- (void) debugConnectionStarted;
- (void) debugConnectionLost;

@end