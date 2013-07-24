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

#import "JavaScriptSyntaxChecker.h"
#import "JavaScriptDocument.h"
#import "SMLSyntaxError.h"
#import "JavaScriptVariableExtractor.h"

@implementation JavaScriptSyntaxChecker

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    return self;
}

- (void) taskEnded:(NSTask*) task
{
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
            if (comps.count < 5) continue;
            
            // Create an error
            SMLSyntaxError* err = [[[SMLSyntaxError alloc] init] autorelease];
            
            err.line = [[comps objectAtIndex:0] intValue];
            err.character = [[comps objectAtIndex:1] intValue];
            err.code = [comps objectAtIndex:2];
            err.length = [[comps objectAtIndex:3] intValue];
            err.description = [comps objectAtIndex:4];
            
            // Handle the case that output description contains ":"
            for (int i = 5; i < comps.count; i++)
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
    
    NSPipe* pipe = [NSPipe pipe];
    [[pipe fileHandleForWriting] writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
    [[pipe fileHandleForWriting] closeFile];
    
    
    [syntaxTask setStandardInput:pipe];
    
    [syntaxTask launch];
    
    syntaxTask.terminationHandler = ^(NSTask *task){
        [self performSelectorOnMainThread:@selector(taskEnded:) withObject:task waitUntilDone:YES];
    };
    
    //JavaScriptVariableExtractor* extractor = [[[JavaScriptVariableExtractor alloc] init] autorelease];
    //[extractor parseScript:text];
    
    //NSLog(@"output: %@ errors: %d", extractor.variableNames, extractor.hasErrors);
}

- (void) dealloc
{
    [super dealloc];
}

@end
