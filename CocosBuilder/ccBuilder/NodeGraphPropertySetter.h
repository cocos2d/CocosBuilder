//
//  NodeGraphPropertySetter.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface NodeGraphPropertySetter : NSObject

+ (void) setNodeGraphForNode:(CCNode*)node andProperty:(NSString*) prop withFile:(NSString*) ccbFileName;

@end
