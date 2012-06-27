//
//  NSString+AppendToFile.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+AppendToFile.h"

@implementation NSString (AppendToFile)

- (BOOL)appendToFile:(NSString *)path usingEncoding:(NSStringEncoding)encoding
{
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:path]; 
    if (fh == nil)
        return [self writeToFile:path atomically:YES encoding:encoding error:nil];
    
    [fh truncateFileAtOffset:[fh seekToEndOfFile]];
    NSData *encoded = [self dataUsingEncoding:encoding];
    
    if (encoded == nil) return NO;
    
    [fh writeData:encoded];
    return YES;
}

@end
