//
//  CustomPropSetting.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 8/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum
{
    kCCBCustomPropTypeInt = 0,
    kCCBCustomPropTypeFloat,
    kCCBCustomPropTypeBool,
    kCCBCustomPropTypeString,
};

@interface CustomPropSetting : NSObject
{
    NSString* name;
    int type;
    NSString* value;
    BOOL optimized;
}

@property (nonatomic,copy) NSString* name;
@property (nonatomic,assign) int type;
@property (nonatomic,assign) BOOL optimized;
@property (nonatomic,copy) NSString* value;

- (id) initWithSerialization:(id)ser;
- (id) serialization;

@end
