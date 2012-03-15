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

#import "InspectorStartStop.h"

@implementation InspectorStartStop

@synthesize startName,stopName;

- (id) initWithSelection:(CCNode *)s andPropertyName:(NSString *)pn andDisplayName:(NSString *)dn andExtra:(NSString *)e
{
    self = [super initWithSelection:s andPropertyName:pn andDisplayName:dn andExtra:e];
    if (!self) return NULL;
    
    NSArray* bntNames = [displayName componentsSeparatedByString:@"|"];
    self.startName = [bntNames objectAtIndex:0];
    self.stopName = [bntNames objectAtIndex:1];
    
    NSArray* methodNames = [extra componentsSeparatedByString:@"|"];
    startMethod = [[methodNames objectAtIndex:0] retain];
    stopMethod = [[methodNames objectAtIndex:1] retain];
    
    return self;
}

- (IBAction)pressedStart:(id)sender
{
    SEL selector = NSSelectorFromString(startMethod);
    [selection performSelector:selector];
}

- (IBAction)pressedStop:(id)sender
{
    SEL selector = NSSelectorFromString(stopMethod);
    [selection performSelector:selector];
}

- (void) dealloc
{
    [startMethod release];
    [stopMethod release];
    self.startName = NULL;
    self.stopName = NULL;
    [super dealloc];
}

@end
