//
//  JavaScriptAutoCompleteHandler.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/12/13.
//
//

#import "JavaScriptAutoCompleteHandler.h"
#import "JavaScriptVariableExtractor.h"

id gJavaScriptAutoCompleteHandler = NULL;

@implementation JavaScriptAutoCompleteHandler

+ (id) sharedAutoCompleteHandler
{
    if (!gJavaScriptAutoCompleteHandler)
    {
        gJavaScriptAutoCompleteHandler = [[JavaScriptAutoCompleteHandler alloc] init];
    }
    return gJavaScriptAutoCompleteHandler;
}

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    globalVariableNames = [[NSMutableSet alloc] init];
    localFiles = [[NSMutableDictionary alloc] init];
    localFunctionNames = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (void) loadGlobalFile:(NSString*) file
{
    NSString* script = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:NULL];
    
    JavaScriptVariableExtractor* extractor = [[[JavaScriptVariableExtractor alloc] init] autorelease];
    
    [extractor parseScript:script];
    
    [globalVariableNames unionSet: extractor.variableNames];
}

- (void) loadGlobalFilesFromDirectory:(NSString*) dir
{
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:NULL];
    
    // Iterate through all JS files
    for (NSString* file in files)
    {
        if ([[[file pathExtension] lowercaseString] isEqualToString:@"js"])
        {
            // Found JS File, add it
            [self loadGlobalFile:[dir stringByAppendingPathComponent:file]];
        }
    }
}

- (void) loadLocalFile:(NSString*) file script:(NSString*)script addWithErrors:(BOOL) addWithErrors
{
    JavaScriptVariableExtractor* extractor = [[[JavaScriptVariableExtractor alloc] init] autorelease];
    
    [extractor parseScript:script];
    
    if (addWithErrors || !extractor.hasErrors)
    {
        [localFiles setObject:extractor.variableNames forKey:file];
        [localFunctionNames setObject:extractor.functionLocations forKey:file];
    }
}

- (void) loadLocalFile:(NSString*) file
{
    NSString* script = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:NULL];
    [self loadLocalFile:file script:script addWithErrors:YES];
}

- (void) removeLocalFiles
{
    [localFiles removeAllObjects];
}

- (NSArray*) completions
{
    NSMutableSet* completions = [NSMutableSet set];
    
    [completions unionSet:globalVariableNames];
    
    for (NSString* key in localFiles)
    {
        NSSet* localVariableNames = [localFiles objectForKey:key];
        [completions unionSet:localVariableNames];
    }
    
    return [[completions allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (NSArray*) functionLocationsForFile:(NSString*)file
{
    return [localFunctionNames objectForKey:file];
}

- (void) dealloc
{
    [globalVariableNames release];
    [localFunctionNames release];
    [localFiles release];
    
    [super dealloc];
}

@end
