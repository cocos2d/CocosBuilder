//
//  CCBReaderInternal.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCBReaderInternal : NSObject

+ (CCNode*) ccObjectFromDictionary:(NSDictionary*) dict;
+ (CCNode*) nodeGraphFromDictionary:(NSDictionary*) dict;

@end
