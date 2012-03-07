//
//  ResourceManagerUtil.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResourceManagerUtil : NSObject

+ (void) populateTexturePopup:(NSPopUpButton*)popup allowSpriteFrames:(BOOL)allowSpriteFrames selectedFile:(NSString*)file selectedSheet:(NSString*) sheetFile target:(id)target;

+ (NSString*) relativePathFromAbsolutePath: (NSString*) path;

+ (void) setTitle:(NSString*)str forPopup:(NSPopUpButton*)popup;

@end
