//
//  CCBPublisherTemplate.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 11/27/12.
//
//

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
