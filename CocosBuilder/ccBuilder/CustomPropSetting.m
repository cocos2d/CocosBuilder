//
//  CustomPropSetting.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 8/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomPropSetting.h"

@implementation CustomPropSetting

@synthesize name;
@synthesize type;
@synthesize defaultValue;
@synthesize optimized;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    self.name = @"myCustomProperty";
    self.type = kCCBCustomPropTypeInt;
    self.optimized = NO;
    self.defaultValue = @"0";
    self.value = @"0";
    
    return self;
}

- (void) dealloc
{
    self.name = NULL;
    self.defaultValue = NULL;
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

- (void) setDefaultValue:(NSString *)val
{
    NSString* newVal = [self formatValue:val];
    if (newVal == defaultValue) return;
    
    [defaultValue release];
    defaultValue = [newVal retain];
}

- (void) setType:(int)t
{
    if (t == type) return;
    
    type = t;
    
    self.defaultValue = self.defaultValue;
    self.value = self.value;
}

- (void) setValue:(NSString *)val
{
    if (!val) val = @"";
    
    NSString* newVal = [self formatValue:val];
    if (newVal == value) return;
    
    NSLog(@"setValue: %@", newVal);
    
    [value release];
    value = [newVal retain];
}

- (NSString*) value
{
    if (!value) return @"";
    return value;
}

- (id) copyWithZone:(NSZone*)zone
{
    CustomPropSetting* copy = [[CustomPropSetting alloc] init];
    
    copy.name = name;
    copy.type = type;
    copy.defaultValue = defaultValue;
    copy.optimized = optimized;
    copy.value = value;
    
    return copy;
}

@end
