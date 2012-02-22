//
//  TexturePropertySetter.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface TexturePropertySetter : NSObject

+ (void) setSpriteFrameForNode:(CCNode*)node andProperty:(NSString*) prop withFile:(NSString*)spriteFile andSheetFile:(NSString*)spriteSheetFile;

+ (void) setTextureForNode:(CCNode*)node andProperty:(NSString*) prop withFile:(NSString*) spriteFile;

+ (void) setFontForNode:(CCNode*)node andProperty:(NSString*) prop withFile:(NSString*) fontFile;

+ (NSString*) fontForNode:(CCNode*)node andProperty:(NSString*) prop;

@end
