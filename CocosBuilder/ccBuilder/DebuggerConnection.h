//
//  DebuggerConnection.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/1/13.
//
//

#define kCCBPlayerDbgPort 1337

#import <Foundation/Foundation.h>

@class PlayerConnection;

@interface DebuggerConnection : NSObject <NSStreamDelegate>
{
    NSString* deviceIP;
    PlayerConnection* delegate;
    
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
}

- (id) initWithPlayerConnection:(PlayerConnection*)pc deviceIP:(NSString*) ip;
- (void) connect;

@end
