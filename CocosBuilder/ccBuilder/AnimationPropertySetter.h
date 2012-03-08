//
//  AnimationPropertySetter.h
//  CocosBuilder
//
//  Created by Joel Petersen on 3/7/12.
//  Copyright (c) 2012 Zynga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface AnimationPropertySetter : NSObject

+ (void) setAnimationForNode:(CCNode *)node andProperty:(NSString *)prop withName:(NSString *)animation andFile:(NSString *)animationFile;

@end
