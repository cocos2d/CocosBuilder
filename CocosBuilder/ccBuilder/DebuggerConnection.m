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
    
    if ([why isEqualToString:@"onBreakpoint"] || [why isEqualToString:@"onStep"])
    {
        NSString* fileName = [[data objectForKey:@"jsfilename"] lastPathComponent];
        int lineNumber = [[data objectForKey:@"linenumber"] intValue];
        
        [ad openJSFile:[ad.resManager toAbsolutePath:fileName] highlightLine:lineNumber];
    }
    else if ([why isEqualToString:@"commandresponse"])
    {
        NSString* commandName = [data objectForKey:@"commandname"];
        
        if ([commandName isEqualToString:@"eval"])
        {
            NSString* stringResult = [data objectForKey:@"stringResult"];
            if (stringResult && stringResult.length > 0)
            {
                // Add a trailing newline if there is no in the string
                if ([stringResult characterAtIndex:stringResult.length-1] != '\n')
                {
                    stringResult = [stringResult stringByAppendingString:@"\n"];
                }
            
                [delegate.delegate playerConnection:delegate receivedDebuggerResult:stringResult];
            }
        }
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
        return;
    }
    
    if (lineBreakLocation == 0)
    {
        // Got an empty message, skip and try again
        [inputData replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:0];
        [self handleWriteToInputData];
        return;
    }
    
    // Read message
    NSData* message = [inputData subdataWithRange:NSMakeRange(0, lineBreakLocation-1)];
    id response = [NSJSONSerialization JSONObjectWithData:message options:0 error:NULL];
    
    if (!response)
    {
        NSLog(@"Failed to parse message len: %d msg: %@", (int)lineBreakLocation, [[[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding] autorelease]);
    }
    
    [self handleMessage:response];
    
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
    
    if (stream == outputStream &&  (evt & NSStreamEventHasSpaceAvailable))
    {
        if (!connected)
        {
            // Set connected property
            [self willChangeValueForKey:@"connected"];
            connected = YES;
            [self didChangeValueForKey:@"connected"];
            
            // Switch to JSON for debugger output
            [self sendMessage:@"uiresponse json"];
            
            // Notify delegate that debug session started
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
    
    str = [str stringByAppendingString:@"\n"];
    
    const uint8_t * rawstring = (const uint8_t *)[str UTF8String];
    [outputStream write:rawstring maxLength:strlen((const char*)rawstring)];
}

- (void) sendBreakpoints:(NSDictionary*)files
{
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
