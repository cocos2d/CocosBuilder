//
//  SpriteSheetSettingsWindow.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 12/19/12.
//
//

#import "CCBModalSheetController.h"

@interface SpriteSheetSettingsWindow : CCBModalSheetController
{
    int textureFileFormat;
    BOOL compress;
    BOOL dither;
}

@property (nonatomic,assign) int textureFileFormat;
@property (nonatomic,assign) BOOL compress;
@property (nonatomic,assign) BOOL dither;

@end
