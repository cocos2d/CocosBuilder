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

#import "NodeInfo.h"
#import "PlugInNode.h"

@implementation NodeInfo

@synthesize plugIn;
@synthesize extraProps;
@synthesize animatableProperties;
@synthesize baseValues;
@synthesize displayName;
@synthesize customProperties;
@synthesize transformStartPosition;

+ (id) nodeInfoWithPlugIn:(PlugInNode*)pin
{
    NodeInfo* info = [[[NodeInfo alloc] init] autorelease];
    info.plugIn = pin;
    return info;
}

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    extraProps = [[NSMutableDictionary alloc] init];
    
    [extraProps setObject:@"" forKey:@"customClass"];
    [extraProps setObject:[NSNumber numberWithBool:YES] forKey:@"isExpanded"];
    [extraProps setObject:[NSNumber numberWithInt:0] forKey:@"memberVarAssignmentType"];
    [extraProps setObject:@"" forKey:@"memberVarAssignmentName"];
    
    self.animatableProperties = [NSMutableDictionary dictionary];
    baseValues = [[NSMutableDictionary alloc] init];
    
    self.customProperties = [NSMutableArray array];
    
    return self;
}

- (void) dealloc
{
    [extraProps release];
    self.animatableProperties = NULL;
    self.displayName = NULL;
    self.customProperties = NULL;
    [baseValues release];
    [super dealloc];
}

@end
