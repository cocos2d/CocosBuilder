/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2011 Viktor Lidholt
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

#import "CCBAnimationParser.h"
#import "CCBUtil.h"

static NSInteger strSort(id num1, id num2, void *context)
{
    return [(NSString*)num1 compare:num2 options:NSNumericSearch];
}

@implementation CCBAnimationParser

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

+ (BOOL) isAnimationFileDict:(NSDictionary*)dict
{    
    NSNumber* docVersion = [[dict objectForKey:@"properties"] objectForKey:@"format"];
    if (!docVersion) return NO;
    
    if ([docVersion intValue] >= 0 && [docVersion intValue] <= 2)
    {
        if ([dict objectForKey:@"animations"]) return YES;
    }
	return NO;
}

+ (BOOL) isAnimationFile:(NSString*) file
{
	BOOL retVal = NO;
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithContentsOfFile:file];
    
	if( dict )
		retVal = [self isAnimationFileDict:dict];
    return retVal;
}

+ (BOOL) isAnimationFileURL:(NSURL*) url
{
	BOOL retVal = NO;
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithContentsOfURL:url];
    
	if( dict )
		retVal = [self isAnimationFileDict:dict];

    return retVal;
}

+ (NSMutableArray*) listAnimationsInFile:(NSString*)absoluteFile
{
    NSMutableArray* animations = [NSMutableArray array];
    
    if ([CCBAnimationParser isAnimationFile:absoluteFile])
    {
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithContentsOfFile:absoluteFile];
        
        NSDictionary* dictAnimations = [dict objectForKey:@"animations"];
        for (NSString* animation in dictAnimations)
        {
            [animations addObject:animation];
        }
    }
    
    [animations sortUsingFunction:strSort context:NULL];
    
    return animations;
}

@end
