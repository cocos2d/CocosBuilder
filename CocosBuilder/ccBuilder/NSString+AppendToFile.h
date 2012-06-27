//
//  NSString+AppendToFile.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AppendToFile)

- (BOOL)appendToFile:(NSString *)path usingEncoding:(NSStringEncoding)encoding;

@end
