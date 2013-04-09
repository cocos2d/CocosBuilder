//
//  JavaScriptSyntaxChecker.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/8/13.
//
//

#import "JavaScriptSyntaxChecker.h"

@implementation JavaScriptSyntaxChecker

- (id) initWithFile:(NSString*)f
{
    self = [super init];
    if (!self) return NULL;
    
    file = [f copy];
    
    return self;
}

- (NSArray*) errors
{
    NSTask* pngTask = [[NSTask alloc] init];
    
    NSString* launchPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"nodejs/bin/local_jshint"];
    
    NSLog(@"launchPath: %@", launchPath);
    
    [pngTask setLaunchPath: launchPath];
    [pngTask setCurrentDirectoryPath:[launchPath stringByDeletingLastPathComponent]];
    
    NSMutableArray* args = [NSMutableArray arrayWithObjects:
                            file,
                            nil];
    [pngTask setArguments:args];
    [pngTask launch];
    [pngTask waitUntilExit];
    
    [pngTask release];
    
    
    return NULL;
}

- (void) dealloc
{
    [file release];
    [super dealloc];
}

@end
