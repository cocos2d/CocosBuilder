//
//  DebuggerConnection.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/1/13.
//
//

#import "DebuggerConnection.h"
#import "PlayerConnection.h"

@implementation DebuggerConnection

@synthesize connected;

- (id) initWithPlayerConnection:(PlayerConnection*)pc deviceIP:(NSString*) ip
{
    self = [super init];
    if (!self) return NULL;
    
    NSLog(@"NSHost addresses: %@", [[NSHost currentHost] addresses]);
    
    if ([[[NSHost currentHost] addresses] containsObject:ip])
    {
        deviceIP = [@"localhost" copy];
    }
    else
    {
        deviceIP = [ip copy];
    }
    delegate = pc;
    
    return self;
}

- (void) connect
{
    NSLog(@"connect deviceIP: %@ port: %d", deviceIP, kCCBPlayerDbgPort);
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, /*(CFStringRef)deviceIP*/(CFStringRef)deviceIP, kCCBPlayerDbgPort, &readStream, &writeStream);
    
    inputStream = (NSInputStream *)readStream;
    outputStream = (NSOutputStream *)writeStream;
    
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    [outputStream open];
}

- (void) dealloc
{
    [inputStream release];
    [outputStream release];
    [deviceIP release];
    [super dealloc];
}

- (void) handleLostConnection
{
    if (connected)
    {
        [self willChangeValueForKey:@"connected"];
        connected = NO;
        [self didChangeValueForKey:@"connected"];
        
        [delegate debugConnectionLost];
    }
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)evt
{
    NSString* descr = @"";
    
    if (evt == NSStreamEventNone) descr = @"No Event";
    if (evt & NSStreamEventOpenCompleted) descr = [descr stringByAppendingString:@"OpenCompleted "];
    if (evt & NSStreamEventHasSpaceAvailable) descr = [descr stringByAppendingString:@"HasSpaceAvailable "];
    if (evt & NSStreamEventHasBytesAvailable) descr = [descr stringByAppendingString:@"HasBytesAvailable "];
    if (evt & NSStreamEventEndEncountered) descr = [descr stringByAppendingString:@"EndEncountered "];
    if (evt & NSStreamEventErrorOccurred) descr = [descr stringByAppendingString:@"ErrorOccurred "];
    
    NSLog(@"stream: %@ handleEvent: %@(%d)", stream, descr, (int)evt);
    
    if (stream == outputStream &&  (evt & NSStreamEventHasSpaceAvailable))
    {
        if (!connected)
        {
            [self willChangeValueForKey:@"connected"];
            connected = YES;
            [self didChangeValueForKey:@"connected"];
        
            [delegate debugConnectionStarted];
        }
    }
    
    if (evt & NSStreamEventErrorOccurred)
    {
        NSLog(@"Error: %@", [stream streamError]);
        [self handleLostConnection];
    }
    else if (evt & NSStreamEventEndEncountered)
    {
        //[self handleLostConnection];
    }
}

- (void) shutdown
{
    [inputStream close];
    [outputStream close];
    
    [self willChangeValueForKey:@"connected"];
    connected = NO;
    [self didChangeValueForKey:@"connected"];
    
    [delegate debugConnectionLost];
}

- (void) sendMessage:(NSString*)str
{
    if (!connected) return;
    
    NSLog(@"sendMessage: %@", str);
    
    //if ([outputStream hasSpaceAvailable])
    //{
        const uint8_t * rawstring =
        (const uint8_t *)[str UTF8String];
        [outputStream write:rawstring maxLength:strlen((const char*)rawstring)];
    //}
}

- (void) sendBreakpoints:(NSDictionary*)files
{
    // TODO: Clear breakpoints
    
    // Send new set of breakpoints
    for (NSString* file in files)
    {
        NSSet* bps = [files objectForKey:file];
        for (NSNumber* bp in bps)
        {
            int line = [bp intValue];
            
            NSString* cmd = [NSString stringWithFormat:@"break %@:%d", file, line];
            [self sendMessage:cmd];
        }
    }
}

@end
