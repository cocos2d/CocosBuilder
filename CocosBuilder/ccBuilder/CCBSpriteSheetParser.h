//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCBSpriteSheetParser : NSObject {   
}

+ (NSMutableArray*) findSpriteSheetsAtPath:(NSString*)assetsPath;
+ (NSMutableArray*) listFramesInSheet:(NSString*)file assetsPath:(NSString*) assetsPath;
@end
