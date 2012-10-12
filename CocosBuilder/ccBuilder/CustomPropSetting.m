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

#import "CustomPropSetting.h"

@implementation CustomPropSetting

@synthesize name;
@synthesize type;
@synthesize optimized;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    self.name = @"myCustomProperty";
    self.type = kCCBCustomPropTypeInt;
    self.optimized = NO;
    self.value = @"0";
    
    return self;
}

- (id) initWithSerialization:(id)ser
{
    self = [super init];
    if (!self) return NULL;
    
    self.name = [ser objectForKey:@"name"];
    self.type = [[ser objectForKey:@"type"] intValue];
    self.optimized = [[ser objectForKey:@"optimized"] boolValue];
    self.value = [ser objectForKey:@"value"];
    
    return self;
}

- (id) serialization
{
    NSMutableDictionary* ser = [NSMutableDictionary dictionary];
    
    [ser setObject:name forKey:@"name"];
    [ser setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    [ser setObject:[NSNumber numberWithBool:optimized] forKey:@"optimized"];
    [ser setObject:value forKey:@"value"];
    
    return ser;
}

- (void) dealloc
{
    self.name = NULL;
    self.value = NULL;
    [super dealloc];
}

- (NSString*) formatValue:(NSString*) val
{
    if (type == kCCBCustomPropTypeInt)
    {
        int n = [val intValue];
        return [NSString stringWithFormat:@"%d",n];
    }
    else if (type == kCCBCustomPropTypeFloat)
    {
        float f = [val floatValue];
        return [NSString stringWithFormat:@"%f",f];
    }
    else if (type == kCCBCustomPropTypeBool)
    {
        BOOL b = [val boolValue];
        return [NSString stringWithFormat:@"%d", b];
    }
    else if (type == kCCBCustomPropTypeString)
    {
        return val;
    }
    else
    {
        NSAssert(NO, @"Undefined value type");
        return NULL;
    }
}

- (void) setType:(int)t
{
    if (t == type) return;
    
    type = t;
    
    self.value = self.value;
}

- (void) setValue:(NSString *)val
{
    if (!val) val = @"";
    
    NSString* newVal = [self formatValue:val];
    if (newVal == value) return;
    
    [value release];
    value = [newVal retain];
}

- (NSString*) value
{
    if (!value) return [self formatValue: @""];
    return value;
}

- (id) copyWithZone:(NSZone*)zone
{
    CustomPropSetting* copy = [[CustomPropSetting alloc] init];
    
    copy.name = name;
    copy.type = type;
    copy.optimized = optimized;
    copy.value = value;
    
    return copy;
}

@end
