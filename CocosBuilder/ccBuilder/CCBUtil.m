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

#import "CCBUtil.h"


@implementation CCBUtil


+ (void) setSelectedSubmenuItemForMenu:(NSMenu*)menu tag:(int)tag
{
    NSArray* items = [menu itemArray];
    for (int i = 0; i < [items count]; i++)
    {
        [[items objectAtIndex:i] setState:NSOffState];
    }
    [[menu itemWithTag:tag] setState:NSOnState];
}

+ (NSArray*) findFilesOfType:(NSString*)type inDirectory:(NSString*)d
{
    NSMutableArray* result = [NSMutableArray array];
    
    NSArray* dir = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:d error:NULL];
    for (int i = 0; i < [dir count]; i++)
    {
        NSString* f = [dir objectAtIndex:i];
        
        if ([[f stringByDeletingPathExtension] hasSuffix:@"-hd"])
        {
            continue;
        }
        
        if ([[[f pathExtension] lowercaseString] isEqualToString:type])
        {
            [result addObject:f];
        }
    }
    
    return result;
}



@end
