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

- (id) initWithPlayerConnection:(PlayerConnection*)pc deviceIP:(NSString*) ip
{
    self = [super init];
    if (!self) return NULL;
    
    deviceIP = [ip copy];
    delegate = pc;
    
    return self;
}

- (void) connect
{
    NSLog(@"connect deviceIP: %@ port: %d", deviceIP, kCCBPlayerDbgPort);
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)deviceIP, kCCBPlayerDbgPort, &readStream, &writeStream);
    
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
    
    if (evt & NSStreamEventErrorOccurred)
    {
        NSLog(@"Error: %@", [stream streamError]);
    }
}

@end
