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

#import "CCBPublisherTemplate.h"

@implementation CCBPublisherTemplate

@synthesize contents;

- (id) initWithTemplateFile:(NSString*)fileName
{
    self = [super init];
    if (!self) return NULL;
    
    NSString* absFile = [[NSBundle mainBundle] pathForResource:fileName ofType:@"" inDirectory:@"publishTemplates"];
    
    //NSLog(@"fileName: %@ absFile: %@", fileName, absFile);
    
    self.contents = [NSString stringWithContentsOfFile:absFile encoding:NSUTF8StringEncoding error:NULL];
    
    //NSLog(@"initWithTemplateFile: %@ contents: %@", fileName, contents);
    
    return self;
}

+ (id) templateWithFile:(NSString*)fileName
{
    return [[[self alloc] initWithTemplateFile:fileName] autorelease];
}

- (void) setString:(NSString*)str forMarker:(NSString*)marker
{
    self.contents = [contents stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<#%@#>",marker] withString:str];
}

- (void) setStrings:(NSArray*)strs forMarker:(NSString*)marker prefix:(NSString*)prefix suffix:(NSString*)suffix
{
    NSString* complete = @"";
    for (NSString* inner in strs)
    {
        NSString* str = [NSString stringWithFormat:@"%@%@%@",prefix,inner,suffix];
        complete = [complete stringByAppendingString:str];
    }
    
    [self setString:complete forMarker:marker];
}

- (void) writeToFile:(NSString*)fileName
{
    [contents writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    
    //NSLog(@"writeToFile: %@ contents: %@", fileName, contents);
}

- (void) dealloc
{
    [contents release];
    [super dealloc];
}

@end
