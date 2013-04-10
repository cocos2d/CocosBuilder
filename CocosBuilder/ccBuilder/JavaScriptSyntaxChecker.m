//
//  JavaScriptSyntaxChecker.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/8/13.
//
//

#import "JavaScriptSyntaxChecker.h"
#import "JavaScriptDocument.h"
#import "SMLSyntaxError.h"

@implementation JavaScriptSyntaxChecker

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    return self;
}

- (void) taskEnded:(NSTask*) task
{
    NSLog(@"Task ended");
    
    NSMutableArray* errors = [NSMutableArray array];
    
    if (task.terminationReason == NSTaskTerminationReasonExit)
    {
        // Last started task has ended, parse the output
        
        NSData* data = [[task.standardOutput fileHandleForReading] readDataToEndOfFile];
        NSString* str = [[[NSString alloc] initWithData:data
                                               encoding:NSUTF8StringEncoding] autorelease];
        
        NSArray* lines = [str componentsSeparatedByString:@"\n"];
        
        for (NSString* line in lines)
        {
            NSArray* comps = [line componentsSeparatedByString:@":"];
            
            // Check for valid format
            if (comps.count < 3) continue;
            
            // Create an error
            SMLSyntaxError* err = [[[SMLSyntaxError alloc] init] autorelease];
            
            err.line = [[comps objectAtIndex:0] intValue];
            err.character = [[comps objectAtIndex:1] intValue];
            err.description = [comps objectAtIndex:2];
            
            // Handle the case that output description contains ":"
            for (int i = 3; i < comps.count; i++)
            {
                err.description = [err.description stringByAppendingFormat:@":%@", [comps objectAtIndex:i]];
            }
            
            // Save error
            [errors addObject:err];
        }
        
        [self.document updateErrors:errors];
    }
    
    [task release];
    syntaxTask = NULL;
}

- (void) checkText:(NSString*)text
{
    if (syntaxTask && syntaxTask.isRunning)
    {
        NSLog(@"terminating task");
        
        // Terminate current task
        [syntaxTask terminate];
        syntaxTask = NULL;
    }  
    
    syntaxTask = [[NSTask alloc] init];
    
    NSString* launchPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"nodejs/bin/local_jshint"];
    
    [syntaxTask setLaunchPath: launchPath];
    [syntaxTask setCurrentDirectoryPath:[launchPath stringByDeletingLastPathComponent]];
    
    NSPipe* outPipe = [NSPipe pipe];
    [syntaxTask setStandardOutput:outPipe];
    
    /*NSMutableArray* args = [NSMutableArray arrayWithObjects:
                            file,
                            nil];
    [pngTask setArguments:args];*/
    
    NSPipe* pipe = [NSPipe pipe];
    [[pipe fileHandleForWriting] writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
    [[pipe fileHandleForWriting] closeFile];
    
    
    [syntaxTask setStandardInput:pipe];
    
    [syntaxTask launch];
    
    syntaxTask.terminationHandler = ^(NSTask *task){
        [self performSelectorOnMainThread:@selector(taskEnded:) withObject:task waitUntilDone:YES];
    };
}

- (void) dealloc
{
    [super dealloc];
}

@end
