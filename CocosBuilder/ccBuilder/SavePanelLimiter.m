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

#import "SavePanelLimiter.h"
#import "ResourceManager.h"
#import <AppKit/AppKitErrors.h>

@implementation SavePanelLimiter

- (id) initWithPanel:(NSSavePanel*)savePanel resManager:(ResourceManager*)rm
{
    self = [super init];
    if (!self) return NULL;
    
    resManager = [rm retain];
    [savePanel setDelegate:self];
    
    return self;
}

- (void) dealloc
{
    [resManager release];
    [super dealloc];
}


- (BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError **)outError
{
    NSString *path = [url path];
    
    NSArray* activeDirs = resManager.activeDirectories;
    BOOL inProjectPath = NO;
    for (RMDirectory* dir in activeDirs)
    {
        if ([path hasPrefix:dir.dirPath])
        {
            inProjectPath = YES;
            break;
        }
    }
    
    if (!inProjectPath)
    {
        if (outError) *outError = [NSError errorWithDomain:NSCocoaErrorDomain code: NSServiceMiscellaneousError userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"You need to save the ccb-file in a directory that is among your projects resource paths. (You can configure the paths in Project Settings).", @"") forKey:NSLocalizedDescriptionKey]];
        return NO;    
    }
    return YES;
}

@end
