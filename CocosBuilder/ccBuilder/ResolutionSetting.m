//
//  ResolutionSetting.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ResolutionSetting.h"

@implementation ResolutionSetting

@synthesize enabled;
@synthesize name;
@synthesize width;
@synthesize height;
@synthesize ext;
@synthesize ext_hd;
@synthesize scale;
@synthesize centeredOrigin;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    enabled = NO;
    self.name = @"Custom";
    self.width = 1000;
    self.height = 1000;
    self.ext = @"";
    self.ext_hd = @"";
    self.scale = 1;
    
    return self;
}

- (id) initWithSerialization:(id)serialization
{
    self = [self init];
    if (!self) return NULL;
    
    self.enabled = YES;
    self.name = [serialization objectForKey:@"name"];
    self.width = [[serialization objectForKey:@"width"] intValue];
    self.height = [[serialization objectForKey:@"height"] intValue];
    self.ext = [serialization objectForKey:@"ext"];
    self.ext_hd = [serialization objectForKey:@"ext_hd"];
    self.scale = [[serialization objectForKey:@"scale"] floatValue];
    self.centeredOrigin = [[serialization objectForKey:@"centeredOrigin"] boolValue];
    
    return self;
}

- (id) serialize
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    [dict setObject:name forKey:@"name"];
    [dict setObject:[NSNumber numberWithInt:width] forKey:@"width"];
    [dict setObject:[NSNumber numberWithInt:height] forKey:@"height"];
    [dict setObject:ext forKey:@"ext"];
    [dict setObject:ext_hd forKey:@"ext_hd"];
    [dict setObject:[NSNumber numberWithFloat:scale] forKey:@"scale"];
    [dict setObject:[NSNumber numberWithBool:centeredOrigin] forKey:@"centeredOrigin"];
    
    return dict;
}


- (void) dealloc
{
    self.name = NULL;
    self.ext = NULL;
    self.ext_hd = NULL;
    
    [super dealloc];
}

+ (ResolutionSetting*) settingIPhoneLandscape
{
    ResolutionSetting* setting = [[[ResolutionSetting alloc] init] autorelease];
    
    setting.name = @"iPhone Landscape";
    setting.width = 480;
    setting.height = 320;
    setting.ext = @"";
    setting.ext_hd = @"hd";
    setting.scale = 1;
    
    return setting;
}

+ (ResolutionSetting*) settingIPhonePortrait
{
    ResolutionSetting* setting = [[[ResolutionSetting alloc] init] autorelease];
    
    setting.name = @"iPhone Portrait";
    setting.width = 320;
    setting.height = 480;
    setting.ext = @"";
    setting.ext_hd = @"hd";
    setting.scale = 1;
    
    return setting;
}

+ (ResolutionSetting*) settingIPadLandscape
{
    ResolutionSetting* setting = [[[ResolutionSetting alloc] init] autorelease];
    
    setting.name = @"iPad Landscape";
    setting.width = 1024;
    setting.height = 768;
    setting.ext = @"ipad hd";
    setting.ext_hd = @"ipadhd";
    setting.scale = 2;
    
    return setting;
}

+ (ResolutionSetting*) settingIPadPortrait
{
    ResolutionSetting* setting = [[[ResolutionSetting alloc] init] autorelease];
    
    setting.name = @"iPad Portrait";
    setting.width = 768;
    setting.height = 1024;
    setting.ext = @"ipad hd";
    setting.ext_hd = @"ipadhd";
    setting.scale = 2;
    
    return setting;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@ <0x%x> (%d x %d)", NSStringFromClass([self class]), self, width, height];
}

- (id) copyWithZone:(NSZone*)zone
{
    NSLog(@"copyWithZone");
    
    ResolutionSetting* copy = [[ResolutionSetting alloc] init];
    
    copy.enabled = enabled;
    copy.name = name;
    copy.width = width;
    copy.height = height;
    copy.ext = ext;
    copy.ext_hd = ext_hd;
    copy.scale = scale;
    copy.centeredOrigin = centeredOrigin;
    
    return copy;
}

@end
