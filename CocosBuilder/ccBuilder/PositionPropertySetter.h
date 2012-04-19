//
//  PositionPropertySetter.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

enum
{
    kCCBPositionTypeRelativeBottomLeft,
    kCCBPositionTypeRelativeTopLeft,
    kCCBPositionTypeRelativeTopRight,
    kCCBPositionTypeRelativeBottomRight,
    kCCBPositionTypePercent
};

enum
{
    kCCBSizeTypeAbsolute,
    kCCBSizeTypePercent,
    kCCBSizeTypeRelativeContainer
};

@interface PositionPropertySetter : NSObject

+ (void) setPosition:(CGPoint)pos type:(int)type forNode:(CCNode*) node prop:(NSString*)prop;
+ (void) setPosition:(CGPoint)pos forNode:(CCNode *)node prop:(NSString *)prop;
+ (CGPoint) positionForNode:(CCNode*)node prop:(NSString*)prop;
+ (int) positionTypeForNode:(CCNode*)node prop:(NSString*)prop;
@end
