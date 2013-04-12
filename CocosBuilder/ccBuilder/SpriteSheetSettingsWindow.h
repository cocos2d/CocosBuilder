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
    int  textureFileFormatAndroid;
    BOOL ditherAndroid;
    BOOL use8bitPng;
    BOOL use8bitPngAndroid;
    BOOL use8bitPngHtml5;
    IBOutlet NSButton *iosDither;
    IBOutlet NSButton *iosCompress;
    IBOutlet NSButton *androidDither;
}

@property (nonatomic,assign) int textureFileFormat;
@property (nonatomic,assign) BOOL compress;
@property (nonatomic,assign) BOOL dither;
@property (nonatomic,assign) int textureFileFormatAndroid;
@property (nonatomic,assign) BOOL ditherAndroid;
@property (nonatomic,assign) BOOL use8bitPng;
@property (nonatomic,assign) BOOL use8bitPngAndroid;
@property (nonatomic,assign) BOOL use8bitPngHtml5;

- (IBAction)updateIOSSettings:(NSPopUpButton *)sender;
- (IBAction)updateAndroidSettings:(NSPopUpButton *)sender;

@end
