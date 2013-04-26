//
//  DebuggerConnection.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/1/13.
//
//

#import "DebuggerConnection.h"
#import "PlayerConnection.h"
#import "CocosBuilderAppDelegate.h"
#import "ResourceManager.h"

@implementation DebuggerConnection

@synthesize connected;

- (id) initWithPlayerConnection:(PlayerConnection*)pc deviceIP:(NSString*) ip
{
    self = [super init];
    if (!self) return NULL;
    
    inputBuffer = malloc(kCCBInputBufferSize);
    inputData = [[NSMutableData data] retain];
    
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
    free(inputBuffer);
    
    [inputStream release];
    [inputData release];
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

- (void) handleMessage:(NSDictionary*) message
{
    CocosBuilderAppDelegate* ad = [CocosBuilderAppDelegate appDelegate];
    
    NSString* why = [message objectForKey:@"why"];
    NSDictionary* data = [message objectForKey:@"data"];
    
    if ([why isEqualToString:@"onBreakpoint"])
    {
        NSString* fileName = [[data objectForKey:@"jsfilename"] lastPathComponent];
        int lineNumber = [[data objectForKey:@"linenumber"] intValue];
        
        [ad openJSFile:[ad.resManager toAbsolutePath:fileName] highlightLine:lineNumber];
    }
}

- (void) handleWriteToInputData
{
    // Scan for end of transmission message
    uint8_t* bytes = (uint8_t*)[inputData bytes];
    
    NSInteger lineBreakLocation = -1;
    for (NSInteger i = 0; i < [inputData length]; i++)
    {
        if (bytes[i] == 23)
        {
            lineBreakLocation = i;
            break;
        }
    }
    
    if (lineBreakLocation == -1)
    {
        // Didn't get a full message
        NSLog(@"NOT FULL JSON: %@ lastChar:%d", [[NSString alloc] initWithData:inputData encoding:NSUTF8StringEncoding], bytes[[inputData length]-1]);
        return;
    }
    
    if (lineBreakLocation == 0)
    {
        // Got an empty message, skip
        NSLog(@"Got an empty message");
        
        [inputData replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:0];
        return;
    }
    
    // Read message
    NSData* message = [inputData subdataWithRange:NSMakeRange(0, lineBreakLocation-1)];
    id response = [NSJSONSerialization JSONObjectWithData:message options:0 error:NULL];
    
    [self handleMessage:response];
    
    NSLog(@"DEBUGGER: %@", response);
    
    if (!response)
    {
        NSLog(@"FAILED JSON: %@", [[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding]);
    }
    
    // Consume message
    [inputData replaceBytesInRange:NSMakeRange(0, lineBreakLocation) withBytes:NULL length:0];
    
    // Check for any additional messages
    [self handleWriteToInputData];
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
    
    if (stream == inputStream && (evt & NSStreamEventHasBytesAvailable))
    {
        NSInteger numBytesRead = [inputStream read:inputBuffer maxLength:kCCBInputBufferSize];
        if (numBytesRead > 0)
        {
            [inputData appendBytes:inputBuffer length:numBytesRead];
            [self handleWriteToInputData];
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
    [[CocosBuilderAppDelegate appDelegate] resetJSFilesLineHighlight];
    
    [self sendMessage:@"clear"];
    [self sendMessage:@"continue"];
    
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
    
    str = [str stringByAppendingString:@"\n"];
    
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
    [self sendMessage:@"clear"];
    
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

- (void) sendContinue
{
    [[CocosBuilderAppDelegate appDelegate] resetJSFilesLineHighlight];
    [self sendMessage:@"continue"];
}

- (void) sendStep
{
    [[CocosBuilderAppDelegate appDelegate] resetJSFilesLineHighlight];
    [self sendMessage:@"step"];
}

@end
