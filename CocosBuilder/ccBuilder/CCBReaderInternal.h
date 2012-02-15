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

+ (CCNode*) nodeGraphFromDictionary:(NSDictionary*) dict;
+ (CCNode*) nodeGraphFromDocumentDictionary:(NSDictionary*) dict;

@end
