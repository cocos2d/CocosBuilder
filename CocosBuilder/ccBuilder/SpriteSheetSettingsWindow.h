/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

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
