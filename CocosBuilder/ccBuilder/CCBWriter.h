//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define kCCBUseRegularFile @"Use regular file"

@interface CCBWriter : NSObject {
@private
    
}
+ (NSMutableDictionary*) dictionaryFromCCObject: (CCNode*) node extraProps:(NSDictionary*) extraPropsDict;
@end
