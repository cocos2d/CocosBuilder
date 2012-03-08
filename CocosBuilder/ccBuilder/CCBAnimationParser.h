//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCBAnimationParser : NSObject {   
}
+ (BOOL) isAnimationFile:(NSString*) file;
//+ (NSMutableArray*) findAnimationsAtPath:(NSString*)assetsPath;
+ (NSMutableArray*) listAnimationsInFile:(NSString*)absoluteFile;
@end
