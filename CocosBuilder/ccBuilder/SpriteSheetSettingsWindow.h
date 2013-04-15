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
    int  textureFileFormatHTML5;
    IBOutlet NSButton *iosDither;
    IBOutlet NSButton *iosCompress;
    IBOutlet NSButton *androidDither;
}

@property (nonatomic,assign) int textureFileFormat;
@property (nonatomic,assign) BOOL compress;
@property (nonatomic,assign) BOOL dither;
@property (nonatomic,assign) int textureFileFormatAndroid;
@property (nonatomic,assign) BOOL ditherAndroid;
@property (nonatomic,assign) int textureFileFormatHTML5;

- (IBAction)updateIOSSettings:(NSPopUpButton *)sender;
- (IBAction)updateAndroidSettings:(NSPopUpButton *)sender;

@end
