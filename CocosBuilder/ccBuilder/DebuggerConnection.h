//
//  DebuggerConnection.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/1/13.
//
//

#define kCCBPlayerDbgPort 5086
#define kCCBInputBufferSize 10240

#import <Foundation/Foundation.h>

@class PlayerConnection;

@interface DebuggerConnection : NSObject <NSStreamDelegate>
{
    NSString* deviceIP;
    PlayerConnection* delegate;
    
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    
    BOOL connected;
    
    uint8_t* inputBuffer;
    NSMutableData* inputData;
}

@property (nonatomic,readonly) BOOL connected;

- (id) initWithPlayerConnection:(PlayerConnection*)pc deviceIP:(NSString*) ip;
- (void) connect;
- (void) shutdown;
- (void) sendMessage:(NSString*)msg;
- (void) sendBreakpoints:(NSDictionary*)files;
- (void) sendContinue;
- (void) sendStep;

@end
