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

#import "PlayerController.h"
#import "ProjectSettings.h"

@implementation PlayerController

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    
    return self;
}

- (void) runPlayerForProject:(ProjectSettings*)ps
{
    // Stop the player if it is running
    [self stopPlayer];
    
    NSString *appPath = [[NSBundle mainBundle] pathForResource:@"Player" ofType:@"app"];
    
    // Player dimensions
    int w = 480;
    int h = 320;
    NSArray* arguments = [NSArray arrayWithObjects:
                          ps.publishCacheDirectory,
                          [[NSNumber numberWithInt:w] stringValue],
                          [[NSNumber numberWithInt:h] stringValue],
                          nil];
    
    player = [NSTask launchedTaskWithLaunchPath:[appPath stringByAppendingString:@"/Contents/MacOS/Player"] arguments:arguments];
    [player retain];
}

- (void) stopPlayer
{
    if (player)
    {
        [player terminate];
        [player release];
        player = NULL;
    }
}

@end
