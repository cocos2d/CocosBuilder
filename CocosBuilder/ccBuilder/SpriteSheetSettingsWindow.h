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
    BOOL ditherHTML5;
    
    IBOutlet NSButton *iosDither;
    IBOutlet NSButton *iosCompress;
    IBOutlet NSButton *androidDither;
    IBOutlet NSButton *HTML5Dither;
    
    BOOL iOSEnabled;
    BOOL androidEnabled;
    BOOL HTML5Enabled;

}

@property (nonatomic,assign) int textureFileFormat;
@property (nonatomic,assign) BOOL compress;
@property (nonatomic,assign) BOOL dither;
@property (nonatomic,assign) int textureFileFormatAndroid;
@property (nonatomic,assign) BOOL ditherAndroid;
@property (nonatomic,assign) int textureFileFormatHTML5;
@property (nonatomic,assign) BOOL ditherHTML5;
@property (nonatomic,assign) BOOL iOSEnabled;
@property (nonatomic,assign) BOOL androidEnabled;
@property (nonatomic,assign) BOOL HTML5Enabled;


- (IBAction)updateIOSSettings:(NSPopUpButton *)sender;
- (IBAction)updateAndroidSettings:(NSPopUpButton *)sender;
- (IBAction)updateHTML5Settings:(NSPopUpButton *)sender;

@end
