//
//  JavaScriptVariableExtractor.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/11/13.
//
//

#import "JavaScriptVariableExtractor.h"

@implementation JavaScriptVariableExtractor

@synthesize variableNames;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    variableNames = [[NSMutableSet alloc] init];
    
    return self;
}

- (NSString*) substringFromString:(NSString*)str withCheckedRange:(NSRange)range
{
    if (range.location + range.length > str.length) return @"";
    return [str substringWithRange:range];
}

- (void) parseScript:(NSString*) script
{
    NSCharacterSet* variableStartChars = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"];
    NSCharacterSet* variableChars = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789"];
    NSCharacterSet* variableCharsInverted = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_/\"'"] invertedSet];
    
    NSScanner* scanner = [NSScanner scannerWithString:script];
    [scanner setCharactersToBeSkipped:NULL];
    
    while (![scanner isAtEnd])
    {
        // Consume white space
        [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:NULL];
        
        // Get two first characters at current position
        NSString* twoChars = [self substringFromString:script withCheckedRange:NSMakeRange(scanner.scanLocation, 2)];
        
        // Check for // comments
        if ([twoChars isEqualToString:@"//"])
        {
            // Scan until eol
            [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:NULL];
            
            continue;
        }
        
        // Check for /* comments
        if ([twoChars isEqualToString:@"/*"])
        {
            [scanner scanUpToString:@"*/" intoString:NULL];
            scanner.scanLocation += 2;
            
            continue;
        }
        
        NSString* oneChar = [self substringFromString:script withCheckedRange:NSMakeRange(scanner.scanLocation, 1)];
        
        // Skip strings starting with "
        if (oneChar.length == 1 && [oneChar isEqualToString:@"\""])
        {
            openString = YES;
            scanner.scanLocation += 1;
            
            BOOL stringEnded = NO;
            while (!stringEnded && ![scanner isAtEnd])
            {
                [scanner scanUpToString:@"\"" intoString:NULL];
                
                if ([script characterAtIndex:scanner.scanLocation - 1] != '\\')
                {
                    if (![scanner isAtEnd])
                    {
                        openString = NO;
                    }
                    stringEnded = YES;
                }
                
                if (![scanner isAtEnd])
                {
                    scanner.scanLocation += 1;
                }
            }
            
            continue;
        }
        
        // Skip strings starting with '
        if (oneChar.length == 1 && [oneChar isEqualToString:@"'"])
        {
            openString = YES;
            scanner.scanLocation += 1;
            
            [scanner scanUpToString:@"'" intoString:NULL];
            
            if (![scanner isAtEnd])
            {
                openString = NO;
                scanner.scanLocation += 1;
            }
            
            continue;
        }
        
        // Skip lonely slashes
        if (oneChar.length == 1 && [oneChar isEqualToString:@"/"])
        {
            scanner.scanLocation += 1;
        }
        
        // Check for keywords
        if (oneChar.length == 1 && [variableStartChars characterIsMember:[oneChar characterAtIndex:0]])
        {
            NSString* variableName;
            [scanner scanCharactersFromSet:variableChars intoString:&variableName];
            
            [variableNames addObject:variableName];
        }
        
        // Scan up to next keword or comment
        [scanner scanCharactersFromSet:variableCharsInverted intoString:NULL];
    }
}

- (BOOL) hasErrors
{
    return openString;
}

- (void) dealloc
{
    [variableNames release];
    [super dealloc];
}

@end
