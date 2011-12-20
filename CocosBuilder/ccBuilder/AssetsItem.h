//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import "cocos2d.h"

@interface AssetsItem : NSObject {
    NSString* spriteFile;
    NSString* spriteSheetFile;
    NSString* title;
    
    NSImage* cachedImage;
    
    NSUInteger version;
}

@property (nonatomic,retain) NSString* spriteFile;
@property (nonatomic,retain) NSString* spriteSheetFile;
@property (nonatomic,retain) NSImage* cachedImage;

- (id) initWithSpriteFile:(NSString*) file;
- (id) initWithSpriteSheet:(NSString *)sheetFile frameName:(NSString*)file;
- (void) setImageVersion:(NSUInteger)v;
- (void) setTitle:(NSString*)t;
@end
