//
//  ResolutionSetting.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResolutionSetting : NSObject
{
    BOOL enabled;
    NSString* name;
    int width;
    int height;
    NSString* ext;
    NSString* ext_hd;
    float scale;
    BOOL centeredOrigin;
}

@property (nonatomic,assign) BOOL enabled;
@property (nonatomic,copy) NSString* name;
@property (nonatomic,assign) int width;
@property (nonatomic,assign) int height;
@property (nonatomic,copy) NSString* ext;
@property (nonatomic,copy) NSString* ext_hd;
@property (nonatomic,assign) float scale;
@property (nonatomic,assign) BOOL centeredOrigin;

+ (ResolutionSetting*) settingIPhoneLandscape;
+ (ResolutionSetting*) settingIPhonePortrait;
+ (ResolutionSetting*) settingIPadLandscape;
+ (ResolutionSetting*) settingIPadPortrait;

- (id) initWithSerialization:(id)serialization;

- (id) serialize;

@end
