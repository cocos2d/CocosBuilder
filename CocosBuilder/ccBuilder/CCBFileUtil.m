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

#import "CCBFileUtil.h"
#import "CCBGlobals.h"
#import "CocosBuilderAppDelegate.h"
#import "CCBDocument.h"
#import "ResolutionSetting.h"

@implementation CCBFileUtil

+ (NSString*) toResolutionIndependentFile:(NSString*)file
{
    CocosBuilderAppDelegate* ad = [CocosBuilderAppDelegate appDelegate];
    
    if (!ad.currentDocument)
    {
        NSLog(@"No document!");
        return file;
    }
    
    NSArray* resolutions = ad.currentDocument.resolutions;
    if (!resolutions)
    {
        NSLog(@"No resolutions!");
        return file;
    }
    
    NSString* fileType = [file pathExtension];
    NSString* fileNoExt = [file stringByDeletingPathExtension];
    
    ResolutionSetting* res = [resolutions objectAtIndex:ad.currentDocument.currentResolution];
    
    for (NSString* ext in res.exts)
    {
        if ([ext isEqualToString:@""]) continue;
        
        NSString* resFile = [NSString stringWithFormat:@"%@-%@.%@",fileNoExt,ext,fileType];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:resFile])
        {
            return resFile;
        }
    }
    return file;
}

+ (NSDate*) modificationDateForFile:(NSString*)file
{
    NSDictionary* attr = [[NSFileManager defaultManager] attributesOfItemAtPath:file error:NULL];
    return [attr objectForKey:NSFileModificationDate];
}

+ (void) setModificationDate:(NSDate*)date forFile:(NSString*)file
{
    NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:
                                   date, NSFileModificationDate, NULL];
    [[NSFileManager defaultManager] setAttributes:attr ofItemAtPath:file error:NULL];
}

@end
