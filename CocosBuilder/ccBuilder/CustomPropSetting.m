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
@synthesize value;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    self.name = @"myCustomProperty";
    self.type = kCCBCustomPropTypeInt;
    self.optimized = NO;
    self.defaultValue = @"0";
    
    return self;
}

- (void) dealloc
{
    self.name = NULL;
    self.defaultValue = NULL;
    self.value = NULL;
    [super dealloc];
}

- (void) setDefaultValue:(NSString *)val
{
    NSString* newVal = [[val copy] autorelease];
    
    [defaultValue release];
    defaultValue = NULL;
    
    if (type == kCCBCustomPropTypeInt)
    {
        int n = [newVal intValue];
        defaultValue = [[NSString stringWithFormat:@"%d",n] retain];
    }
    else if (type == kCCBCustomPropTypeFloat)
    {
        float f = [newVal floatValue];
        defaultValue = [[NSString stringWithFormat:@"%f",f] retain];
    }
    else if (type == kCCBCustomPropTypeBool)
    {
        BOOL b = [newVal boolValue];
        defaultValue = [[NSString stringWithFormat:@"%d", b] retain];
    }
    else if (type == kCCBCustomPropTypeString)
    {
        defaultValue = [newVal retain];
    }
    else
    {
        NSAssert(NO, @"Undefined value type");
    }
}

- (void) setType:(int)t
{
    if (t == type) return;
    
    type = t;
    
    self.defaultValue = self.defaultValue;
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
