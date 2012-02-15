//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define kCCBUseRegularFile @"Use regular file"

@interface CCBWriterInternal : NSObject {
@private
    
}
+ (NSMutableDictionary*) dictionaryFromCCObject: (CCNode*) node;
@end
