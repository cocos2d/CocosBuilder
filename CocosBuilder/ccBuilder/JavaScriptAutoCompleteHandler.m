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
